;; SkillFlow Validation Contract
;; Core validation functions for STX and other parameters

;; Maximum values for safety
(define-constant MAX-STX-AMOUNT u100000000000) ;; Max 100K STX
(define-constant MAX-TOKEN-AMOUNT u1000000000000) ;; Max 1M tokens for other assets
(define-constant MAX-PERCENTAGE u10000) ;; 100% in basis points
(define-constant BASIS-POINTS u10000)

;; Basic validation functions
(define-read-only (is-valid-token-type (token-type uint))
  (<= token-type u3) ;; TOKEN-STX = u3
)

(define-read-only (is-valid-chain (target-chain uint))
  (and (>= target-chain u0) (<= target-chain u5)) ;; CHAIN-BITCOIN to CHAIN-AVALANCHE
)

(define-read-only (is-valid-stx-amount (amount uint))
  (and (> amount u0) (<= amount MAX-STX-AMOUNT))
)

(define-read-only (is-valid-amount (amount uint))
  (and (> amount u0) (<= amount MAX-TOKEN-AMOUNT))
)

(define-read-only (is-valid-address (address (string-ascii 100)))
  (and (> (len address) u0) (<= (len address) u100))
)

(define-read-only (is-valid-tx-hash (hash (string-ascii 100)))
  (and (> (len hash) u0) (<= (len hash) u100))
)

(define-read-only (is-valid-principal (addr principal))
  (and 
    (not (is-eq addr tx-sender))
    (not (is-eq addr 'SP000000000000000000002Q6VF78))
  )
)

(define-read-only (is-valid-fee-rate (fee-rate uint))
  (<= fee-rate u1000) ;; Max 10%
)

(define-read-only (is-valid-min-max-amount (min-amount uint) (max-amount uint))
  (and (> min-amount u0) (> max-amount min-amount))
)

(define-read-only (is-valid-estimated-time (time uint))
  (<= time u1440) ;; Max 24 hours in blocks
)

(define-read-only (is-valid-confidence (confidence uint))
  (<= confidence u100)
)

(define-read-only (is-valid-volatility (volatility uint))
  (<= volatility u10000)
)

(define-read-only (is-valid-source (source (string-ascii 50)))
  (and (> (len source) u0) (<= (len source) u50))
)

(define-read-only (is-valid-skill-name (skill-name (string-ascii 50)))
  (and (> (len skill-name) u0) (<= (len skill-name) u50))
)

(define-read-only (is-valid-video-hash (video-hash (string-ascii 200)))
  (and (> (len video-hash) u0) (<= (len video-hash) u200))
)

(define-read-only (is-valid-review-notes (notes (optional (string-ascii 300))))
  (match notes
    some-notes (<= (len some-notes) u300)
    true
  )
)

(define-read-only (is-valid-string (str (string-ascii 500)) (min-len uint) (max-len uint))
  (and 
    (>= (len str) min-len)
    (<= (len str) max-len)
  )
)

(define-read-only (is-valid-yield-rate (rate uint))
  (<= rate u2000) ;; Max 20% APY
)

(define-read-only (is-valid-bridge-fee-rate (rate uint))
  (<= rate u1000) ;; Max 10%
)

(define-read-only (is-valid-percentage (percentage uint))
  (<= percentage MAX-PERCENTAGE)
)

(define-read-only (is-valid-rating (rating uint))
  (and (>= rating u10) (<= rating u50)) ;; 1.0 to 5.0 (scaled by 10)
)

(define-read-only (is-valid-duration-minutes (minutes uint))
  (<= minutes u1440) ;; Max 24 hours
)

(define-read-only (is-valid-service-status (status uint))
  (<= status u5) ;; SERVICE-STATUS-CANCELLED = u5
)

(define-read-only (is-valid-token-symbol (symbol (string-ascii 10)))
  (and (> (len symbol) u0) (<= (len symbol) u10))
)

(define-read-only (is-valid-token-name (name (string-ascii 32)))
  (and (> (len name) u0) (<= (len name) u32))
)

(define-read-only (is-valid-decimals (decimals uint))
  (<= decimals u18) ;; Max 18 decimals
)

;; STX-specific validation functions
(define-read-only (is-valid-stx-service-amount (amount uint))
  (and 
    (>= amount u1000000) ;; Minimum 1 STX
    (<= amount u50000000000) ;; Maximum 50K STX
  )
)

(define-read-only (is-sufficient-stx-balance (user-balance uint) (required-amount uint) (fee-rate uint))
  (let 
    (
      (fee-amount (/ (* required-amount fee-rate) BASIS-POINTS))
      (total-needed (+ required-amount fee-amount))
    )
    (>= user-balance total-needed)
  )
)

;; Batch validation functions
(define-read-only (validate-service-creation-params
  (skill-category (string-ascii 50))
  (service-description (string-ascii 500))
  (payment-amount uint)
  (duration-minutes uint)
)
  {
    valid-skill-category: (is-valid-string skill-category u1 u50),
    valid-description: (is-valid-string service-description u1 u500),
    valid-payment-amount: (is-valid-stx-service-amount payment-amount),
    valid-duration: (is-valid-duration-minutes duration-minutes),
    all-valid: (and 
      (is-valid-string skill-category u1 u50)
      (is-valid-string service-description u1 u500)
      (is-valid-stx-service-amount payment-amount)
      (is-valid-duration-minutes duration-minutes)
    )
  }
)

(define-read-only (validate-bridge-params
  (token-type uint)
  (amount uint)
  (target-chain uint)
  (target-address (string-ascii 100))
)
  {
    valid-token-type: (is-valid-token-type token-type),
    valid-amount: (if (is-eq token-type u3) 
      (is-valid-stx-amount amount) 
      (is-valid-amount amount)),
    valid-chain: (is-valid-chain target-chain),
    valid-address: (is-valid-address target-address),
    all-valid: (and
      (is-valid-token-type token-type)
      (if (is-eq token-type u3) 
        (is-valid-stx-amount amount) 
        (is-valid-amount amount))
      (is-valid-chain target-chain)
      (is-valid-address target-address)
    )
  }
)

(define-read-only (validate-stx-transaction
  (amount uint)
  (user-balance uint)
  (fee-rate uint)
)
  (let 
    (
      (fee-amount (/ (* amount fee-rate) BASIS-POINTS))
      (total-needed (+ amount fee-amount))
    )
    {
      valid-amount: (is-valid-stx-amount amount),
      sufficient-balance: (>= user-balance total-needed),
      fee-amount: fee-amount,
      total-needed: total-needed,
      remaining-balance: (if (>= user-balance total-needed) 
        (- user-balance total-needed) 
        u0),
      all-valid: (and 
        (is-valid-stx-amount amount)
        (>= user-balance total-needed)
      )
    }
  )
)