;; constants.clar
;; SkillFlow Platform Constants
;; Shared constants across all SkillFlow contracts

;; Contract deployer (will be set to actual deployer address)
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
(define-constant ERR-NOT-TOKEN-OWNER (err u119))
(define-constant ERR-INSUFFICIENT-BALANCE (err u120))
(define-constant ERR-TRANSFER-FAILED (err u121))
(define-constant ERR-INVALID-RECIPIENT (err u124))
(define-constant ERR-INVALID-STATUS (err u128))
(define-constant ERR-INVALID-CONFIDENCE (err u129))
(define-constant ERR-STALE-PRICE (err u130))
(define-constant ERR-INVALID-PRICE (err u131))

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
(define-read-only (err-not-token-owner) ERR-NOT-TOKEN-OWNER)
(define-read-only (err-insufficient-balance) ERR-INSUFFICIENT-BALANCE)
(define-read-only (err-transfer-failed) ERR-TRANSFER-FAILED)
(define-read-only (err-invalid-recipient) ERR-INVALID-RECIPIENT)
(define-read-only (err-invalid-status) ERR-INVALID-STATUS)
(define-read-only (err-invalid-confidence) ERR-INVALID-CONFIDENCE)
(define-read-only (err-stale-price) ERR-STALE-PRICE)
(define-read-only (err-invalid-price) ERR-INVALID-PRICE)

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

;; Platform information
(define-read-only (get-platform-info)
  {
    primary-token: "STX",
    platform-fee-rate: PLATFORM-FEE-RATE,
    min-service-amount: MIN-STX-AMOUNT,
    native-currency: true,
    blockchain: "Stacks",
    token-standard: "Native STX"
  }
)