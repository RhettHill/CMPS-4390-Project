
/*
TEAM NAME:
TEAM MEMBERS' NAME:
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
--QM2: INSERT DATA:
----Description: Inserts a transaction for a checked out book
Insert into Transaction(book_id,member_id,checkout_date,due_date,return_date)
VALUES ('OL45846W', 'M8', '2025-04-03', '2025-04-16', null);


--QM3: UPDATE DATA:
----Description: Sets the return date for a transaction
Update Table Transaction
set return_date = '2025-04-12'
WHERE transaction_id = 'T34'

--QM4: DELETE DATA:
----Description: Deletes a transaction

Delete from Transaction WHERE transaction_id = 'T34'

--QM5: QUERY DATA WITH WHERE CLAUSE:
----Description: Returns Books that were either returned late or not returned
SELECT b.id, b.title, t.due_date, t.return_date
FROM book b JOIN transaction t on b.book_id=t.book_id
WHERE (return_date is null ) OR
( NOT (return_date is  null) AND
(return_date - due_date >0)
)
--QM6.1: QUERY DATA WITH 'SUB-QUERY IN WHERE CLAUSE':
----Description: Returns all transactions that have an unpaid fine
SELECT *
FROM transaction
WHERE transaction_id in (SELECT * FROM fine WHERE is_payed = FALSE)

--QM6.2: QUERY DATA WITH SUB-QUERY IN FROM CLAUSE:
----Description: Get all members who returned a book late

SELECT m.first_name, m.last_name, late_returns.transaction_id, late_returns.return_date, late_returns.due_date
FROM (
    SELECT transaction_id, member_id, return_date, due_date
    FROM Transaction
    WHERE return_date IS NOT NULL AND return_date > due_date
) AS late_returns
JOIN Member m ON m.member_id = late_returns.member_id;



--QM6.3: QUERY DATA WITH 'SUB-QUERY IN SELECT CLAUSE':
----Description: Show each transaction with its fine amount (if it exists)

SELECT 
    t.transaction_id,t.book_id,t.member_id,t.due_date,t.return_date,
    (
        SELECT f.amount
        FROM Fine f
        WHERE f.transaction_id = t.transaction_id
    )
FROM Transaction t
WHERE t.return_date IS NOT NULL;

--QM7: QUERY DATA WITH EXCEPT:
-- Description: Show all members who have not made any transactions

SELECT member_id
FROM Member
EXCEPT(
SELECT member_id
FROM Transaction);

--QM8.1: QUERY DATA WITH ANY/SOME:
-- Description: Show all members who have made a transaction

SELECT first_name,last_name
FROM Member
WHERE member_id = ANY (
    SELECT member_id
    FROM Transaction
);


--QM8.2: QUERY DATA WITH ALL in front of a sub-query:
-- Description: Returns the transaction with the highest fine amount

SELECT book_id, member_id, checkout_date, due_date, return_date, amount, is_payed
FROM Transaction t JOIN fine f ON t.transaction_id = f.transaction_id
WHERE amount >= ALL (
    SELECT amount
    FROM Fine
);


Annotations
