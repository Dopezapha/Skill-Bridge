;; sbtc-moc.clar
;; Mock sBTC contract for local testing
;; This simulates the real sBTC contract for Clarinet testing

;; Import SIP-010 trait
(impl-trait .sip010-trait.sip010-trait)

;; Token balances
(define-map balances principal uint)

;; Total supply
(define-data-var total-supply uint u0)

;; Contract owner for mint function
(define-constant CONTRACT-OWNER tx-sender)

;; Error constants
(define-constant ERR-INSUFFICIENT-BALANCE (err u1))
(define-constant ERR-INVALID-RECIPIENT (err u2))
(define-constant ERR-INVALID-AMOUNT (err u110))
(define-constant ERR-INVALID-PRINCIPAL (err u117))
(define-constant ERR-UNAUTHORIZED (err u100))

;; Initialize with test balances for development
(map-set balances 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u100000000) ;; 1 sBTC
(map-set balances 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5 u50000000)  ;; 0.5 sBTC
(map-set balances 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG u200000000) ;; 2 sBTC
(map-set balances 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC u300000000) ;; 3 sBTC
(var-set total-supply u650000000) ;; 6.5 sBTC total

;; Validation functions
(define-private (is-valid-principal (addr principal))
  (not (is-eq addr 'SP000000000000000000002Q6VF78))
)

(define-private (is-valid-amount (amount uint))
  (and (> amount u0) (<= amount u100000000000)) ;; Max 1000 sBTC
)

;; SIP-010 compliant transfer function
(define-public (transfer
  (amount uint)
  (sender principal)
  (recipient principal)
  (memo (optional (buff 34)))
)
  (let
    (
      (sender-balance (default-to u0 (map-get? balances sender)))
      (recipient-balance (default-to u0 (map-get? balances recipient)))
    )
    ;; Input validation
    (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
    (asserts! (is-valid-principal sender) ERR-INVALID-PRINCIPAL)
    (asserts! (is-valid-principal recipient) ERR-INVALID-PRINCIPAL)
    (asserts! (not (is-eq sender recipient)) ERR-INVALID-RECIPIENT)
    
    ;; Authorization check - sender must be tx-sender or contract-caller
    (asserts! (or (is-eq tx-sender sender) (is-eq contract-caller sender)) ERR-UNAUTHORIZED)
    
    ;; Check sender has enough balance
    (asserts! (>= sender-balance amount) ERR-INSUFFICIENT-BALANCE)
    
    ;; Update balances
    (map-set balances sender (- sender-balance amount))
    (map-set balances recipient (+ recipient-balance amount))
    
    (print {
      type: "sbtc-transfer",
      amount: amount,
      sender: sender,
      recipient: recipient,
      sender-new-balance: (- sender-balance amount),
      recipient-new-balance: (+ recipient-balance amount)
    })
    
    (ok true)
  )
)

;; Get balance function
(define-read-only (get-balance (account principal))
  (ok (default-to u0 (map-get? balances account)))
)

;; SIP-010 standard functions
(define-read-only (get-name)
  (ok "sBTC Mock")
)

(define-read-only (get-symbol)
  (ok "sBTC")
)

(define-read-only (get-decimals)
  (ok u8)
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

;; Get-token-uri to match trait signature exactly
(define-read-only (get-token-uri)
  (ok none)
)

;; Mint function for testing (not in real sBTC)
(define-public (mint (amount uint) (recipient principal))
  (let ((current-balance (default-to u0 (map-get? balances recipient))))
    ;; Input validation
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
    (asserts! (is-valid-principal recipient) ERR-INVALID-PRINCIPAL)
    
    ;; Update balance and supply
    (map-set balances recipient (+ current-balance amount))
    (var-set total-supply (+ (var-get total-supply) amount))
    
    (print {
      type: "sbtc-mint",
      amount: amount,
      recipient: recipient,
      new-balance: (+ current-balance amount),
      new-total-supply: (var-get total-supply)
    })
    
    (ok true)
  )
)

;; Burn function for testing (not in real sBTC)
(define-public (burn (amount uint) (owner principal))
  (let ((current-balance (default-to u0 (map-get? balances owner))))
    ;; Input validation
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
    (asserts! (is-valid-principal owner) ERR-INVALID-PRINCIPAL)
    (asserts! (>= current-balance amount) ERR-INSUFFICIENT-BALANCE)
    
    ;; Update balance and supply
    (map-set balances owner (- current-balance amount))
    (var-set total-supply (- (var-get total-supply) amount))
    
    (print {
      type: "sbtc-burn",
      amount: amount,
      owner: owner,
      new-balance: (- current-balance amount),
      new-total-supply: (var-get total-supply)
    })
    
    (ok true)
  )
)

;; Get multiple balances for efficiency
(define-read-only (get-balances (accounts (list 10 principal)))
  (map get-balance-internal accounts)
)

(define-private (get-balance-internal (account principal))
  {
    account: account,
    balance: (default-to u0 (map-get? balances account))
  }
)

;; Check if user meets minimum balance requirements
(define-read-only (meets-minimum-balance (account principal) (minimum uint))
  (let ((balance (default-to u0 (map-get? balances account))))
    {
      account: account,
      balance: balance,
      minimum-required: minimum,
      meets-requirement: (>= balance minimum),
      shortfall: (if (>= balance minimum) u0 (- minimum balance))
    }
  )
)

;; Contract info for integration
(define-read-only (get-contract-info)
  {
    name: "sBTC Mock Contract",
    symbol: "sBTC",
    decimals: u8,
    total-supply: (var-get total-supply),
    purpose: "Local testing and development",
    sip010-compliant: true,
    test-accounts-funded: true
  }
)