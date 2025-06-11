;; skillflow-main.clar
;; SkillFlow Main Contract
;; Provider Selection System - AI suggests, client chooses
;; STX as the only payment token

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant BASIS-POINTS u10000)
(define-constant MAX-APPLICATIONS-PER-SERVICE u15)
(define-constant MAX-PORTFOLIO-LINKS u5)
(define-constant APPLICATION-WINDOW-BLOCKS u144) ;; 24 hours to apply
(define-constant PLATFORM-FEE-RATE u250) ;; 2.5%
(define-constant MIN-STX-AMOUNT u1000000) ;; 1 STX minimum

;; Data variables
(define-data-var platform-active bool true)
(define-data-var emergency-mode bool false)
(define-data-var minimum-service-amount uint u1000000) ;; 1 STX minimum
(define-data-var next-service-id uint u1)
(define-data-var platform-treasury principal tx-sender)
(define-data-var oracle-contract principal tx-sender)

;; Enhanced data maps
(define-map skill-provider-profiles
  principal
  {
    verified-skills: (list 15 (string-ascii 50)),
    verification-status: uint,
    verification-timestamp: uint,
    total-services-completed: uint,
    total-earnings: uint, ;; in microSTX
    current-rating: uint,
    rating-count: uint,
    profile-creation-block: uint,
    kyc-verified: bool,
    response-rate: uint,
    avg-delivery-time: uint,
    active-applications: uint
  }
)

(define-map service-requests
  uint
  {
    client-address: principal,
    provider-address: (optional principal),
    skill-category: (string-ascii 50),
    service-description: (string-ascii 500),
    payment-amount: uint, ;; in microSTX
    creation-timestamp: uint,
    expiration-timestamp: uint,
    application-deadline: uint,
    current-status: uint,
    video-session-url: (optional (string-ascii 200)),
    completion-evidence: (optional (string-ascii 200)),
    client-rating: (optional uint),
    provider-rating: (optional uint),
    rush-delivery: bool,
    estimated-duration-minutes: uint,
    ai-suggestions-generated: bool,
    client-selection-required: bool
  }
)

;; Provider applications system
(define-map service-applications
  { service-id: uint, provider: principal }
  {
    application-message: (string-ascii 300),
    proposed-timeline: uint,
    proposed-price: (optional uint), ;; in microSTX
    portfolio-links: (list 5 (string-ascii 200)),
    application-timestamp: uint,
    application-status: uint,
    estimated-delivery: uint,
    provider-questions: (optional (string-ascii 200)),
    is-ai-suggested: bool
  }
)

(define-map service-application-count
  uint ;; service-id
  uint ;; number of applications
)

(define-map provider-applications
  principal
  (list 20 uint)
)

;; AI suggestions tracking
(define-map ai-suggestion-status
  uint ;; service-id
  {
    suggestions-requested: bool,
    suggestions-generated: bool,
    suggestion-count: uint
  }
)

(define-map payment-escrow-system
  uint
  {
    total-escrowed-amount: uint, ;; in microSTX
    platform-fee-amount: uint, ;; in microSTX
    provider-payout-amount: uint, ;; in microSTX
    funds-locked-status: bool,
    escrow-creation-block: uint,
    auto-release-block: (optional uint)
  }
)

(define-map client-profiles
  principal
  {
    total-services-requested: uint,
    total-amount-spent: uint, ;; in microSTX
    average-provider-rating: uint,
    payment-defaults: uint,
    account-creation-block: uint,
    kyc-status: bool
  }
)

;; Validation functions
(define-private (is-valid-stx-amount (amount uint))
  (and (> amount u0) (<= amount u100000000000)) ;; Max 100K STX
)

(define-private (is-valid-string (str (string-ascii 500)) (min-len uint) (max-len uint))
  (and 
    (>= (len str) min-len)
    (<= (len str) max-len)
  )
)

(define-private (is-valid-rating (rating uint))
  (and (>= rating u10) (<= rating u50))
)

(define-private (calculate-percentage (amount uint) (percentage uint))
  (/ (* amount percentage) BASIS-POINTS)
)

;; STX balance functions
(define-read-only (check-user-stx-balance (user principal))
  (stx-get-balance user)
)

(define-read-only (validate-user-balance-for-service (user principal) (service-cost uint))
  (let 
    (
      (platform-fee (calculate-percentage service-cost PLATFORM-FEE-RATE))
      (total-needed (+ service-cost platform-fee))
      (user-balance (stx-get-balance user))
    )
    (ok {
      sufficient: (>= user-balance total-needed),
      user-balance: user-balance,
      service-cost: service-cost,
      platform-fee: platform-fee,
      total-needed: total-needed,
      remaining-after: (if (>= user-balance total-needed) 
                         (some (- user-balance total-needed)) 
                         none),
      shortfall: (if (< user-balance total-needed) 
                   (some (- total-needed user-balance)) 
                   none)
    })
  )
)