;; 1.1.3 Evaluating combinations
;;
;; To evaluate a combination:
;; 1. Evaluate the subexpressions of the combination
;; 2. Apply the procedure that is the value of the leftmost subexpression (the operator) to the arguments that are the values of the other subexpression (the operands).

(define (square x)
  (* x x))

(define (sq-sum x y)
  (+ (square x) (square y)))

;; If we call (sq-sum (+ a 1) (* a 2)) where a is 5 then:

;; "applicative order"

;; 1. (sq-sum (+ 5 1) (* 5 2)) replace parameter a by the argument 5
;; 2. (+ (square 6) (square 10)) evaluate operands and replace sq-sum with the body of the procedure sq-sum
;; 3. (+ (* 6 6) (* 10 10)) replace square with the body of the procedure square
;; 4. (+ 36 100)
;; 5. 136
;;
;; According to the description of evaluation given in section 1.1.3, the interpreter first evaluates the
;; operator and operands and then applies the resulting procedure to the resulting arguments.
;; An alternative evaluation model would not evaluate the operands
;; until their values were needed. Instead it would first substitute operand expressions for parameters
;; until it obtained an expression involving only primitive operators, and would then perform the
;; evaluation.
;;
;; "normal-order"

1. (sq-sum (+ 5 1) (* 5 2))
2. (+ (square (+ 5 1) square (* 5 2)))
3. (+ (* (+ 5 1) (+ 5 1)) (* (* 5 2) (* 5 2)))

;; And then reduction
;;
;; 4. (+ (* 6 6) (* 10 10))
;; 5. (+ 36 100)
;; 6. 136

;; This alternative "fully expand and then reduce" evaluation method is known as normal-order
;; evaluation.

;; In contrast to the "evaluate the arguments and then apply" method that the interpreter
;; actually uses, which is called applicative-order evaluation

;; Ex. 1.3

(define (square x)
    (* x x))

(define (sum-of-squares a b)
    (+ (square a) (square b)))


(define (sum-of-two-largest a b c)
    (cond ((and (< c a) (< c b)) (sum-of-squares a b))
          ((and (< a c) (< a b)) (sum-of-squares c b))
          ((and (< b c) (< b a)) (sum-of-squares a c))
          ((= a b) (sum-of-squares a c))
          ((= a c) (sum-of-squares a b))
          ((= b c) (sum-of-squares a c))
          ((= a b c) (sum-of-squares a b))
          (else "really?")
          )
    )

;; Alternative and more clear solution

(define (sq-sum-of-lg x y z)
  (if (> x y)
    (sum-of-squares y (if (> x z) x z))
    (sum-of-squares x (if (> y z) y z))))


;; Ex. 1.5

(define (p) (p))

(define (test x y)
    (if (= x 0)
        0
        y))

(test 0 (p))

;; In case of an applicative order we won't be able to evaluate operands because of recursive procedure "p"
;; With normal order first if will be evaluated

;; Ex. 1.6

(define (square x)
    (* x x))

;;(define (sqrt-iter guess x)
;;    (if (good-enough? guess x)
;;        guess
;;        (sqrt-iter (improve guess x) x)
;;        )
;;       )

(define (improve guess x)
    (average (/ x guess) guess)
    )

(define (average x y)
    (/ (+ x y) 2)
    )

;;(define (good-enough? guess x)
;;    (< (abs (- x (square guess))) 0.001)
;;    )

;;(define (sqrt x)
;;    (sqrt-iter 1.0 x))


(define (new-if predicate then-clause else-clause)
    (cond (predicate then-clause)
          (else else-clause))
    )


;; It'll be an infinite loop with new-if.
;; if is a special form, so it evaluates then-clause first
;; new-if is a procedure, it tries to evaluate all the arguments (and because of an applicative order it gets stuck in an infinite loop)

;; It will work if we put cond like this
(define (sqrt-iter1 guess x)
    (cond ((good-enough? guess x) guess)
        (else (sqrt-iter (improve guess x) x))
        )
       )


;; Ex. 1.7

(define (sqrt-iter previous-guess guess x)
    (if (good-enough? previous-guess guess x)
        guess
        (sqrt-iter previous-guess (improve guess x) x)
        )
       )

(define (good-enough? previous-guess guess x)
    (< (/ (abs (- previous-guess guess)) guess) 0.001)
    )

(define (sqrt x)
    (sqrt-iter 1.0 1.0 x))

;; Ex. 1.8

(define (cqrt-iter guess x)
    (if (cqrt-good-enough? guess x)
        guess
        (cqrt-iter (cqrt-improve guess x) x)
        )
       )

(define (cqrt-good-enough? guess x)
    (< (abs (- x (* guess guess guess))) 0.001)
    )

(define (cqrt-improve guess x)
    (cqrt-average (/ x (square guess)) (* 2 guess))
    )

(define (cqrt-average x y)
    (/ (+ x y) 3)
    )

(define (cqrt x)
    (cqrt-iter 1.0 x))

;; Ex. 1.9

;; (define (+ a b)
;;   (if (= a 0)
;;    b
;;    (inc (+ (dec a) b))))

;; 1. if (= 4 0)
;;     (inc (+ dec 4) 5)
;; 2. if (= 3 0)
;;     (inc (+ dec 3) 5)
;; 3. if (= 2 0)
;;     (inc (+ dec 2) 5)
;; 4. if (= 1 0)
;;     (inc (+ dec 1) 5)
;; 5. if (= 0 0)
;;     5

;; First one is recursive process, we need a stack to keep "save" the answers

;;(define (+ a b)
;;    (if (= a 0)
;;    b
;;    (+ (dec a) (inc b))))

;; 1. if (= 4 0)
;;     (+ (dec 4) (inc 5))
;; 2. if (= 3 0)
;;     (+ (dec 4) (inc 6))
;; 3. if (= 2 0)
;;     (+ (dec 4) (inc 7))
;; 4. if (= 1 0)
;;     (+ (dec 4) (inc 8))
;; 5. if (= 0 0)
;;     9

;; Second is iterative process, we always have the current state (on each step).

;; Ex. 1.10

;; (define (f n) (A 0 n)) ;; 2n
;; (define (g n) (A 1 n)) ;; 2^n
;; (define (h n) (A 2 n)) ;; 2^(A 1 (- n 1))

;; Ex. 1.11

(define (f n)
    (if (< n 3)
        n
        (+ (f (- n 1)) (f (- n 2)) (f (- n 3))))

(define (ff-iter a b c count)
    (if (= count 0)
        a
        (ff-iter b c (+ a b c) (- count 1)) ))

(define (ff n)
    (ff-iter 0 1 2 n))

;; Ex. 1.11 (eng)

(define (f-second n)
    (if (< n 3)
        n
        (+ (f-second (- n 1)) (* 2 (f-second (- n 2))) (* 3 (f-second (- n 3))))))

(define (ff-iter-second a b c count)
    (if (= count 0)
        a
        (ff-iter-second b (* 2 c) (+ a (* 2 b) (* 3 c)) (- count 1)) ))

(define (ff-second n)
    (ff-iter-second 0 1 2 n)) ;; Change iter nums


;; Ex. 1.12
(define (f row col)
    (if (or (= col 1) (= row col))
        1
        (+ (f (- row 1) (- col 1)) (f (- row 1) col)) ))

;; Ex. 1.15
;; (sine 12.15)
;; (p (sine 4.05))
;; (p (p (sine 1.35)))
;; (p (p (p (sine 0.45))))
;; (p (p (p (p (sine 0.15)))))
;; (p (p (p (p (p (sine 0.05))))))
;; (p (p (p (p (p 0.05)))))


;; Ex. 1.16
(define (fast-expt-iter a b n)
  (cond ((= n 0) a)
        ((even? n) (fast-expt-iter a (square b) (/ n 2)))
        (else (fast-expt-iter (* a b) b (- n 1)))))

(define (expt-iter b n)
  (fast-expt-iter 1 b n))

;; Ex. 1.17
(define (halve x)
  (/ x 2))

(define (double x)
  (* x 2))

(define (fast-mult a b)
  (cond ((= b 0) 0)
        ((even? b) (double (fast-mult a (halve b))))
        (else (+ a (fast-mult a (- b 1))))))

;; Ex. 1.18

(define (fast-mult-iter x a b)
  (cond ((= b 0) x)
        ((even? b) (fast-mult-iter x (double a) (halve b)))
        (else (fast-mult-iter (+ x a) (double a) (halve (- b 1))) )))

(define (mult-iter a b)
  (fast-mult-iter 0 a b))

;; Ex. 1.20

(define (gcd a b)
  (if (= b 0)
    a
    (gcd b (remainder a b))))

(gcd 206 40)

;; Applicative order
;; (gcd 40 (remainder 206 40))
;; (gcd 40 6)
;; (gcd 6 (reminder 40 6))
;; (gcd 6 4)
;; (gcd 4 (reminder 6 4))
;; (gcd 4 2)
;; (gcd 2 (reminder 4 2))
;; "reminder" called 4 times
;;
;; Normal order
;; 1. if (= 40 0)
;; (gcd 40 (reminder 206 40))
;; 2. if (= (reminder 206 40) 0)
;; (gcd (reminder 206 40) (reminder 40 (reminder 206 40))) ;; 1
;; 3. if (= (reminder 40 (reminder 206 40) 0) ;; 1 + 2
;; (gcd (reminder 40 (reminder 206 40)) (reminder (reminder 206 40) (reminder 40 (reminder 206 40))))
;; 4. if (= (reminder (reminder 206 40) (reminder 40 (reminder 206 40)))) ;; 3 + 4
;; And so on...

;; Ex. 1.21
(define (smallest-divisor n)
   (find-divisor n 2))

(define (find-divisor n test-divisor)
   (cond ((> (square test-divisor) n) n)
         ((divides? test-divisor n) test-divisor)
         (else (find-divisor n (+ test-divisor 1)))))

(define (divides? a b)
   (= (remainder b a) 0))

;; > (smallest-divisor 199)
;; 199
;; > (smallest-divisor 1999)
;; 1999
;; > (smallest-divisor 19999)
;; 7
   
;; Ex. 1.22

#lang sicp
(#%require (only racket/base random))

(define (square x)
  x * x)

(define (smallest-divisor n)
  (find-divisor n 2))

(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
        ((divides? test-divisor n) test-divisor)
        (else (find-divisor n (+ test-divisor 1)))))

(define (divides? a b)
  (= (remainder b a) 0))

(define (prime? n)
  (= n (smallest-divisor n)))

(define (timed-prime-test n)
  (newline)
  (display n)
  (start-prime-test n (runtime)))

(define (start-prime-test n start-time)
  (if (prime? n)
      (report-prime (- (runtime) start-time))))

(define (report-prime elapsed-time)
  (display " *** ")
  (display elapsed-time))

(define (search-for-primes number-from prime-count) 
  (if (> prime-count 0) 
      (if (timed-prime-test number-from) 
          (search-for-primes (+ number-from 1) (- prime-count 1)) 
          (search-for-primes (+ number-from 1) prime-count))))
          
 ;; Ex 1.23
 
 (define (next x) 
  (if (= x 2) 
      3 
      (+ x 2)))
      
(define (find-divisor n test-divisor) 
  (cond ((> (square test-divisor) n) n) 
        ((divides? test-divisor n) test-divisor) 
        (else (find-divisor n (next test-divisor)))))
        
 ;; Ex 1.27
 
 (define (square x) 
  (* x x))
 
 (define (expmod base exp m) 
  (cond ((= exp 0) 1) 
        ((even? exp) 
         (remainder (square (expmod base (/ exp 2) m)) 
                    m)) 
        (else 
         (remainder (* base (expmod base (- exp 1) m)) 
                    m))))

(define (carmichael-prime? n)
  (define (carmichael-prime-iter a)
    (cond ((= a 0) true)
          ((= (expmod a n n) a)) (carmichael-prime-iter (- a 1)))
          (else false)))


;; Ex 1.28

(define (expmod base exp m)  
  (cond ((= exp 0) 1)  
        ((even? exp)  
         (let ((tmp (expmod base (/ exp 2) m)))  
         (if (and (or (not (= tmp 1)) (not (= tmp (- m 1)))) (= (square tmp) 1))  
             0  
             (remainder (square tmp) m))))  
        (else (remainder (* base (expmod base (- exp 1) m)) m))))
        

;; Ex 1.30

(define (sum term a next b)
    (define (iter a result)
      (if (> a b)
          result
          (iter (next a) (+ result (term a)))))
    (iter a 0))
    
;; Ex 1.31

(define (product term a next b) 
  (if (> a b) 
      1 
      (* (term a) 
         (product term (next a) next b))))

;; Ex 1.32

(define (accumulate combiner null-value term a next b) 
  (if (> a b) 
      null-value 
      (combiner (term a) 
                (accumulate combiner null-value term (next a) next b))))

;; Ex 1.33

(define (filtered-accumulate combiner null-value term a next b filter) 
  (if (> a b) 
      null-value 
      (if (filter a) 
          (combiner (term a) 
                    (filtered-accumulate combiner null-value term (next a) next b filter)) 
          (filtered-accumulate combiner null-value term (next a) next b filter))))
          
;; Ex 1.34

(define (f g)
  (g 2))
  
(f f)

(f (lambda (z) (* z (+ z 1))))
;; 6
          
;; Ex 1.35

(fixed-point (lambda (x) (+ 1 (/ 1 x))) 1.0) 

;; Ex 1.36

(define (average x y)
  (/ (+ x y) 2))

(define tolerance 0.00001)

(define (fixed-point f first-guess)
  (define (try guess)
    (let ((next (f guess)))
      (display guess)
      (if (close-enough? guess next fixed-point-tolerance)
          next
          (try next))))
  (try first-guess))
  
;; Ex 1.37

(define (cont-frac n d k)
  (define (frac i)
     (if (< i k)
         (/ (n i) (+ (d i) (frac (+ i 1))))
         (/ (n i) (d i))))
  (frac 1))
  
(cont-frac (lambda (i) 1.0)
  (lambda (i) 1.0)
    k)
    
;; Ex 1.41

(define (inc n)
  (+ 1 n))

(define (double p)
  (lambda (y) (p (p y)))
  )
  
(((double (double double)) inc) 5) ;; 21

;; Ex 1.42

(define (compose f1 f2)
  (lambda (x) (f1 (f2 x)) )
  )

((compose square inc) 6)

;; Ex 1.43

(define (repeated f n)
  (lambda (y)
    (if (<= n 1)
      (f y)
      ((repeated f (- n 1)) (f y))
    )
  ))
  
;; Ex 1.44

(define (smooth f)
  (lambda (y)
    (/ (+ (f y) (f (- y 0.01)) (f (+ y 0.01))) 3)
  )
)
