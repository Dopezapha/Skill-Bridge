;; sip-010-trait.clar
;; This is the standard template for creating fungible tokens on the Stacks blockchain
;; Think of it like a checklist of functions every token needs to have

(define-trait sip-010-trait
  (
    ;; Moves tokens from one wallet to another
    ;; Takes: amount, from-wallet, to-wallet, and optional memo
    ;; Returns: success/failure message
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    
    ;; Gets the full name of the token (like "Bitcoin" or "My Cool Token")
    ;; Returns: the token name as text
    (get-name () (response (string-ascii 32) uint))
    
    ;; Gets the short symbol for the token (like "BTC" or "MCT")
    ;; Returns: the symbol or nothing if there isn't one
    (get-symbol () (response (string-ascii 10) uint))
    
    ;; Shows how many decimal places the token uses
    ;; For example: if this returns 6, then 1,000,000 token units = 1 whole token
    (get-decimals () (response uint uint))
    
    ;; Checks how many tokens a specific wallet owns
    ;; Takes: wallet address
    ;; Returns: number of tokens they have
    (get-balance (principal) (response uint uint))
    
    ;; Shows the total number of tokens that exist right now
    ;; This number can change if tokens are minted or burned
    (get-total-supply () (response uint uint))
    
    ;; Provides a web link to more information about the token
    ;; This is optional - some tokens have it, others don't
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)