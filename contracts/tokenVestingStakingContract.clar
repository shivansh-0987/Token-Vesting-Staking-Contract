(define-map vested-tokens
  {user: principal}
  {total: uint, claimed: uint})

(define-data-var reward-pool uint u10000)

(define-constant err-nothing-to-claim (err u102))

;; Deposit vested tokens for a user
(define-public (add-vesting (beneficiary principal) (amount uint))
  (begin
    (asserts! (> amount u0) (err u100))
    (map-set vested-tokens {user: beneficiary}
             {total: amount, claimed: u0})
    (ok true)))

;; Claim vested tokens (full claim here)
(define-public (claim-vested)
  (let ((entry (map-get? vested-tokens {user: tx-sender})))
    (match entry vest
      (let (
        (claimable (- (get total vest) (get claimed vest)))
      )
        (asserts! (> claimable u0) err-nothing-to-claim)
        (try! (stx-transfer? claimable (as-contract tx-sender) tx-sender))
        (map-set vested-tokens {user: tx-sender}
                 {total: (get total vest), claimed: (+ (get claimed vest) claimable)})
        (ok claimable))
      err-nothing-to-claim)))

;; Check user's vesting status
(define-read-only (check-vesting)
  (let ((entry (map-get? vested-tokens {user: tx-sender})))
    (ok entry)))
