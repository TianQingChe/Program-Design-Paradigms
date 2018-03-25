;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "08" "q2.rkt")

(provide
 tie
 defeated
 defeated?
 outranks
 outranked-by
 power-ranking)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DATA DEFINITIONS

;;; A Competitor is represented as a String (any string will do).

;;; A Tie is represented as a struct
;;; (make-tie competitor-1 competitor-1)
;;; competitor-1: Competitor one competitor in a contest whose result 
;;;               is a tie 
;;; competitor-1: Competitor another competitor in this contest 

;;; IMPLEMENTATION
(define-struct tie-exp (competitor-1 competitor-2))

;;; CONSTRUCTOR TEMPLATE
;;; (make-tie Competitor Competitor)

;;; OBSERVER TEMPLATE
;;; tie-fn : Tie -> ??
(define (tie-fn t)
  (...
    (tie-competitor-1 t)
    (tie-competitor-2 t)))

;;; A Defeat is represented as a struct
;;; (make-tie competitor-1 competitor-2)
;;; competitor-1: Competitor one competitor in a contest has defeated
;;;               another one
;;; competitor-2: Competitor the competitor defeafted by the first
;;;               competitor

;;; IMPLEMENTATION
(define-struct defeat-exp (competitor-1 competitor-2))

;;; CONSTRUCTOR TEMPLATE
;;; (make-defeat Competitor Competitor)

;;; OBSERVER TEMPLATE
;;; defeat-fn : Defeat -> ??
(define (defeat-fn t)
  (...
    (defeat-competitor-1 t)
    (defeat-competitor-2 t)))

;;; An Outcome is one of
;;;     -- a Tie
;;;     -- a Defeat
;;;
;;; OBSERVER TEMPLATE:
;;; outcome-fn : Outcome -> ??
#;
(define (outcome-fn o)
  (cond ((tie? o) ...)
        ((defeat? o) ...)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FUNCTIONS
;;; tie : Competitor Competitor -> Tie
;;; GIVEN: the names of two competitors
;;; RETURNS: an indication that the two competitors have
;;;     engaged in a contest, and the outcome was a tie
;;; EXAMPLE: (see the examples given below for defeated?,
;;;     which shows the desired combined behavior of tie
;;;     and defeated?)
;;; STRATEGY: Use the constructor template for Tie
(define (tie c1 c2)
  (make-tie-exp c1 c2))

;;; defeated : Competitor Competitor -> Defeat
;;; GIVEN: the names of two competitors
;;; RETURNS: an indication that the two competitors have
;;;     engaged in a contest, with the first competitor
;;;     defeating the second
;;; EXAMPLE: (see the examples given below for defeated?,
;;;     which shows the desired combined behavior of defeated
;;;     and defeated?)
;;; STRATEGY: Use the constructor template for Defeat
(define (defeated c1 c2)
  (make-defeat-exp c1 c2))

;;; defeated? : Competitor Competitor OutcomeList -> Boolean
;;; GIVEN: the names of two competitors and a list of outcomes
;;; RETURNS: true if and only if one or more of the outcomes indicates
;;;     the first competitor has defeated or tied the second
;;; EXAMPLES:
;;;     (defeated? "A" "B" (list (defeated "A" "B") (tie "B" "C")))
;;;  => true
;;;
;;;     (defeated? "A" "C" (list (defeated "A" "B") (tie "B" "C")))
;;;  => false
;;;
;;;     (defeated? "B" "A" (list (defeated "A" "B") (tie "B" "C")))
;;;  => false
;;;
;;;     (defeated? "B" "C" (list (defeated "A" "B") (tie "B" "C")))
;;;  => true
;;;
;;;     (defeated? "C" "B" (list (defeated "A" "B") (tie "B" "C")))
;;;  => true
;;; STRATEGY: Use HOF ormap on ol
;;; HALTING MEASURE: (length ol)
(define (defeated? c1 c2 ol)
  (ormap
   (lambda (o) (single-contest-defeated? c1 c2 o))
   ol))

(begin-for-test
  (check-equal?
   (defeated? "A" "B" (list (defeated "A" "B") (tie "B" "C")))
   true)
  (check-equal?
   (defeated? "A" "C" (list (defeated "A" "B") (tie "B" "C")))
   false)
  (check-equal?
   (defeated? "B" "A" (list (defeated "A" "B") (tie "B" "C")))
   false)
  (check-equal?
   (defeated? "B" "C" (list (defeated "A" "B") (tie "B" "C")))
   true)
  (check-equal?
   (defeated? "C" "B" (list (defeated "A" "B") (tie "B" "C")))
   true))

;;; single-contest-defeated? : Competitor Competitor Outcome -> Boolean
;;; Given: an outcome
;;; RETURNS: true if true if and only if the outcomes indicates
;;;          the first competitor has defeated or tied the second
;;; Strategy: Use template of Outcome
(define (single-contest-defeated? c1 c2 o)
  (cond
    [(defeat-exp? o) (and (equal? (defeat-exp-competitor-1 o) c1)
                          (equal? (defeat-exp-competitor-2 o) c2))]
    [(tie-exp? o) (or (and (equal? (tie-exp-competitor-1 o) c1)
                           (equal? (tie-exp-competitor-2 o) c2))
                  (and (equal? (tie-exp-competitor-1 o) c2)
                       (equal? (tie-exp-competitor-2 o) c1)))]))

;;; outranks : Competitor OutcomeList -> CompetitorList
;;; GIVEN: the name of a competitor and a list of outcomes
;;; RETURNS: a list of the competitors outranked by the given
;;;     competitor, in alphabetical order
;;; NOTE: it is possible for a competitor to outrank itself
;;; EXAMPLES:
;;;     (outranks "A" (list (defeated "A" "B") (tie "B" "C")))
;;;  => (list "B" "C")
;;;
;;;     (outranks "B" (list (defeated "A" "B") (defeated "B" "A")))
;;;  => (list "A" "B")
;;;
;;;     (outranks "C" (list (defeated "A" "B") (tie "B" "C")))
;;;  => (list "B" "C")
;;; STRATEGY: Combine simpler functions
(define (outranks c ol)
  (sort (remove-duplicates
         (add-indirect-outranks
          (direct-outranks c ol)
          (remove-lst (direct-outranks-outcomes c ol) ol)))
  string-increase-order?))

(begin-for-test
  (check-equal?
   (outranks "A" (list (defeated "A" "B") (tie "B" "C")))
   (list "B" "C"))
  (check-equal?
   (outranks "B" (list (defeated "A" "B") (defeated "B" "A")))
   (list "A" "B"))
  (check-equal?
   (outranks "C" (list (defeated "A" "B") (tie "B" "C")))
   (list "B" "C")))

;;; add-indirect-outranks : CompetitorList OutcomeList -> CompetitorList
;;; GIVEN: a competitorlist rl and an outcomelist il
;;; WHERE: the first competitorlist rl is direct-outranks of original
;;;        outcomelist, il is the outcomelist after original list
;;;        removing outcomes containing direct outranks
;;; RETURNS: the competitorlist just like the given one, but with
;;;          competitors from il which are outranked by rl's competitors
;;; EXAMPLES:
;;;     (add-indirect-outranks (list "A" "B" "C")
;;;                            (list (defeated "A" "D") (tie "B" "E")))
;;;      => (list "A" "B" "C" "D" "E")
;;; STRATEGY: Combine simpler functions
;;; HALTING MEASURE: (length il)
(define (add-indirect-outranks rl il)
 (remove-duplicates
  (if (no-indirect-outranks? rl il)
      rl
      (local ((define updated-rl (append rl (indirect-outranks rl il)))
              (define updated-il
                (remove-lst (indirect-outranks-outcomes rl il) il)))
        (append updated-rl
               (add-indirect-outranks updated-rl updated-il))))))

(begin-for-test
  (check-equal?
   (add-indirect-outranks (list "A" "B" "C")
                          (list (defeated "A" "D") (tie "B" "E")))
   (list "A" "B" "C" "D" "E")))

;;; indirect-outranks : CompetitorList OutcomeList -> CompetitorList
;;; GIVEN: a competitorlist rl and an outcomelist il
;;; WHERE: the first competitorlist rl is direct-outranks of original
;;;        outcomelist, il is the outcomelist after original list
;;;        removing outcomes containing direct outranks
;;; RETURNS: the competitors from il which are outranked by rl's competitors
;;; EXAMPLE:
;;;     (indirect-outranks (list "A" "B" "C")
;;;                        (list (defeated "A" "D") (tie "B" "E")))
;;;      => (list "D" "E")
;;; STRATEGY:Use HOF map on rl and il
;;; HALTING MEASURE: (length (indirect-outranks-outcomes rl il))
(define (indirect-outranks rl il)
 (map
   ;;; Outcome -> Competitor
   ;;; RETURNS: competitor from the outcome outranked by competitor
   ;;;          from rl
   (lambda (x) 
        (cond
          [(defeat-exp? x) (defeat-exp-competitor-2 x)]
          [(tie-exp? x) (if (member? (tie-exp-competitor-1 x) rl)
                            (tie-exp-competitor-2 x)
                            (tie-exp-competitor-1 x))]))
 (indirect-outranks-outcomes rl il)))

(begin-for-test
  (check-equal?
   (indirect-outranks (list "A" "B" "C")
                     (list (defeated "A" "D") (tie "B" "E")))
   (list "D" "E"))
  (check-equal?
   (indirect-outranks (list "A" "B" "C")
                     (list (defeated "A" "D") (tie "B" "E") (tie "Q" "C")))
   (list "D" "E" "Q")))


;;; indirect-outranks-outcomes : CompetitorList OutcomeList -> OutcomeList
;;; GIVEN: a competitorlist rl and an outcomelist il
;;; WHERE: the first competitorlist rl is direct-outranks of original
;;;        outcomelist, il is the outcomelist after original list
;;;        removing outcomes containing direct outranks
;;; RETURNS: the outcomelist like the given one, but only has outcomes
;;;          with competitors outranked by competitors in rl
;;; EXAMPLE:
;;;     (indirect-outranks-outcomes (list "A" "B" "C")
;;;                                 (list (defeated "A" "D") (tie "G" "E")))
;;;      => (list (defeated "A" "D"))
;;; STRATEGY: Use HOF filter on rl and il
;;; HALTING MEASURE: (length il)
(define (indirect-outranks-outcomes rl il)
  (filter
   ;;; Outcome -> Boolean
   ;;; RETURNS: true if the outcome contains competitor in rl
   (lambda (o)(ormap (lambda (c) (contain-outrank? c o)) rl))
   il))

;;; no-indirect-outranks? : CompetitorList OutcomeList -> Boolean
;;; GIVEN: a competitorlist rl and an outcomelist il
;;; WHERE: the first competitorlist rl is direct-outranks of original
;;;        outcomelist, il is the outcomelist after original list
;;;        removing outcomes containing direct outranks
;;; RETURNS: true if al competitors in rl outrank no competitors in il
;;; EXAMPLES:
;;;     (no-indirect-outranks? (list "A" "B" "C")
;;;                            (list (defeated "D" "E")))
;;;      => true
;;;     (no-indirect-outranks? (list "A" "B" "C")
;;;                            (list (defeated "C" "E") (tie "J" "B")))
;;;      => false
;;; STRATEGY: Use HOF andmap on rl and il
;;; HALTING MEASURE: (length il)
(define (no-indirect-outranks? rl il)
  (andmap
      ;;; Outcome -> Boolean
      ;;; RETURNS: true if competitors in the outcome are not been
      ;;;          outranked by competitors in rl
      (lambda (o)
        (not (cond
          [(defeat-exp? o) (member? (defeat-exp-competitor-1 o) rl)]
          [(tie-exp? o) (or (member? (tie-exp-competitor-1 o) rl)
                            (member? (tie-exp-competitor-2 o) rl))])))
  il))

(begin-for-test
  (check-equal?
   (no-indirect-outranks? (list "A" "B" "C") (list (defeated "D" "E")))
   true)
  (check-equal?
   (no-indirect-outranks? (list "A" "B" "C") (list (tie "J" "B") 
                                                   (defeated "C" "E")))
   false))

;;; direct-outranks : Competitor OutcomeList -> CompetitorList
;;; GIVEN: a competitor c and an outcomelist ol
;;; RETURNS: a competitorlist whose competitors has been defeated
;;;          by c or in a tie with c according to ol, including
;;;          c itself if it has been in a tie
;;; EXAMPLE:
;;;     (direct-outranks-2 "D" (list (defeated "D" "E") (tie "C" "D")
;;;                                  (tie "D" "Q")))
;;;      => (list "E" "C" "D" "Q")
;;; STRATEGY: Call another function
(define (direct-outranks c ol)
  (if (outranked-by-self? c ol)
      (cons c (direct-outranks-2 c ol))
      (direct-outranks-2 c ol)))

;;; outranked-by-self? : Competitor OutcomeList -> Boolean
;;; GIVEN: a competitor c and an outcomelist ol
;;; RETURNS: true if c has been in a tie according to ol
;;; STRATEGY: Use HOF ormap on ol
;;; HALTING MEASURE: (length ol)
(define (outranked-by-self? c ol)
  (ormap
   ;;; Outcome -> Boolean
   ;;; RETRURNS: true if the outcome is a tie and has c
   (lambda (o) (and (tie-exp? o)
                     (or (equal? (tie-exp-competitor-1 o) c)
                        (equal? (tie-exp-competitor-2 o) c))))
  ol))

;;; direct-outranks-2 : Competitor OutcomeList -> CompetitorList
;;; GIVEN: a competitor c and an outcomelist ol
;;; RETURNS: a competitorlist whose competitors has been defeated
;;;          by c or in a tie with c according to ol
;;; EXAMPLE:
;;;     (direct-outranks-2 "D" (list (defeated "D" "E") (tie "C" "D")
;;;                                  (tie "D" "Q")))
;;;      => (list "E" "C" "Q")
;;; STRATEGY: Use HOF map on ol
;;; HALTING MEASURE: (length (direct-outranks-outcomes c ol))
(define (direct-outranks-2 c ol)
  (map
   ;;; Outcome -> Competitor
   ;;; RETURNS: competitor from the outcome outranked by c
   (lambda (o)
         (cond
            [(defeat-exp? o) (defeat-exp-competitor-2 o)]
            [(tie-exp? o) (if (equal? (tie-exp-competitor-1 o) c)
                              (tie-exp-competitor-2 o)
                              (tie-exp-competitor-1 o))]))
   (direct-outranks-outcomes c ol)))

(begin-for-test
  (check-equal?
   (direct-outranks-2 "D" (list (defeated "D" "E") (tie "C" "D")
                                (tie "D" "Q")))
   (list "E" "C" "Q")))

;;; direct-outranks-outcomes: Competitor OutcomeList -> OutcomeList
;;; GIVEN: a competitor c and an outcomelist ol
;;; RETURNS: an outcomelist in whose outcome competitors has been 
;;;          defeated by c or in a tie with c according to ol
;;; EXAMPLE:
;;;     (direct-outranks-outcomes "D" (list (defeated "D" "E") (tie "C" "D")
;;;                                  (tie "D" "Q")))
;;;      => (list (defeated "D" "E") (tie "C" "D") (tie "D" "Q"))
;;; STRATEGY: Use HOF filter on ol
;;; HALTING MEASURE: (length ol)
(define (direct-outranks-outcomes c ol)
  (filter
   ;;; Outcome -> Boolean
   ;;; RETURNS: true if the c is in o and c outranks another competitor
   ;;;          in o
   (lambda (o) (contain-outrank? c o))
   ol))

;;; contain-outrank? : Competitor Outcome -> Boolean
;;; GIVEN: a competitor c and an outcome o
;;; RETURNS: true if c outranks competitor in o
;;; STRATEGY: Cases on the type of outcome
(define (contain-outrank? c o)
  (cond
        [(defeat-exp? o) (equal? (defeat-exp-competitor-1 o) c)]
        [(tie-exp? o) (or (equal? (tie-exp-competitor-1 o) c)
                          (equal? (tie-exp-competitor-2 o) c))]))

;;; remove-duplicates : XList -> XList
;;; GIVEN: a list
;;; RETURNS: the list after removing duplicate elements
;;; STARTEGY: Use observer template for XList
;;; HALTING MEASURE: (length lst)
(define (remove-duplicates lst)
  (cond
    [(empty? lst) empty]
    [else (if (member? (first lst) (rest lst))
              (remove-duplicates (rest lst))
              (cons (first lst) (remove-duplicates (rest lst))))]))

;;; string-increase-order? : String String -> Boolean
;;; GIVEN: a string s1 and a string s2
;;; RETURNS: true if s1 is smaller than s2 in alphabetical order
;;; STRATEGY: Call another function
(define (string-increase-order? s1 s2)
  (string<=? s1 s2))

;;; remove-lst : XList XList -> XList
;;; GIVEN: a xlist sub-l and xlist l
;;; RETURNS: the xlist l after removing elements the same as in sub-l
;;; STRATEGY:Use HOF filter on l
;;; HALTING MEASURE: (length l)
(define (remove-lst sub-l l)
  (filter
   ;;; String -> Boolean
   ;;; true if the element is not contained in sub-l
   (lambda (x) (not (member? x sub-l)))
   l))

;;; outranked-by : Competitor OutcomeList -> CompetitorList
;;; GIVEN: the name of a competitor and a list of outcomes
;;; RETURNS: a list of the competitors that outrank the given
;;;     competitor, in alphabetical order
;;; NOTE: it is possible for a competitor to outrank itself
;;; EXAMPLES:
;;;     (outranked-by "A" (list (defeated "A" "B") (tie "B" "C")))
;;;  => (list)
;;;
;;;     (outranked-by "B" (list (defeated "A" "B") (defeated "B" "A")))
;;;  => (list "A" "B")
;;;
;;;     (outranked-by "C" (list (defeated "A" "B") (tie "B" "C")))
;;;  => (list "A" "B" "C")
;;; STRATEGY: Use HOF sort on ol, followed by filter
;;; HALTING MEASURE(filter): (length (competitors ol))
(define (outranked-by c ol)
  (sort
   (filter
    ;;; Competitor -> Boolean
    ;;; RETURNS: true if the competitor outranks c
    (lambda (x) (member? c (outranks x ol)))
    (competitors ol))
   string-increase-order?))

(begin-for-test
  (check-equal?
   (outranked-by "A" (list (defeated "A" "B") (tie "B" "C")))
   (list))
  (check-equal?
   (outranked-by "B" (list (defeated "A" "B") (defeated "B" "A")))
   (list "A" "B"))
  (check-equal?
   (outranked-by "C" (list (defeated "A" "B") (tie "B" "C")))
   (list "A" "B" "C")))

;;; competitors : OutcomeList -> CompetitorList
;;; GIVEN: an outcomelist ol
;;; RETURNS: a competitorlist made up of all competitors from ol
;;; STRATEGY: Use HOF map on ol
;;; HALTING MEASURE: (length ol)
(define (competitors ol)
  (remove-duplicates
   (apply append
    (map
     ;;; Outcome -> CompetitorList
     ;;; RETURNS: a competitorlist made up of competitors from the
     ;;;          outcome
     (lambda (o)
      (cond [(defeat-exp? o) (list (defeat-exp-competitor-1 o)
                                  (defeat-exp-competitor-2 o))]
           [(tie-exp? o) (list (tie-exp-competitor-1 o)
                               (tie-exp-competitor-2 o))]))
    ol))))

;;; power-ranking : OutcomeList -> CompetitorList
;;; GIVEN: a list of outcomes
;;; RETURNS: a list of all competitors mentioned by one or more
;;;     of the outcomes, without repetitions, with competitor A
;;;     coming before competitor B in the list if and only if
;;;     the power-ranking of A is higher than the power ranking
;;;     of B.
;;; EXAMPLE:
;;;     (power-ranking
;;;      (list (defeated "A" "D")
;;;            (defeated "A" "E")
;;;            (defeated "C" "B")
;;;            (defeated "C" "F")
;;;            (tie "D" "B")
;;;            (defeated "F" "E")))
;;;  => (list "C"   ; outranked by 0, outranks 4
;;;           "A"   ; outranked by 0, outranks 3
;;;           "F"   ; outranked by 1
;;;           "E"   ; outranked by 3
;;;           "B"   ; outranked by 4, outranks 12, 50%
;;;           "D")  ; outranked by 4, outranks 12, 50%
;;; STRATEGY: Use HOF sort on (competitors ol)
(define (power-ranking ol)
  (sort (competitors ol) (lambda (c1 c2)
                           (higher-power-rank? c1 c2 ol))))

(begin-for-test
  (check-equal?
   (power-ranking
      (list (defeated "A" "D")
            (defeated "A" "E")
            (defeated "C" "B")
            (defeated "C" "F")
            (tie "D" "B")
            (defeated "F" "E")))
   (list "C" "A" "F" "E" "B" "D")))

;;; higher-power-rank? : Competitor Competitor OutcomeList -> Boolean
;;; GIVEN: a competitor c1, a competitor c2 and an outcomelist ol
;;; WHERE: c1 and c2 are conatined in ol
;;; RETURNS: true if c1 has higher power rank than c2
;;; EXAMPLE:
;;;     (higher-power-rank? "B" "A"
;;;                       (list (defeated "C" "A") (defeated "D" "B")
;;;                             (defeated "A" "E") (defeated "B" "F")
;;;                             (defeated "E" "G") (defeated "B" "H")))
;;;      => true
;;; STRATEGY: Cases on power-ranking rules
(define (higher-power-rank? c1 c2 ol)
  (cond
    [(< (length (outranked-by c1 ol)) (length (outranked-by c2 ol)))
     true]
    [(and (= (length (outranked-by c1 ol)) (length (outranked-by c2 ol)))
          (> (length (outranks c1 ol)) (length (outranks c2 ol))))
     true]
    [(and (= (length (outranked-by c1 ol)) (length (outranked-by c2 ol)))
          (= (length (outranks c1 ol)) (length (outranks c2 ol)))
          (> (non-losing-percentage c1 ol) (non-losing-percentage c2 ol)))
     true]
    [(and (= (length (outranked-by c1 ol)) (length (outranked-by c2 ol)))
          (= (length (outranks c1 ol)) (length (outranks c2 ol)))
          (= (non-losing-percentage c1 ol) (non-losing-percentage c2 ol))
          (string<=? c1 c2))
     true]
    [else false]))

(begin-for-test
  (check-equal?
   (higher-power-rank? "B" "A"
                       (list (defeated "C" "A") (defeated "D" "B")
                             (defeated "A" "E") (defeated "B" "F")
                             (defeated "E" "G") (defeated "B" "H")))
   true))

;;; non-losing-percentage: Competitor OutcomeList -> NonNegReal
;;; GIVEN: a competitor c and an outcomelist ol
;;; RETURNS: the non-losing percentage of c in ol
;;; STRATEGY: Transcribe formula
(define (non-losing-percentage c ol)
  (/ (length (non-losing-outcomes c ol))
     (length (mention-outcomes c ol))))

;;; non-losing-outcomes : Competitor OutcomeList -> OutcomeList
;;; GIVEN: a competitor c and an outcomelist ol
;;; RETURNS: the outcomelist with outcomes in which c does not lose
;;; STRATEGY: Use HOF filter on ol
;;; HALTING MEASURE: (length ol)
(define (non-losing-outcomes c ol)
  (filter
   ;;; Outcome -> Boolean
   ;;; RETURNS: true if the c does not lose in o
   (lambda (o)
     (cond
       [(defeat-exp? o) (equal? c (defeat-exp-competitor-1 o))]
       [(tie-exp? o) (or (equal? c (tie-exp-competitor-1 o))
                         (equal? c (tie-exp-competitor-2 o)))]))
   ol))

;;; mention-outcomes : Competitor OutcomeList -> OutcomeList
;;; GIVEN: a competitor c and an outcomelist ol
;;; RETURNS: the outcomelist with all outcomes mention c
;;; STRATEGY: Use HOF filter on ol
;;; HALTING MEASURE: (length ol)
(define (mention-outcomes c ol)
  (filter
   ;;; Outcome -> Boolean
   ;;; RETURNS: true if o mentions c
   (lambda (o)
     (cond
       [(defeat-exp? o) (or (equal? c (defeat-exp-competitor-1 o))
                            (equal? c (defeat-exp-competitor-2 o)))]
       [(tie-exp? o) (or (equal? c (tie-exp-competitor-1 o))
                         (equal? c (tie-exp-competitor-2 o)))]))
   ol))


