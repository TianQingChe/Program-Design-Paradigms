;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(require "q1.rkt")
(check-location "07" "q2.rkt")

(provide
 lit
 literal-value
 var
 variable-name
 op
 operation-name
 call
 call-operator
 call-operands
 block
 block-var
 block-rhs
 block-body
 literal?
 variable?
 operation?
 call?
 block?
 undefined-variables
 well-typed?
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DATA DEFINITIONS

;;; An Int is represented as a strcut
;;; (make-int)
;;; IMPLEMENTATION:
(define-struct int ())
;;; CONSTRUCTOR TEMPLATE:
;;; (make-int)

;;; An Op0 is represented as a strcut
;;; (make-Op0)
;;; IMPLEMENTATION:
(define-struct Op0 ())
;;; CONSTRUCTOR TEMPLATE:
;;; (make-Op0)

;;; An Op1 is represented as a strcut
;;; (make-Op1)
;;; IMPLEMENTATION:
(define-struct Op1 ())
;;; CONSTRUCTOR TEMPLATE:
;;; (make-Op1)

;;; An Error is represented as a strcut
;;; (make-error)
;;; IMPLEMENTATION:
(define-struct Error ())
;;; CONSTRUCTOR TEMPLATE:
;;; (make-Error)

;;; An Type is one of
;;;     -- an Int
;;;     -- an Op0
;;;     -- an Op1
;;;     -- an Error
;;;
;;; OBSERVER TEMPLATE:
;;; type-fn : Type -> ??
#;
(define (type-fn t)
  (cond ((Int? t) ...)
        ((Op0? t) ...)
        ((Op1? t) ...)
        ((Error? t) ...)))

;;; An OperationName is represented as one of the following strings:
;;;     -- "+"      (indicating addition)
;;;     -- "-"      (indicating subtraction)
;;;     -- "*"      (indicating multiplication)
;;;     -- "/"      (indicating division)
;;;
;;; OBSERVER TEMPLATE:
;;; operation-name-fn : OperationName -> ??
#;
(define (operation-name-fn op)
  (cond ((string=? op "+") ...)
        ((string=? op "-") ...)
        ((string=? op "*") ...)
        ((string=? op "/") ...)))

;;; A Call is represented as a struct
;;; (make-call-exp operator operands)
;;; INTERPRETATION:
;;; operator : ArithmeticExpression the operator of the call expression
;;; operands : ArithmeticExpressionList the list of operand expressions

;;; IMPLEMENTATION:
(define-struct call-exp (operator operands))

;;; CONSTRUCTOR TEMPLATE:
;;; (make-call-exp ArithmeticExpression ArithmeticExpressionList)

;; OBSERVER TEMPLATE
;; call-exp-fn : Call -> ??
(define (call-exp-fn c)
  (...
    (call-exp-operator c)
    (call-exp-operands c)))

;;; A Block is represented as a struct
;;; (make-block-exp var rhs body)
;;; INTERPRETATION:
;;; var :  Variable variable defined in the expression
;;; rhs :  ArithmeticExpression value used in the expression
;;; body : ArithmeticExpression the arithmetic body of the expression

;;; IMPLEMENTATION:
(define-struct block-exp (var rhs body))

;;; CONSTRUCTOR TEMPLATE:
;;; (make-block-exp Variable ArithmeticExpression ArithmeticExpression)

;; OBSERVER TEMPLATE
;; block-exp-fn : Block -> ??
(define (block-exp-fn b)
  (...
    (block-exp-var b)
    (block-exp-rhs b)
    (block-exp-body b)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; FUNCTIONS

;;; variables-no-repetition : StringList -> StringList
;;; GIVEN: a stringlist of variables' names
;;; RETURNS: the given stringlist but after removing repeated strings
;;; EXAMPLE: (variables-no-repetition (list "x" "y" "z" "x" "y"))
;;;          => (list "z" "x" "y")
;;; DESIGN STRATEGY: Use observer template for StringList
(define (variables-no-repetition vl)
  (cond
    [(empty? vl) empty]
    [else (if (contains? (first vl) (rest vl))
              (variables-no-repetition (rest vl))
              (cons (first vl) (variables-no-repetition (rest vl))))]))

(begin-for-test
  (check-equal?
   (variables-no-repetition (list "x" "y" "z" "x" "y"))
   (list "z" "x" "y")))

;;; contains? : String StringList -> Boolean
;;; GIVEN: a string and a stringlist
;;; RETURNS: true if the stringlist contains the string
;;; EXAMPLES: (contains? "x" (list "x" "y" "z")) => true
;;;           (contains? "x" (list "y" "z")) => false
;;; DESIGN STRATEGY: Use HOF ormap on sl
(define (contains? s sl)
  (ormap
   ;;; String -> Boolean
   (lambda (x) (string=? x s)) sl))

(begin-for-test
  (check-equal?
   (contains? "x" (list "x" "y" "z")) true)
  (check-equal?
   (contains? "x" (list "y" "z")) false))

;;; all-variables-in-exp : ArithmeticExpression -> StringList
;;; GIVEN: an arithmetic expression
;;; RETURNS: a stringlist made up of all variables contained in
;;;          this arithemetic expression
;;; EXAMPLE: (all-variables-in-exp
;;;             (block (var "x")
;;;                    (var "y")
;;;                    (call (block (var "z")
;;;                                 (call (op "*")
;;;                                       (list (var "x") (var "y")))
;;;                                 (op "+"))
;;;                    (list (lit 3)
;;;                          (call (op "*")
;;;                                (list (lit 4) (lit 5)))))))
;;;          => (list "z" "x" "y")
;;; DESIGN STRATEGY: Use template for
;;;                  ArithmeticExpression/ArithmeticExpressionList
(define (all-variables-in-exp ae)
  (variables-no-repetition (all-variables ae)))

(define (all-variables ae)
  (cond
    [(variable? ae) (list (variable-name ae))]
    [(call? ae) (append (all-variables-in-exp (call-operator ae))
                        (all-variables-in-exp-lst (call-operands ae)))]
    [(block? ae) (append (list (variable-name (block-var ae)))
                         (all-variables-in-exp (block-rhs ae))
                         (all-variables-in-exp (block-body ae)))]
    [else empty]))
(define (all-variables-in-exp-lst ae)
  (cond
    [(empty? ae) empty]
    [else (append (all-variables-in-exp (first ae))
                  (all-variables-in-exp-lst (rest ae)))]))

(begin-for-test
  (check-equal?
   (all-variables-in-exp
    (block (var "x")
             (var "y")
             (call (block (var "z")
                          (call (op "*")
                                (list (var "x") (var "y")))
                          (op "+"))
                   (list (lit 3)
                         (call (op "*")
                               (list (lit 4) (lit 5)))))))
   (list "z" "x" "y")))

;;; well-typed? : ArithmeticExpression -> Boolean
;;; GIVEN: an arbitrary arithmetic expression
;;; RETURNS: true if and only if the expression is well-typed
;;; EXAMPLES:
;;;     (well-typed? (lit 17))  =>  true
;;;     (well-typed? (var "x"))  =>  false
;;;     (well-typed? (call (op "+") (list (lit 1) (lit 2))))
;;;      =>  true
;;;     (well-typed?
;;;      (block (var "f")
;;;             (op "+")
;;;             (block (var "x")
;;;                    (call (var "f") (list))
;;;                    (call (op "*")
;;;                          (list (var "x")))))) => true
;;;
;;;     (well-typed?
;;;      (block (var "f")
;;;             (op "+")
;;;             (block (var "f")
;;;                    (call (var "f") (list))
;;;                    (call (op "*")
;;;                          (list (var "f")))))) => true
;;;
;;;     (well-typed?
;;;      (block (var "f")
;;;             (op "+")
;;;             (block (var "x")
;;;                    (call (var "f") (list))
;;;                    (call (op "*")
;;;                          (list (var "f")))))) => false
;;; DESIGN STRATEGY: Divide into cases on the data types of the
;;;                  arithmetic expression
(define (well-typed? ae)
  (cond
    [(or (literal? ae) (operation? ae)) true]
    [(call? ae) (call-int? ae)]
    [(and (block? ae) (empty? (undefined-variables ae)))
     (block-well-typed? ae (all-blocks ae))]
    [else false]))

(begin-for-test
  (check-equal?
   (well-typed? (lit 17)) true)
  (check-equal?
   (well-typed? (var "x")) false)
  (check-equal?
   (well-typed? (call (op "+") (list (lit 1) (lit 2)))) true)
  (check-equal?
   (well-typed?
      (block (var "f")
             (op "+")
             (block (var "x")
                    (call (var "f") (list))
                    (call (op "*")
                          (list (var "x"))))))
   true)  
  (check-equal?
   (well-typed?
      (block (var "f")
             (op "+")
             (block (var "x")
                    (call (var "f") (list))
                    (call (op "*")
                          (list (var "f"))))))
   false)
  (check-equal?
   (well-typed?
      (block (var "f")
             (op "+")
             (block (var "f")
                    (call (var "f") (list))
                   (call (op "*")
                          (list (var "f"))))))
   true))

;;; in-block-well-typed? : ArithmeticExpression BlockList-> Boolean
;;; GIVEN: an arbitrary arithmetic expression after coming into
;;;        the condition of block in well-typed?  and a block list bs
;;; WHERE: bs is the block list produced at well-typed?
;;; RETURNS: true if and only if the expression is well-typed
;;; EXAMPLES:
;;;     (in-block-well-typed?
;;;       (call (op "+") (list (lit 1) (lit 2)))
;;;       (list (block (var "x")(var "x")(var "x")))))
;;;      =>  true
;;;   
;;;     (in-block-well-typed?
;;;       (var "x") (list (block (var "y")(var "y")(var "y"))))
;;;      => false 
;;; DESIGN STRATEGY: Divide into cases on the data types of the
;;;                  arithmetic expression
(define (in-block-well-typed? ae bs)
  (cond
    [(or (literal? ae) (operation? ae)) true]
    [(variable-call? ae) (variable-call-well-typed? ae bs)]
    [(call? ae) (call-int? ae)]
    [(block? ae) (block-well-typed? ae bs)]
    [else false]))

(begin-for-test
  (check-equal?
   (in-block-well-typed?
    (call (op "+") (list (lit 1) (lit 2)))
    (list (block (var "x")(var "x")(var "x"))))
   true)
  (check-equal?
   (in-block-well-typed?
    (var "x") (list (block (var "y")(var "y")(var "y"))))
   false))

;;; Op-0? : ArithmeticExpression -> Boolean
;;; GIVEN: an arbitrary arithmetic expression ae
;;; RETURNS: true if the type of ae is (op "*") or (op "+")
;;; DESIGN STRATEGY: Cases on the data type of ae
(define (Op-0? ae)
  (or (equal? (op "*") ae) (equal? (op "+") ae)))

;;; Op-1? : ArithmeticExpression -> Boolean
;;; GIVEN: an arbitrary arithmetic expression ae
;;; RETURNS: true if the type of ae is (op "-") or (op "/")
;;; EXAMPLE: (Op-1? (op "+")) => false
;;; DESIGN STRATEGY: Cases on the datatype of ae
(define (Op-1? ae)
  (or (equal? (op "-") ae) (equal? (op "/") ae)))

(begin-for-test
  (check-equal? (Op-1? (op "+")) false))

;;; call-int? : ArithmeticExpression -> Boolean
;;; GIVEN: an arbitrary arithmetic expression ae
;;; RETURNS: true if the data type of ae is call and
;;;          its type is int
;;; EXAMPLES:
;;;    (call-int? (call (op "+") (list (lit 1) (lit 2))))
;;;     => true
;;;    (call-int? (call (op "/") (list (lit 1) (lit 2))))
;;;     => true
;;;    (call-int? (call (var "x") (list (var "x"))))
;;;     => false
;;;    (call-int? (var "x")) => false
;;;    (call-int?
;;;      (call (op "+")
;;;       (list (call (op "+") (list (lit 1))) (lit 2))))
;;;     => true
;;; DESIGN STRATEGY: Use template for
;;;                  ArithmeticExpression/ArithmeticExpressionList
(define (call-int? exp)
  (if (call? exp)
   (cond
    [(and (Op-0? (call-operator exp))
          (call-operands-int? (call-operands exp))) true]
    [(and (Op-1? (call-operator exp))
          (call-operands-int? (call-operands exp))
          (> (length (call-operands exp)) 0)) true]
    [else false])
   false))

(begin-for-test
  (check-equal?
   (call-int? (call (op "+") (list (lit 1) (lit 2)))) true)
  (check-equal?
   (call-int? (call (op "/") (list (lit 1) (lit 2)))) true)
  (check-equal?
   (call-int? (call (var "x") (list (var "x")))) false)
  (check-equal?
   (call-int? (var "x")) false)
  (check-equal?
   (call-int?
    (call (op "+") (list (call (op "+") (list (lit 1))) (lit 2))))
   true))

;;; call-operands-int? : ArithmeticExpressionList -> Boolean
;;; GIVEN: an arbitrary arithmetic expression list exp-lst
;;; RETURNS: true if the type of all exp-lst's elements is int
;;; DESIGN STRATEGY: Use HOF andmap on exp-lst
(define (call-operands-int? exp-lst)
  (andmap
   ;;; ArithmeticExpression -> Boolean
   ;;; RETURNS: true if the arithmetic expression's type is int
   (lambda (exp) (or (literal? exp) (call-int? exp))) exp-lst))

;;; variable-call-well-typed? : Call BlockList -> Boolean
;;; GIVEN: a call c and a blocklist bs
;;; WHERE: the call c contains variable,
;;;        bs is the block list produced at well-typed?
;;; RETURNS: true is the call c is well typed
;;; EXAMPLE:
;;;   (variable-call-well-typed?
;;;           (call (var "f") (list))
;;;           (list (block (var "f") (op "+")
;;;                   (block (var "x") (call (var "f") (list))
;;;                   (call (op "*") (list (var "x")))))
;;;                 (block (var "x") (call (var "f") (list))
;;;                        (call (op "*") (list (var "x"))))))
;;;   =>
;;; DESIGN STRATEGY: Use HOF andmap on c
(define (variable-call-well-typed? c bs)
  (andmap
   ;;; Variable -> Boolean
   ;;; RETURNS: true if the type of the use of the variable
   ;;;          is not Error
   (lambda (v) (variable-use-no-error? v bs))
   (all-variables-in-exp c)))

(begin-for-test
  (check-equal?
   (variable-call-well-typed?
           (call (var "f") (list))
           (list (block (var "f") (op "+")
                   (block (var "x") (call (var "f") (list))
                   (call (op "*") (list (var "x")))))
                 (block (var "x") (call (var "f") (list))
                        (call (op "*") (list (var "x"))))))
   true))

;;; block-well-typed? ： Block BlockList -> Boolean
;;; GIVEN：a Block b and a block list bs
;;; WHERE: bs is the block list produced at well-typed? and
;;;        b is contained in bs
;;; RETURN: true if the block is well typed
;;; DESIGN STRATEGY: Combine simpler functions
(define (block-well-typed? b bs)
      (and (block-rhs-no-error? (block-rhs b) bs)
           (block-body-no-error? (block-body b) bs)))

;;; block-rhs-no-error? : ArithmeticExpression BlockList
;;;                       -> Boolean
;;; GIVEN: an arithemetic expression rhs and a block list bs
;;; WHERE: rhs is the rhs of a block which is contained in bs
;;;        and bs is the block list produced at well-typed?
;;; RETURN: true is the type of rhs is not Error
;;; DESIGN STRATEGY: Cases on data type of rhs
(define (block-rhs-no-error? rhs bs)
  (if (variable-call? rhs)
      (variable-call-well-typed? rhs bs)
      (in-block-well-typed? rhs bs)))

;;; block-body-no-error? : ArithmeticExpression BlockList
;;;                       -> Boolean
;;; GIVEN: an arithemetic expression rhs and a block list bs
;;; WHERE: body is the body of a block which is contained in bs
;;;        and bs is the block list produced at well-typed?
;;; RETURN: true is the type of body is not Error
;;; DESIGN STRATEGY: Cases on data type of body
(define (block-body-no-error? body bs)
  (if (variable-call? body)
      (variable-call-well-typed? body bs)
      (in-block-well-typed? body bs)))

;;; variable-call? : ArithemeticExpression -> Boolean
;;; GIVEN: an arbitrary arithmetic expression ae
;;; RETURNS: true if the data type of ae is call
;;;          and ae contains at least one variable
;;; DESIGN STRATEGY: Combine simpler functions
(define (variable-call? ae)
  (and (call? ae)
       (not (empty? (all-variables-in-exp ae)))))

;;; variable-use-no-error? : String BlockList -> Boolean
;;; GIVEN: an string v and a block list bs
;;; WHERE: bs contains the variable with name v
;;; RETURNS: true if one block in bs whose block-var's name 
;;;          is v and whose rhs's type is not Error
;;; DESIGN STRATEGY: Use HOF ormap on bs
(define (variable-use-no-error? v bs)
  (ormap
   ;;; ArithmeticExpression -> Boolean
   ;;; RETURNS：true if the arithmetic expression is well typed
   (lambda (x) (in-block-well-typed? x bs))
   (rhs-list-of-block-define-v v bs)))

;;; rhs-list-of-block-define-v : String BlockList
;;;                                -> ArithmeticExpressionList
;;; GIVEN: a string v and a block list bs
;;; WHERE: bs contains the variable with name v
;;; RETURNS: the list of rhs of all blocks whose block-var's name
;;;          is v
;;; DESIGN STRATEGY: Use HOF map on bs
(define (rhs-list-of-block-define-v v bs)
  (map
   (lambda (x) (block-rhs x))
   (all-blocks-define-v v bs)))

;;; all-blocks-define-v : String BlockList -> BlockList
;;; GIVEN: a string v and a block list bs
;;; WHERE: bs contains the variable with the name v
;;; RETURNS: the block list after bs removing the blocks
;;;          whose block-var's name is not v
;;; DESIGN STATEGY: Use HOF filter on bs
(define (all-blocks-define-v v bs)
  (filter
   ;;; Block -> Boolean
   ;;; RERTUNS: true of the block' s var's name equals to v
   (lambda (x) (string=? (variable-name (block-var x)) v)) bs))

;;; all-blocks : ArithemeticExpression -> BlockList
;;; GIVEN: an arbitrary arithemtic expression ae
;;; RETURNS: all blocks contained in ae with removing empty
;;; DESIGN STRATEGY: Call helper functions 
(define (all-blocks ae)
  (remove empty (all-blocks-in-exp ae)))

;;; all-blocks-in-exp : ArithmetixExpression -> BlockList
;;; GIVEN: an arbitrary arithemtic expression ae
;;; RETURNS: all blocks contained in ae
;;; DESIGN STRATEGY: Use template for
;;;                  ArithmeticExpression/ArithmeticExpressionList
(define (all-blocks-in-exp ae)
  (cond
    [(call? ae) (append (all-blocks-in-exp (call-operator ae))
                        (all-blocks-in-exp-lst (call-operands ae)))]
    [(block? ae) (append (list ae)
                         (all-blocks-in-exp (block-rhs ae))
                         (all-blocks-in-exp (block-body ae)))]
    [else empty]))
(define (all-blocks-in-exp-lst ae)
  (cond
    [(empty? ae) empty]
    [else (append (all-blocks-in-exp (first ae))
                  (all-blocks-in-exp-lst (rest ae)))]))
