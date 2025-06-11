;; constants.clar
;; SkillFlow Platform Constants
;; STX-only payment system with AI predictions and new provider opportunities
;; SKILL Token for application fees

;; Contract deployer
(define-constant CONTRACT-DEPLOYER tx-sender)

;; Platform version management
(define-constant CONTRACT-VERSION "1.0.0")
(define-constant PLATFORM-VERSION-MAJOR u1)
(define-constant PLATFORM-VERSION-MINOR u0)
(define-constant PLATFORM-VERSION-PATCH u0)

;; Platform configuration
(define-constant PLATFORM-FEE-RATE u250) ;; 2.5% = 250/10000
(define-constant BASIS-POINTS u10000)
(define-constant MINIMUM-LIQUIDITY u1000)

;; SKILL TOKEN CONSTANTS
(define-constant SKILL-TOKEN-PRICE-STX u100000) ;; 0.1 STX = 100,000 microSTX per SKILL token
(define-constant APPLICATION-COST-SKILL u1000000) ;; 1 SKILL token per application
(define-constant APPLICATION-COST-STX u100000) ;; Equivalent to 0.1 STX

;; Error constants (comprehensive coverage)
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
;; Additional error codes (filling the gap)
(define-constant ERR-INVALID-DURATION (err u125))
(define-constant ERR-CONTRACT-PAUSED (err u126))
(define-constant ERR-RATE-LIMITED (err u127))
(define-constant ERR-INVALID-STATUS (err u128))
(define-constant ERR-INVALID-CONFIDENCE (err u129))
(define-constant ERR-STALE-PRICE (err u130))
(define-constant ERR-INVALID-PRICE (err u131))
;; NEW ERROR CODES FOR ADVANCED FEATURES
(define-constant ERR-SUCCESS-THRESHOLD-NOT-MET (err u132))
(define-constant ERR-EXPERIENCED-PROVIDER-QUOTA-FULL (err u133))
(define-constant ERR-NOT-NEW-PROVIDER (err u134))
(define-constant ERR-NEW-PROVIDER-QUOTA-FULL (err u135))
;; SKILL TOKEN ERROR CODES
(define-constant ERR-INSUFFICIENT-SKILL-TOKENS (err u136))
(define-constant ERR-SKILL-TOKEN-CONTRACT-NOT-SET (err u137))
(define-constant ERR-APPLICATION-FEE-REQUIRED (err u138))

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
(define-constant MIN-PROVIDER-RATING-THRESHOLD u20) ;; 2.0 stars minimum

;; Time constants
(define-constant BLOCKS-PER-DAY u144) ;; ~10 min blocks
(define-constant BLOCKS-PER-YEAR u52560) ;; Approximate blocks per year
(define-constant RUSH-DELIVERY-BLOCKS u60) ;; ~10 hours for rush delivery

;; Enhanced time constants
(define-constant MAX-SERVICE-DURATION-BLOCKS u8640) ;; 60 days max
(define-constant EMERGENCY-AUTO-RELEASE-BLOCKS u2160) ;; 15 days
(define-constant STALE-SERVICE-TIMEOUT-BLOCKS u4320) ;; 30 days
(define-constant MAX-DISPUTE-RESOLUTION-BLOCKS u1440) ;; 10 days max

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
(define-constant MAX-SKILL-VERIFICATION-BOOST u25) ;; Max boost from optional verification

;; DYNAMIC PRICING CONSTANTS
(define-constant MAX-COMPETENCY-BONUS u20) ;; Max 20% bonus for overperformance
(define-constant MAX-COMPETENCY-PENALTY u30) ;; Max 30% penalty for underperformance
(define-constant MIN-PRICE-ADJUSTMENT-FACTOR u5000) ;; Min 50% of original price
(define-constant MAX-PRICE-ADJUSTMENT-FACTOR u15000) ;; Max 150% of original price
(define-constant SIGNIFICANT-PRICE-CHANGE-THRESHOLD u1000) ;; 10% change triggers update

;; Rate limiting constants (anti-spam)
(define-constant MAX-APPLICATIONS-PER-BLOCK u3) ;; Per provider
(define-constant MAX-SERVICES-PER-BLOCK u5) ;; Per client
(define-constant MAX-APPLICATIONS-PER-SERVICE u15) ;; Total per service
(define-constant APPLICATION-WINDOW-BLOCKS u144) ;; 24 hours to apply

;; Advanced verification constants
(define-constant MIN-PORTFOLIO-LINKS u1)
(define-constant MAX-PORTFOLIO-LINKS u5)
(define-constant MAX-EXTERNAL-VERIFICATIONS u5)
(define-constant SKILL-BOOST-COOLDOWN-BLOCKS u144) ;; 24 hours between boosts

;; Public functions to access constants
(define-read-only (get-platform-fee-rate) PLATFORM-FEE-RATE)
(define-read-only (get-basis-points) BASIS-POINTS)

;; SKILL Token getters
(define-read-only (get-skill-token-price) SKILL-TOKEN-PRICE-STX)
(define-read-only (get-application-cost-skill) APPLICATION-COST-SKILL)
(define-read-only (get-application-cost-stx) APPLICATION-COST-STX)

;; Version information
(define-read-only (get-contract-version)
  {
    version: CONTRACT-VERSION,
    major: PLATFORM-VERSION-MAJOR,
    minor: PLATFORM-VERSION-MINOR,
    patch: PLATFORM-VERSION-PATCH,
    deployment-block: block-height
  }
)

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
(define-read-only (err-invalid-duration) ERR-INVALID-DURATION)
(define-read-only (err-contract-paused) ERR-CONTRACT-PAUSED)
(define-read-only (err-rate-limited) ERR-RATE-LIMITED)
(define-read-only (err-invalid-status) ERR-INVALID-STATUS)
(define-read-only (err-invalid-confidence) ERR-INVALID-CONFIDENCE)
(define-read-only (err-stale-price) ERR-STALE-PRICE)
(define-read-only (err-invalid-price) ERR-INVALID-PRICE)
;; New error getters
(define-read-only (err-success-threshold-not-met) ERR-SUCCESS-THRESHOLD-NOT-MET)
(define-read-only (err-experienced-provider-quota-full) ERR-EXPERIENCED-PROVIDER-QUOTA-FULL)
(define-read-only (err-not-new-provider) ERR-NOT-NEW-PROVIDER)
(define-read-only (err-new-provider-quota-full) ERR-NEW-PROVIDER-QUOTA-FULL)
;; SKILL Token error getters
(define-read-only (err-insufficient-skill-tokens) ERR-INSUFFICIENT-SKILL-TOKENS)
(define-read-only (err-skill-token-contract-not-set) ERR-SKILL-TOKEN-CONTRACT-NOT-SET)
(define-read-only (err-application-fee-required) ERR-APPLICATION-FEE-REQUIRED)

;; Status constants as public read-only functions
(define-read-only (get-service-status-open) SERVICE-STATUS-OPEN)
(define-read-only (get-service-status-matched) SERVICE-STATUS-MATCHED)
(define-read-only (get-service-status-in-progress) SERVICE-STATUS-IN-PROGRESS)
(define-read-only (get-service-status-completed) SERVICE-STATUS-COMPLETED)
(define-read-only (get-service-status-disputed) SERVICE-STATUS-DISPUTED)
(define-read-only (get-service-status-cancelled) SERVICE-STATUS-CANCELLED)

(define-read-only (get-min-rating) MIN-RATING)
(define-read-only (get-max-rating) MAX-RATING)
(define-read-only (get-min-provider-rating-threshold) MIN-PROVIDER-RATING-THRESHOLD)

(define-read-only (get-blocks-per-day) BLOCKS-PER-DAY)
(define-read-only (get-blocks-per-year) BLOCKS-PER-YEAR)
(define-read-only (get-rush-delivery-blocks) RUSH-DELIVERY-BLOCKS)
(define-read-only (get-price-staleness-threshold) PRICE-STALENESS-THRESHOLD)

;; Enhanced time getters
(define-read-only (get-max-service-duration) MAX-SERVICE-DURATION-BLOCKS)
(define-read-only (get-emergency-timeout) EMERGENCY-AUTO-RELEASE-BLOCKS)
(define-read-only (get-stale-service-timeout) STALE-SERVICE-TIMEOUT-BLOCKS)
(define-read-only (get-max-dispute-resolution-time) MAX-DISPUTE-RESOLUTION-BLOCKS)

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
(define-read-only (get-max-skill-verification-boost) MAX-SKILL-VERIFICATION-BOOST)

;; Dynamic pricing getters
(define-read-only (get-max-competency-bonus) MAX-COMPETENCY-BONUS)
(define-read-only (get-max-competency-penalty) MAX-COMPETENCY-PENALTY)
(define-read-only (get-min-price-adjustment-factor) MIN-PRICE-ADJUSTMENT-FACTOR)
(define-read-only (get-max-price-adjustment-factor) MAX-PRICE-ADJUSTMENT-FACTOR)

;; Rate limiting getters
(define-read-only (get-max-applications-per-block) MAX-APPLICATIONS-PER-BLOCK)
(define-read-only (get-max-services-per-block) MAX-SERVICES-PER-BLOCK)
(define-read-only (get-max-applications-per-service) MAX-APPLICATIONS-PER-SERVICE)
(define-read-only (get-application-window-blocks) APPLICATION-WINDOW-BLOCKS)

;; Platform limits function
(define-read-only (get-platform-limits-extended)
  {
    max-service-duration: MAX-SERVICE-DURATION-BLOCKS,
    min-provider-rating: MIN-PROVIDER-RATING-THRESHOLD,
    max-applications-per-block: MAX-APPLICATIONS-PER-BLOCK,
    max-services-per-block: MAX-SERVICES-PER-BLOCK,
    max-applications-per-service: MAX-APPLICATIONS-PER-SERVICE,
    emergency-timeout: EMERGENCY-AUTO-RELEASE-BLOCKS,
    skill-boost-cooldown: SKILL-BOOST-COOLDOWN-BLOCKS,
    min-portfolio-links: MIN-PORTFOLIO-LINKS,
    max-portfolio-links: MAX-PORTFOLIO-LINKS,
    max-external-verifications: MAX-EXTERNAL-VERIFICATIONS
  }
)

;; Platform information (comprehensive)
(define-read-only (get-platform-info)
  {
    primary-token: "STX",
    application-token: "SKILL",
    platform-fee-rate: PLATFORM-FEE-RATE,
    min-service-amount: MIN-STX-AMOUNT,
    application-cost: APPLICATION-COST-STX,
    application-cost-display: "0.1 STX per application",
    native-currency: true,
    blockchain: "Stacks",
    payment-model: "stx-escrow-with-skill-token-applications",
    version: CONTRACT-VERSION,
    ai-features: (list
      "Success prediction (80%+ threshold)"
      "Dynamic competency-based pricing"
      "New provider opportunities (30% quota)"
      "Real-time skill verification"
      "Spam prevention via SKILL tokens"
    ),
    success-thresholds: {
      experienced-providers: MIN-SUCCESS-PROBABILITY,
      new-providers: NEW-PROVIDER-SUCCESS-THRESHOLD
    },
    quota-system: {
      new-provider-percentage: NEW-PROVIDER-QUOTA-PERCENTAGE,
      max-suggestions: MAX-TOTAL-SUGGESTIONS,
      trial-projects: NEW-PROVIDER-TRIAL-PROJECTS
    },
    pricing-system: {
      max-bonus-percentage: MAX-COMPETENCY-BONUS,
      max-penalty-percentage: MAX-COMPETENCY-PENALTY,
      min-adjustment-factor: MIN-PRICE-ADJUSTMENT-FACTOR,
      max-adjustment-factor: MAX-PRICE-ADJUSTMENT-FACTOR
    },
    application-system: {
      cost-per-application: APPLICATION-COST-STX,
      cost-in-skill-tokens: APPLICATION-COST-SKILL,
      purchase-rate: "0.1 STX = 1 SKILL token",
      benefit: "Prevents spam applications, much cheaper than 15-20% competitor fees"
    },
    rate-limits: {
      max-applications-per-block: MAX-APPLICATIONS-PER-BLOCK,
      max-services-per-block: MAX-SERVICES-PER-BLOCK,
      application-window-hours: (/ APPLICATION-WINDOW-BLOCKS u6)
    }
  }
)