(use coops)

(define-class <fragment> ()
  (name))

(define-method (->sql (stmt <fragment>))
  (sql-quote name))

(define-class <field> (<fragment>)
  (name))

(define-class <table> (<fragment>))

(define-class <join> (<fragment>)
  (tables))

(define-class <query> ()
  (table
   fields
   conditions))

(define-class <select> (<query>)
  (join
   group-by
   order-by
   limit))

(define-class <condition> (<fragment>)
  (children))

(define-method (has-children? (object  <condition>))
  (slot-value object 'children))

(define-class <where> (<condition>))

(define (from table #!optional fields)
  (let ([select (make <select> 'table (make <table> 'name table) 'fields (add-fields fields))])
    select))

(define (add-fields fields)
  (let ([->field (lambda (f)
                   (make <field> 'name f))])
    (if fields
        (if (list? fields)
            (map ->field fields)
            (list (->field fields)))
        (list (->field "*")))))

(define *conditions*
  '(
    (= sql-=)
    (like sql-like)
    (>= sql->=)
    (<= sql-<=)
    (in sql-in)
    (and sql-and)
    (or sql-or)))

(define (with-value-if-present object field #!key default procedure)
  (let ([value (slot-value object field)])
    (if value
        (if procedure
            (procedure value)
            value)
        (if default
            default
            ""))))

(define-method (->sql (object <select>))
  (string-trim
   (string-append
    (string-intersperse (list " "
                              "select"
                              (sql-enumerate (slot-value object 'fields))
                              "from"
                              (->sql (slot-value object 'table)))))))

(define-method (->sql (fragment <fragment>))
  (sql-quote (slot-value fragment 'name)))

(define-method (->sql (field <field>))
  (if (equal? (slot-value field 'name) "*")
      "*"
      (sql-quote (slot-value field 'name))))

(define-method (->sql (table <table>))
  (sql-quote (slot-value table 'name) quote-type: "\""))

(define (sql-enumerate lst)
  (if (list? lst)
      (string-intersperse (map (lambda (item)
                                 (sql-enumerate item)) lst) ",")
      (->sql lst)))

(define (sql-quote something #!key (quote-type "'"))
  (if (list? something)
      (string-intersperse (map (lambda (item)
                                 (sql-quote item)) something) ",")
      (string-append quote-type (->string something) quote-type)))
