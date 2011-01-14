(use coops)
(use test)

(include "real.scm")

(test-group "Select queries"
            (test "Should be able to perform a simple select"
                  "select * from \"teste\""
                  (->sql (from "teste")))
            (test "Should be able to perform a select, returning the given fields"
                  "select 'field1','field2','field3' from \"teste\""
                  (->sql (from "teste" '(field1 field2 field3))))
            (test-group "Conditions"
                        (test "Should be able to perform a simple where"
                              "select * from \"teste\" where 1 = 1"
                              (->sql (where (= 1 1 (from "teste")))))))