;; skillflow-main.clar
;; Client must deposit sBTC to escrow BEFORE freelancer sees acceptance
;; This prevents fake acceptances and ensures immediate payment security

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant JOB-CREATION-FEE-STX u1000000) ;; 1 STX to create job
(define-constant MIN-STX-BALANCE u1000000) ;; 1 STX minimum balance
(define-constant MIN-SBTC-ESCROW u100000) ;; 0.001 sBTC minimum escrow

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-INVALID-STATE (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-DUPLICATE (err u104))
(define-constant ERR-INVALID-AMOUNT (err u110))
(define-constant ERR-INVALID-INPUT (err u117))
(define-constant ERR-INSUFFICIENT-BALANCE (err u120))

;; Data variables
(define-data-var platform-treasury principal tx-sender)
(define-data-var platform-active bool true)
(define-data-var total-jobs-created uint u0)
(define-data-var total-fees-collected uint u0)

;; Job creation tracking - minimal on-chain data
(define-map job-payments
  (string-ascii 64) ;; external-job-id from off-chain system
  {
    client: principal,
    fee-paid: uint,
    created-at: uint,
    status: uint, ;; 0: posted, 1: accepted-with-escrow, 2: completed, 3: cancelled
    escrow-created: bool,
    escrow-id: (optional uint),
    accepted-freelancer: (optional principal), ;; Set when escrow created
    acceptance-block: (optional uint) ;; When freelancer was accepted
  }
)

;; Freelancer acceptance tracking - only visible after escrow creation
(define-map freelancer-acceptances
  { job-id: (string-ascii 64), freelancer: principal }
  {
    accepted-at: uint,
    escrow-id: uint,
    client: principal,
    sbtc-amount: uint,
    visible-to-freelancer: bool ;; Only true after escrow funding
  }
)

;; Validation functions
(define-private (is-valid-job-id (job-id (string-ascii 64)))
  (> (len job-id) u0)
)

(define-private (is-valid-principal (addr principal))
  (and 
    (not (is-eq addr 'SP000000000000000000002Q6VF78))
    (not (is-eq addr (as-contract tx-sender)))
  )
)

(define-private (is-valid-sbtc-amount (amount uint))
  (and (>= amount MIN-SBTC-ESCROW) (<= amount u100000000000)) ;; 0.001 to 1000 sBTC
)

;; Pay job creation fee - called when job is posted off-chain
(define-public (pay-job-creation-fee (external-job-id (string-ascii 64)))
  (begin
    ;; Input validation
    (asserts! (var-get platform-active) ERR-UNAUTHORIZED)
    (asserts! (is-valid-job-id external-job-id) ERR-INVALID-INPUT)
    (asserts! (is-none (map-get? job-payments external-job-id)) ERR-DUPLICATE)
    
    ;; Check STX balance and charge fee
    (asserts! (>= (stx-get-balance tx-sender) JOB-CREATION-FEE-STX) ERR-INSUFFICIENT-BALANCE)
    (try! (stx-transfer? JOB-CREATION-FEE-STX tx-sender (var-get platform-treasury)))
    
    ;; Record payment
    (map-set job-payments external-job-id
      {
        client: tx-sender,
        fee-paid: JOB-CREATION-FEE-STX,
        created-at: block-height,
        status: u0, ;; posted
        escrow-created: false,
        escrow-id: none,
        accepted-freelancer: none,
        acceptance-block: none
      }
    )
    
    ;; Update stats
    (var-set total-jobs-created (+ (var-get total-jobs-created) u1))
    (var-set total-fees-collected (+ (var-get total-fees-collected) JOB-CREATION-FEE-STX))
    
    (print {
      type: "job-creation-fee-paid",
      external-job-id: external-job-id,
      client: tx-sender,
      fee-paid: JOB-CREATION-FEE-STX,
      status: "posted-awaiting-applications"
    })
    
    (ok true)
  )
)

;; Accept freelancer and create escrow in one transaction
;; Client must deposit sBTC to accept freelancer
(define-public (accept-freelancer-with-escrow
  (external-job-id (string-ascii 64))
  (freelancer principal)
  (sbtc-amount uint)
)
  (let 
    (
      (job-payment (unwrap! (map-get? job-payments external-job-id) ERR-NOT-FOUND))
    )
    ;; Input validation
    (asserts! (is-valid-job-id external-job-id) ERR-INVALID-INPUT)
    (asserts! (is-valid-principal freelancer) ERR-INVALID-INPUT)
    (asserts! (is-valid-sbtc-amount sbtc-amount) ERR-INVALID-AMOUNT)
    
    ;; Authorization - only job creator can accept freelancer
    (asserts! (is-eq tx-sender (get client job-payment)) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get status job-payment) u0) ERR-INVALID-STATE) ;; Must be posted
    (asserts! (not (get escrow-created job-payment)) ERR-DUPLICATE)
    
    ;; Create escrow through escrow contract (this locks the sBTC)
    (match (contract-call? .escrow create-escrow 
      external-job-id 
      tx-sender 
      freelancer 
      sbtc-amount)
      
      escrow-id
      (begin
        ;; Update job payment record - mark as accepted with escrow
        (map-set job-payments external-job-id
          (merge job-payment {
            status: u1, ;; accepted-with-escrow
            escrow-created: true,
            escrow-id: (some escrow-id),
            accepted-freelancer: (some freelancer),
            acceptance-block: (some block-height)
          })
        )
        
        ;; Create freelancer acceptance record - Visible to freelancer
        (map-set freelancer-acceptances 
          { job-id: external-job-id, freelancer: freelancer }
          {
            accepted-at: block-height,
            escrow-id: escrow-id,
            client: tx-sender,
            sbtc-amount: sbtc-amount,
            visible-to-freelancer: true ;; Key: only true after escrow funded
          }
        )
        
        (print {
          type: "freelancer-accepted-with-escrow",
          external-job-id: external-job-id,
          client: tx-sender,
          freelancer: freelancer,
          escrow-id: escrow-id,
          sbtc-amount: sbtc-amount,
          status: "funds-locked-freelancer-can-start-work",
          freelancer-notification: "You have been accepted! Funds are secured in escrow."
        })
        
        (ok escrow-id)
      )
      error-data (err error-data)
    )
  )
)

;; Check if freelancer has been accepted for a specific job
;; This is how freelancers know they've been hired
(define-read-only (check-freelancer-acceptance 
  (external-job-id (string-ascii 64))
  (freelancer principal)
)
  (let 
    (
      (acceptance-key { job-id: external-job-id, freelancer: freelancer })
      (acceptance-data (map-get? freelancer-acceptances acceptance-key))
    )
    (match acceptance-data
      acceptance
      (if (get visible-to-freelancer acceptance)
        (ok {
          accepted: true,
          acceptance-details: (some acceptance),
          message: "Congratulations! You have been hired. Funds are secured in escrow.",
          can-start-work: true
        })
        (ok {
          accepted: false,
          acceptance-details: none,
          message: "No acceptance found or escrow not yet funded",
          can-start-work: false
        })
      )
      (ok {
        accepted: false,
        acceptance-details: none,
        message: "You have not been accepted for this job",
        can-start-work: false
      })
    )
  )
)

;; Get all job acceptances for a freelancer (their active jobs)
(define-read-only (get-freelancer-active-jobs (freelancer principal))
  {
    instructions: "Query freelancer-acceptances map with freelancer address",
    example-key: { job-id: "job-12345", freelancer: freelancer },
    note: "Off-chain service should index all acceptance events for each freelancer"
  }
)

;; Freelancer marks job as completed (Step 1 of 2)
(define-public (freelancer-mark-completed (external-job-id (string-ascii 64)))
  (let 
    (
      (job-payment (unwrap! (map-get? job-payments external-job-id) ERR-NOT-FOUND))
      (escrow-id (unwrap! (get escrow-id job-payment) ERR-NOT-FOUND))
      (acceptance-key { job-id: external-job-id, freelancer: tx-sender })
      (acceptance-data (unwrap! (map-get? freelancer-acceptances acceptance-key) ERR-UNAUTHORIZED))
    )
    ;; Authorization - only accepted freelancer can mark complete
    (asserts! (get visible-to-freelancer acceptance-data) ERR-UNAUTHORIZED)
    (asserts! (is-eq (get escrow-id acceptance-data) escrow-id) ERR-INVALID-STATE)
    (asserts! (get escrow-created job-payment) ERR-INVALID-STATE)
    
    ;; Call escrow contract to mark as completed
    (try! (contract-call? .escrow mark-job-completed escrow-id))
    
    (print {
      type: "freelancer-marked-job-completed",
      external-job-id: external-job-id,
      escrow-id: escrow-id,
      freelancer: tx-sender,
      awaiting-client-confirmation: true
    })
    
    (ok true)
  )
)

;; Client confirms job completion (Step 2 of 2) - triggers automatic payment
(define-public (client-confirm-completion (external-job-id (string-ascii 64)))
  (let 
    (
      (job-payment (unwrap! (map-get? job-payments external-job-id) ERR-NOT-FOUND))
      (escrow-id (unwrap! (get escrow-id job-payment) ERR-NOT-FOUND))
    )
    ;; Authorization - only job creator can confirm
    (asserts! (is-eq tx-sender (get client job-payment)) ERR-UNAUTHORIZED)
    (asserts! (get escrow-created job-payment) ERR-INVALID-STATE)
    
    ;; Confirm completion through escrow contract (triggers automatic payment)
    (try! (contract-call? .escrow confirm-job-completion escrow-id))
    
    ;; Update job status to completed
    (map-set job-payments external-job-id
      (merge job-payment { status: u2 })) ;; completed
    
    (print {
      type: "client-confirmed-completion-payment-released",
      external-job-id: external-job-id,
      escrow-id: escrow-id,
      client: tx-sender,
      payment-released: true,
      job-status: "completed"
    })
    
    (ok true)
  )
)

;; Initiate dispute - proxy to escrow contract
(define-public (initiate-job-dispute (external-job-id (string-ascii 64)))
  (let 
    (
      (job-payment (unwrap! (map-get? job-payments external-job-id) ERR-NOT-FOUND))
      (escrow-id (unwrap! (get escrow-id job-payment) ERR-NOT-FOUND))
    )
    ;; Authorization checked by escrow contract
    (asserts! (get escrow-created job-payment) ERR-INVALID-STATE)
    
    ;; Initiate dispute through escrow contract
    (try! (contract-call? .escrow initiate-dispute escrow-id))
    
    (print {
      type: "job-dispute-initiated",
      external-job-id: external-job-id,
      escrow-id: escrow-id,
      initiated-by: tx-sender
    })
    
    (ok true)
  )
)

;; Job status function
(define-read-only (get-job-complete-status (external-job-id (string-ascii 64)))
  (let ((job-payment (map-get? job-payments external-job-id)))
    (match job-payment
      job-data
      (let ((escrow-id (get escrow-id job-data)))
        (match escrow-id
          esc-id
          ;; Get escrow status from escrow contract
          (let ((escrow-result (contract-call? .escrow get-escrow-with-status esc-id)))
            (match escrow-result
              escrow-status
              (ok {
                job-payment: job-data,
                escrow-status: (some escrow-status),
                has-escrow: true,
                freelancer-hired: (is-some (get accepted-freelancer job-data)),
                job-stage: (if (is-eq (get status job-data) u0) 
                  "posted-accepting-applications"
                  (if (is-eq (get status job-data) u1)
                    "freelancer-hired-work-in-progress"
                    (if (is-eq (get status job-data) u2)
                      "completed"
                      "cancelled")))
              })
              escrow-error
              (ok {
                job-payment: job-data,
                escrow-status: none,
                has-escrow: false,
                freelancer-hired: false,
                job-stage: "error-fetching-escrow-status"
              })
            )
          )
          (ok {
            job-payment: job-data,
            escrow-status: none,
            has-escrow: false,
            freelancer-hired: false,
            job-stage: "posted-no-escrow"
          })
        )
      )
      ERR-NOT-FOUND
    )
  )
)

;; Platform statistics
(define-read-only (get-platform-stats)
  {
    total-jobs-created: (var-get total-jobs-created),
    total-fees-collected-stx: (var-get total-fees-collected),
    active: (var-get platform-active),
    job-creation-fee: JOB-CREATION-FEE-STX,
    min-stx-balance: MIN-STX-BALANCE,
    min-sbtc-escrow: MIN-SBTC-ESCROW,
    payment-currency: "sBTC",
    platform-currency: "STX",
    completion-process: "two-step-confirmation",
    key-feature: "Escrow-first acceptance - freelancers only see acceptance after funds locked",
    workflow: "Post job > Accept freelancer with escrow > Freelancer works > Two-step completion",
    security-improvement: "Prevents fake acceptances and ensures immediate payment security"
  }
)

;; Admin functions
(define-public (set-treasury (treasury principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (is-valid-principal treasury) ERR-INVALID-INPUT)
    (var-set platform-treasury treasury)
    (ok treasury)
  )
)

;; Get contract info
(define-read-only (get-contract-info)
  {
    treasury: (var-get platform-treasury),
    platform-active: (var-get platform-active),
    job-creation-fee: JOB-CREATION-FEE-STX,
    min-balances: {
      stx: MIN-STX-BALANCE,
      sbtc: MIN-SBTC-ESCROW
    },
    total-stats: {
      jobs-created: (var-get total-jobs-created),
      fees-collected: (var-get total-fees-collected)
    },
    architecture: "Escrow-first acceptance model",
    key-change: "Client must deposit sBTC before freelancer sees acceptance",
    completion-process: {
      type: "two-step-confirmation",
      step1: "Freelancer marks job completed",
      step2: "Client confirms completion", 
      step3: "Payment automatically released"
    },
    workflow: {
      step1: "Client posts job (pays STX fee)",
      step2: "Freelancers apply off-chain",
      step3: "Client accepts freelancer + deposits sBTC in one transaction",
      step4: "Freelancer sees acceptance notification with secured funds",
      step5: "Work period with funds safely escrowed",
      step6: "Two-step completion process"
    },
    security-benefits: {
      no-fake-acceptances: "Freelancer only sees acceptance when funds are locked",
      immediate-security: "Payment guaranteed from moment of acceptance",
      client-commitment: "Client must commit funds to hire freelancer"
    }
  }
)