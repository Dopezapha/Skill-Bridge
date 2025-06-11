;; oracle.clar
;; SkillFlow Oracle Contract
;; Manages STX price feeds and AI verification services

;; Constants
(define-constant CONTRACT-OWNER tx-sender)

;; Data variables
(define-data-var price-oracle-operator principal tx-sender)
(define-data-var ai-oracle-operator principal tx-sender)
(define-data-var emergency-mode bool false)
(define-data-var next-verification-id uint u1)

;; Data maps
(define-map stx-price-data
  uint ;; timestamp or block height
  {
    price-usd: uint, ;; Price in micro-dollars (6 decimals)
    last-update: uint,
    source: (string-ascii 50),
    confidence: uint, ;; 0-100
    volatility-index: uint
  }
)

(define-map authorized-price-feeders
  principal
  bool
)

(define-map ai-verification-requests
  { provider: principal, request-id: uint }
  {
    skill-name: (string-ascii 50),
    video-hash: (string-ascii 200),
    submission-block: uint,
    ai-confidence: (optional uint),
    verification-status: uint, ;; 0: pending, 1: approved, 2: rejected
    review-notes: (optional (string-ascii 300))
  }
)

;; Current STX price storage
(define-data-var current-stx-price-usd uint u2000000) ;; Default $2.00
(define-data-var last-price-update uint u0)
(define-data-var price-confidence uint u90)

;; Enhanced validation functions
(define-private (is-valid-principal (addr principal))
  (not (is-eq addr 'ST000000000000000000002AMW42H)) ;; Not burn address
)

(define-private (is-valid-confidence (confidence uint))
  (<= confidence u100)
)

(define-private (is-valid-source (source (string-ascii 50)))
  (and (> (len source) u0) (<= (len source) u50))
)

(define-private (is-valid-skill-name (skill-name (string-ascii 50)))
  (and (> (len skill-name) u0) (<= (len skill-name) u50))
)

(define-private (is-valid-video-hash (video-hash (string-ascii 200)))
  (and (> (len video-hash) u0) (<= (len video-hash) u200))
)

(define-private (is-valid-review-notes (notes (optional (string-ascii 300))))
  (match notes
    some-notes (<= (len some-notes) u300)
    true
  )
)

(define-private (is-valid-volatility (volatility uint))
  (<= volatility u10000)
)

(define-private (is-valid-request-id (request-id uint))
  (and (> request-id u0) (< request-id (var-get next-verification-id)))
)

;; STX Price feed functions
(define-public (update-stx-price
  (price-usd uint)
  (source (string-ascii 50))
  (confidence uint)
  (volatility-index uint)
)
  (begin
    ;; Input validation
    (asserts! (or 
      (is-eq tx-sender (var-get price-oracle-operator))
      (default-to false (map-get? authorized-price-feeders tx-sender))
    ) (err u100))
    (asserts! (and (> price-usd u0) (<= price-usd u1000000000000)) (err u131))
    (asserts! (is-valid-source source) (err u117))
    (asserts! (is-valid-confidence confidence) (err u129))
    (asserts! (is-valid-volatility volatility-index) (err u117))
    
    ;; Store price history
    (map-set stx-price-data block-height
      {
        price-usd: price-usd,
        last-update: block-height,
        source: source,
        confidence: confidence,
        volatility-index: volatility-index
      }
    )
    
    ;; Update current price variables
    (var-set current-stx-price-usd price-usd)
    (var-set last-price-update block-height)
    (var-set price-confidence confidence)
    
    (print {
      type: "stx-price-update",
      price-usd: price-usd,
      source: source,
      confidence: confidence,
      volatility-index: volatility-index,
      block: block-height
    })
    
    (ok true)
  )
)

;; AI Verification functions
(define-public (submit-skill-verification
  (skill-name (string-ascii 50))
  (video-hash (string-ascii 200))
)
  (let ((request-id (var-get next-verification-id)))
    ;; Input validation
    (asserts! (is-valid-skill-name skill-name) (err u117))
    (asserts! (is-valid-video-hash video-hash) (err u117))
    
    (map-set ai-verification-requests
      { provider: tx-sender, request-id: request-id }
      {
        skill-name: skill-name,
        video-hash: video-hash,
        submission-block: block-height,
        ai-confidence: none,
        verification-status: u0, ;; pending
        review-notes: none
      }
    )
    
    (var-set next-verification-id (+ request-id u1))
    
    (print {
      type: "verification-submitted",
      provider: tx-sender,
      request-id: request-id,
      skill-name: skill-name,
      video-hash: video-hash,
      block: block-height
    })
    
    (ok request-id)
  )
)

(define-public (process-verification
  (provider principal)
  (request-id uint)
  (approved bool)
  (confidence uint)
  (review-notes (optional (string-ascii 300)))
)
  (let ((request (unwrap! (map-get? ai-verification-requests { provider: provider, request-id: request-id }) (err u101))))
    ;; Input validation
    (asserts! (is-eq tx-sender (var-get ai-oracle-operator)) (err u100))
    (asserts! (is-valid-principal provider) (err u117))
    (asserts! (is-valid-request-id request-id) (err u117))
    (asserts! (is-eq (get verification-status request) u0) (err u129)) ;; Must be pending
    (asserts! (is-valid-confidence confidence) (err u129))
    (asserts! (is-valid-review-notes review-notes) (err u117))
    
    (map-set ai-verification-requests { provider: provider, request-id: request-id }
      (merge request {
        ai-confidence: (some confidence),
        verification-status: (if approved u1 u2),
        review-notes: review-notes
      })
    )
    
    (print {
      type: "verification-processed",
      provider: provider,
      request-id: request-id,
      approved: approved,
      confidence: confidence,
      block: block-height
    })
    
    (ok approved)
  )
)

;; STX price utilities
(define-read-only (get-current-stx-price)
  (ok (var-get current-stx-price-usd))
)

(define-read-only (is-stx-price-stale)
  (ok (> (- block-height (var-get last-price-update)) u144))
)

(define-read-only (convert-stx-to-usd (stx-amount uint))
  (let ((stx-price (var-get current-stx-price-usd)))
    (ok (/ (* stx-amount stx-price) u1000000)) ;; Convert from microSTX to USD
  )
)

(define-read-only (convert-usd-to-stx (usd-amount uint))
  (let ((stx-price (var-get current-stx-price-usd)))
    (ok (/ (* usd-amount u1000000) stx-price)) ;; Convert from USD to microSTX
  )
)

(define-read-only (get-stx-price-with-confidence)
  (ok {
    price: (var-get current-stx-price-usd),
    confidence: (var-get price-confidence),
    last-update: (var-get last-price-update),
    is-stale: (> (- block-height (var-get last-price-update)) u144)
  })
)

;; Service integration functions
(define-read-only (estimate-service-cost-in-stx 
  (service-cost-usd uint)
  (include-platform-fee bool)
)
  (let 
    (
      (stx-price (var-get current-stx-price-usd))
      (base-stx-cost (/ (* service-cost-usd u1000000) stx-price))
      (platform-fee (if include-platform-fee (/ (* base-stx-cost u250) u10000) u0))
      (total-stx-cost (+ base-stx-cost platform-fee))
    )
    (ok {
      service-cost-usd: service-cost-usd,
      stx-price-usd: stx-price,
      base-stx-cost: base-stx-cost,
      platform-fee-stx: platform-fee,
      total-stx-cost: total-stx-cost,
      confidence: (var-get price-confidence)
    })
  )
)

(define-read-only (get-stx-value-in-usd (stx-amount uint))
  (let ((stx-price (var-get current-stx-price-usd)))
    (ok {
      stx-amount: stx-amount,
      stx-price-usd: stx-price,
      usd-value: (/ (* stx-amount stx-price) u1000000),
      last-update: (var-get last-price-update)
    })
  )
)

;; Verification queries
(define-read-only (get-verification-request (provider principal) (request-id uint))
  (map-get? ai-verification-requests { provider: provider, request-id: request-id })
)

(define-read-only (get-verification-status (provider principal) (request-id uint))
  (match (map-get? ai-verification-requests { provider: provider, request-id: request-id })
    request (ok (get verification-status request))
    (err u101)
  )
)

;; Price history functions
(define-read-only (get-historical-stx-price (target-block uint))
  (map-get? stx-price-data target-block)
)

(define-read-only (calculate-stx-price-change (blocks-ago uint))
  (let 
    (
      (current-price (var-get current-stx-price-usd))
      (historical-block (- block-height blocks-ago))
      (historical-data (map-get? stx-price-data historical-block))
    )
    (match historical-data
      price-data
      (let ((historical-price (get price-usd price-data)))
        (if (> historical-price u0)
          (ok {
            current-price: current-price,
            historical-price: historical-price,
            change-amount: (if (> current-price historical-price) 
              (- current-price historical-price)
              (- historical-price current-price)),
            change-percentage: (if (> current-price historical-price)
              (/ (* (- current-price historical-price) u10000) historical-price)
              (/ (* (- historical-price current-price) u10000) historical-price)),
            is-increase: (> current-price historical-price)
          })
          (err u131)
        )
      )
      (err u101)
    )
  )
)

;; Platform integration helpers
(define-read-only (calculate-dynamic-stx-fees 
  (base-stx-amount uint)
  (urgency-multiplier uint)
)
  (let 
    (
      (historical-data (map-get? stx-price-data (var-get last-price-update)))
      (volatility (match historical-data 
        data (get volatility-index data)
        u300)) ;; Default volatility
      (base-fee-rate u250) ;; 2.5%
      (volatility-adjustment (/ volatility u1000)) ;; Convert to basis points
      (urgency-adjustment (* urgency-multiplier u50)) ;; 0.5% per urgency level
      (total-fee-rate (+ base-fee-rate volatility-adjustment urgency-adjustment))
      (fee-amount (/ (* base-stx-amount total-fee-rate) u10000))
    )
    (ok {
      base-amount: base-stx-amount,
      base-fee-rate: base-fee-rate,
      volatility-adjustment: volatility-adjustment,
      urgency-adjustment: urgency-adjustment,
      total-fee-rate: total-fee-rate,
      fee-amount: fee-amount,
      total-cost: (+ base-stx-amount fee-amount)
    })
  )
)

;; Oracle health monitoring
(define-read-only (get-oracle-health)
  (let 
    (
      (last-update (var-get last-price-update))
      (current-block block-height)
      (blocks-since-update (- current-block last-update))
      (is-healthy (< blocks-since-update u72)) ;; Less than 12 hours
    )
    {
      oracle-status: (if is-healthy "healthy" "stale"),
      last-price-update: last-update,
      blocks-since-update: blocks-since-update,
      emergency-mode: (var-get emergency-mode),
      price-feeds-active: true,
      ai-verification-active: true,
      current-stx-price: (var-get current-stx-price-usd),
      confidence-level: (var-get price-confidence)
    }
  )
)

;; Admin functions
(define-public (set-price-oracle-operator (new-operator principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u118))
    (asserts! (is-valid-principal new-operator) (err u117))
    (var-set price-oracle-operator new-operator)
    (ok new-operator)
  )
)

(define-public (set-ai-oracle-operator (new-operator principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u118))
    (asserts! (is-valid-principal new-operator) (err u117))
    (var-set ai-oracle-operator new-operator)
    (ok new-operator)
  )
)

(define-public (authorize-price-feeder (feeder principal) (authorized bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u118))
    (asserts! (is-valid-principal feeder) (err u117))
    (map-set authorized-price-feeders feeder authorized)
    (ok authorized)
  )
)

(define-public (set-emergency-mode (emergency bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u118))
    (var-set emergency-mode emergency)
    (ok emergency)
  )
)

;; Emergency price update (only in emergency mode)
(define-public (emergency-stx-price-update (price-usd uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) (err u118))
    (asserts! (var-get emergency-mode) (err u100))
    (asserts! (and (> price-usd u0) (<= price-usd u1000000000000)) (err u131))
    
    (var-set current-stx-price-usd price-usd)
    (var-set last-price-update block-height)
    (var-set price-confidence u50)
    
    (print {
      type: "emergency-stx-price-update",
      price-usd: price-usd,
      block: block-height
    })
    
    (ok true)
  )
)

;; Utility functions
(define-read-only (get-oracle-info)
  {
    price-oracle-operator: (var-get price-oracle-operator),
    ai-oracle-operator: (var-get ai-oracle-operator),
    emergency-mode: (var-get emergency-mode),
    next-verification-id: (var-get next-verification-id),
    price-staleness-threshold: u144,
    primary-token: "STX",
    oracle-version: "1.0.0-stx-only",
    deployment-block: block-height
  }
)

(define-read-only (get-current-stx-data)
  {
    price-usd: (var-get current-stx-price-usd),
    last-update: (var-get last-price-update),
    confidence: (var-get price-confidence),
    is-stale: (> (- block-height (var-get last-price-update)) u144)
  }
)