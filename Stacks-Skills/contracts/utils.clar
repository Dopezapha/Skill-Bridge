;; utils.clar
;; SkillFlow Utilities Contract
;; Validation and utility functions optimized for STX

;; Maximum values for safety
(define-constant MAX-STX-AMOUNT u100000000000) ;; Max 100K STX
(define-constant MAX-PERCENTAGE u10000) ;; 100% in basis points
(define-constant BASIS-POINTS u10000)
(define-constant BLOCKS-PER-YEAR u52560) ;; Approximate blocks per year
(define-constant STX-DECIMALS u6) ;; STX uses 6 decimals
(define-constant MIN-STX-AMOUNT u1000000) ;; 1 STX minimum
(define-constant PLATFORM-FEE-RATE u250) ;; 2.5%

;; Basic validation functions
(define-read-only (is-valid-stx-amount (amount uint))
  (and (> amount u0) (<= amount MAX-STX-AMOUNT))
)

(define-read-only (is-valid-address (address (string-ascii 100)))
  (and (> (len address) u0) (<= (len address) u100))
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

(define-read-only (is-valid-estimated-time (time uint))
  (<= time u1440) ;; Max 24 hours in blocks
)

(define-read-only (is-valid-confidence (confidence uint))
  (<= confidence u100)
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

;; STX-specific validation functions
(define-read-only (is-valid-stx-service-amount (amount uint))
  (and 
    (>= amount MIN-STX-AMOUNT) ;; Minimum 1 STX
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

(define-read-only (calculate-fee-with-minimum (amount uint) (fee-rate uint) (minimum-fee uint))
  (let ((calculated-fee (calculate-percentage amount fee-rate)))
    (if (> calculated-fee minimum-fee)
      calculated-fee
      minimum-fee
    )
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
    decimals: STX-DECIMALS,
    native-currency: true,
    min-amount: MIN-STX-AMOUNT,
    max-amount: MAX-STX-AMOUNT,
    display-name: "Stacks (STX)",
    blockchain: "Stacks"
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

;; Service cost estimation
(define-read-only (estimate-service-total-cost (service-amount uint))
  (let 
    (
      (platform-fee (calculate-percentage service-amount PLATFORM-FEE-RATE))
      (total-cost (+ service-amount platform-fee))
    )
    {
      service-amount: service-amount,
      platform-fee: platform-fee,
      fee-percentage: "2.5%",
      total-cost: total-cost,
      service-amount-stx: (microSTX-to-STX service-amount),
      platform-fee-stx: (microSTX-to-STX platform-fee),
      total-cost-stx: (microSTX-to-STX total-cost)
    }
  )
)

;; Provider earnings calculation
(define-read-only (calculate-provider-earnings (gross-amount uint))
  (let 
    (
      (platform-fee (calculate-percentage gross-amount PLATFORM-FEE-RATE))
      (net-earnings (- gross-amount platform-fee))
    )
    {
      gross-amount: gross-amount,
      platform-fee: platform-fee,
      net-earnings: net-earnings,
      fee-rate: PLATFORM-FEE-RATE,
      gross-stx: (microSTX-to-STX gross-amount),
      net-stx: (microSTX-to-STX net-earnings)
    }
  )
)

;; Balance validation helpers
(define-read-only (check-sufficient-balance-for-service 
  (user-balance uint) 
  (service-cost uint)
)
  (let 
    (
      (platform-fee (calculate-percentage service-cost PLATFORM-FEE-RATE))
      (total-needed (+ service-cost platform-fee))
      (sufficient (>= user-balance total-needed))
    )
    {
      user-balance: user-balance,
      service-cost: service-cost,
      platform-fee: platform-fee,
      total-needed: total-needed,
      sufficient: sufficient,
      shortfall: (if sufficient u0 (- total-needed user-balance)),
      user-balance-stx: (microSTX-to-STX user-balance),
      total-needed-stx: (microSTX-to-STX total-needed)
    }
  )
)

;; Time and rating utilities
(define-read-only (blocks-to-hours (blocks uint))
  (/ (* blocks u10) u60) ;; Assuming 10 minute blocks
)

(define-read-only (hours-to-blocks (hours uint))
  (* hours u6) ;; 6 blocks per hour
)

(define-read-only (format-rating (rating-scaled uint))
  {
    raw-rating: rating-scaled,
    display-rating: (/ rating-scaled u10),
    stars: (/ rating-scaled u10),
    is-excellent: (>= rating-scaled u45), ;; 4.5+ stars
    is-good: (>= rating-scaled u35), ;; 3.5+ stars
    is-poor: (< rating-scaled u25) ;; Less than 2.5 stars
  }
)

;; Platform configuration helpers
(define-read-only (get-platform-limits)
  {
    min-service-amount: MIN-STX-AMOUNT,
    max-service-amount: u50000000000, ;; 50K STX
    platform-fee-rate: PLATFORM-FEE-RATE,
    max-applications-per-service: u15,
    application-window-hours: u24,
    rush-delivery-hours: u10,
    max-portfolio-links: u5
  }
)

(define-read-only (get-fee-breakdown (amount uint))
  {
    amount: amount,
    platform-fee: (calculate-percentage amount PLATFORM-FEE-RATE),
    provider-receives: (- amount (calculate-percentage amount PLATFORM-FEE-RATE)),
    fee-rate-display: "2.5%",
    currency: "STX"
  }
)

;; Validation summary functions
(define-read-only (validate-complete-service-request
  (skill-category (string-ascii 50))
  (description (string-ascii 500))
  (amount uint)
  (duration uint)
  (user-balance uint)
)
  (let 
    (
      (basic-validation (validate-service-creation-params skill-category description amount duration))
      (balance-check (check-sufficient-balance-for-service user-balance amount))
    )
    {
      basic-validation: basic-validation,
      balance-check: balance-check,
      ready-to-create: (and 
        (get all-valid basic-validation)
        (get sufficient balance-check)
      )
    }
  )
)

;; Emergency and admin utilities
(define-read-only (is-emergency-situation (blocks-since-last-update uint))
  (> blocks-since-last-update u288) ;; More than 48 hours
)

(define-read-only (calculate-refund-amounts 
  (total-escrowed uint) 
  (refund-percentage uint)
)
  (let 
    (
      (refund-amount (/ (* total-escrowed refund-percentage) u100))
      (remaining-amount (- total-escrowed refund-amount))
    )
    {
      total-escrowed: total-escrowed,
      refund-percentage: refund-percentage,
      refund-amount: refund-amount,
      remaining-amount: remaining-amount,
      refund-stx: (microSTX-to-STX refund-amount),
      remaining-stx: (microSTX-to-STX remaining-amount)
    }
  )
)