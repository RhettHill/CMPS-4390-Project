/*
TEAM NAME: Goated
TEAM MEMBERS' NAME: Rhett Hill, Muhamad Warrad
Instructions
- Descriptions must reflect a business operation's need
- One query for each item (Q..) is enough. E.g.,forQD1: CREATE TABLE, write
a DDL query to create one of your project's tables. Similar for the others.
- You must use the exact format
- Project a few attributes only unless otherwise said
- Do not change the order of the queries
*/
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DDL QUERIES
--QD1: CREATE TABLE ...
/*
Instructions:
- Must define PK
- Must define a default value as needed
*/


--Keeps track of members id and info
CREATE TABLE Member (
    id Serial PRIMARY Key,
    member_id VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    membership_date DATE DEFAULT CURRENT_DATE,
    Bio VARCHAR(255)
);



--QD2: ALTER TABLE ...
----Description: Unneeded column.....................

ALTER TABLE Member DROP COLUMN Bio;


--QD3: ADD "CHECK" CONSTRAINT:
----Description: Makes sure a Fine is never under the minimum amount.....................

ALTER TABLE Fine ADD CONSTRAINT check_fine_amount CHECK (amount >= 0.5);


--QD4: ADD FK CONSTRAINT(S) TO THE TABLE
/*
Instructions:
- Must define action
- At least one of the FKs must utilize the default value
*/
----Description: Alters the fk constraint for the book-author relation .....................

ALTER TABLE Book ADD CONSTRAINT fk_author FOREIGN KEY (author_id)
REFERENCES Author(author_id) ON DELETE SET NULL;


--QD5: Create TRIGGER ...
----Description: Calculated fine amount for overdue Book.....................

CREATE OR REPLACE FUNCTION apply_fine_if_overdue()
RETURNS TRIGGER AS $$
DECLARE 
    overdue_days INT;
    fine_amount NUMERIC;
BEGIN
    -- Check if return_date is after due_date, and if it's not NULL
    IF NEW.return_date IS NOT NULL AND NEW.return_date > NEW.due_date THEN
        -- Calculate overdue days
        overdue_days := NEW.return_date - NEW.due_date;
        fine_amount := overdue_days * 0.50;
        INSERT INTO Fine (fine_id, transaction_id, amount, is_payed)
        VALUES ('F' || nextval('fine_seq'), NEW.transaction_id, fine_amount, FALSE);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;




--Checks if a book is overdue when it is returned
CREATE TRIGGER check_overdue_fine
AFTER INSERT OR UPDATE ON Transaction
FOR EACH ROW
WHEN (NEW.return_date IS NOT NULL AND NEW.return_date > NEW.due_date)
EXECUTE FUNCTION apply_fine_if_overdue();






-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DML QUERIES



--QM1.1: A TEST QUERY FOR THE TRIGGER CREATED in QD5:
----Description: Inserting an overdue book.....................


INSERT INTO Transaction(book_id, member_id, checkout_date, due_date, return_date)
VALUES ('OL81634W', 'M5', '2025-02-26','2025-03-12','2025-03-19')


--QM1.2: A TEST QUERY FOR THE "CHECK" CONSTRAINT DEFINED in QD3:
----Description: Fine is below minimum value and will not work.....................

INSERT INTO Fine (fine_id, transaction_id, amount, is_payed)
VALUES ('F2', 'T2', 0.00, FALSE);


--QM1.3: A TEST QUERY FOR THE FK CONSTRAINT DEFINED in QD4:
----Description: Should set the fk to null in book table.....................

DELETE FROM author WHERE author_id = 'pearl_s._buck';

