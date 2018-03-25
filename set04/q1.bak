;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "04" "q1.rkt")

(provide
 inner-product
 permutation-of?
 shortlex-less-than?
 permutations)
;;; inner-product : RealList RealList -> Real
;;; GIVEN: two lists of real numbers
;;; WHERE: the two lists have the same length
;;; RETURNS: the inner product of those lists
;;; EXAMPLES:
;;;     (inner-product (list 2.5) (list 3.0))  =>  7.5
;;;     (inner-product (list 1 2 3 4) (list 5 6 7 8))  =>  70
;;;     (inner-product (list) (list))  =>  0
;;; DESIGN STRATEGY: Use observer template for RealList
(define (inner-product rlist-1 rlist-2)
  (cond
    [(empty? rlist-1) 0]
    [else
     (+ (* (first rlist-1) (first rlist-2))
        (inner-product (rest rlist-1) (rest rlist-2)))]))
(begin-for-test
  (check-equal?
   (inner-product (list 2.5) (list 3.0)) 7.5)
  (check-equal?
   (inner-product (list 1 2 3 4) (list 5 6 7 8)) 70)
  (check-equal?
   (inner-product (list) (list)) 0))

;; list-length :List -> Integer
;; GIVEN: a List
;; RETURNS: its length
(begin-for-test
  (check-equal? (list-length empty) 0)
  (check-equal? (list-length (cons 11 empty)) 1)
  (check-equal? (list-length (cons 33 (cons 11 empty))) 2))
; STRATEGY: Use observer template for List on lst
(define (list-length lst)
  (cond
    [(empty? lst) 0]
    [else (+ 1 
            (list-length (rest lst)))]))

;;; permutation-of? : IntList IntList -> Boolean
;;; GIVEN: two lists of integers
;;; WHERE: neither list contains duplicate elements
;;; RETURNS: true if and only if one of the lists
;;;     is a permutation of the other
;;; EXAMPLES:
;;;     (permutation-of? (list 1 2 3) (list 1 2 3)) => true
;;;     (permutation-of? (list 3 1 2) (list 1 2 3)) => true
;;;     (permutation-of? (list 3 1 2) (list 1 2 4)) => false
;;;     (permutation-of? (list 1 2 3) (list 1 2)) => false
;;;     (permutation-of? (list) (list)) => true
;;; DESIGN STRATEGY: Use observer template for IntList
(define (permutation-of? ilist-1 ilist-2)
  (cond
    [(not (= (list-length ilist-1) (list-length ilist-2)))
     false]
    [(empty? ilist-1) true]
    [else (if (contains-number? (first ilist-1) ilist-2)
              (permutation-of? (rest ilist-1)
                               (remove-number (first ilist-1) ilist-1))
              false)]))
(begin-for-test
  (check-equal?
   (permutation-of? (list 1 2 3) (list 1 2 3)) true)
  (check-equal?
   (permutation-of? (list 3 1 2) (list 1 2 3)) true)
  (check-equal?
   (permutation-of? (list 3 1 2) (list 1 2 4)) false)
  (check-equal?
   (permutation-of? (list 1 2 3) (list 1 2)) false)
  (check-equal?
   (permutation-of? (list) (list)) true))

;;; contains-number? : Number NumberList -> Boolean
;;; GIVEN: a number n and a numberlist nl
;;; RETURNS: true if the number is an element of the numberlist
;;; DESIGN STRATEGY: Use observer template for NumberList
(define (contains-number? n nlist)
  (cond
    [(empty? nlist) false]
    [else (if (= n (first nlist))
            true
            (contains-number? n (rest nlist)))]))

;;; remove-number : Number NumberList -> NumberList
;;; GIVEN: a number n and a numberlist nl
;;; RETURNS: the numberlist without the number n
;;; DESIGN STRATEGY: Use observer template for NumberList
(define (remove-number n nlist)
  (cond
    [(empty? nlist) empty]
    [else (if (= n (first nlist))
              (rest nlist)
              (cons (first nlist)
                    (remove-number n (rest nlist))))]))
(begin-for-test
  (check-equal?
   (remove-number 4 empty) empty)
  (check-equal?
   (remove-number 5 (list 1 3 5)) (list 1 3)))

          
;;; shortlex-less-than? : IntList IntList -> Boolean
;;; GIVEN: two lists of integers
;;; RETURNS: true if and only either
;;;     the first list is shorter than the second
;;;  or both are non-empty, have the same length, and either
;;;         the first element of the first list is less than
;;;             the first element of the second list
;;;      or the first elements are equal, and the rest of
;;;             the first list is less than the rest of the
;;;             second list according to shortlex-less-than?
;;; EXAMPLES:
;;;     (shortlex-less-than? (list) (list)) => false
;;;     (shortlex-less-than? (list) (list 3)) => true
;;;     (shortlex-less-than? (list 3) (list)) => false
;;;     (shortlex-less-than? (list 3) (list 3)) => false
;;;     (shortlex-less-than? (list 3) (list 1 2)) => true
;;;     (shortlex-less-than? (list 3 0) (list 1 2)) => false
;;;     (shortlex-less-than? (list 0 3) (list 1 2)) => true
;;; DESIGN STRATEGY: Use observer template for IntList
(define (shortlex-less-than? ilist-1 ilist-2)
  (cond
    [(< (list-length ilist-1) (list-length ilist-2))
     true]
    [(and (non-empty-length-equal? ilist-1 ilist-2) (< (first ilist-1) (first ilist-2)))
     true]
    [(and (non-empty-length-equal? ilist-1 ilist-2)
          (= (first ilist-1) (first ilist-2))
          (shortlex-less-than? (rest ilist-1) (rest ilist-2)))
     true]
    [else false]))
(define (non-empty-length-equal? list-1 list-2)
  (and (non-empty? list-1) (non-empty? list-2) (length-equal? list-1 list-2)))
(define (non-empty? lst)
  (not (empty? lst)))
(define (length-equal? list-1 list-2)
  (= (list-length list-1) (list-length list-2)))

(begin-for-test
  (check-equal?
   (shortlex-less-than? (list) (list)) false)
  (check-equal?
   (shortlex-less-than? (list) (list 3)) true)
  (check-equal?
   (shortlex-less-than? (list 1 2 3) (list 1 2 4)) true)
  (check-equal?
   (shortlex-less-than? (list 3) (list)) false)
  (check-equal?
   (shortlex-less-than? (list 3) (list 3)) false)
  (check-equal?
   (shortlex-less-than? (list 3) (list 1 2)) true)
  (check-equal?
   (shortlex-less-than? (list 3 0) (list 1 2)) false)
  (check-equal?
   (shortlex-less-than? (list 0 3) (list 1 2)) true))
          
;;; permutations : IntList -> IntListList
;;; GIVEN: a list of integers
;;; WHERE: the list contains no duplicates
;;; RETURNS: a list of all permutations of that list,
;;;     in shortlex order
;;; EXAMPLES:
;;;     (permutations (list))  =>  (list (list))
;;;     (permutations (list 9))  =>  (list (list 9))
;;;     (permutations (list 3 1 2))
;;;         =>  (list (list 1 2 3)
;;;                   (list 1 3 2)
;;;                   (list 2 1 3)
;;;                   (list 2 3 1)
;;;                   (list 3 1 2)
;;;                   (list 3 2 1))
;;; DESIGN STRATEGY: Use observer template for IntList
(define (permutations ilist)
  (cond
    [(= (list-length ilist) 1)
     (cons ilist empty)]
    [else
     (cons ilist empty)]))
(begin-for-test
  (check-equal?
   (permutations (list 9)) (list (list 9))))






