;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "06" "q1.rkt")

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
;(define (inner-product rlist-1 rlist-2)
;  (cond
;    [(empty? rlist-1) 0]
;    [else
;     (+ (* (first rlist-1) (first rlist-2))
;        (inner-product (rest rlist-1) (rest rlist-2)))]))
;;; DESIGN STRATEGY: Use HOF map on rlist-1 and rlist-2, followed
;;;                  by foldr
(define (inner-product rlist-1 rlist-2)
  (foldr + 0
         (map
          ;; Real Real -> Real
          ;; RETURNS: the product of the two numbers
          (lambda (n1 n2) (* n1 n2))
           rlist-1 rlist-2)))

(begin-for-test
  (check-equal?
   (inner-product (list 2.5) (list 3.0)) 7.5)
  (check-equal?
   (inner-product (list 1 2 3 4) (list 5 6 7 8)) 70)
  (check-equal?
   (inner-product (list) (list)) 0))

;;; contains-number? : Number NumberList -> Boolean
;;; GIVEN: a number n and a numberlist nl
;;; RETURNS: true if the number is an element of the numberlist
;(define (contains-number? n nlist)
;  (cond
;    [(empty? nlist) false]
;    [else (and (= n (first nlist))
;            true
;            (contains-number? n (rest nlist)))]))
;;; DESIGN STRATEGY: Use HOF ormap on nlist
(define (contains-number? n nlist)
  (ormap
   ;; Number -> Boolean
   ;; RETURNS: true if the number equals n
   (lambda (x) (= x n))
    nlist))

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
;(define (permutation-of? ilist-1 ilist-2)
;(cond
;[(empty? ilist-1) true]
;[else (and (and (= (length ilist-1) (length ilist-2))
;           (contains-number? (first ilist-1) ilist-2))
;           (permutation-of? (rest ilist-1)
;           (remove-number (first ilist-1) ilist-2)))]))
;;; DESIGN STRATEGY: Use HOF filter on ilist-2
(define (permutation-of? ilist-1 ilist-2)
  (and (= (length ilist-1) (length ilist-2))
       (empty?
        (filter
         ;; Integer -> Boolean
         ;; RETURNS: true if the number is not contained in ilist-1
         (lambda (x) (not (contains-number? x ilist-1)))
          ilist-2))))

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
    [(< (length ilist-1) (length ilist-2))
     true]
    [(and (non-empty-length-equal? ilist-1 ilist-2)
          (< (first ilist-1) (first ilist-2)))
     true]
    [(and (non-empty-length-equal? ilist-1 ilist-2)
          (= (first ilist-1) (first ilist-2))
          (shortlex-less-than? (rest ilist-1) (rest ilist-2)))
     true]
    [else false]))

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

;;; non-empty-length-equal? : IntList IntList -> Boolean
;;; GIVEN: two lists of integers
;;; RETURNS: true if the two lists are both non empty and
;;;          have the same length
;;; DESIGN STRATEGY: Combine simpler functions
(define (non-empty-length-equal? list-1 list-2)
  (and (not (empty? list-1)) (not (empty? list-2))
       (= (length list-1) (length list-2))))
          
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
;(define (permutations ilist)
;  (cond
;    [(= (length ilist) 1)
;     (cons ilist empty)]
;    [else
;     (cons ilist empty)]))
;;; DESIGN STRATEGY: Use HOF sort on (permutations-unsorted ilist)
(define (permutations ilist)
  (sort (permutations-unsorted ilist) shortlex-less-than?))

(begin-for-test
  (check-equal? (permutations (list 3 1 2))
                (list (list 1 2 3) (list 1 3 2) (list 2 1 3)
                      (list 2 3 1) (list 3 1 2) (list 3 2 1)))
  (check-equal? (permutations (list)) (list (list)))
  (check-equal? (permutations (list 9)) (list (list 9))))

;;; permutations-unsorted : IntList -> IntListList
;;; GIVEN: a list of integers
;;; WHERE: the list contains no duplicates
;;; RETURNS: a list of all permutations of that list,in any order
;;; EXAMPLES: (permutations (list 3 1 2))
;;;               =>  (list (list 3 1 2)
;;;                         (list 3 2 1)
;;;                         (list 1 3 2)
;;;                         (list 1 2 3)
;;;                         (list 2 3 1)
;;;                         (list 2 1 3))
;;; DESIGN STRATEGY: Use HOF map on ilist, followed by append and apply
(define (permutations-unsorted ilist)
  (cond
    [(empty? ilist) (list empty)]
    [(= (length ilist) 1)(list ilist)]
    [else (apply append (map
                 ;; Integer -> IntLists
                 ;; RETUNRS: intlists each of which begin with the
                 ;;          the given integer
                 (lambda (x)
                 (map
                  ;; Integer -> IntLists
                  ;; RETURNS: intlists each of which begin with x and
                  ;;          followed by the given integer
                  (lambda (y)
                   (append (list x)
                           (append (list y)  (remove y (remove x ilist)))))
                   (remove x ilist))) ilist))]))





