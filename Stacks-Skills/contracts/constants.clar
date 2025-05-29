;; constants.clar
;; SkillFlow Platform Core Constants
;; Core platform configuration and business logic constants

;; Contract deployer (will be set to actual deployer address)
(define-constant CONTRACT-DEPLOYER tx-sender)

;; Platform configuration
(define-constant PLATFORM-FEE-RATE u250) ;; 2.5% = 250/10000
(define-constant BASIS-POINTS u10000)
(define-constant MINIMUM-LIQUIDITY u1000)

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

;; STX-specific constants
(define-constant STX-DECIMALS u6) ;; STX uses 6 decimals (microSTX)
(define-constant MIN-STX-AMOUNT u1000000) ;; 1 STX minimum
(define-constant MAX-STX-AMOUNT u100000000000) ;; 100K STX maximum

;; Public functions to access core constants
(define-read-only (get-platform-fee-rate) PLATFORM-FEE-RATE)
(define-read-only (get-basis-points) BASIS-POINTS)

;; Status constants as public read-only functions
(define-read-only (get-service-status-open) SERVICE-STATUS-OPEN)
(define-read-only (get-service-status-matched) SERVICE-STATUS-MATCHED)
(define-read-only (get-service-status-in-progress) SERVICE-STATUS-IN-PROGRESS)
(define-read-only (get-service-status-completed) SERVICE-STATUS-COMPLETED)
(define-read-only (get-service-status-disputed) SERVICE-STATUS-DISPUTED)
(define-read-only (get-service-status-cancelled) SERVICE-STATUS-CANCELLED)

(define-read-only (get-min-rating) MIN-RATING)
(define-read-only (get-max-rating) MAX-RATING)

;; STX-specific getters
(define-read-only (get-stx-decimals) STX-DECIMALS)
(define-read-only (get-min-stx-amount) MIN-STX-AMOUNT)
(define-read-only (get-max-stx-amount) MAX-STX-AMOUNT)

;; Platform information
(define-read-only (get-platform-info)
  {
    primary-token: "STX",
    supported-tokens: (list "STX" "USDT" "USDC"),
    platform-fee-rate: PLATFORM-FEE-RATE,
    min-service-amount: MIN-STX-AMOUNT,
    trustless-model: true,
    native-currency: true
  }
)