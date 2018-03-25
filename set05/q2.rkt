;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "05" "q2.rkt")

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
 variables-defined-by
 variables-used-by
 constant-expression?
 constant-expression-value
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DATA DEFINITIONS

(define ADDITION "+")
(define SUBTRACT "-")
(define MULTIPLY "*")
(define DIVISION "/")

;;; A Literal is represented as a strcut
;;; (make-literal value)
;;; INTERPRETATION:
;;; value: Real the value of the literal

;;; IMPLEMENTATION:
(define-struct literal (value))

;;; CONSTRUCTOR TEMPLATE:
;;; (make-literal Real)

;;; A Variable is represented as a strcut
;;; (make-variable name)
;;; INTEPRETATION:
;;; name:String the name of the variable

;;; IMPLEMENTATION:
(define-struct variable (name))

;;; CONSTRUCTOR TEMPLATE
;;; (make-variable String)

;;; A Operation is represented as a struct
;;; (make-operation name)
;;; INTEPRETATION:
;;; name:String the name of the operation

;;; IMPLEMENTATION:
(define-struct operation (name))

;;; CONSTRUCTOR TEMPLATE
;;; (make-operation String)



;;; A OperandList is represented as a list of operands.

;;; CONSTRUCTOR TEMPLATE AND INTERPRETATION
;;; empty                  -- the empty sequence
;;; (cons o ol)
;;;   WHERE:
;;;    o  is a Literal or Variable      -- the first operand
;;;                                        in the sequence
;;;    os is a OperandList              -- the rest of the 
;;;                                        operands in the sequence

;;  OBSERVER TEMPLATE:
;;  ol-fn : OperandList -> ??
;;; (define (ol-fn lst)
;;;  (cond
;;;    [(empty? lst) ...]
;;;    [else (... (first lst)
;;;               (ol-fn (rest lst)))]))

;;; A Call is represented as a struct
;;; (make-call-exp operator operands)
;;; INTERPRETATION:
;;; operator : Operation operator of the call expression
;;; operands : OperandlList list of the operands of the expression

;;; IMPLEMENTATION:
(define-struct call-exp (operator operands))

;;; CONSTRUCTOR TEMPLATE:
;;; (make-call-exp Operation LiteralList)

;; OBSERVER TEMPLATE
;; call-exp-fn : Call -> ??
(define (call-exp-fn c)
  (...
    (call-exp-operator c)
    (call-exp-operands c)))

;;; A Block is represented as a struct
;;; (make-block-exp var rhs body)
;;; INTERPRETATION:
;;; var : Variable variable defined
;;; rhs : ArithmeticExpression
;;; body : Call the arithmetic body

;;; IMPLEMENTATION:
(define-struct block-exp (var rhs body))

;;; CONSTRUCTOR TEMPLATE:
;;; (make-block-exp Variable Literal Call)

;; OBSERVER TEMPLATE
;; block-exp-fn : Block -> ??
(define (block-exp-fn b)
  (...
    (block-exp-var b)
    (block-exp-rhs b)
    (block-exp-body b)))

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
          
;;; An ArithmeticExpression is one of
;;;     -- a Literal
;;;     -- a Variable
;;;     -- an Operation
;;;     -- a Call
;;;     -- a Block
;;;
;;; OBSERVER TEMPLATE:
;;; arithmetic-expression-fn : ArithmeticExpression -> ??
#;
(define (arithmetic-expression-fn exp)
  (cond ((literal? exp) ...)
        ((variable? exp) ...)
        ((operation? exp) ...)
        ((call? exp) ...)
        ((block? exp) ...)))

;;; An Operation Expression is an arithmetic expression that is either
;;; an Operation
;;; or a Block whose body is an operation expression.

;;; A Constant Expression is an arithmetic expression that is either
;;; a Literal,
;;; a Call whose operator is an operation expression and whose 
;;; operands are all constant expressions, or a Block whose body is a
;;; constant expression.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Functions

;;; lit : Real -> Literal
;;; GIVEN: a real number
;;; RETURNS: a literal that represents that number
;;; EXAMPLE: (see the example given for literal-value,
;;;          which shows the desired combined behavior
;;;          of lit and literal-value)
;;; DESIGN STRATEGY: Use the constructor template for Literal
(define (lit r)
  (make-literal r))
          
;;; literal-value : Literal -> Real
;;; GIVEN: a literal
;;; RETURNS: the number it represents
;;; EXAMPLE: (literal-value (lit 17.4)) => 17.4
(begin-for-test
  (check-equal? (literal-value (lit 17.4)) 17.4))
          
;;; var : String -> Variable
;;; GIVEN: a string
;;; WHERE: the string begins with a letter and contains
;;;     nothing but letters and digits
;;; RETURNS: a variable whose name is the given string
;;; EXAMPLE: (see the example given for variable-name,
;;;          which shows the desired combined behavior
;;;          of var and variable-name)
;;; DESIGN STRATEGY:Use constructor template for Variable
(define (var str)
  (make-variable str))
          
;;; variable-name : Variable -> String
;;; GIVEN: a variable
;;; RETURNS: the name of that variable
;;; EXAMPLE: (variable-name (var "x15")) => "x15"
(begin-for-test
  (check-equal? (variable-name (var "x15")) "x15"))
          
;;; op : OperationName -> Operation
;;; GIVEN: the name of an operation
;;; RETURNS: the operation with that name
;;; EXAMPLES: (see the examples given for operation-name,
;;;           which show the desired combined behavior
;;;           of op and operation-name)
;;; DESIGN STRATEGY: Use constructor template for Operation
(define (op name)
  (make-operation name))
          
;;; operation-name : Operation -> OperationName
;;; GIVEN: an operation
;;; RETURNS: the name of that operation
;;; EXAMPLES:
;;;     (operation-name (op "+")) => "+"
;;;     (operation-name (op "/")) => "/"
(begin-for-test
  (check-equal? (operation-name (op "+")) "+")
  (check-equal? (operation-name (op "/")) "/"))
          
;;; call : ArithmeticExpression ArithmeticExpressionList -> Call
;;; GIVEN: an operator expression and a list of operand expressions
;;; RETURNS: a call expression whose operator and operands are as
;;;     given
;;; EXAMPLES: (see the examples given for call-operator and
;;;           call-operands, which show the desired combined
;;;           behavior of call and those functions)
;;; DESIGN STRATEGY: Use constructor template for Call
(define (call operator operands)
  (make-call-exp operator operands))
          
;;; call-operator : Call -> ArithmeticExpression
;;; GIVEN: a call
;;; RETURNS: the operator expression of that call
;;; EXAMPLE:
;;;     (call-operator (call (op "-")
;;;                          (list (lit 7) (lit 2.5))))
;;;         => (op "-")
;;; DESIGN STRATEGY: Use observer template for Call
(define (call-operator c)
  (call-exp-operator c))
(begin-for-test
  (check-equal? (call-operator (call (op "-")
                          (list (lit 7) (lit 2.5)))) (op "-")))

;;; call-operands : Call -> ArithmeticExpressionList
;;; GIVEN: a call
;;; RETURNS: the operand expressions of that call
;;; EXAMPLE:
;;;     (call-operands (call (op "-")
;;;                          (list (lit 7) (lit 2.5))))
;;;         => (list (lit 7) (lit 2.5))
;;; DESIGN STRATEGY: Use observer template for Call
(define (call-operands c)
  (call-exp-operands c))
(begin-for-test
  (check-equal? (call-operands (call (op "-")
                          (list (lit 7) (lit 2.5))))
                (list (lit 7) (lit 2.5))))
          
;;; block : Variable ArithmeticExpression ArithmeticExpression
;;;             -> ArithmeticExpression
;;; GIVEN: a variable, an expression e0, and an expression e1
;;; RETURNS: a block that defines the variable's value as the
;;;     value of e0; the block's value will be the value of e1
;;; EXAMPLES: (see the examples given for block-var, block-rhs,
;;;           and block-body, which show the desired combined
;;;           behavior of block and those functions)
;;; DESIGN STRATEGY: Use constructor template for Block
(define (block var e0 e1)
  (make-block-exp var e0 e1))
          
;;; block-var : Block -> Variable
;;; GIVEN: a block
;;; RETURNS: the variable defined by that block
;;; EXAMPLE:
;;;     (block-var (block (var "x5")
;;;                       (lit 5)
;;;                       (call (op "*")
;;;                             (list (var "x6") (var "x7")))))
;;;         => (var "x5")
;;; DESIGN STRATEGY: Use observer template for Block
(define (block-var b)
  (block-exp-var b))
(begin-for-test
  (check-equal? (block-var (block (var "x5") (lit 5) (call (op "*")
                            (list (var "x6") (var "x7")))))
                (var "x5")))
          
;;; block-rhs : Block -> ArithmeticExpression
;;; GIVEN: a block
;;; RETURNS: the expression whose value will become the value of
;;;     the variable defined by that block
;;; EXAMPLE:
;;;     (block-rhs (block (var "x5")
;;;                       (lit 5)
;;;                       (call (op "*")
;;;                             (list (var "x6") (var "x7")))))
;;;         => (lit 5)
;;; DESIGN STRATEGY: Use observer template for Block
(define (block-rhs b)
  (block-exp-rhs b))
(begin-for-test
  (check-equal? (block-rhs (block (var "x5") (lit 5) (call (op "*")
                           (list (var "x6") (var "x7")))))
                (lit 5)))
          
;;; block-body : Block -> ArithmeticExpression
;;; GIVEN: a block
;;; RETURNS: the expression whose value will become the value of
;;;     the block expression
;;; EXAMPLE:
;;;     (block-body (block (var "x5")
;;;                        (lit 5)
;;;                        (call (op "*")
;;;                              (list (var "x6") (var "x7")))))
;;;         => (call (op "*") (list (var "x6") (var "x7")))
;;; DESIGN STRETEGY: Use observer template for Block
(define (block-body b)
  (block-exp-body b))
(begin-for-test
  (check-equal? (block-body (block (var "x5") (lit 5) (call (op "*")
                            (list (var "x6") (var "x7")))))
                (call (op "*") (list (var "x6") (var "x7")))))
          
;;; literal?   : ArithmeticExpression -> Boolean
;;; variable?  : ArithmeticExpression -> Boolean
;;; operation? : ArithmeticExpression -> Boolean
;;; call?      : ArithmeticExpression -> Boolean
;;; block?     : ArithmeticExpression -> Boolean
;;; GIVEN: an arithmetic expression
;;; RETURNS: true if and only the expression is (respectively)
;;;     a literal, variable, operation, call, or block
;;; EXAMPLES:
;;;     (variable? (block-body (block (var "y") (lit 3) (var "z"))))
;;;         => true
;;;     (variable? (block-rhs (block (var "y") (lit 3) (var "z"))))
;;;         => false
(define (call? ae)
  (call-exp? ae))
(define (block? ae)
  (block-exp? ae))
(begin-for-test
  (check-equal?
   (variable? (block-body (block (var "y") (lit 3) (var "z"))))
   true)
  (check-equal?
   (variable? (block-rhs (block (var "y") (lit 3) (var "z"))))
   false)
  (check-equal?
   (call? (call (op "-") (list (lit 7) (lit 2.5)))) true)
  (check-equal?
   (block? (block (var "x5") (lit 5) (call (op "*")
                           (list (var "x6") (var "x7"))))) true))

;;; variables-defined-by : ArithmeticExpression -> StringList
;;; GIVEN: an arithmetic expression
;;; RETURNS: a list of the names of all variables defined by
;;;     all blocks that occur within the expression, without
;;;     repetitions, in any order
;;; EXAMPLE:
;;;     (variables-defined-by
;;;      (block (var "x")
;;;             (var "y")
;;;             (call (block (var "z")
;;;                          (var "x")
;;;                          (op "+"))
;;;                   (list (block (var "x")
;;;                                (lit 5)
;;;                                (var "x"))
;;;                         (var "x")))))
;;;  => (list "x" "z") or (list "z" "x")
;;; DESIGN STRATEGY: Combine simpler functions
(define (variables-defined-by ae)
  (variables-no-repetition
   (variables-defined-by-exp ae)))
(begin-for-test
  (check-equal?
   (variables-defined-by
      (block (var "x")
             (var "y")
             (call (block (var "z")
                          (var "x")
                          (op "+"))
                   (list (block (var "x")
                                (lit 5)
                               (var "x"))
                         (var "x")))))
   (list "z" "x")))

;;; variables-defined-by-exp : ArithmeticExpression -> StringList
;;; GIVEN: an arithmetic expression
;;; RETURNS: a list of the names of all variables defined by
;;;     all blocks that occur within the expression, without
;;;     repetitions, in any order
;;; EXAMPLE:
;;;     (variables-defined-by-exp
;;;      (block (var "x")
;;;             (var "y")
;;;             (call (block (var "z")
;;;                          (var "x")
;;;                          (op "+"))
;;;                   (list (block (var "x")
;;;                                (lit 5)
;;;                                (var "x"))
;;;                         (var "x")))))
;;;  => (list "x" "z") or (list "z" "x")
;;; DESIGN STRATEGY: Use template for
;;;                  ArithmeticExpression/ArithmeticExpressionList
(define (variables-defined-by-exp ae)
  (cond
    [(call? ae) (append (variables-defined-by-exp (call-operator ae))
                        (variables-defined-by-exp-lst (call-operands ae)))]
    [(block? ae) (append (list (variable-name (block-var ae)))
                         (variables-defined-by-exp (block-rhs ae))
                         (variables-defined-by-exp (block-body ae)))]
    [else empty]))
(define (variables-defined-by-exp-lst ae)
  (cond
    [(empty? ae) empty]
    [else (append (variables-defined-by-exp (first ae))
                  (variables-defined-by-exp-lst (rest ae)))]))

;;; variables-no-repetition : StringList -> StringList
;;; GIVEN: a stringlist of variables' names
;;; RETURNS: the given stringlist but after removing repeated strings
;;; DESIGN STRATEGY: Use observer template for StringList
(define (variables-no-repetition vl)
  (cond
    [(empty? vl) empty]
    [else (if (is-repetition? (first vl) (rest vl))
              (variables-no-repetition (rest vl))
              (cons (first vl) (variables-no-repetition (rest vl))))]))

;;; is-repetition? : String StringList -> Boolean
;;; GIVEN: a string and a stringlist
;;; RETURNS: true if the stringlist contains the string
;;; DESIGN STRATEGY: Use observer template for StringList
(define (is-repetition? var-name vl)
  (cond
    [(empty? vl) false]
    [else (if (string=? var-name (first vl))
              true
              (is-repetition? var-name (rest vl)))]))
          
;;; variables-used-by : ArithmeticExpression -> StringList
;;; GIVEN: an arithmetic expression
;;; RETURNS: a list of the names of all variables used in
;;;     the expression, including variables used in a block
;;;     on the right hand side of its definition or in its body,
;;;     but not including variables defined by a block unless
;;;     they are also used
;;; EXAMPLE:
;;;     (variables-used-by
;;;      (block (var "x")
;;;             (var "y")
;;;             (call (block (var "z")
;;;                          (var "x")
;;;                          (op "+"))
;;;                   (list (block (var "x")
;;;                                (lit 5)
;;;                                (var "x"))
;;;                         (var "x")))))
;;;  => (list "x" "y") or (list "y" "x")
;;; DESIGN STRATEGY: Combine simpler functions
(define (variables-used-by ae)
  (variables-no-repetition
   (variables-used-by-exp ae)))

;;; variables-used-by-exp : ArithmeticExpression -> StringList
;;; GIVEN: an arithmetic expression
;;; RETURNS: a list of the names of all variables used in
;;;     the expression, including variables used in a block
;;;     on the right hand side of its definition or in its body,
;;;     but not including variables defined by a block unless
;;;     they are also used
;;; EXAMPLE:
;;;     (variables-used-by-exp
;;;      (block (var "x")
;;;             (var "y")
;;;             (call (block (var "z")
;;;                          (var "x")
;;;                          (op "+"))
;;;                   (list (block (var "x")
;;;                                (lit 5)
;;;                                (var "x"))
;;;                         (var "x")))))
;;;  => (list "y" "x" "x" "x")
;;; DESIGN STRATEGY: Use template for
;;;                  ArithmeticExpression/ArithmeticExpressionList
(define (variables-used-by-exp ae)
  (cond
    [(variable? ae) (list (variable-name ae))]
    [(call? ae) (append (variables-used-by-exp (call-operator ae))
                        (variables-used-by-exp-lst (call-operands ae)))]
    [(block? ae) (append (variables-used-by-exp (block-rhs ae))
                         (variables-used-by-exp (block-body ae)))]
    [else empty]))
(define (variables-used-by-exp-lst ae)
  (cond
    [(empty? ae) empty]
    [else (append (variables-used-by-exp (first ae))
                  (variables-used-by-exp-lst (rest ae)))]))

(begin-for-test
  (check-equal?
   (variables-used-by
      (block (var "x")
             (var "y")
             (call (block (var "z")
                         (var "x")
                          (op "+"))
                   (list (block (var "x")
                                (lit 5)
                                (var "x"))
                         (var "x")))))
   (list "y" "x")))
          
;;; constant-expression? : ArithmeticExpression -> Boolean
;;; GIVEN: an arithmetic expression
;;; RETURNS: true if and only if the expression is a constant
;;;     expression
;;; EXAMPLES:
;;;     (constant-expression?
;;;      (call (var "f") (list (lit -3) (lit 44))))
;;;         => false
;;;     (constant-expression?
;;;      (call (op "+") (list (var "x") (lit 44))))
;;;         => false
;;;     (constant-expression?
;;;      (block (var "x")
;;;             (var "y")
;;;             (call (block (var "z")
;;;                          (call (op "*")
;;;                                (list (var "x") (var "y")))
;;;                          (op "+"))
;;;                   (list (lit 3)
;;;                         (call (op "*")
;;;                               (list (lit 4) (lit 5)))))))
;;;         => true
;;;
;;; DESIGN STRATEGY: Use template for
;;;                  ArithmeticExpression/ArithmeticExpressionList
(define (constant-expression? ae)
  (cond
    [(literal? ae) true]
    [(call? ae) (and (operation-expression? (call-operator ae))
                     (constant-expression-lst? (call-operands ae)))]
    [(block? ae) (constant-expression? (block-body ae))]
    [else false]))
(define (constant-expression-lst? exp-lst)
  (cond
    [(empty? exp-lst) true]
    [else (if (constant-expression? (first exp-lst))
              (constant-expression-lst? (rest exp-lst))
              false)]))

(begin-for-test
  (check-equal?
   (constant-expression?
      (call (var "f") (list (lit -3) (lit 44)))) false)
  (check-equal?
   (constant-expression?
      (call (op "+") (list (var "x") (lit 44)))) false)
  (check-equal?
   (constant-expression?
      (block (var "x")
             (var "y")
             (call (block (var "z")
                          (call (op "*")
                                (list (var "x") (var "y")))
                          (op "+"))
                   (list (lit 3)
                         (call (op "*")
                               (list (lit 4) (lit 5)))))))
   true))

;;; operation-expression? : ArithmeticExpression -> Boolean
;;; GIVEN: an arithmetic expression
;;; RETURNS: true if the expression is am operation expression
;;; DESIGN STRATEGY: Use observer template for Operation
;;;                  Expression
(define (operation-expression? exp)
  (cond
    [(operation? exp) true]
    [(block? exp) (operation-expression? (block-body exp))]
    [else false]))
          
;;; constant-expression-value : ArithmeticExpression -> Real
;;; GIVEN: an arithmetic expression
;;; WHERE: the expression is a constant expression
;;; RETURNS: the numerical value of the expression
;;; EXAMPLES:
;;;     (constant-expression-value
;;;      (call (op "/") (list (lit 15) (lit 3))))
;;;         => 5
;;;     (constant-expression-value
;;;      (block (var "x")
;;;             (var "y")
;;;             (call (block (var "z")
;;;                          (call (op "*")
;;;                                (list (var "x") (var "y")))
;;;                          (op "+"))
;;;                   (list (lit 3)
;;;                         (call (op "*")
;;;                               (list (lit 4) (lit 5)))))))
;;;         => 23
;;; DESIGN STRATEGY: Use template for
;;;                  ArithmeticExpression/ArithmeticExpressionList
(define (constant-expression-value ae)
  (cond
    [(literal? ae) (literal-value ae)]
    [(call? ae) (apply (operation-for-calc
                        (call-operator-for-cal (call-operator ae)))
                 (constant-expression-values (call-operands ae)))]
    [(block? ae) (constant-expression-value (block-body ae))]))
(define (constant-expression-values exp-lst)
  (cond
    [(empty? exp-lst) empty]
    [else (cons (constant-expression-value (first exp-lst))
                (constant-expression-values (rest exp-lst)))]))
(begin-for-test
  (check-equal?
   (constant-expression-value
      (call (op "/") (list (lit 15) (lit 3)))) 5)
  (check-equal?
   (constant-expression-value
      (block (var "x")
             (var "y")
             (call (block (var "z")
                          (call (op "*")
                                (list (var "x") (var "y")))
                          (op "+"))
                   (list (lit 3)
                         (call (op "*")
                               (list (lit 4) (lit 5)))))))
   23))

;;; call-operator-for-cal : Operation-Expression -> Operation
;;; GIVEN: an operation expression
;;; RETURNS: the operator for calcution
;;; DESIGN STRATEGY: Use observer template for Operation Expression
(define (call-operator-for-cal exp)
  (cond
    [(block? exp) (call-operator-for-cal (block-body exp))]
    [(operation? exp) exp]))

;;; operation-for-calc : Operation -> Arithmetic Operation
;;; GIVEN: an operation
;;; RETURNS: an arithmetic operation named after the operation
;;; EXAMPLES:
;;;          (operation-for-calc "+") = +
;;;          (operation-for-calc "-") = -
;;; DESIGN STRATEGY: Use observer template for Operation
(define (operation-for-calc op)
  (cond
    [(string=? (operation-name op) ADDITION) +]
    [(string=? (operation-name op) SUBTRACT) -]
    [(string=? (operation-name op) MULTIPLY) *]
    [(string=? (operation-name op) DIVISION) /]))
(begin-for-test
  (check-equal?
   (operation-for-calc (make-operation "+")) +)
  (check-equal?
   (operation-for-calc (make-operation "-")) -))


