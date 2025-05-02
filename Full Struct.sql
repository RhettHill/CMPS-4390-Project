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

CREATE TABLE Author (
    id Serial PRIMARY Key,
    author_id VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL
);


CREATE TABLE Book (
    id Serial PRIMARY Key,
    book_id VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    author_id VARCHAR(50) REFERENCES Author(author_id) ON DELETE SET NULL,
    genre VARCHAR(100) DEFAULT NULL
);



CREATE SEQUENCE member_seq START 1;


CREATE TABLE Member (
    id Serial PRIMARY Key,
    member_id VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    membership_date DATE DEFAULT CURRENT_DATE,
    Bio VARCHAR(255)
);

CREATE SEQUENCE transaction_seq START 1;


CREATE TABLE Transaction (
    id Serial PRIMARY Key,
    transaction_id VARCHAR(10) UNIQUE NOT NULL,
    book_id VARCHAR(50) REFERENCES Book(book_id) ON DELETE CASCADE,
    member_id VARCHAR(50) REFERENCES Member(member_id) ON DELETE SET NULL,
    checkout_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    return_date DATE DEFAULT NULL
);


CREATE SEQUENCE fine_seq START 1;


CREATE TABLE Fine (
    id Serial PRIMARY Key,
    fine_id VARCHAR(10) UNIQUE NOT NULL,
    transaction_id VARCHAR(50) UNIQUE REFERENCES Transaction(transaction_id) ON DELETE CASCADE,
    amount DECIMAL(6,2) NOT NULL CHECK (amount >= 0),
    is_payed BOOLEAN DEFAULT FALSE
);


CREATE TABLE Staff (
    id Serial PRIMARY Key,
    staff_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE DEFAULT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('Librarian', 'Assistant', 'Archivist', 'Manager')),
    hire_date DATE DEFAULT CURRENT_DATE
);




--QD2: ALTER TABLE ...
----Description: .....................

ALTER TABLE Member DROP COLUMN Bio;
ALTER TABLE Member ALTER COLUMN member_id SET DEFAULT 'M' || nextval('member_seq');
ALTER TABLE Fine ALTER COLUMN fine_id SET DEFAULT 'F' || nextval('fine_seq');
ALTER TABLE Transaction ALTER COLUMN transaction_id SET DEFAULT 'T' || nextval('transaction_seq');



--QD3: ADD "CHECK" CONSTRAINT:
----Description: .....................

ALTER TABLE Fine ADD CONSTRAINT check_fine_amount CHECK (amount >= 0.5);


--QD4: ADD FK CONSTRAINT(S) TO THE TABLE
/*
Instructions:
- Must define action
- At least one of the FKs must utilize the default value
*/
----Description: .....................

ALTER TABLE Book
ALTER COLUMN author_id SET DEFAULT NULL;

ALTER TABLE Book 
ADD CONSTRAINT fk_author 
    FOREIGN KEY (author_id)
    REFERENCES Author(author_id)
    ON DELETE SET NULL;


--QD5: Create TRIGGER ...
----Description: .....................




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
        
        -- Check if a fine already exists for this transaction_id
        IF NOT EXISTS (SELECT 1 FROM Fine WHERE transaction_id = NEW.transaction_id) THEN
            -- Insert a new fine only if the transaction_id does not exist
            INSERT INTO Fine (fine_id, transaction_id, amount, is_payed)
            VALUES ('F' || nextval('fine_seq'), NEW.transaction_id, fine_amount, FALSE);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;






CREATE TRIGGER check_overdue_fine
AFTER INSERT OR UPDATE ON Transaction
FOR EACH ROW
WHEN (NEW.return_date IS NOT NULL AND NEW.return_date > NEW.due_date)
EXECUTE FUNCTION apply_fine_if_overdue();






-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DML QUERIES



--QM1.1: A TEST QUERY FOR THE TRIGGER CREATED in QD5:
----Description: .....................

UPDATE Transaction
SET return_date = '2025-03-22'
WHERE transaction_id = 'T1';


--QM1.2: A TEST QUERY FOR THE "CHECK" CONSTRAINT DEFINED in QD3:
----Description: .....................


-- This insert should fail because the amount is less than 1, violating the CHECK constraint.
INSERT INTO Fine (fine_id, transaction_id, amount, is_payed)
VALUES ('F2', 'T2', 0.00, FALSE);


--QM1.3: A TEST QUERY FOR THE FK CONSTRAINT DEFINED in QD4:
----Description: .....................

DELETE FROM Book WHERE book_id = 'OL98501W';

