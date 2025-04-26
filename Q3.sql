/*
TEAM NAME:Byte Size
TEAM MEMBERS' NAME:Rhett Hill, Muhamad Warrad
Instructions
- Descriptions must reflect a business operation's need
- One query for each item (Q..) is enough. E.g.,forQD1: CREATE TABLE, write
a DDL query to create one of your project's tables. Similar for the others.
- You must use the exact format
- Project a few attributes only unless otherwise said
- Do not change the order of the queries
*/
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DML QUERIES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--QM9.1: INNER-JOIN-QUERY WITH WHERE CLAUSE:
----Description: Returns all transactions with fine information

SELECT book_id, member_id,checkout_date,due_date, return_date, amount
from transaction t INNER JOIN fine f on t.transaction_id = f.transaction_id
WHERE f.is_payed = FALSE

--QM9.2: LEFT-OUTER-JOIN-QUERY WITH WHERE CLAUSE:
----Instruction: The query must return NULL DUE TO MISMATCHING TUPLES
during the outer join:
----Description: returns all members and transactions of non returned books

SELECT * 
FROM member m 
LEFT OUTER JOIN transaction t 
    ON m.member_id = t.member_id
WHERE t.return_date IS NULL;
AND t.transaction_id IS NOT NULL




--QM9.3: RIGHT-OUTER-JOIN-QUERY WITH WHERE CLAUSE:
----Instruction: The query must return NULL DUE TO MISMATCHING TUPLES
during the outer join:
----Description: returns transaction info for all horror genre books

select *
from transaction t right join book b on t.book_id = b.book_id
where b.genre = 'Horror'


--QM9.4: FULL-OUTER-JOIN-QUERY WITH WHERE CLAUSE:
----Instruction: The query must return NULL DUE TO MISMATCHING TUPLES
from LEFT and RIGHT tables due to the outer join:
----Description: Retuns authors who have no books and books that have no authors

SELECT * 
FROM author a  
FULL OUTER JOIN book b
  ON a.author_id = b.author_id
WHERE  a.author_id IS NULL OR b.author_id IS NULL;

--QM10.1: AGGREGATION-JOIN-QUERY WITH GROUP BY & HAVING:
----Description: shows members who have made more than 2 transactions

SELECT m.member_id, m.first_name,m.Last_name, COUNT(t.transaction_id) AS borrow_count
FROM member m
JOIN transaction t ON m.member_id = t.member_id
GROUP BY m.member_id, m.first_name, m.last_name
HAVING COUNT(t.transaction_id) > 2;


--QM10.2: AGGREGATION-JOIN-QUERY WITH SUB-QUERY:
----Description: Shows members who have checked out more books than the average

SELECT m.member_id, m.first_name, m.last_name, COUNT(t.transaction_id) AS borrow_count
FROM member m
JOIN transaction t ON m.member_id = t.member_id
GROUP BY m.member_id, m.first_name, m.last_name
HAVING COUNT(t.transaction_id) > (
  SELECT AVG(borrow_count)
  FROM (
    SELECT COUNT(*) AS borrow_count
    FROM transaction
    GROUP BY member_id
  ) AS member_borrow_counts
);



--QM11: WITH-QUERY:
----Description: Returns the top 5 members who borrowed the most books

WITH borrow_counts AS (
  SELECT m.member_id, m.first_name, m.last_name, COUNT(t.transaction_id) AS total_borrowed
  FROM member m
  JOIN transaction t ON m.member_id = t.member_id
  GROUP BY m.member_id, m.first_name, m.last_name
)
SELECT * 
FROM borrow_counts
ORDER BY total_borrowed DESC
LIMIT 5;
