;; utils.clar
;; SkillFlow Utilities Contract
;; Validation and utility functions optimized for STX

;; Maximum values for safety
(define-constant MAX-STX-AMOUNT u100000000000) ;; Max 100K STX
(define-constant MAX-TOKEN-AMOUNT u1000000000000) ;; Max 1M tokens for other assets
(define-constant MAX-PERCENTAGE u10000) ;; 100% in basis points
(define-constant BASIS-POINTS u10000)
(define-constant BLOCKS-PER-YEAR u52560) ;; Approximate blocks per year
(define-constant STX-DECIMALS u6) ;; STX uses 6 decimals

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

;; Validation functions
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

;; Math utilities
(define-read-only (calculate-percentage (amount uint) (percentage uint))
  (/ (* amount percentage) BASIS-POINTS)
)

(define-read-only (calculate-stx-fee (stx-amount uint) (fee-rate uint))
  (/ (* stx-amount fee-rate) BASIS-POINTS)
)

(define-read-only (calculate-yield (staked-amount uint) (blocks-elapsed uint) (yield-rate uint))
  (if (and (> staked-amount u0) (> blocks-elapsed u0))
    (/ (* (* staked-amount yield-rate) blocks-elapsed) (* BLOCKS-PER-YEAR BASIS-POINTS))
    u0
  )
)

(define-read-only (calculate-compound-yield 
  (principal-amount uint) 
  (annual-rate uint) 
  (blocks-elapsed uint)
  (compound-frequency uint)
)
  (let 
    (
      (periods-per-year (/ BLOCKS-PER-YEAR compound-frequency))
      (rate-per-period (/ annual-rate periods-per-year))
      (periods-elapsed (/ blocks-elapsed compound-frequency))
    )
    (if (and (> principal-amount u0) (> periods-elapsed u0))
      (- (+ principal-amount (/ (* principal-amount rate-per-period periods-elapsed) BASIS-POINTS)) principal-amount)
      u0
    )
  )
)

(define-read-only (calculate-fee-with-minimum (amount uint) (fee-rate uint) (minimum-fee uint))
  (let ((calculated-fee (calculate-percentage amount fee-rate)))
    (if (> calculated-fee minimum-fee)
      calculated-fee
      minimum-fee
    )
  )
)

(define-read-only (calculate-slippage (expected-amount uint) (actual-amount uint))
  (if (> expected-amount u0)
    (if (>= actual-amount expected-amount)
      u0
      (/ (* (- expected-amount actual-amount) BASIS-POINTS) expected-amount)
    )
    u0
  )
)

;; STX conversion utilities
(define-read-only (microSTX-to-STX (micro-stx uint))
  (/ micro-stx u1000000)
)

(define-read-only (STX-to-microSTX (stx uint))
  (* stx u1000000)
)

(define-read-only (format-stx-amount (micro-stx uint))
  {
    micro-stx: micro-stx,
    stx: (microSTX-to-STX micro-stx),
    formatted: (microSTX-to-STX micro-stx)
  }
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
      (fee-amount (calculate-stx-fee amount fee-rate))
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

;; Utility functions for common operations
(define-read-only (get-token-type-name (token-type uint))
  (if (is-eq token-type u1)
    "USDT"
    (if (is-eq token-type u2)
      "USDC"
      (if (is-eq token-type u3)
        "STX"
        "UNKNOWN"
      )
    )
  )
)

(define-read-only (get-blockchain-name (blockchain-id uint))
  (if (is-eq blockchain-id u0)
    "Bitcoin"
    (if (is-eq blockchain-id u1)
      "Ethereum"
      (if (is-eq blockchain-id u2)
        "Polygon"
        (if (is-eq blockchain-id u3)
          "BSC"
          (if (is-eq blockchain-id u4)
            "Arbitrum"
            (if (is-eq blockchain-id u5)
              "Avalanche"
              "UNKNOWN"
            )
          )
        )
      )
    )
  )
)

(define-read-only (get-service-status-name (status uint))
  (if (is-eq status u0)
    "Open"
    (if (is-eq status u1)
      "Matched"
      (if (is-eq status u2)
        "In Progress"
        (if (is-eq status u3)
          "Completed"
          (if (is-eq status u4)
            "Disputed"
            (if (is-eq status u5)
              "Cancelled"
              "UNKNOWN"
            )
          )
        )
      )
    )
  )
)

;; Platform utility functions
(define-read-only (get-platform-token-info)
  {
    primary-token: "STX",
    token-id: u3,
    decimals: STX-DECIMALS,
    native-currency: true,
    min-amount: u1000000,
    max-amount: MAX-STX-AMOUNT,
    display-name: "Stacks (STX)"
  }
)

(define-read-only (estimate-transaction-cost 
  (base-amount uint) 
  (platform-fee-rate uint)
  (additional-fees (optional uint))
)
  (let 
    (
      (platform-fee (calculate-percentage base-amount platform-fee-rate))
      (extra-fees (default-to u0 additional-fees))
      (total-cost (+ base-amount platform-fee extra-fees))
    )
    {
      base-amount: base-amount,
      platform-fee: platform-fee,
      additional-fees: extra-fees,
      total-cost: total-cost,
      formatted-total: (format-stx-amount total-cost)
    }
  )
)