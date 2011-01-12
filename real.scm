(use coops)

(define-class <query> ()
  (table
   fields
   conditions))

(define-class <select> (<query>)
  (join
   group-by
   order-by
   limit))

(define (from table #!optional fields)
  (make <select> 'table table 'fields fields))

(define-method (->sql (object <select>))
  (string-trim
   (string-append
    (string-intersperse (list " "
                              "select"
                              (if (slot-value object 'fields)
                                  (sql-quote (slot-value object 'fields))
                                  "*")
                              "from"
                              (sql-quote (slot-value object 'table) quote-type: "\""))))))

(define (sql-quote something #!key (quote-type "'"))
  (if (list? something)
      (string-intersperse (map (lambda (item)
                                 (sql-quote item)) something) ",")
      (string-append quote-type (->string something) quote-type)))
