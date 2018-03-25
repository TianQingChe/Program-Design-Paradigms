;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "07" "q1.rkt")

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
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DATA DEFINITIONS

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
;;; name: String the name of the variable

;;; IMPLEMENTATION:
(define-struct variable (name))

;;; CONSTRUCTOR TEMPLATE
;;; (make-variable String)

;;; A Operation is represented as a struct
;;; (make-operation name)
;;; INTEPRETATION:
;;; name: OperationName the name of the operation

;;; IMPLEMENTATION:
(define-struct operation (name))

;;; CONSTRUCTOR TEMPLATE
;;; (make-operation OperationName)

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

;;; An ArithmeticExpressionList is represented as a list of
;;; ArithmeticExpressions.

;;; CONSTRUCTOR TEMPLATE AND INTERPRETATION
;;; empty                  -- the empty sequence
;;; (cons exp exp-lst)
;;;   WHERE:
;;;    exp     is an ArithmeticExpression
;;;            -- the first arithmetic expression in the sequence                           
;;     exp-lst is an ArithmeticExpressionList  
;;             -- the rest of the arithmetic expressions in the sequence

;; OBSERVER TEMPLATE:
;; al-fn : ArithmeticExpressionList  -> ??
;;(define (al-fn lst)
;;  (cond
;;    [(empty? lst) ...]
;;    [else (... (first lst)
;;               (al-fn (rest lst)))]))

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
;;;             -> Block
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
          
;;; undefined-variables : ArithmeticExpression -> StringList
;;; GIVEN: an arbitrary arithmetic expression
;;; RETURNS: a list of the names of all undefined variables
;;;     for the expression, without repetitions, in any order
;;; EXAMPLE:
;;;     (undefined-variables
;;;      (call (var "f")
;;;            (list (block (var "x")
;;;                         (var "x")
;;;                         (var "x"))
;;;                  (block (var "y")
;;;                         (lit 7)
;;;                         (var "y"))
;;;                  (var "z"))))
;;;  => some permutation of (list "f" "x" "z")
;;; When a variable is defined by a block, its region is the body of the block.
;;; otherwise it is undefined
;;; DESIGN STRATEGY: Combine simpler functions
(define (undefined-variables ae)
  (remove-lst (defined-variables ae)
              (all-variables-in-exp ae)))

(begin-for-test
  (check-equal?
   (undefined-variables
      (call (var "f")
            (list (block (var "x")
                         (var "x")
                         (var "x"))
                  (block (var "y")
                         (lit 7)
                         (var "y"))
                  (var "z"))))
   (list "f" "x" "z")))

;;; defined-variables : ArithmeticExpression -> StringList
;;; GIVEN: an arbitrary arithmetic expression
;;; RETURNS: a list of the names of all defined variables
;;;     for the expression, without repetitions, in any order
;;; EXAMPLE:
;;;     (defined-variables
;;;      (call (var "f")
;;;            (list (block (var "x")
;;;                         (var "x")
;;;                         (var "x"))
;;;                  (block (var "y")
;;;                         (lit 7)
;;;                         (var "y"))
;;;                  (var "z"))))
;;;  => (list "y")
;;; When a variable is defined by a block, its region is the body of the block.
;;; otherwise it is undefined
;;; DESIGN STRATEGY: Combine simpler functions
(define (defined-variables ae)
  (variables-no-repetition (defined-variables-by-exp ae)))

(begin-for-test
  (check-equal?
   (defined-variables
      (call (var "f")
            (list (block (var "x")
                         (var "x")
                         (var "x"))
                  (block (var "y")
                         (lit 7)
                         (var "y"))
                  (var "z"))))
   (list "y")))

;;; defined-variables-by-exp : ArithmeticExpression -> StringList
;;; GIVEN: an arbitrary arithmetic expression
;;; RETURNS: a list of the names of all defined variables
;;;     for the expression, without removing repetitions, in any order
;;; EXAMPLE:
;;;     (defined-variables-by-exp
;;;      (block (var "x")
;;;             (var "y")
;;;             (call (block (var "z")
;;;                          (var "x")
;;;                          (op "+"))
;;;                   (list (block (var "x")
;;;                                (lit 5)
;;;                                (var "x"))
;;;                         (var "x")))))
;;;  => (list "x" "x")
;;; When a variable is defined by a block, its region is the body of the block.
;;; otherwise it is undefined
;;; DESIGN STRATEGY: Use template for
;;;                  ArithmeticExpression/ArithmeticExpressionList
(define (defined-variables-by-exp ae)
  (cond
    [(call? ae) (append (defined-variables-by-exp (call-operator ae))
                        (defined-variables-by-exp-lst (call-operands ae)))]
    [(block? ae) (append (defined-variable-by-block (block-var ae) ae)
                         (defined-variables-by-exp (block-body ae)))]
    [else empty]))
(define (defined-variables-by-exp-lst ae)
  (cond
    [(empty? ae) empty]
    [else (append (defined-variables-by-exp (first ae))
                  (defined-variables-by-exp-lst (rest ae)))]))

(begin-for-test
  (check-equal?
   (defined-variables-by-exp
      (block (var "x")
             (var "y")
             (call (block (var "z")
                         (var "x")
                          (op "+"))
                   (list (block (var "x")
                                (lit 5)
                                (var "x"))
                         (var "x")))))
   (list "x" "x")))

;;; defined-variable-by-block : Variable Block -> StringList
;;; GIVEN: a variable v and a block b
;;; RETURNS: a stringlist only contains the name of the variable if the
;;;          variable is not contained in the block's rhs and contained in  
;;;          the block's body, otherwise return empty
;;; EXAMPLES:
;;;         (defined-variable-by-block (var "x") (block (var "x")
;;;                                                     (var "x")
;;;                                                      (op "+"))
;;;          => empty
;;;         (defined-variable-by-block (var "x") (block (var "x")
;;;                                                     (var "y")
;;;                                                     (var "x"))
;;;          => (list "x")
;;; DESIGN STRATEGY: Caes on whether variable is in block's body and
;;;                  not in its rhs 
(define (defined-variable-by-block v b)
  (if (and (not (variables-in-block-rhs? v b)) (variables-in-block-body? v b))
      (list (variable-name v))
      empty))

(begin-for-test
  (check-equal?
   (defined-variable-by-block (var "x") (block (var "x")
                                               (var "x")
                                               (op "+")))
   empty)
  (check-equal?
   (defined-variable-by-block (var "x") (block (var "x")
                                               (var "y")
                                               (var "x")))
   (list "x")))

;;; variables-in-block-rhs? : Variable Block -> Boolean
;;; GIVEN: a variable v and a block b
;;; RETURNS: true if the variable v is contained in the block's rhs
;;; EXAMPLES: (variables-in-block-rhs? (var "x") (block (var "x")
;;;                                                     (var "x")
;;;                                                     (op "+")))
;;;          => true
;;;          (variables-in-block-rhs? (var "x") (block (var "x")
;;;                                                    (var "y")
;;;                                                    (var "x")))
;;;          => false
;;; DESIGN STRATEGY: Call helper functions contains and 
;;;                  all-variables-in-exp 
(define (variables-in-block-rhs? v b)
  (contains? (variable-name v) (all-variables-in-exp (block-rhs b))))

;;; variables-in-block-body? : Variable Block -> Boolean
;;; GIVEN: a variable v and a block b
;;; RETURNS: true if the variable v is contained in the block's body
;;; EXAMPLES: (variables-in-block-body? (var "x") (block (var "x")
;;;                                                      (var "x")
;;;                                                      (op "+")))
;;;          => false
;;;          (variables-in-block-body? (var "x") (block (var "x")
;;;                                                     (var "y")
;;;                                                     (var "x")))
;;;          => true
;;; DESIGN STRATEGY: Call helper functions contains and 
;;;                  all-variables-in-exp 
(define (variables-in-block-body? v b)
  (contains? (variable-name v) (all-variables-in-exp (block-body b))))

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
    [(call? ae) (append (all-variables (call-operator ae))
                        (all-variables-in-exp-lst (call-operands ae)))]
    [(block? ae) (append (list (variable-name (block-var ae)))
                         (all-variables (block-rhs ae))
                         (all-variables (block-body ae)))]
    [else empty]))
(define (all-variables-in-exp-lst ae)
  (cond
    [(empty? ae) empty]
    [else (append (all-variables (first ae))
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

;;; remove-lst : StringList StringList -> StringList
;;; GIVEN: a StringList sub-sl and a StringList sl
;;; RETURNS: the stringlist sl after removing same strings 
;;;          in sub-sl
;;; EXAMPLE：(remove-lst (list "x" "y") (list "a" "x" "y" "z"))
;;;          => (list "a" "z")
;;; DESIGN STRATEGY: Use HOF filter on sl
(define (remove-lst sub-sl sl)
  (filter
   ;;; String -> Boolean
   ;;; true if the string is not contained in sub-sl
   (lambda (x) (not (contains? x sub-sl)))
   sl))
(begin-for-test
  (check-equal?
   (remove-lst (list "x" "y") (list "a" "x" "y" "z"))
   (list "a" "z")))

