;; constants.clar
;; SkillFlow Platform Constants
;; STX-only payment system with AI predictions and new provider opportunities

;; Contract deployer
(define-constant CONTRACT-DEPLOYER tx-sender)

;; Platform configuration
(define-constant PLATFORM-FEE-RATE u250) ;; 2.5% = 250/10000
(define-constant BASIS-POINTS u10000)
(define-constant MINIMUM-LIQUIDITY u1000)

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-INVALID-STATE (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-DUPLICATE (err u104))
(define-constant ERR-VERIFICATION-REQUIRED (err u105))
(define-constant ERR-EXPIRED (err u106))
(define-constant ERR-INVALID-RATING (err u107))
(define-constant ERR-ADMIN-ONLY (err u108))
(define-constant ERR-FUNDS-LOCKED (err u109))
(define-constant ERR-INVALID-AMOUNT (err u110))
(define-constant ERR-ORACLE-STALE (err u115))
(define-constant ERR-PAUSED (err u116))
(define-constant ERR-INVALID-INPUT (err u117))
(define-constant ERR-OWNER-ONLY (err u118))
(define-constant ERR-INSUFFICIENT-BALANCE (err u120))
(define-constant ERR-TRANSFER-FAILED (err u121))
(define-constant ERR-INVALID-RECIPIENT (err u124))
(define-constant ERR-INVALID-STATUS (err u128))
(define-constant ERR-INVALID-CONFIDENCE (err u129))
(define-constant ERR-STALE-PRICE (err u130))
(define-constant ERR-INVALID-PRICE (err u131))
;; NEW ERROR CODES FOR ADVANCED FEATURES
(define-constant ERR-SUCCESS-THRESHOLD-NOT-MET (err u132))
(define-constant ERR-EXPERIENCED-PROVIDER-QUOTA-FULL (err u133))
(define-constant ERR-NOT-NEW-PROVIDER (err u134))
(define-constant ERR-NEW-PROVIDER-QUOTA-FULL (err u135))

;; Service status constants
(define-constant SERVICE-STATUS-OPEN u0)
(define-constant SERVICE-STATUS-MATCHED u1)
(define-constant SERVICE-STATUS-IN-PROGRESS u2)
(define-constant SERVICE-STATUS-COMPLETED u3)
(define-constant SERVICE-STATUS-DISPUTED u4)
(define-constant SERVICE-STATUS-CANCELLED u5)

;; Verification status constants
(define-constant VERIFICATION-PENDING u0)
(define-constant VERIFICATION-APPROVED u1)
(define-constant VERIFICATION-REJECTED u2)

;; Rating system constants
(define-constant MIN-RATING u10) ;; 1.0 (scaled by 10)
(define-constant MAX-RATING u50) ;; 5.0 (scaled by 10)

;; Time constants
(define-constant BLOCKS-PER-DAY u144) ;; ~10 min blocks
(define-constant BLOCKS-PER-YEAR u52560) ;; Approximate blocks per year
(define-constant RUSH-DELIVERY-BLOCKS u60) ;; ~10 hours for rush delivery

;; Price staleness threshold (blocks)
(define-constant PRICE-STALENESS-THRESHOLD u144) ;; ~24 hours

;; STX-specific constants
(define-constant STX-DECIMALS u6) ;; STX uses 6 decimals (microSTX)
(define-constant MIN-STX-AMOUNT u1000000) ;; 1 STX minimum
(define-constant MAX-STX-AMOUNT u100000000000) ;; 100K STX maximum

;; SUCCESS PREDICTION CONSTANTS
(define-constant MIN-SUCCESS-PROBABILITY u80) ;; 80% minimum for experienced
(define-constant NEW-PROVIDER-SUCCESS-THRESHOLD u70) ;; 70% for new providers
(define-constant DEFAULT-NEW-PROVIDER-SKILL-SCORE u75) ;; Default skill score for new providers

;; NEW PROVIDER SYSTEM CONSTANTS
(define-constant NEW-PROVIDER-TRIAL-PROJECTS u3) ;; First 3 projects are trial
(define-constant NEW-PROVIDER-QUOTA-PERCENTAGE u30) ;; 30% of suggestions must be new providers
(define-constant MIN-NEW-PROVIDER-SUGGESTIONS u1) ;; At least 1 new provider per service
(define-constant MAX-TOTAL-SUGGESTIONS u5) ;; Max suggestions per service
(define-constant MAX-SKILL-VERIFICATION_BOOST u25) ;; Max boost from optional verification

;; DYNAMIC PRICING CONSTANTS
(define-constant MAX-COMPETENCY-BONUS u20) ;; Max 20% bonus for overperformance
(define-constant MAX-COMPETENCY-PENALTY u30) ;; Max 30% penalty for underperformance
(define-constant MIN-PRICE-ADJUSTMENT-FACTOR u5000) ;; Min 50% of original price
(define-constant MAX-PRICE-ADJUSTMENT-FACTOR u15000) ;; Max 150% of original price
(define-constant SIGNIFICANT-PRICE_CHANGE_THRESHOLD u1000) ;; 10% change triggers update

;; Public functions to access constants
(define-read-only (get-platform-fee-rate) PLATFORM-FEE-RATE)
(define-read-only (get-basis-points) BASIS-POINTS)

;; Error constants as public read-only functions
(define-read-only (err-unauthorized) ERR-UNAUTHORIZED)
(define-read-only (err-not-found) ERR-NOT-FOUND)
(define-read-only (err-invalid-state) ERR-INVALID-STATE)
(define-read-only (err-insufficient-funds) ERR-INSUFFICIENT-FUNDS)
(define-read-only (err-duplicate) ERR-DUPLICATE)
(define-read-only (err-verification-required) ERR-VERIFICATION-REQUIRED)
(define-read-only (err-expired) ERR-EXPIRED)
(define-read-only (err-invalid-rating) ERR-INVALID-RATING)
(define-read-only (err-admin-only) ERR-ADMIN-ONLY)
(define-read-only (err-funds-locked) ERR-FUNDS-LOCKED)
(define-read-only (err-invalid-amount) ERR-INVALID-AMOUNT)
(define-read-only (err-oracle-stale) ERR-ORACLE-STALE)
(define-read-only (err-paused) ERR-PAUSED)
(define-read-only (err-invalid-input) ERR-INVALID-INPUT)
(define-read-only (err-owner-only) ERR-OWNER-ONLY)
(define-read-only (err-insufficient-balance) ERR-INSUFFICIENT-BALANCE)
(define-read-only (err-transfer-failed) ERR-TRANSFER-FAILED)
(define-read-only (err-invalid-recipient) ERR-INVALID-RECIPIENT)
(define-read-only (err-invalid-status) ERR-INVALID-STATUS)
(define-read-only (err-invalid-confidence) ERR-INVALID-CONFIDENCE)
(define-read-only (err-stale-price) ERR-STALE-PRICE)
(define-read-only (err-invalid-price) ERR-INVALID-PRICE)
;; New error getters
(define-read-only (err-success-threshold-not-met) ERR-SUCCESS-THRESHOLD-NOT-MET)
(define-read-only (err-experienced-provider-quota-full) ERR-EXPERIENCED-PROVIDER-QUOTA-FULL)
(define-read-only (err-not-new-provider) ERR-NOT-NEW-PROVIDER)
(define-read-only (err-new-provider-quota-full) ERR-NEW-PROVIDER-QUOTA-FULL)

;; Status constants as public read-only functions
(define-read-only (get-service-status-open) SERVICE-STATUS-OPEN)
(define-read-only (get-service-status-matched) SERVICE-STATUS-MATCHED)
(define-read-only (get-service-status-in-progress) SERVICE-STATUS-IN-PROGRESS)
(define-read-only (get-service-status-completed) SERVICE-STATUS-COMPLETED)
(define-read-only (get-service-status-disputed) SERVICE-STATUS-DISPUTED)
(define-read-only (get-service-status-cancelled) SERVICE-STATUS-CANCELLED)

(define-read-only (get-min-rating) MIN-RATING)
(define-read-only (get-max-rating) MAX-RATING)

(define-read-only (get-blocks-per-day) BLOCKS-PER-DAY)
(define-read-only (get-blocks-per-year) BLOCKS-PER-YEAR)
(define-read-only (get-rush-delivery-blocks) RUSH-DELIVERY-BLOCKS)
(define-read-only (get-price-staleness-threshold) PRICE-STALENESS-THRESHOLD)

;; STX-specific getters
(define-read-only (get-stx-decimals) STX-DECIMALS)
(define-read-only (get-min-stx-amount) MIN-STX-AMOUNT)
(define-read-only (get-max-stx-amount) MAX-STX-AMOUNT)

;; New feature getters
(define-read-only (get-min-success-probability) MIN-SUCCESS-PROBABILITY)
(define-read-only (get-new-provider-success-threshold) NEW-PROVIDER-SUCCESS-THRESHOLD)
(define-read-only (get-new-provider-quota-percentage) NEW-PROVIDER-QUOTA-PERCENTAGE)
(define-read-only (get-max-total-suggestions) MAX-TOTAL-SUGGESTIONS)
(define-read-only (get-new-provider-trial-projects) NEW-PROVIDER-TRIAL-PROJECTS)

;; Platform information
(define-read-only (get-platform-info)
  {
    primary-token: "STX",
    platform-fee-rate: PLATFORM-FEE-RATE,
    min-service-amount: MIN-STX-AMOUNT,
    native-currency: true,
    blockchain: "Stacks",
    payment-model: "stx-escrow-with-dynamic-pricing",
    ai-features: (list
      "Success prediction (80%+ threshold)"
      "Dynamic competency-based pricing"
      "New provider opportunities (30% quota)"
      "Real-time skill verification"
    ),
    success-thresholds: {
      experienced-providers: MIN-SUCCESS-PROBABILITY,
      new-providers: NEW-PROVIDER-SUCCESS-THRESHOLD
    },
    quota-system: {
      new-provider-percentage: NEW-PROVIDER-QUOTA-PERCENTAGE,
      max-suggestions: MAX-TOTAL-SUGGESTIONS,
      trial-projects: NEW-PROVIDER-TRIAL-PROJECTS
    }
  }
)