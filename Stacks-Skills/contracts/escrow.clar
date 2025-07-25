;; escrow.clar

;; SkillFlow Escrow System
;; This version supports acceptance workflow with two-step completion
;; Escrow creation triggers freelancer acceptance visibility

;; Import SIP-010 trait
(use-trait sip010-trait .sip010-trait.sip010-trait)

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant PLATFORM-FEE-RATE u250) ;; 2.5%
(define-constant BASIS-POINTS u10000)
(define-constant DISPUTE-WINDOW-BLOCKS u2880) ;; 20 days to dispute

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-INVALID-STATE (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-DUPLICATE (err u104))
(define-constant ERR-INVALID-AMOUNT (err u110))
(define-constant ERR-INVALID-INPUT (err u117))
(define-constant ERR-EXPIRED (err u106))

;; Get sBTC contract address
;; For local checking, use mock. For deployment, use real address
(define-constant SBTC-CONTRACT 
  ;; LOCAL TESTING (comment this for deployment):
  .sbtc-moc
  ;; TESTNET/MAINNET (uncomment this for deployment):
  ;; SM3VDXK3WZZSA84XXFKAFAF15NNZX32CTSG82JFQ4.sbtc-token
)

;; Data variables
(define-data-var next-escrow-id uint u1)
(define-data-var platform-treasury principal tx-sender)

;; Escrow data map with acceptance tracking
(define-map escrows
  uint ;; escrow-id
  {
    external-job-id: (string-ascii 64),
    client: principal,
    freelancer: principal,
    sbtc-amount: uint,
    platform-fee: uint,
    status: uint, ;; 0: active, 1: completed, 2: disputed, 3: cancelled
    created-at: uint,
    dispute-deadline: uint,
    freelancer-completed: bool,
    freelancer-completed-at: (optional uint),
    client-confirmed: bool,
    client-confirmed-at: (optional uint),
    released: bool,
    ;; Acceptance tracking
    represents-job-acceptance: bool, ;; True when this escrow represents freelancer hiring
    acceptance-notified: bool ;; True when freelancer has been notified
  }
)

;; Dispute tracking
(define-map disputes
  uint ;; escrow-id
  {
    initiated-by: principal,
    created-at: uint,
    resolved: bool
  }
)

;; Validation functions
(define-private (is-valid-sbtc-amount (amount uint))
  (and (>= amount u100000) (<= amount u100000000000))
)

(define-private (is-valid-principal (addr principal))
  (and 
    (not (is-eq addr 'SP000000000000000000002Q6VF78))
    (not (is-eq addr (as-contract tx-sender)))
  )
)

(define-private (is-valid-job-id (job-id (string-ascii 64)))
  (> (len job-id) u0)
)

(define-private (is-valid-escrow-id (escrow-id uint))
  (and (> escrow-id u0) (< escrow-id (var-get next-escrow-id)))
)

;; Create escrow - represents freelancer acceptance
(define-public (create-escrow 
  (external-job-id (string-ascii 64))
  (client principal)
  (freelancer principal) 
  (sbtc-amount uint)
)
  (let 
    (
      (escrow-id (var-get next-escrow-id))
      (platform-fee (/ (* sbtc-amount PLATFORM-FEE-RATE) BASIS-POINTS))
    )
    ;; Input validation
    (asserts! (is-valid-job-id external-job-id) ERR-INVALID-INPUT)
    (asserts! (is-valid-sbtc-amount sbtc-amount) ERR-INVALID-AMOUNT)
    (asserts! (is-valid-principal client) ERR-INVALID-INPUT)
    (asserts! (is-valid-principal freelancer) ERR-INVALID-INPUT)
    (asserts! (not (is-eq client freelancer)) ERR-INVALID-INPUT)
    
    ;; Verify client has sufficient sBTC balance
    (let ((client-balance (unwrap! (contract-call? SBTC-CONTRACT get-balance client) ERR-INSUFFICIENT-FUNDS)))
      (asserts! (>= client-balance sbtc-amount) ERR-INSUFFICIENT-FUNDS)
    )
    
    ;; Transfer sBTC from client to escrow contract
    (try! (contract-call? 
      SBTC-CONTRACT 
      transfer 
      sbtc-amount 
      client 
      (as-contract tx-sender) 
      none))
    
    ;; Create escrow record with acceptance tracking
    (map-set escrows escrow-id
      {
        external-job-id: external-job-id,
        client: client,
        freelancer: freelancer,
        sbtc-amount: sbtc-amount,
        platform-fee: platform-fee,
        status: u0, ;; active
        created-at: block-height,
        dispute-deadline: (+ block-height DISPUTE-WINDOW-BLOCKS),
        freelancer-completed: false,
        freelancer-completed-at: none,
        client-confirmed: false,
        client-confirmed-at: none,
        released: false,
        ;; This escrow represents job acceptance
        represents-job-acceptance: true,
        acceptance-notified: true ;; Freelancer can now see they're hired
      }
    )
    
    (var-set next-escrow-id (+ escrow-id u1))
    
    (print {
      type: "escrow-created-freelancer-accepted",
      escrow-id: escrow-id,
      external-job-id: external-job-id,
      client: client,
      freelancer: freelancer,
      sbtc-amount: sbtc-amount,
      platform-fee: platform-fee,
      completion-process: "two-step-confirmation",
      freelancer-status: "HIRED - Funds secured in escrow",
      message-to-freelancer: "Congratulations! You have been hired and payment is guaranteed."
    })
    
    (ok escrow-id)
  )
)

;; Mark job as completed by freelancer (Step 1 of 2)
(define-public (mark-job-completed (escrow-id uint))
  (let 
    (
      (escrow (unwrap! (map-get? escrows escrow-id) ERR-NOT-FOUND))
    )
    ;; Authorization - only freelancer can mark completed
    (asserts! (is-eq tx-sender (get freelancer escrow)) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get status escrow) u0) ERR-INVALID-STATE) ;; Must be active
    (asserts! (not (get freelancer-completed escrow)) ERR-INVALID-STATE)
    (asserts! (not (get released escrow)) ERR-INVALID-STATE)
    
    ;; Update escrow with freelancer completion
    (map-set escrows escrow-id
      (merge escrow {
        freelancer-completed: true,
        freelancer-completed-at: (some block-height)
      })
    )
    
    (print {
      type: "freelancer-marked-job-completed",
      escrow-id: escrow-id,
      external-job-id: (get external-job-id escrow),
      freelancer: tx-sender,
      awaiting-client-confirmation: true,
      message: "Job marked as completed. Awaiting client confirmation for payment release."
    })
    
    (ok true)
  )
)

;; Confirm job completion by client (Step 2 of 2) - triggers payment
(define-public (confirm-job-completion (escrow-id uint))
  (let 
    (
      (escrow (unwrap! (map-get? escrows escrow-id) ERR-NOT-FOUND))
    )
    ;; Authorization - only client can confirm completion
    (asserts! (is-eq tx-sender (get client escrow)) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get status escrow) u0) ERR-INVALID-STATE) ;; Must be active
    (asserts! (get freelancer-completed escrow) ERR-INVALID-STATE) ;; Freelancer must mark first
    (asserts! (not (get client-confirmed escrow)) ERR-INVALID-STATE)
    (asserts! (not (get released escrow)) ERR-INVALID-STATE)
    
    ;; Calculate amounts
    (let 
      (
        (total-amount (get sbtc-amount escrow))
        (platform-fee (get platform-fee escrow))
        (freelancer-payment (- total-amount platform-fee))
      )
      
      ;; Transfer payment to freelancer
      (try! (as-contract (contract-call? 
        SBTC-CONTRACT 
        transfer 
        freelancer-payment 
        tx-sender 
        (get freelancer escrow) 
        none)))
      
      ;; Transfer platform fee to treasury
      (try! (as-contract (contract-call? 
        SBTC-CONTRACT 
        transfer 
        platform-fee 
        tx-sender 
        (var-get platform-treasury) 
        none)))
      
      ;; Update escrow status
      (map-set escrows escrow-id
        (merge escrow {
          status: u1, ;; completed
          client-confirmed: true,
          client-confirmed-at: (some block-height),
          released: true
        })
      )
      
      (print {
        type: "job-completion-confirmed-payment-released",
        escrow-id: escrow-id,
        external-job-id: (get external-job-id escrow),
        client: tx-sender,
        freelancer: (get freelancer escrow),
        freelancer-payment: freelancer-payment,
        platform-fee: platform-fee,
        total-amount: total-amount,
        payment-released: true
      })
      
      (ok true)
    )
  )
)

;; Initiate dispute
(define-public (initiate-dispute (escrow-id uint))
  (let 
    (
      (escrow (unwrap! (map-get? escrows escrow-id) ERR-NOT-FOUND))
    )
    ;; Authorization - either client or freelancer can initiate
    (asserts! (or 
      (is-eq tx-sender (get client escrow))
      (is-eq tx-sender (get freelancer escrow))) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get status escrow) u0) ERR-INVALID-STATE) ;; Must be active
    (asserts! (< block-height (get dispute-deadline escrow)) ERR-EXPIRED)
    (asserts! (is-none (map-get? disputes escrow-id)) ERR-DUPLICATE)
    
    ;; Create dispute record
    (map-set disputes escrow-id
      {
        initiated-by: tx-sender,
        created-at: block-height,
        resolved: false
      }
    )
    
    ;; Update escrow status
    (map-set escrows escrow-id
      (merge escrow { status: u2 })) ;; disputed
    
    (print {
      type: "dispute-initiated",
      escrow-id: escrow-id,
      external-job-id: (get external-job-id escrow),
      initiated-by: tx-sender,
      dispute-deadline: (get dispute-deadline escrow)
    })
    
    (ok true)
  )
)

;; Resolve dispute (admin only)
(define-public (resolve-dispute 
  (escrow-id uint)
  (refund-to-client-percentage uint) ;; 0-100
)
  (let 
    (
      (escrow (unwrap! (map-get? escrows escrow-id) ERR-NOT-FOUND))
      (dispute (unwrap! (map-get? disputes escrow-id) ERR-NOT-FOUND))
      (total-amount (get sbtc-amount escrow))
      (platform-fee (get platform-fee escrow))
      (available-amount (- total-amount platform-fee))
      (refund-amount (/ (* available-amount refund-to-client-percentage) u100))
      (freelancer-amount (- available-amount refund-amount))
    )
    ;; Input validation
    (asserts! (is-valid-escrow-id escrow-id) ERR-INVALID-INPUT)
    (asserts! (<= refund-to-client-percentage u100) ERR-INVALID-INPUT)
    
    ;; Authorization check
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get status escrow) u2) ERR-INVALID-STATE)
    (asserts! (not (get resolved dispute)) ERR-DUPLICATE)
    
    ;; Transfer refund to client if any
    (if (> refund-amount u0)
      (try! (as-contract (contract-call? 
        SBTC-CONTRACT 
        transfer 
        refund-amount
        tx-sender 
        (get client escrow) 
        none)))
      true)
    
    ;; Transfer remaining to freelancer if any
    (if (> freelancer-amount u0)
      (try! (as-contract (contract-call? 
        SBTC-CONTRACT 
        transfer 
        freelancer-amount
        tx-sender 
        (get freelancer escrow) 
        none)))
      true)
    
    ;; Transfer platform fee
    (try! (as-contract (contract-call? 
      SBTC-CONTRACT 
      transfer 
      platform-fee
      tx-sender 
      (var-get platform-treasury) 
      none)))
    
    ;; Update records
    (map-set escrows escrow-id
      (merge escrow {
        status: u1, ;; completed via dispute resolution
        released: true
      })
    )
    
    (map-set disputes escrow-id
      (merge dispute { resolved: true })
    )
    
    (print {
      type: "dispute-resolved",
      escrow-id: escrow-id,
      external-job-id: (get external-job-id escrow),
      refund-to-client: refund-amount,
      payment-to-freelancer: freelancer-amount,
      platform-fee: platform-fee
    })
    
    (ok true)
  )
)

;; Cancel escrow (admin only)
(define-public (cancel-escrow (escrow-id uint))
  (let ((escrow (unwrap! (map-get? escrows escrow-id) ERR-NOT-FOUND)))
    (asserts! (is-valid-escrow-id escrow-id) ERR-INVALID-INPUT)
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get status escrow) u0) ERR-INVALID-STATE)
    (asserts! (not (get released escrow)) ERR-DUPLICATE)
    
    ;; Refund amount minus platform fee
    (let ((refund-amount (- (get sbtc-amount escrow) (get platform-fee escrow))))
      (try! (as-contract (contract-call? 
        SBTC-CONTRACT 
        transfer 
        refund-amount
        tx-sender 
        (get client escrow) 
        none)))
      
      ;; Platform keeps fee for processing
      (try! (as-contract (contract-call? 
        SBTC-CONTRACT 
        transfer 
        (get platform-fee escrow)
        tx-sender 
        (var-get platform-treasury) 
        none)))
    )
    
    ;; Update escrow status
    (map-set escrows escrow-id
      (merge escrow {
        status: u3, ;; cancelled
        released: true
      })
    )
    
    (print {
      type: "escrow-cancelled",
      escrow-id: escrow-id,
      external-job-id: (get external-job-id escrow),
      refunded-amount: (- (get sbtc-amount escrow) (get platform-fee escrow))
    })
    
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-escrow-with-status (escrow-id uint))
  (let ((escrow (map-get? escrows escrow-id)))
    (match escrow
      escrow-data
      (ok {
        escrow: escrow-data,
        dispute: (map-get? disputes escrow-id),
        can-dispute: (< block-height (get dispute-deadline escrow-data)),
        blocks-until-dispute-deadline: (if (>= block-height (get dispute-deadline escrow-data))
          u0
          (- (get dispute-deadline escrow-data) block-height)),
        completion-status: {
          freelancer-completed: (get freelancer-completed escrow-data),
          client-confirmed: (get client-confirmed escrow-data),
          can-freelancer-complete: (and 
            (is-eq (get status escrow-data) u0)
            (not (get freelancer-completed escrow-data))
            (not (get released escrow-data))),
          can-client-confirm: (and 
            (is-eq (get status escrow-data) u0)
            (get freelancer-completed escrow-data)
            (not (get client-confirmed escrow-data))
            (not (get released escrow-data))),
          payment-released: (get released escrow-data)
        }
      })
      ERR-NOT-FOUND
    )
  )
)

;; Read-only function with acceptance status
(define-read-only (get-escrow-with-acceptance-status (escrow-id uint))
  (let ((escrow (map-get? escrows escrow-id)))
    (match escrow
      escrow-data
      (ok {
        escrow: escrow-data,
        dispute: (map-get? disputes escrow-id),
        can-dispute: (< block-height (get dispute-deadline escrow-data)),
        blocks-until-dispute-deadline: (if (>= block-height (get dispute-deadline escrow-data))
          u0
          (- (get dispute-deadline escrow-data) block-height)),
        completion-status: {
          freelancer-completed: (get freelancer-completed escrow-data),
          client-confirmed: (get client-confirmed escrow-data),
          can-freelancer-complete: (and 
            (is-eq (get status escrow-data) u0)
            (not (get freelancer-completed escrow-data))
            (not (get released escrow-data))),
          can-client-confirm: (and 
            (is-eq (get status escrow-data) u0)
            (get freelancer-completed escrow-data)
            (not (get client-confirmed escrow-data))
            (not (get released escrow-data))),
          payment-released: (get released escrow-data)
        },
        ;; Acceptance information
        acceptance-info: {
          represents-job-acceptance: (get represents-job-acceptance escrow-data),
          freelancer-notified: (get acceptance-notified escrow-data),
          freelancer-hired: (get represents-job-acceptance escrow-data),
          funds-secured: true,
          message: "Freelancer has been hired and funds are secured"
        }
      })
      ERR-NOT-FOUND
    )
  )
)

;; Basic read-only functions
(define-read-only (get-escrow-info (escrow-id uint))
  (map-get? escrows escrow-id)
)

(define-read-only (get-dispute-info (escrow-id uint))
  (map-get? disputes escrow-id)
)

(define-read-only (is-escrow-participant (escrow-id uint) (user principal))
  (let ((escrow (map-get? escrows escrow-id)))
    (match escrow
      escrow-data
      (or 
        (is-eq user (get client escrow-data))
        (is-eq user (get freelancer escrow-data)))
      false
    )
  )
)

;; Get platform statistics
(define-read-only (get-escrow-stats)
  {
    next-escrow-id: (var-get next-escrow-id),
    total-escrows-created: (- (var-get next-escrow-id) u1),
    platform-treasury: (var-get platform-treasury),
    platform-fee-rate: PLATFORM-FEE-RATE,
    dispute-window-blocks: DISPUTE-WINDOW-BLOCKS,
    sbtc-contract: SBTC-CONTRACT
  }
)

;; Admin function to set treasury with proper validation
(define-public (set-escrow-treasury (treasury principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (is-valid-principal treasury) ERR-INVALID-INPUT)
    (var-set platform-treasury treasury)
    (ok treasury)
  )
)