;; skillflow-main.clar
;; SkillFlow Main Contract
;; Provider Selection System - AI suggests, client chooses
;; STX-only payment system

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

;; SUCCESS PREDICTION SYSTEM
(define-map project-success-predictions
  uint ;; service-id
  {
    success-probability: uint, ;; 0-100%
    risk-factors: (list 10 (string-ascii 50)),
    recommended-adjustments: (string-ascii 300),
    prediction-timestamp: uint,
    confidence-score: uint
  }
)

;; DYNAMIC COMPETENCY PRICING
(define-map competency-assessments
  { service-id: uint, provider: principal }
  {
    initial-skill-score: uint, ;; 0-100
    demonstrated-competency: uint, ;; 0-100, updated during work
    competency-verified: bool,
    price-adjustment-factor: uint, ;; basis points (10000 = 100%)
    assessment-timestamp: uint,
    verification-evidence: (optional (string-ascii 200))
  }
)

;; MINIMUM SUCCESS THRESHOLD
(define-constant MIN-SUCCESS-PROBABILITY u80) ;; 80% minimum
(define-constant NEW-PROVIDER-SUCCESS-THRESHOLD u70) ;; 70% for new providers
(define-constant NEW-PROVIDER-TRIAL-PROJECTS u3) ;; First 3 projects get special treatment

;; NEW PROVIDER QUOTA SYSTEM
(define-constant NEW-PROVIDER-QUOTA-PERCENTAGE u30) ;; 30% of suggestions must be new providers
(define-constant MIN-NEW-PROVIDER-SUGGESTIONS u1) ;; At least 1 new provider per service
(define-constant MAX-TOTAL-SUGGESTIONS u5) ;; Max suggestions per service

;; SERVICE SUGGESTION TRACKING
(define-map service-suggestion-quotas
  uint ;; service-id
  {
    total-suggestions-target: uint,
    new-provider-suggestions-target: uint,
    experienced-provider-suggestions-target: uint,
    new-provider-suggestions-made: uint,
    experienced-provider-suggestions-made: uint,
    quota-fulfilled: bool
  }
)

;; NEW PROVIDER OPPORTUNITY SYSTEM
(define-map new-provider-trials
  principal
  {
    trial-projects-completed: uint,
    trial-success-rate: uint,
    skill-verification-score: uint,
    portfolio-verification-score: uint,
    external-verification-score: uint,
    trial-period-active: bool,
    trial-start-block: uint
  }
)

;; SKILL VERIFICATION FOR NEW PROVIDERS
(define-map skill-verification-challenges
  { provider: principal, skill: (string-ascii 50) }
  {
    challenge-type: (string-ascii 100),
    submission-hash: (optional (string-ascii 200)),
    ai-assessment-score: (optional uint),
    verification-status: uint, ;; 0: pending, 1: passed, 2: failed
    completion-timestamp: (optional uint),
    external-proof: (optional (string-ascii 300))
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

;; Helper function to get the maximum of two values
(define-private (get-max (a uint) (b uint))
  (if (> a b) a b)
)

;; Enhanced validation functions
(define-private (is-valid-timeline (timeline uint))
  (and (> timeline u0) (<= timeline u1440)) ;; Max 24 hours
)

(define-private (is-valid-probability (prob uint))
  (and (>= prob u0) (<= prob u100))
)

(define-private (is-valid-skill-score (score uint))
  (and (>= score u0) (<= score u100))
)

(define-private (is-valid-risk-factors (factors (list 10 (string-ascii 50))))
  (and 
    (>= (len factors) u0)
    (<= (len factors) u10)
  )
)

(define-private (is-valid-adjustments (adjustments (string-ascii 300)))
  (and 
    (>= (len adjustments) u0)
    (<= (len adjustments) u300)
  )
)

(define-private (is-valid-portfolio-links (links (list 5 (string-ascii 200))))
  (and 
    (>= (len links) u0)
    (<= (len links) u5)
  )
)

(define-private (is-valid-boost-amount (amount uint))
  (and (>= amount u1) (<= amount u25))
)

(define-private (is-valid-principal (addr principal))
  (not (is-eq addr 'ST000000000000000000002AMW42H)) ;; Not burn address
)

;; New validation functions for optional types
(define-private (is-valid-optional-price (price (optional uint)))
  (match price
    some-price (is-valid-stx-amount some-price)
    true
  )
)

(define-private (is-valid-optional-questions (questions (optional (string-ascii 200))))
  (match questions
    some-questions (is-valid-string some-questions u1 u200)
    true
  )
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

;; MAIN SERVICE CREATION
(define-public (create-service-request
  (skill-category (string-ascii 50))
  (service-description (string-ascii 500))
  (payment-amount uint) ;; in microSTX
  (rush-delivery bool)
  (duration-minutes uint)
  (request-ai-suggestions bool)
)
  (let 
    (
      (service-id (var-get next-service-id))
      (platform-fee (calculate-percentage payment-amount PLATFORM-FEE-RATE))
      (total-payment (+ payment-amount platform-fee))
      (expiration-time (+ block-height (if rush-delivery u60 u288)))
      (application-deadline (+ block-height APPLICATION-WINDOW-BLOCKS))
      (user-stx-balance (stx-get-balance tx-sender))
    )
    ;; Input validation
    (asserts! (var-get platform-active) (err u100))
    (asserts! (is-valid-string skill-category u1 u50) (err u117))
    (asserts! (is-valid-string service-description u1 u500) (err u117))
    (asserts! (is-valid-stx-amount payment-amount) (err u110))
    (asserts! (<= duration-minutes u1440) (err u117))
    (asserts! (>= payment-amount (var-get minimum-service-amount)) (err u110))
    (asserts! (>= user-stx-balance total-payment) (err u120))
    
    ;; Transfer STX to escrow
    (try! (stx-transfer? total-payment tx-sender (as-contract tx-sender)))
    
    ;; Create service request
    (map-set service-requests service-id
      {
        client-address: tx-sender,
        provider-address: none,
        skill-category: skill-category,
        service-description: service-description,
        payment-amount: payment-amount,
        creation-timestamp: block-height,
        expiration-timestamp: expiration-time,
        application-deadline: application-deadline,
        current-status: u0,
        video-session-url: none,
        completion-evidence: none,
        client-rating: none,
        provider-rating: none,
        rush-delivery: rush-delivery,
        estimated-duration-minutes: duration-minutes,
        ai-suggestions-generated: false,
        client-selection-required: true
      }
    )
    
    ;; Setup escrow
    (map-set payment-escrow-system service-id
      {
        total-escrowed-amount: total-payment,
        platform-fee-amount: platform-fee,
        provider-payout-amount: payment-amount,
        funds-locked-status: true,
        escrow-creation-block: block-height,
        auto-release-block: (if rush-delivery (some (+ block-height u1440)) none)
      }
    )
    
    ;; Initialize application tracking
    (map-set service-application-count service-id u0)
    (map-set ai-suggestion-status service-id
      {
        suggestions-requested: request-ai-suggestions,
        suggestions-generated: false,
        suggestion-count: u0
      }
    )
    
    ;; Update client profile
    (let ((profile-updated (update-client-profile payment-amount)))
      (var-set next-service-id (+ service-id u1))
      
      (print {
        type: "service-request-created",
        service-id: service-id,
        client: tx-sender,
        skill-category: skill-category,
        payment-amount: payment-amount,
        ai-suggestions-requested: request-ai-suggestions,
        application-deadline: application-deadline,
        block: block-height
      })
      
      (ok service-id)
    )
  )
)

;; AI ORACLE CREATES SUGGESTION WITH SUCCESS PREDICTION
(define-public (create-ai-suggested-application-with-prediction
  (service-id uint)
  (suggested-provider principal)
  (estimated-timeline uint)
  (success-probability uint)
  (risk-factors (list 10 (string-ascii 50)))
  (recommended-adjustments (string-ascii 300))
  (initial-skill-score uint)
)
  (let 
    (
      (service-info (unwrap! (map-get? service-requests service-id) (err u101)))
      (provider-profile (unwrap! (map-get? skill-provider-profiles suggested-provider) (err u105)))
      (current-app-count (default-to u0 (map-get? service-application-count service-id)))
      (ai-status (unwrap! (map-get? ai-suggestion-status service-id) (err u101)))
    )
    ;; Input validation
    (asserts! (is-eq tx-sender (var-get oracle-contract)) (err u100))
    (asserts! (is-eq (get current-status service-info) u0) (err u102))
    (asserts! (< block-height (get application-deadline service-info)) (err u106))
    (asserts! (is-eq (get verification-status provider-profile) u1) (err u105))
    (asserts! (get suggestions-requested ai-status) (err u102))
    (asserts! (< current-app-count MAX-APPLICATIONS-PER-SERVICE) (err u117))
    (asserts! (not (is-eq suggested-provider (get client-address service-info))) (err u100))
    (asserts! (is-none (map-get? service-applications { service-id: service-id, provider: suggested-provider })) (err u104))
    
    ;; Validate untrusted inputs
    (asserts! (is-valid-principal suggested-provider) (err u117))
    (asserts! (is-valid-timeline estimated-timeline) (err u117))
    (asserts! (is-valid-probability success-probability) (err u117))
    (asserts! (is-valid-skill-score initial-skill-score) (err u117))
    (asserts! (is-valid-risk-factors risk-factors) (err u117))
    (asserts! (is-valid-adjustments recommended-adjustments) (err u117))
    
    ;; SUCCESS PROBABILITY FILTER - Only suggest if >80% success rate
    (asserts! (>= success-probability MIN-SUCCESS-PROBABILITY) (err u132))
    
    ;; Store success prediction
    (map-set project-success-predictions service-id
      {
        success-probability: success-probability,
        risk-factors: risk-factors,
        recommended-adjustments: recommended-adjustments,
        prediction-timestamp: block-height,
        confidence-score: u90
      }
    )
    
    ;; Store initial competency assessment
    (map-set competency-assessments { service-id: service-id, provider: suggested-provider }
      {
        initial-skill-score: initial-skill-score,
        demonstrated-competency: initial-skill-score, ;; Starts same as initial
        competency-verified: false,
        price-adjustment-factor: u10000, ;; Starts at 100% (no adjustment)
        assessment-timestamp: block-height,
        verification-evidence: none
      }
    )
    
    ;; Create AI suggested application
    (map-set service-applications 
      { service-id: service-id, provider: suggested-provider }
      {
        application-message: "AI suggested provider with high success probability",
        proposed-timeline: estimated-timeline,
        proposed-price: none,
        portfolio-links: (list "" "" "" "" ""),
        application-timestamp: block-height,
        application-status: u0,
        estimated-delivery: (+ block-height estimated-timeline),
        provider-questions: none,
        is-ai-suggested: true
      }
    )
    
    ;; Update counters
    (map-set service-application-count service-id (+ current-app-count u1))
    (map-set ai-suggestion-status service-id
      (merge ai-status {
        suggestion-count: (+ (get suggestion-count ai-status) u1)
      })
    )
    
    ;; Update provider stats
    (map-set skill-provider-profiles suggested-provider
      (merge provider-profile {
        active-applications: (+ (get active-applications provider-profile) u1)
      })
    )
    
    (print {
      type: "ai-suggested-application-with-prediction",
      service-id: service-id,
      suggested-provider: suggested-provider,
      success-probability: success-probability,
      initial-skill-score: initial-skill-score,
      estimated-timeline: estimated-timeline,
      total-applications: (+ current-app-count u1),
      block: block-height
    })
    
    (ok true)
  )
)

;; MARK AI SUGGESTIONS AS COMPLETE
(define-public (complete-ai-suggestions (service-id uint))
  (let ((ai-status (unwrap! (map-get? ai-suggestion-status service-id) (err u101))))
    (asserts! (is-eq tx-sender (var-get oracle-contract)) (err u100))
    (asserts! (get suggestions-requested ai-status) (err u102))
    (asserts! (not (get suggestions-generated ai-status)) (err u104))
    
    ;; Mark suggestions as complete
    (map-set ai-suggestion-status service-id
      (merge ai-status { suggestions-generated: true })
    )
    
    ;; Update service
    (let ((service-info (unwrap! (map-get? service-requests service-id) (err u101))))
      (map-set service-requests service-id
        (merge service-info { ai-suggestions-generated: true })
      )
    )
    
    (print {
      type: "ai-suggestions-completed",
      service-id: service-id,
      suggestion-count: (get suggestion-count ai-status),
      block: block-height
    })
    
    (ok true)
  )
)

;; PROVIDER APPLIES TO SERVICE
(define-public (apply-to-service
  (service-id uint)
  (application-message (string-ascii 300))
  (proposed-timeline uint)
  (portfolio-links (list 5 (string-ascii 200)))
  (proposed-price (optional uint)) ;; in microSTX
  (provider-questions (optional (string-ascii 200)))
)
  (let 
    (
      (service-info (unwrap! (map-get? service-requests service-id) (err u101)))
      (provider-profile (unwrap! (map-get? skill-provider-profiles tx-sender) (err u105)))
      (current-app-count (default-to u0 (map-get? service-application-count service-id)))
      (provider-apps (default-to (list) (map-get? provider-applications tx-sender)))
    )
    ;; Input validation
    (asserts! (is-eq (get current-status service-info) u0) (err u102))
    (asserts! (< block-height (get application-deadline service-info)) (err u106))
    (asserts! (is-eq (get verification-status provider-profile) u1) (err u105))
    (asserts! (not (is-eq tx-sender (get client-address service-info))) (err u100))
    (asserts! (is-none (map-get? service-applications { service-id: service-id, provider: tx-sender })) (err u104))
    (asserts! (is-valid-string application-message u10 u300) (err u117))
    (asserts! (< current-app-count MAX-APPLICATIONS-PER-SERVICE) (err u117))
    (asserts! (< (get active-applications provider-profile) u5) (err u117))
    
    ;; Validate untrusted inputs
    (asserts! (is-valid-timeline proposed-timeline) (err u117))
    (asserts! (is-valid-portfolio-links portfolio-links) (err u117))
    (asserts! (is-valid-optional-price proposed-price) (err u110))
    (asserts! (is-valid-optional-questions provider-questions) (err u117))
    
    ;; Additional validation for proposed price if provided
    (match proposed-price
      some-price (begin
        (asserts! (and (>= some-price (/ (get payment-amount service-info) u2)) 
                       (<= some-price (* (get payment-amount service-info) u2))) (err u110))
      )
      true
    )
    
    ;; Create application with validated inputs
    (map-set service-applications 
      { service-id: service-id, provider: tx-sender }
      {
        application-message: application-message,
        proposed-timeline: proposed-timeline,
        proposed-price: proposed-price,
        portfolio-links: portfolio-links,
        application-timestamp: block-height,
        application-status: u0,
        estimated-delivery: (+ block-height proposed-timeline),
        provider-questions: provider-questions,
        is-ai-suggested: false
      }
    )
    
    ;; Update counters
    (map-set service-application-count service-id (+ current-app-count u1))
    (map-set provider-applications tx-sender 
      (unwrap! (as-max-len? (append provider-apps service-id) u20) (err u117)))
    
    ;; Update provider stats
    (map-set skill-provider-profiles tx-sender
      (merge provider-profile {
        active-applications: (+ (get active-applications provider-profile) u1)
      })
    )
    
    (print {
      type: "provider-applied",
      service-id: service-id,
      provider: tx-sender,
      timeline: proposed-timeline,
      proposed-price: proposed-price,
      application-count: (+ current-app-count u1),
      block: block-height
    })
    
    (ok true)
  )
)

;; CLIENT SELECTS PROVIDER
(define-public (select-provider
  (service-id uint)
  (chosen-provider principal)
  (accept-proposed-price bool)
)
  (let 
    (
      (service-info (unwrap! (map-get? service-requests service-id) (err u101)))
      (application (unwrap! (map-get? service-applications 
        { service-id: service-id, provider: chosen-provider }) (err u101)))
      (escrow-info (unwrap! (map-get? payment-escrow-system service-id) (err u101)))
    )
    ;; Input validation
    (asserts! (is-eq tx-sender (get client-address service-info)) (err u100))
    (asserts! (is-eq (get current-status service-info) u0) (err u102))
    (asserts! (is-eq (get application-status application) u0) (err u102))
    
    ;; Validate untrusted inputs
    (asserts! (is-valid-principal chosen-provider) (err u117))
    
    ;; Handle price adjustment
    (let ((final-payout-amount 
      (if (and accept-proposed-price (is-some (get proposed-price application)))
        (unwrap-panic (get proposed-price application))
        (get payment-amount service-info))))
      
      ;; Update service with chosen provider
      (map-set service-requests service-id
        (merge service-info {
          provider-address: (some chosen-provider),
          current-status: u1,
          payment-amount: final-payout-amount
        })
      )
      
      ;; Update escrow if needed
      (if (not (is-eq final-payout-amount (get payment-amount service-info)))
        (map-set payment-escrow-system service-id
          (merge escrow-info {
            provider-payout-amount: final-payout-amount
          }))
        true
      )
      
      ;; Update chosen application
      (map-set service-applications 
        { service-id: service-id, provider: chosen-provider }
        (merge application { application-status: u1 }))
      
      ;; Update provider stats
      (let ((provider-profile (unwrap! (map-get? skill-provider-profiles chosen-provider) (err u105))))
        (map-set skill-provider-profiles chosen-provider
          (merge provider-profile {
            active-applications: (- (get active-applications provider-profile) u1)
          })
        )
      )
      
      (print {
        type: "provider-selected",
        service-id: service-id,
        chosen-provider: chosen-provider,
        final-price: final-payout-amount,
        was-ai-suggested: (get is-ai-suggested application),
        block: block-height
      })
      
      (ok true)
    )
  )
)

;; WITHDRAW APPLICATION
(define-public (withdraw-application (service-id uint))
  (let ((application (unwrap! (map-get? service-applications 
    { service-id: service-id, provider: tx-sender }) (err u101))))
    
    ;; Validate input
    (asserts! (> service-id u0) (err u117))
    (asserts! (is-eq (get application-status application) u0) (err u102))
    
    (map-set service-applications 
      { service-id: service-id, provider: tx-sender }
      (merge application { application-status: u3 }))
    
    ;; Update provider stats
    (let ((provider-profile (unwrap! (map-get? skill-provider-profiles tx-sender) (err u105))))
      (map-set skill-provider-profiles tx-sender
        (merge provider-profile {
          active-applications: (- (get active-applications provider-profile) u1)
        })
      )
    )
    
    (ok true)
  )
)

;; START SERVICE SESSION
(define-public (start-service-session
  (service-id uint)
  (video-session-url (string-ascii 200))
)
  (let 
    (
      (service-info (unwrap! (map-get? service-requests service-id) (err u101)))
      (provider (unwrap! (get provider-address service-info) (err u101)))
    )
    (asserts! (is-valid-string video-session-url u1 u200) (err u117))
    (asserts! (or (is-eq tx-sender (get client-address service-info)) (is-eq tx-sender provider)) (err u100))
    (asserts! (is-eq (get current-status service-info) u1) (err u102))
    
    (map-set service-requests service-id
      (merge service-info {
        current-status: u2,
        video-session-url: (some video-session-url)
      })
    )
    
    (ok true)
  )
)

;; COMPLETE SERVICE
(define-public (complete-service-delivery
  (service-id uint)
  (completion-evidence (string-ascii 200))
)
  (let 
    (
      (service-info (unwrap! (map-get? service-requests service-id) (err u101)))
      (provider (unwrap! (get provider-address service-info) (err u101)))
    )
    (asserts! (is-valid-string completion-evidence u1 u200) (err u117))
    (asserts! (is-eq tx-sender provider) (err u100))
    (asserts! (is-eq (get current-status service-info) u2) (err u102))
    
    (map-set service-requests service-id
      (merge service-info {
        current-status: u3,
        completion-evidence: (some completion-evidence)
      })
    )
    
    ;; Release payment and update stats
    (try! (release-stx-payment service-id provider))
    (let ((stats-updated (update-provider-stats provider service-id)))
      (ok true)
    )
  )
)

;; RATE PROVIDER
(define-public (rate-service-provider (service-id uint) (rating uint))
  (let 
    (
      (service-info (unwrap! (map-get? service-requests service-id) (err u101)))
      (provider (unwrap! (get provider-address service-info) (err u101)))
    )
    (asserts! (is-valid-rating rating) (err u107))
    (asserts! (is-eq tx-sender (get client-address service-info)) (err u100))
    (asserts! (is-eq (get current-status service-info) u3) (err u102))
    (asserts! (is-none (get client-rating service-info)) (err u104))
    
    (map-set service-requests service-id
      (merge service-info { client-rating: (some rating) })
    )
    
    (let ((rating-updated (update-provider-rating provider rating)))
      (ok true)
    )
  )
)

;; HELPER FUNCTIONS
(define-private (release-stx-payment (service-id uint) (provider principal))
  (let ((escrow-info (unwrap! (map-get? payment-escrow-system service-id) (err u101))))
    (try! (as-contract (stx-transfer? 
      (get provider-payout-amount escrow-info) tx-sender provider)))
    (try! (as-contract (stx-transfer? 
      (get platform-fee-amount escrow-info) tx-sender (var-get platform-treasury))))
    
    (map-set payment-escrow-system service-id
      (merge escrow-info { funds-locked-status: false })
    )
    (ok true)
  )
)

(define-private (update-client-profile (amount uint))
  (let ((current-profile (default-to 
    {
      total-services-requested: u0,
      total-amount-spent: u0,
      average-provider-rating: u0,
      payment-defaults: u0,
      account-creation-block: block-height,
      kyc-status: false
    }
    (map-get? client-profiles tx-sender))))
    
    (map-set client-profiles tx-sender
      (merge current-profile {
        total-services-requested: (+ (get total-services-requested current-profile) u1),
        total-amount-spent: (+ (get total-amount-spent current-profile) amount)
      })
    )
    (ok true)
  )
)

(define-private (update-provider-stats (provider principal) (service-id uint))
  (let ((current-profile (map-get? skill-provider-profiles provider)))
    (match current-profile
      profile
      (let ((escrow-info (map-get? payment-escrow-system service-id)))
        (match escrow-info
          escrow
          (begin
            (map-set skill-provider-profiles provider
              (merge profile {
                total-services-completed: (+ (get total-services-completed profile) u1),
                total-earnings: (+ (get total-earnings profile) (get provider-payout-amount escrow))
              })
            )
            (ok true)
          )
          (ok false)
        )
      )
      (ok false)
    )
  )
)

(define-private (update-provider-rating (provider principal) (new-rating uint))
  (let ((current-profile (map-get? skill-provider-profiles provider)))
    (match current-profile
      profile
      (let 
        (
          (total-rating-points (* (get current-rating profile) (get rating-count profile)))
          (new-rating-count (+ (get rating-count profile) u1))
          (new-average-rating (/ (+ total-rating-points new-rating) new-rating-count))
        )
        (map-set skill-provider-profiles provider
          (merge profile {
            current-rating: new-average-rating,
            rating-count: new-rating-count
          })
        )
        (ok true)
      )
      (ok false)
    )
  )
)

;; INITIALIZE SERVICE SUGGESTION QUOTA
(define-public (initialize-service-suggestion-quota (service-id uint))
  (let 
    (
      (service-info (unwrap! (map-get? service-requests service-id) (err u101)))
      (ai-status (unwrap! (map-get? ai-suggestion-status service-id) (err u101)))
    )
    (asserts! (is-eq tx-sender (var-get oracle-contract)) (err u100))
    (asserts! (get suggestions-requested ai-status) (err u102))
    (asserts! (not (get suggestions-generated ai-status)) (err u104))
    
    ;; Calculate quotas: 30% new providers, 70% experienced
    (let 
      (
        (total-target MAX-TOTAL-SUGGESTIONS)
        (calculated-new-provider-target (/ (* total-target NEW-PROVIDER-QUOTA-PERCENTAGE) u100))
        (new-provider-target (get-max calculated-new-provider-target MIN-NEW-PROVIDER-SUGGESTIONS))
        (experienced-target (- total-target new-provider-target))
      )
      
      (map-set service-suggestion-quotas service-id
        {
          total-suggestions-target: total-target,
          new-provider-suggestions-target: new-provider-target,
          experienced-provider-suggestions-target: experienced-target,
          new-provider-suggestions-made: u0,
          experienced-provider-suggestions-made: u0,
          quota-fulfilled: false
        }
      )
      
      (print {
        type: "suggestion-quota-initialized",
        service-id: service-id,
        new-provider-quota: new-provider-target,
        experienced-provider-quota: experienced-target,
        total-quota: total-target,
        block: block-height
      })
      
      (ok {
        new-provider-slots: new-provider-target,
        experienced-slots: experienced-target
      })
    )
  )
)

;; QUOTA-AWARE AI SUGGESTION FOR EXPERIENCED PROVIDERS
(define-public (create-experienced-provider-suggestion
  (service-id uint)
  (suggested-provider principal)
  (estimated-timeline uint)
  (success-probability uint)
  (risk-factors (list 10 (string-ascii 50)))
  (recommended-adjustments (string-ascii 300))
  (initial-skill-score uint)
)
  (let 
    (
      (service-info (unwrap! (map-get? service-requests service-id) (err u101)))
      (provider-profile (unwrap! (map-get? skill-provider-profiles suggested-provider) (err u105)))
      (current-app-count (default-to u0 (map-get? service-application-count service-id)))
      (ai-status (unwrap! (map-get? ai-suggestion-status service-id) (err u101)))
      (quota-info (unwrap! (map-get? service-suggestion-quotas service-id) (err u101)))
    )
    ;; Input validation
    (asserts! (is-eq tx-sender (var-get oracle-contract)) (err u100))
    (asserts! (is-eq (get current-status service-info) u0) (err u102))
    (asserts! (< block-height (get application-deadline service-info)) (err u106))
    (asserts! (is-eq (get verification-status provider-profile) u1) (err u105))
    (asserts! (get suggestions-requested ai-status) (err u102))
    (asserts! (< current-app-count MAX-APPLICATIONS-PER-SERVICE) (err u117))
    (asserts! (not (is-eq suggested-provider (get client-address service-info))) (err u100))
    (asserts! (is-none (map-get? service-applications { service-id: service-id, provider: suggested-provider })) (err u104))
    
    ;; Validate untrusted inputs
    (asserts! (is-valid-principal suggested-provider) (err u117))
    (asserts! (is-valid-timeline estimated-timeline) (err u117))
    (asserts! (is-valid-probability success-probability) (err u117))
    (asserts! (is-valid-skill-score initial-skill-score) (err u117))
    (asserts! (is-valid-risk-factors risk-factors) (err u117))
    (asserts! (is-valid-adjustments recommended-adjustments) (err u117))
    
    ;; CHECK EXPERIENCED PROVIDER QUOTA
    (asserts! (< (get experienced-provider-suggestions-made quota-info) 
                 (get experienced-provider-suggestions-target quota-info)) (err u133))
    
    ;; EXPERIENCED PROVIDER THRESHOLD (80%)
    (asserts! (>= success-probability MIN-SUCCESS-PROBABILITY) (err u132))
    
    ;; Ensure this is NOT a new provider
    (asserts! (is-none (map-get? new-provider-trials suggested-provider)) (err u134))
    
    ;; Store success prediction
    (map-set project-success-predictions service-id
      {
        success-probability: success-probability,
        risk-factors: risk-factors,
        recommended-adjustments: recommended-adjustments,
        prediction-timestamp: block-height,
        confidence-score: u90
      }
    )
    
    ;; Store competency assessment
    (map-set competency-assessments { service-id: service-id, provider: suggested-provider }
      {
        initial-skill-score: initial-skill-score,
        demonstrated-competency: initial-skill-score,
        competency-verified: false,
        price-adjustment-factor: u10000,
        assessment-timestamp: block-height,
        verification-evidence: none
      }
    )
    
    ;; Create application
    (map-set service-applications 
      { service-id: service-id, provider: suggested-provider }
      {
        application-message: "EXPERIENCED PROVIDER: High success rate with proven track record",
        proposed-timeline: estimated-timeline,
        proposed-price: none,
        portfolio-links: (list "" "" "" "" ""),
        application-timestamp: block-height,
        application-status: u0,
        estimated-delivery: (+ block-height estimated-timeline),
        provider-questions: none,
        is-ai-suggested: true
      }
    )
    
    ;; Update quotas and counters
    (map-set service-suggestion-quotas service-id
      (merge quota-info {
        experienced-provider-suggestions-made: (+ (get experienced-provider-suggestions-made quota-info) u1)
      })
    )
    
    (map-set service-application-count service-id (+ current-app-count u1))
    (map-set ai-suggestion-status service-id
      (merge ai-status {
        suggestion-count: (+ (get suggestion-count ai-status) u1)
      })
    )
    
    (map-set skill-provider-profiles suggested-provider
      (merge provider-profile {
        active-applications: (+ (get active-applications provider-profile) u1)
      })
    )
    
    (print {
      type: "experienced-provider-suggested",
      service-id: service-id,
      suggested-provider: suggested-provider,
      success-probability: success-probability,
      initial-skill-score: initial-skill-score,
      quota-slot: "experienced",
      experienced-suggestions-made: (+ (get experienced-provider-suggestions-made quota-info) u1),
      block: block-height
    })
    
    (ok true)
  )
)

;; NEW PROVIDER ONBOARDING SYSTEM (SIMPLIFIED)
(define-public (start-new-provider-onboarding
  (skills-to-verify (list 5 (string-ascii 50)))
  (portfolio-links (list 5 (string-ascii 200)))
  (external-verifications (list 3 (string-ascii 300))) ;; GitHub, LinkedIn, etc.
)
  (let ((provider-profile (map-get? skill-provider-profiles tx-sender)))
    (asserts! (is-some provider-profile) (err u105)) ;; Must have basic profile
    (asserts! (and (> (len skills-to-verify) u0) (<= (len skills-to-verify) u5)) (err u117))
    
    ;; Initialize new provider trial system
    (map-set new-provider-trials tx-sender
      {
        trial-projects-completed: u0,
        trial-success-rate: u0,
        skill-verification-score: u0,
        portfolio-verification-score: u0,
        external-verification-score: u0,
        trial-period-active: true,
        trial-start-block: block-height
      }
    )
    
    (print {
      type: "new-provider-onboarding-started",
      provider: tx-sender,
      skills-to-verify: skills-to-verify,
      portfolio-count: (len portfolio-links),
      external-verifications: external-verifications,
      block: block-height
    })
    
    (ok true)
  )
)

;; AI GIVES SIMPLE SKILL BOOST (Optional)
(define-public (give-skill-verification-boost
  (provider principal)
  (skill (string-ascii 50))
  (boost-amount uint) ;; 5-25 point boost
)
  (let 
    (
      (challenge (map-get? skill-verification-challenges { provider: provider, skill: skill }))
      (trial-data (unwrap! (map-get? new-provider-trials provider) (err u101)))
    )
    (asserts! (is-eq tx-sender (var-get oracle-contract)) (err u100))
    (asserts! (is-some challenge) (err u101))
    
    ;; Validate untrusted inputs
    (asserts! (is-valid-principal provider) (err u117))
    (asserts! (is-valid-string skill u1 u50) (err u117))
    (asserts! (is-valid-boost-amount boost-amount) (err u117))
    
    (match challenge
      challenge-data
      (begin
        ;; Update challenge status
        (map-set skill-verification-challenges { provider: provider, skill: skill }
          (merge challenge-data {
            ai-assessment-score: (some boost-amount),
            verification-status: u1, ;; passed
            completion-timestamp: (some block-height)
          })
        )
        
        ;; Give skill boost to provider
        (let ((current-score (get skill-verification-score trial-data)))
          (map-set new-provider-trials provider
            (merge trial-data {
              skill-verification-score: (+ current-score boost-amount)
            })
          )
        )
        
        (print {
          type: "optional-skill-boost-given",
          provider: provider,
          skill: skill,
          boost-amount: boost-amount,
          new-total-score: (+ (get skill-verification-score trial-data) boost-amount),
          block: block-height
        })
        
        (ok boost-amount)
      )
      (err u101)
    )
  )
)

;; CREATE PROVIDER PROFILE
(define-public (create-provider-profile (initial-skills (list 15 (string-ascii 50))))
  (let ((skills-len (len initial-skills)))
    (asserts! (and (> skills-len u0) (<= skills-len u15)) (err u117))
    (asserts! (is-none (map-get? skill-provider-profiles tx-sender)) (err u104))
    
    (map-set skill-provider-profiles tx-sender
      {
        verified-skills: initial-skills,
        verification-status: u0,
        verification-timestamp: u0,
        total-services-completed: u0,
        total-earnings: u0,
        current-rating: u0,
        rating-count: u0,
        profile-creation-block: block-height,
        kyc-verified: false,
        response-rate: u100,
        avg-delivery-time: u360,
        active-applications: u0
      }
    )
    
    (ok true)
  )
)

(define-public (update-provider-verification-status
  (provider principal)
  (approved bool)
)
  (let ((current-profile (unwrap! (map-get? skill-provider-profiles provider) (err u101))))
    (asserts! (not (is-eq provider tx-sender)) (err u117))
    (asserts! (is-eq tx-sender (var-get oracle-contract)) (err u100))
    
    (map-set skill-provider-profiles provider
      (merge current-profile {
        verification-status: (if approved u1 u2),
        verification-timestamp: block-height
      })
    )
    
    (ok approved)
  )
)

;; DISPUTE RESOLUTION
(define-public (initiate-dispute (service-id uint) (reason (string-ascii 200)))
  (let ((service-info (unwrap! (map-get? service-requests service-id) (err u101))))
    (asserts! (is-valid-string reason u1 u200) (err u117))
    (asserts! (or 
      (is-eq tx-sender (get client-address service-info))
      (is-eq tx-sender (unwrap-panic (get provider-address service-info)))
    ) (err u100))
    (asserts! (is-eq (get current-status service-info) u2) (err u102))
    
    (map-set service-requests service-id
      (merge service-info { current-status: u4 })
    )
    
    (ok true)
  )
)

(define-public (resolve-dispute
  (service-id uint)
  (favor-client bool)
  (refund-percentage uint)
)
  (let 
    (
      (service-info (unwrap! (map-get? service-requests service-id) (err u101)))
      (escrow-info (unwrap! (map-get? payment-escrow-system service-id) (err u101)))
    )
    (asserts! (<= refund-percentage u100) (err u110))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u108))
    (asserts! (is-eq (get current-status service-info) u4) (err u102))
    
    (let 
      (
        (total-amount (get total-escrowed-amount escrow-info))
        (refund-amount (/ (* total-amount refund-percentage) u100))
        (provider-amount (- total-amount refund-amount))
      )
      (if favor-client
        (begin
          (try! (as-contract (stx-transfer? refund-amount tx-sender (get client-address service-info))))
          (try! (as-contract (stx-transfer? provider-amount tx-sender (unwrap-panic (get provider-address service-info)))))
        )
        (begin
          (try! (as-contract (stx-transfer? refund-amount tx-sender (get client-address service-info))))
          (try! (as-contract (stx-transfer? provider-amount tx-sender (unwrap-panic (get provider-address service-info)))))
        )
      )
      
      (map-set service-requests service-id
        (merge service-info { current-status: u3 })
      )
      
      (map-set payment-escrow-system service-id
        (merge escrow-info { funds-locked-status: false })
      )
      
      (ok true)
    )
  )
)

;; READ-ONLY FUNCTIONS
(define-read-only (get-service-request (service-id uint))
  (map-get? service-requests service-id)
)

(define-read-only (get-service-with-applications (service-id uint))
  (let ((service (map-get? service-requests service-id)))
    (match service
      service-data
      (ok {
        service: service-data,
        application-count: (default-to u0 (map-get? service-application-count service-id)),
        ai-status: (map-get? ai-suggestion-status service-id),
        applications-open: (< block-height (get application-deadline service-data)),
        selection-required: (get client-selection-required service-data)
      })
      (err u101)
    )
  )
)

(define-read-only (get-provider-application (service-id uint) (provider principal))
  (map-get? service-applications { service-id: service-id, provider: provider })
)

(define-read-only (get-application-count (service-id uint))
  (default-to u0 (map-get? service-application-count service-id))
)

(define-read-only (get-provider-applications (provider principal))
  (default-to (list) (map-get? provider-applications provider))
)

(define-read-only (get-skill-provider-profile (provider principal))
  (map-get? skill-provider-profiles provider)
)

(define-read-only (get-enhanced-provider-profile (provider principal))
  (let ((profile (map-get? skill-provider-profiles provider)))
    (match profile
      profile-data
      (ok {
        profile: profile-data,
        active-applications: (get active-applications profile-data),
        rating-display: (/ (get current-rating profile-data) u10),
        experience-level: (if (< (get total-services-completed profile-data) u5)
          "Beginner"
          (if (< (get total-services-completed profile-data) u20)
            "Intermediate" 
            "Expert"))
      })
      (err u101)
    )
  )
)

(define-read-only (get-client-profile (client principal))
  (map-get? client-profiles client)
)

(define-read-only (get-escrow-details (service-id uint))
  (map-get? payment-escrow-system service-id)
)

(define-read-only (get-ai-suggestion-status (service-id uint))
  (map-get? ai-suggestion-status service-id)
)

(define-read-only (get-platform-stats)
  {
    total-services: (- (var-get next-service-id) u1),
    platform-active: (var-get platform-active),
    emergency-mode: (var-get emergency-mode),
    minimum-service-amount: (var-get minimum-service-amount),
    platform-fee-rate: PLATFORM-FEE-RATE,
    primary-currency: "STX",
    selection-model: "ai-predicted-success-with-dynamic-pricing",
    native-blockchain: "Stacks",
    payment-model: "stx-escrow-with-competency-adjustments",
    min-success-threshold: MIN-SUCCESS-PROBABILITY,
    dynamic-pricing-enabled: true
  }
)

(define-read-only (get-stx-platform-info)
  {
    required-token: "STX (Stacks)",
    minimum-balance-for-jobs: (var-get minimum-service-amount),
    platform-fee: "2.5%",
    native-currency: true,
    blockchain: "Stacks",
    benefits: (list 
      "Native STX tokens - no wrapping required"
      "Direct wallet integration"
      "Fast transaction settlement"
      "Built-in escrow protection"
      "AI-predicted success matching (80%+ only)"
      "Dynamic pricing based on real competency"
      "Performance-based payment adjustments"
    )
  }
)

;; ADMIN FUNCTIONS
(define-public (set-oracle-contract (oracle-addr principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u108))
    (asserts! (is-valid-principal oracle-addr) (err u117))
    (var-set oracle-contract oracle-addr)
    (ok oracle-addr)
  )
)

(define-public (set-platform-active (active bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u108))
    (var-set platform-active active)
    (ok active)
  )
)

(define-public (set-emergency-mode (emergency bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u108))
    (var-set emergency-mode emergency)
    (ok emergency)
  )
)

(define-public (set-minimum-service-amount (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u108))
    (asserts! (> amount u0) (err u110))
    (asserts! (<= amount u100000000) (err u110))
    (var-set minimum-service-amount amount)
    (ok amount)
  )
)

(define-public (set-treasury-address (treasury principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u108))
    (asserts! (is-valid-principal treasury) (err u117))
    (var-set platform-treasury treasury)
    (ok treasury)
  )
)

;; EMERGENCY FUNCTIONS
(define-public (emergency-service-cancel (service-id uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u108))
    (asserts! (and (> service-id u0) (< service-id (var-get next-service-id))) (err u117))
    (asserts! (var-get emergency-mode) (err u100))
    
    (let 
      (
        (service-info (unwrap! (map-get? service-requests service-id) (err u101)))
        (escrow-info (unwrap! (map-get? payment-escrow-system service-id) (err u101)))
      )
      (try! (as-contract (stx-transfer? 
        (get total-escrowed-amount escrow-info) tx-sender (get client-address service-info))))
      
      (map-set service-requests service-id
        (merge service-info { current-status: u5 })
      )
      
      (map-set payment-escrow-system service-id
        (merge escrow-info { funds-locked-status: false })
      )
      
      (ok true)
    )
  )
)

(define-public (emergency-pause)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u118))
    (var-set platform-active false)
    (var-set emergency-mode true)
    (ok true)
  )
)