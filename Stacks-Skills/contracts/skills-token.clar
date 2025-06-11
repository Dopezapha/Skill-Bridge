;; skills-token.clar
;; SkillFlow Skills Token Contract
;; Users buy SKILL tokens with STX at 0.1 STX per token for job applications

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant TOKEN-NAME "SkillFlow Application Token")
(define-constant TOKEN-SYMBOL "SKILL")
(define-constant TOKEN-DECIMALS u6) ;; Same as STX

;; Token price: 0.1 STX = 100,000 microSTX per SKILL token
(define-constant SKILL-TOKEN-PRICE-STX u100000) ;; 0.1 STX in microSTX
(define-constant APPLICATION-COST-SKILL u1000000) ;; 1 SKILL token (1,000,000 micro-SKILL)

;; Maximum supply: 10 million SKILL tokens
(define-constant MAX-SUPPLY u10000000000000) ;; 10M tokens with 6 decimals

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOT-TOKEN-OWNER (err u101))
(define-constant ERR-INSUFFICIENT-BALANCE (err u102))
(define-constant ERR-INSUFFICIENT-STX (err u103))
(define-constant ERR-MAX-SUPPLY-REACHED (err u104))
(define-constant ERR-INVALID-AMOUNT (err u105))
(define-constant ERR-TRANSFER-FAILED (err u106))
(define-constant ERR-INVALID-PRINCIPAL (err u107))
(define-constant ERR-TOKEN-PURCHASE-DISABLED (err u108))
(define-constant ERR-INVALID-PRICE (err u109))

;; Data variables
(define-data-var token-total-supply uint u0)
(define-data-var purchase-enabled bool true)
(define-data-var platform-treasury principal tx-sender)
(define-data-var authorized-spender principal tx-sender) ;; SkillFlow main contract

;; Token balances
(define-map token-balances principal uint)

;; Purchase tracking
(define-map purchase-history 
  principal 
  {
    total-purchased: uint,
    total-spent-stx: uint,
    last-purchase-block: uint,
    purchase-count: uint
  }
)

;; Validation functions
(define-private (is-valid-amount (amount uint))
  (and (> amount u0) (<= amount u1000000000000)) ;; Max 1M SKILL tokens per transaction
)

(define-private (is-valid-principal (addr principal))
  (not (is-eq addr 'ST000000000000000000002AMW42H)) ;; Not burn address
)

;; Core token functions
(define-public (transfer (amount uint) (from principal) (to principal))
  (begin
    (asserts! (or (is-eq tx-sender from) (is-eq contract-caller from)) ERR-UNAUTHORIZED)
    (asserts! (is-valid-principal to) ERR-INVALID-PRINCIPAL)
    (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
    (asserts! (<= amount (unwrap-panic (get-balance from))) ERR-INSUFFICIENT-BALANCE)
    
    ;; Update balances
    (map-set token-balances from (- (unwrap-panic (get-balance from)) amount))
    (map-set token-balances to (+ (unwrap-panic (get-balance to)) amount))
    
    (print {
      type: "skill-token-transfer",
      from: from,
      to: to,
      amount: amount,
      block: block-height
    })
    
    (ok true)
  )
)

(define-read-only (get-name)
  TOKEN-NAME
)

(define-read-only (get-symbol)
  TOKEN-SYMBOL
)

(define-read-only (get-decimals)
  TOKEN-DECIMALS
)

;; Returns response type for trait compatibility
(define-read-only (get-balance (who principal))
  (ok (default-to u0 (map-get? token-balances who)))
)

;; Helper function for internal use (returns uint directly)
(define-private (get-balance-uint (who principal))
  (default-to u0 (map-get? token-balances who))
)

(define-read-only (get-total-supply)
  (var-get token-total-supply)
)

;; SKILL Token Purchase with STX
(define-public (buy-skill-tokens (skill-amount uint))
  (let 
    (
      (stx-cost (* skill-amount SKILL-TOKEN-PRICE-STX))
      (buyer-stx-balance (stx-get-balance tx-sender))
      (current-supply (var-get token-total-supply))
      (new-supply (+ current-supply skill-amount))
    )
    ;; Input validation
    (asserts! (var-get purchase-enabled) ERR-TOKEN-PURCHASE-DISABLED)
    (asserts! (is-valid-amount skill-amount) ERR-INVALID-AMOUNT)
    (asserts! (>= buyer-stx-balance stx-cost) ERR-INSUFFICIENT-STX)
    (asserts! (<= new-supply MAX-SUPPLY) ERR-MAX-SUPPLY-REACHED)
    
    ;; Transfer STX from buyer to treasury
    (try! (stx-transfer? stx-cost tx-sender (var-get platform-treasury)))
    
    ;; Mint SKILL tokens to buyer
    (map-set token-balances tx-sender 
      (+ (get-balance-uint tx-sender) skill-amount))
    (var-set token-total-supply new-supply)
    
    ;; Track purchase history
    (let ((current-history (default-to 
      { total-purchased: u0, total-spent-stx: u0, last-purchase-block: u0, purchase-count: u0 }
      (map-get? purchase-history tx-sender))))
      
      (map-set purchase-history tx-sender {
        total-purchased: (+ (get total-purchased current-history) skill-amount),
        total-spent-stx: (+ (get total-spent-stx current-history) stx-cost),
        last-purchase-block: block-height,
        purchase-count: (+ (get purchase-count current-history) u1)
      })
    )
    
    (print {
      type: "skill-tokens-purchased",
      buyer: tx-sender,
      skill-amount: skill-amount,
      stx-cost: stx-cost,
      new-balance: (get-balance-uint tx-sender),
      block: block-height
    })
    
    (ok skill-amount)
  )
)

;; Spend SKILL tokens for job applications (called by main contract)
(define-public (spend-for-application (applicant principal) (amount uint))
  (begin
    ;; Only authorized spender (main contract) can call this
    (asserts! (is-eq tx-sender (var-get authorized-spender)) ERR-UNAUTHORIZED)
    (asserts! (is-valid-principal applicant) ERR-INVALID-PRINCIPAL)
    (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
    (asserts! (>= (get-balance-uint applicant) amount) ERR-INSUFFICIENT-BALANCE)
    
    ;; Burn the tokens (remove from circulation)
    (map-set token-balances applicant 
      (- (get-balance-uint applicant) amount))
    
    ;; Update total supply
    (var-set token-total-supply (- (var-get token-total-supply) amount))
    
    (print {
      type: "skill-tokens-spent-application",
      applicant: applicant,
      amount: amount,
      remaining-balance: (get-balance-uint applicant),
      block: block-height
    })
    
    (ok true)
  )
)

;; Returns response type for trait compatibility
(define-read-only (can-afford-application (user principal))
  (ok (>= (get-balance-uint user) APPLICATION-COST-SKILL))
)

;; Get application cost in SKILL tokens
(define-read-only (get-application-cost)
  APPLICATION-COST-SKILL
)

;; Get SKILL token price in STX
(define-read-only (get-skill-token-price)
  SKILL-TOKEN-PRICE-STX
)

;; Calculate STX cost for SKILL tokens
(define-read-only (calculate-stx-cost (skill-amount uint))
  (* skill-amount SKILL-TOKEN-PRICE-STX)
)

;; Calculate how many SKILL tokens user can buy with STX
(define-read-only (calculate-skill-tokens-from-stx (stx-amount uint))
  (/ stx-amount SKILL-TOKEN-PRICE-STX)
)

;; Get user's purchase history
(define-read-only (get-purchase-history (user principal))
  (map-get? purchase-history user)
)

;; Get user's token info
(define-read-only (get-user-token-info (user principal))
  {
    skill-balance: (get-balance-uint user),
    can-apply: (unwrap-panic (can-afford-application user)),
    applications-affordable: (/ (get-balance-uint user) APPLICATION-COST-SKILL),
    purchase-history: (map-get? purchase-history user),
    stx-balance: (stx-get-balance user)
  }
)

;; Platform statistics
(define-read-only (get-token-stats)
  {
    total-supply: (var-get token-total-supply),
    max-supply: MAX-SUPPLY,
    supply-percentage: (/ (* (var-get token-total-supply) u100) MAX-SUPPLY),
    token-price-stx: SKILL-TOKEN-PRICE-STX,
    application-cost: APPLICATION-COST-SKILL,
    purchase-enabled: (var-get purchase-enabled),
    treasury: (var-get platform-treasury)
  }
)

;; Estimate costs
(define-read-only (estimate-application-costs (num-applications uint))
  (let ((total-skill-needed (* num-applications APPLICATION-COST-SKILL)))
    {
      applications: num-applications,
      skill-tokens-needed: total-skill-needed,
      stx-cost-if-buying: (calculate-stx-cost total-skill-needed),
      cost-per-application-stx: SKILL-TOKEN-PRICE-STX,
      much-cheaper-than-competitors: "Yes! Only 0.1 STX vs 15-20% fees elsewhere"
    }
  )
)

;; Admin functions
(define-public (set-authorized-spender (new-spender principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (is-valid-principal new-spender) ERR-INVALID-PRINCIPAL)
    (var-set authorized-spender new-spender)
    (ok new-spender)
  )
)

(define-public (set-platform-treasury (new-treasury principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (is-valid-principal new-treasury) ERR-INVALID-PRINCIPAL)
    (var-set platform-treasury new-treasury)
    (ok new-treasury)
  )
)

(define-public (toggle-purchase-enabled)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (var-set purchase-enabled (not (var-get purchase-enabled)))
    (ok (var-get purchase-enabled))
  )
)

;; Emergency functions
(define-public (emergency-mint (recipient principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (is-valid-principal recipient) ERR-INVALID-PRINCIPAL)
    (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
    
    (map-set token-balances recipient 
      (+ (get-balance-uint recipient) amount))
    (var-set token-total-supply (+ (var-get token-total-supply) amount))
    
    (ok amount)
  )
)

;; Get contract info
(define-read-only (get-contract-info)
  {
    name: TOKEN-NAME,
    symbol: TOKEN-SYMBOL,
    decimals: TOKEN-DECIMALS,
    total-supply: (var-get token-total-supply),
    max-supply: MAX-SUPPLY,
    price-per-token: SKILL-TOKEN-PRICE-STX,
    application-cost: APPLICATION-COST-SKILL,
    owner: CONTRACT-OWNER,
    treasury: (var-get platform-treasury),
    authorized-spender: (var-get authorized-spender)
  }
)