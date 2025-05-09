;; contracts/counter.clar

;; A simple counter contract with extended functionality.

;; Define a map data structure from principal → uint
(define-map counters principal uint)

;; Read-only function to get the current count for any principal
(define-read-only (get-count (who principal))
  (default-to u0 (map-get? counters who))
)

;; Public function: increment the caller’s count by 1
(define-public (count-up)
  (ok
    (map-set
      counters
      tx-sender
      (+ (get-count tx-sender) u1)))
)

;; Public function: decrement the caller’s count by 1 (floor at 0)
(define-public (count-down)
  (let ((current (get-count tx-sender)))
    (ok
      (map-set
        counters
        tx-sender
        (if (>= current u1)
            (- current u1)
            u0)))))
)

;; Public function: reset the caller’s count to 0
(define-public (reset-count)
  (ok
    (map-set
      counters
      tx-sender
      u0))
)

;; Public function: increment the caller’s count by an arbitrary amount
(define-public (count-up-by (amount uint))
  (ok
    (map-set
      counters
      tx-sender
      (+ (get-count tx-sender) amount)))
)

;; Public function: set the caller’s count to a specific value
(define-public (set-count (value uint))
  (ok
    (map-set
      counters
      tx-sender
      value))
)

;; Public function: transfer part of your count to another principal
(define-public (transfer-count (to principal) (amount uint))
  (let ((my-count (get-count tx-sender)))
    (if (>= my-count amount)
        (begin
          ;; deduct from sender
          (map-set counters tx-sender (- my-count amount))
          ;; credit to recipient
          (map-set counters to (+ (get-count to) amount))
          (ok true))
        (err u1) ;; error code u1 = insufficient balance
  ))
)
