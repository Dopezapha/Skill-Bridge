;; constants.clar
;; Shared constants for the SkillFlow platform

;; Platform fee constants
(define-constant PLATFORM-FEE-RATE u250) ;; 2.5%
(define-constant BASIS-POINTS u10000)

;; Timing constants (in blocks)
;; Using two-step completion instead
(define-constant DISPUTE-WINDOW-BLOCKS u2880) ;; ~20 days
(define-constant BLOCKS-PER-DAY u144) ;; Approximate blocks per day

;; Amount limits
(define-constant MIN-STX-BALANCE u1000000) ;; 1 STX minimum
(define-constant MIN-SBTC-ESCROW u100000) ;; 0.001 sBTC minimum
(define-constant JOB-CREATION-FEE-STX u1000000) ;; 1 STX to create job
(define-constant MAX-SBTC-AMOUNT u100000000000) ;; 1000 sBTC maximum

;; Error constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-INVALID-STATE (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-DUPLICATE (err u104))
(define-constant ERR-EXPIRED (err u106))
(define-constant ERR-INVALID-AMOUNT (err u110))
(define-constant ERR-INVALID-INPUT (err u117))
(define-constant ERR-INSUFFICIENT-BALANCE (err u120))

;; Status constants
(define-constant STATUS-ACTIVE u0)
(define-constant STATUS-COMPLETED u1)
(define-constant STATUS-DISPUTED u2)
(define-constant STATUS-CANCELLED u3)

;; Special addresses to exclude
(define-constant ZERO-ADDRESS 'SP000000000000000000002Q6VF78)

;; Platform info
(define-constant PLATFORM-NAME "SkillFlow")
(define-constant PLATFORM-VERSION "1.2.0") ;; Two-step completion
(define-constant PLATFORM-DESCRIPTION "Bitcoin-native freelancing platform with two-step completion process")

;; Read-only functions for external access
(define-read-only (get-platform-fee-rate)
  PLATFORM-FEE-RATE
)

(define-read-only (get-timing-constants)
  {
    dispute-window-blocks: DISPUTE-WINDOW-BLOCKS,
    blocks-per-day: BLOCKS-PER-DAY,
    auto-release-enabled: false,
    completion-process: "two-step-confirmation"
  }
)

(define-read-only (get-amount-limits)
  {
    min-stx-balance: MIN-STX-BALANCE,
    min-sbtc-escrow: MIN-SBTC-ESCROW,
    job-creation-fee: JOB-CREATION-FEE-STX,
    max-sbtc-amount: MAX-SBTC-AMOUNT
  }
)

(define-read-only (get-platform-info)
  {
    name: PLATFORM-NAME,
    version: PLATFORM-VERSION,
    description: PLATFORM-DESCRIPTION,
    fee-rate: PLATFORM-FEE-RATE,
    completion-process: {
      type: "two-step-confirmation",
      step1: "Freelancer marks job completed",
      step2: "Client confirms completion",
      step3: "Payment automatically released"
    },
    currencies: {
      platform-fee: "STX",
      payments: "sBTC"
    },
    escrow-features: {
      auto-release: false,
      two-step-completion: true,
      dispute-resolution: true,
      admin-cancellation: true
    }
  }
)