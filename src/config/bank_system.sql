DROP DATABASE IF EXISTS bank_system;
CREATE DATABASE bank_system;

\c bank_system

CREATE TABLE account_type (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE,
  interest_rate NUMERIC(4,2),
  minimum_amount NUMERIC(10,2),
  withdrawal_limit INT,
  description VARCHAR(255)
);

CREATE TABLE branch (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE,
  branch_address VARCHAR(255) UNIQUE,
  contact_number VARCHAR(50) UNIQUE
);

CREATE TABLE customer_type (
  id SERIAL PRIMARY KEY,
  type_name VARCHAR(50) UNIQUE,
  description VARCHAR(255)
);

CREATE TABLE customer (
  id SERIAL PRIMARY KEY,
  nic VARCHAR(12),
  customer_type_id INT REFERENCES customer_type(id) ON DELETE CASCADE ON UPDATE CASCADE,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  address VARCHAR(255),
  phone VARCHAR(10),
  email VARCHAR(255) UNIQUE,
  username VARCHAR(50) UNIQUE,
  password VARCHAR(255),
  date_of_birth_or_origin DATE
);

CREATE TABLE loan_type (
  id SERIAL PRIMARY KEY,
  type_name VARCHAR(50) UNIQUE,
  is_online BOOLEAN,
  description VARCHAR(255)
);

CREATE TABLE loan (
  id SERIAL PRIMARY KEY,
  type_id INT REFERENCES loan_type(id) ON DELETE CASCADE ON UPDATE CASCADE,
  customer_id INT REFERENCES customer(id) ON DELETE CASCADE ON UPDATE CASCADE,
  fixed_deposit_id INT,
  branch_id INT REFERENCES branch(id) ON DELETE CASCADE ON UPDATE CASCADE,
  status TEXT CHECK (status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
  loan_amount NUMERIC(15,2),
  loan_term INT,
  interest_rate NUMERIC(4,2),
  start_date DATE
);

CREATE TABLE account (
  account_number SERIAL PRIMARY KEY,
  account_type_id INT REFERENCES account_type(id) ON DELETE CASCADE ON UPDATE CASCADE,
  customer_id INT REFERENCES customer(id) ON DELETE CASCADE ON UPDATE CASCADE,
  branch_id INT REFERENCES branch(id) ON DELETE CASCADE ON UPDATE CASCADE,
  withdrawals_used INT DEFAULT 0 CHECK (withdrawals_used BETWEEN 0 AND 5),
  acc_balance NUMERIC(15,2) CHECK (acc_balance >= 500)
);

CREATE TABLE loan_installment (
  id SERIAL PRIMARY KEY,
  loan_id INT REFERENCES loan(id) ON DELETE CASCADE ON UPDATE CASCADE,
  installment_amount NUMERIC(15,2),
  paid NUMERIC(15,2),
  next_due_date DATE
);

CREATE TABLE fixed_deposit (
  id SERIAL PRIMARY KEY,
  customer_id INT REFERENCES customer(id) ON DELETE CASCADE ON UPDATE CASCADE,
  account_number INT REFERENCES account(account_number) ON DELETE CASCADE ON UPDATE CASCADE,
  amount NUMERIC(15,2),
  start_date DATE,
  end_date DATE
);

CREATE TABLE transaction_type (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE,
  description VARCHAR(255)
);

CREATE TABLE transaction (
  id SERIAL PRIMARY KEY,
  customer_id INT REFERENCES customer(id) ON DELETE CASCADE ON UPDATE CASCADE,
  from_account_number INT REFERENCES account(account_number) ON DELETE CASCADE ON UPDATE CASCADE,
  to_account_number INT REFERENCES account(account_number) ON DELETE CASCADE ON UPDATE CASCADE,
  amount NUMERIC(15,2),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  transaction_type_id INT REFERENCES transaction_type(id) ON DELETE CASCADE ON UPDATE CASCADE,
  beneficiary_name VARCHAR(255),
  receiver_reference VARCHAR(255),
  my_reference VARCHAR(255)
);

CREATE TABLE position (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE,
  description VARCHAR(255)
);

CREATE TABLE employee (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  address VARCHAR(255),
  phone VARCHAR(10),
  nic VARCHAR(12) UNIQUE,
  email VARCHAR(255) UNIQUE,
  username VARCHAR(50) UNIQUE,
  password VARCHAR(255),
  position_id INT REFERENCES position(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE manager_employee (
  manager_id INT PRIMARY KEY,
  branch_id INT REFERENCES branch(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE general_employee (
  employee_id INT PRIMARY KEY,
  branch_id INT REFERENCES branch(id) ON DELETE CASCADE ON UPDATE CASCADE,
  supervisor_id INT REFERENCES employee(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE action (
  id SERIAL PRIMARY KEY,
  action_name VARCHAR(50) UNIQUE,
  description VARCHAR(255)
);

CREATE TABLE position_action (
  position_id INT REFERENCES position(id) ON DELETE CASCADE ON UPDATE CASCADE,
  action_id INT REFERENCES action(id) ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY (position_id, action_id)
);

CREATE VIEW customer_details AS
SELECT id, address, date_of_birth_or_origin, email, first_name, last_name, nic, phone
FROM customer;

CREATE VIEW employee_details AS
SELECT id, address, email, first_name, last_name, phone, nic, position_id
FROM employee;

CREATE INDEX idx_loan_status ON loan(status);

CREATE INDEX idx_transaction_timestamp ON transaction(timestamp);

CREATE INDEX idx_loan_installment_due_date ON loan_installment(next_due_date);

CREATE OR REPLACE FUNCTION generate_loan_installments()
RETURNS TRIGGER AS $$
DECLARE
    num_installments INT;
    monthly_payment NUMERIC(15,2);
    total_amount NUMERIC(15,2);
    installment_due_date DATE;
    monthly_interest_rate NUMERIC(4,2);
    next_due_date DATE;
BEGIN
    IF NEW.status = 'approved' THEN
        monthly_interest_rate := NEW.interest_rate / 12;
        total_amount := NEW.loan_amount + (NEW.loan_amount * monthly_interest_rate / 100 * NEW.loan_term);
        monthly_payment := total_amount / NEW.loan_term;
        num_installments := NEW.loan_term;
        installment_due_date := NEW.start_date + INTERVAL '1 month';

        WHILE num_installments > 0 LOOP
            IF num_installments = 1 THEN
                next_due_date := NULL;
            ELSE
                next_due_date := installment_due_date + INTERVAL '1 month';
            END IF;

            INSERT INTO loan_installment (loan_id, installment_amount, paid, next_due_date)
            VALUES (NEW.id, monthly_payment, 0, next_due_date);

            installment_due_date := next_due_date;
            num_installments := num_installments - 1;
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_loan_installments
AFTER INSERT ON loan
FOR EACH ROW
EXECUTE FUNCTION generate_loan_installments();

CREATE OR REPLACE FUNCTION branch_wise_transaction_details_last_month(branchId INT)
RETURNS TABLE(
    transaction_id INT,
    customer_id INT,
    from_account_number INT,
    to_account_number INT,
    amount NUMERIC(15,2),
    timestamp TIMESTAMP,
    transaction_type TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id, t.customer_id, t.from_account_number, t.to_account_number, t.amount, t.timestamp, tt.name
    FROM transaction t
    JOIN account a ON t.from_account_number = a.account_number OR t.to_account_number = a.account_number
    JOIN transaction_type tt ON t.transaction_type_id = tt.id
    WHERE a.branch_id = branchId
      AND t.timestamp >= CURRENT_DATE - INTERVAL '1 month'
    ORDER BY t.timestamp DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_branch_transactions(
    emp_id INT,
    start_date DATE,
    end_date DATE
)
RETURNS TABLE(
    transaction_id INT,
    transaction_time TIMESTAMP,
    from_account_number INT,
    to_account_number INT,
    amount NUMERIC(15,2),
    transaction_type TEXT,
    beneficiary_name TEXT,
    receiver_reference TEXT,
    my_reference TEXT
) AS $$
DECLARE
    branchId INT;
BEGIN
    SELECT branch_id INTO branchId
    FROM manager_employee
    WHERE manager_id = emp_id;

    IF branchId IS NULL THEN
        RAISE EXCEPTION 'Branch not found for the provided employee.';
    END IF;

    RETURN QUERY
    SELECT 
        t.id, t.timestamp, t.from_account_number, t.to_account_number, t.amount, tt.name,
        t.beneficiary_name, t.receiver_reference, t.my_reference
    FROM transaction t
    JOIN account a ON t.from_account_number = a.account_number OR t.to_account_number = a.account_number
    JOIN transaction_type tt ON t.transaction_type_id = tt.id
    WHERE a.branch_id = branchId
      AND t.timestamp BETWEEN start_date AND end_date
    ORDER BY t.timestamp DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION branch_wise_late_installments(emp_id INT)
RETURNS TABLE(
    loan_id INT,
    first_name TEXT,
    last_name TEXT,
    next_due_date DATE,
    installment_amount NUMERIC(15,2),
    paid NUMERIC(15,2)
) AS $$
DECLARE
    branchId INT;
BEGIN
    SELECT branch_id INTO branchId 
    FROM manager_employee 
    WHERE manager_id = emp_id;

    IF branchId IS NULL THEN
        RAISE EXCEPTION 'Branch not found for the provided employee.';
    END IF;

    RETURN QUERY
    SELECT 
        l.id, 
        c.first_name, 
        c.last_name, 
        li.next_due_date, 
        li.installment_amount, 
        li.paid
    FROM 
        loan_installment li
    JOIN 
        loan l ON li.loan_id = l.id
    JOIN 
        customer c ON l.customer_id = c.id
    JOIN 
        account a ON a.customer_id = c.id
    WHERE 
        a.branch_id = branchId
        AND li.next_due_date < CURRENT_DATE
        AND li.paid = 0
    ORDER BY 
        li.next_due_date ASC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_recent_transactions_by_branch(emp_id INT)
RETURNS TABLE(
    timestamp TIMESTAMP,
    name TEXT,
    description TEXT,
    amount NUMERIC(15,2)
) AS $$
DECLARE
    branchId INT;
BEGIN
    SELECT branch_id INTO branchId 
    FROM general_employee 
    WHERE employee_id = emp_id;

    IF branchId IS NULL THEN
        RAISE EXCEPTION 'Branch not found for the provided employee.';
    END IF;

    RETURN QUERY
    SELECT t.timestamp, tt.name, tt.description, t.amount
    FROM transaction t
    JOIN account a ON t.from_account_number = a.account_number  
    JOIN customer c ON a.customer_id = c.id 
    JOIN branch b ON a.branch_id = b.id  
    JOIN transaction_type tt ON t.transaction_type_id = tt.id
    WHERE b.id = branchId  
    ORDER BY t.timestamp DESC
    LIMIT 20;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_recent_transactions_for_branch(empId INT)
RETURNS TABLE(
    transaction_id INT,
    timestamp TIMESTAMP,
    account_holder_name TEXT,
    transaction_type TEXT,
    amount NUMERIC(15,2)
) AS $$
DECLARE
    branchId INT;
BEGIN
    SELECT branch_id INTO branchId 
    FROM general_employee 
    WHERE employee_id = empId;

    IF branchId IS NULL THEN
        RAISE EXCEPTION 'Invalid employee ID or branch not found.';
    END IF;

    RETURN QUERY
    SELECT 
        t.id, 
        t.timestamp, 
        CONCAT(c.first_name, ' ', c.last_name), 
        tt.name, 
        t.amount
    FROM 
        transaction t
    JOIN 
        account a ON t.from_account_number = a.account_number 
    JOIN 
        customer c ON a.customer_id = c.id
    JOIN 
        transaction_type tt ON t.transaction_type_id = tt.id
    WHERE 
        a.branch_id = branchId
    ORDER BY 
        t.timestamp DESC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_customer_account_summary(custId INT)
RETURNS TABLE(
    account_number INT,
    account_type TEXT,
    acc_balance NUMERIC(15,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.account_number,
        at.name,
        a.acc_balance
    FROM account a
    JOIN account_type at ON a.account_type_id = at.id
    WHERE a.customer_id = custId;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION do_transaction(
    p_customerId INT,
    p_fromAccount VARCHAR(20),
    p_toAccount VARCHAR(20),
    p_beneficiaryName VARCHAR(255),
    p_amount NUMERIC(10,2),
    p_receiverReference VARCHAR(255),
    p_myReference VARCHAR(255)
) RETURNS VOID AS $$
DECLARE
    v_fromAccountBalance NUMERIC(10,2);
BEGIN
    -- Lock the row for update
    SELECT acc_balance INTO v_fromAccountBalance
    FROM account
    WHERE account_number = p_fromAccount
    FOR UPDATE;

    IF v_fromAccountBalance IS NULL THEN
        RAISE EXCEPTION 'From account not found';
    ELSIF v_fromAccountBalance < p_amount THEN
        RAISE EXCEPTION 'Insufficient balance';
    ELSE
        UPDATE account
        SET acc_balance = acc_balance - p_amount
        WHERE account_number = p_fromAccount;

        UPDATE account
        SET acc_balance = acc_balance + p_amount
        WHERE account_number = p_toAccount;

        INSERT INTO transaction 
            (customer_id, from_account_number, to_account_number, beneficiary_name, amount, receiver_reference, my_reference, transaction_type_id)
        VALUES 
            (p_customerId, p_fromAccount, p_toAccount, p_beneficiaryName, p_amount, p_receiverReference, p_myReference, 3);
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_loan_details(
    p_customerId INT,
    p_loanId INT
) RETURNS TABLE(
    loanId INT,
    loanType TEXT,
    loanStatus TEXT,
    applicationDate DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id, lt.type_name, l.status, l.start_date
    FROM loan l
    JOIN loan_type lt ON l.type_id = lt.id
    WHERE l.customer_id = p_customerId AND l.id = p_loanId;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_pending_loans()
RETURNS TABLE(
    loanId INT,
    loanType TEXT,
    loanAmount NUMERIC(15,2),
    loanTerm INT,
    customerName TEXT,
    loanStatus TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT loan.id, loan_type.type_name, loan.loan_amount, loan.loan_term,
           CONCAT(customer.first_name, ' ', customer.last_name), loan.status
    FROM loan
    JOIN loan_type ON loan.type_id = loan_type.id
    JOIN customer ON loan.customer_id = customer.id
    WHERE loan.status = 'pending';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_loan_status(
    p_loanId INT,
    p_newStatus TEXT
) RETURNS VOID AS $$
BEGIN
    UPDATE loan
    SET status = p_newStatus,
        start_date = CURRENT_DATE
    WHERE id = p_loanId AND status = 'pending';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION process_online_loan()
RETURNS TRIGGER AS $$
DECLARE
    fd_amount NUMERIC(15,2);
    max_loan_amount_by_fd NUMERIC(15,2);
    online_loan_limit NUMERIC(15,2) DEFAULT 500000;
    fd_account_number INT;
    savings_account_number INT;
BEGIN
    IF NEW.status = 'approved' AND NEW.fixed_deposit_id IS NOT NULL AND
       NEW.type_id = (SELECT id FROM loan_type WHERE is_online = TRUE LIMIT 1) THEN

        SELECT amount, account_number INTO fd_amount, fd_account_number
        FROM fixed_deposit
        WHERE id = NEW.fixed_deposit_id;

        max_loan_amount_by_fd := fd_amount * 0.60;

        IF NEW.loan_amount <= max_loan_amount_by_fd AND NEW.loan_amount <= online_loan_limit THEN
            SELECT account_number INTO savings_account_number
            FROM account
            WHERE customer_id = NEW.customer_id AND account_type_id = (
                SELECT id FROM account_type WHERE name LIKE 'Savings%' LIMIT 1);

            UPDATE account
            SET acc_balance = acc_balance + NEW.loan_amount
            WHERE account_number = savings_account_number;
        ELSE
            RAISE EXCEPTION 'Requested loan exceeds the maximum allowed loan limit based on the FD amount';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER process_online_loan
AFTER UPDATE ON loan
FOR EACH ROW
EXECUTE FUNCTION process_online_loan();

CREATE OR REPLACE FUNCTION get_branch_account_summaries(
    empId INT
) RETURNS TABLE(
    account_number INT,
    account_holder_name TEXT,
    account_type TEXT,
    acc_balance NUMERIC(15,2)
) AS $$
DECLARE
    branchId INT;
BEGIN
    SELECT branch_id INTO branchId
    FROM general_employee
    WHERE employee_id = empId;

    IF branchId IS NULL THEN
        RAISE EXCEPTION 'Invalid employee ID or branch not found';
    END IF;

    RETURN QUERY
    SELECT 
        a.account_number, 
        CONCAT(c.first_name, ' ', c.last_name), 
        at.name, 
        a.acc_balance
    FROM account a
    JOIN customer c ON a.customer_id = c.id
    JOIN account_type at ON a.account_type_id = at.id
    WHERE a.branch_id = branchId
    ORDER BY a.account_number;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION request_loan(
    p_customerId INT,
    p_loanTypeId INT,
    p_loanAmount NUMERIC(10, 2),
    p_loanDuration INT
) RETURNS VOID AS $$
DECLARE
    v_fdAmount NUMERIC(15, 2);
    v_fdAccountNumber INT;
    v_maxLoanAmount NUMERIC(15, 2);
    v_savingsAccountNumber INT;
BEGIN
    SELECT amount, account_number INTO v_fdAmount, v_fdAccountNumber
    FROM fixed_deposit
    WHERE customer_id = p_customerId LIMIT 1;

    SELECT account_number INTO v_savingsAccountNumber
    FROM account
    WHERE customer_id = p_customerId
      AND account_type_id IN (SELECT id FROM account_type WHERE name LIKE 'Savings%')
    LIMIT 1;

    -- Additional loan logic would go here

END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    IF v_fdAmount IS NULL THEN
        v_status := 'rejected';
    ELSE
        v_maxLoanAmount := LEAST(v_fdAmount * 0.60, 500000);

        IF p_loanAmount <= v_maxLoanAmount THEN
            v_status := 'approved';

            INSERT INTO loan (
                customer_id, type_id, fixed_deposit_id, branch_id,
                status, loan_amount, loan_term, interest_rate, start_date
            ) VALUES (
                p_customerId, p_loanTypeId, v_fdAccountNumber,
                (SELECT branch_id FROM account WHERE account_number = v_savingsAccountNumber),
                v_status, p_loanAmount, p_loanDuration, 5.00, CURRENT_DATE
            );

            UPDATE account
            SET acc_balance = acc_balance + p_loanAmount
            WHERE account_number = v_savingsAccountNumber;

        ELSE
            v_status := 'rejected';

            INSERT INTO loan (
                customer_id, type_id, fixed_deposit_id, branch_id,
                status, loan_amount, loan_term, interest_rate, start_date
            ) VALUES (
                p_customerId, p_loanTypeId, v_fdAccountNumber,
                (SELECT branch_id FROM account WHERE account_number = v_savingsAccountNumber),
                v_status, p_loanAmount, p_loanDuration, 5.00, CURRENT_DATE
            );
        END IF;
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_loan_amount(loan_id INT)
RETURNS NUMERIC(15,2) AS $$
DECLARE
    principal NUMERIC(15,2);
    rate NUMERIC(5,2);
    total NUMERIC(15,2);
BEGIN
    SELECT loan_amount, interest_rate
    INTO principal, rate
    FROM loan
    WHERE id = loan_id;

    IF principal IS NULL OR rate IS NULL THEN
        RETURN 0;
    END IF;

    total := principal + (principal * rate / 100);

    RETURN total;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION withdrawals_left(acc_number INT)
RETURNS INT AS $$
DECLARE
    used_withdrawals INT DEFAULT 0;
    limit_per_month INT DEFAULT 5;
    remaining_withdrawals INT;
BEGIN
    SELECT withdrawals_used
    INTO used_withdrawals
    FROM account
    WHERE account_number = acc_number;

    remaining_withdrawals := limit_per_month - used_withdrawals;

    IF remaining_withdrawals < 0 THEN
        remaining_withdrawals := 0;
    END IF;

    RETURN remaining_withdrawals;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reset_withdrawals_used()
RETURNS VOID AS $$
BEGIN
    UPDATE account
    SET withdrawals_used = 0;
END
$$ LANGUAGE plpgsql;

INSERT INTO account_type (name, interest_rate, minimum_amount, withdrawal_limit, description)
VALUES 
('Savings - Children', 12.00, 0, 5, 'Savings account for children with high interest and no minimum balance'),
('Savings - Teen', 11.00, 500, 5, 'Savings account for teenagers with moderate interest and a minimum balance'),
('Savings - Adult', 10.00, 1000, 5, 'Savings account for adults with moderate interest and a minimum balance of 1000'),
('Savings - Senior', 13.00, 1000, 5, 'Savings account for seniors with high interest and a minimum balance of 1000'),
('Fixed Deposit - 6 months', 13.00, 5000, 0, '6-month Fixed Deposit account'),
('Fixed Deposit - 1 year', 14.00, 5000, 0, '1-year Fixed Deposit account'),
('Fixed Deposit - 3 years', 15.00, 5000, 0, '3-year Fixed Deposit account');

INSERT INTO branch (name, branch_address, contact_number)
VALUES 
('Head Office', '123 Main St, Capital City', '111-222-3333'),
('North Branch', '45 North St, Uptown', '222-333-4444'),
('South Branch', '67 South St, Downtown', '333-444-5555'),
('East Branch', '123 East St, City', '444-555-6666'),
('West Branch', '456 West St, Suburbs', '555-666-7777');

INSERT INTO customer_type (type_name, description)
VALUES 
('Individual', 'Personal banking for individual customers'),
('Organization', 'Banking services for corporate organizations');

INSERT INTO customer (nic, customer_type_id, first_name, last_name, address, phone, email, username, password, date_of_birth_or_origin)
VALUES 
('123456789V', 1, 'Alice', 'Smith', '456 Elm St', '0115551234', 'alice@example.com', 'alice01', '$2a$10$r997wlXuZyphF2FmjVKleesT7557JQqbFEJMdMXjjFogPSvz2MQhG', '2010-04-15'), 
('987654321V', 1, 'John', 'Doe', '789 Oak St', '0115555678', 'john@example.com', 'john01', '$2a$10$gLl8smHkhUK7xNpAXh62Vut9tt9I8TnwoWePLSdtmiuCAeU0.Goqu', '2005-09-25'), 
('543216789V', 1, 'Sam', 'Adams', '789 Pine St', '0115559876', 'sam@example.com', 'samadams', '$2a$10$DsMGDeS3a/OdcuC59CxkoegWaloDv5hNiquW/pwv7LBmXUYcGb1Ee', '1975-11-30'), 
('321654987V', 1, 'Elder', 'John', '1010 Maple St', '0115550001', 'elderjohn@example.com', 'elderjohn', '$2a$10$oeE4rvCaCldkxBMcrGRJrOc2yxJEbRN7kxWIk8d.Herty1xMSfkje', '1955-03-10'), 
('852963741V', 2, 'XYZ Corp', 'Ltd', '22 Corporate Ave', '0115559876', 'xyzcorp@example.com', 'xyzcorp', '$2a$10$X1aSzbnckesYHrGObXSbReMtWNusBTLGbycKg/wtNzEIK7P6rH8me', '1985-06-10'); 

INSERT INTO loan_type (type_name, is_online, description)
VALUES 
('Business Loan', FALSE, 'Loans for businesses and organizations'),
('Personal Loan', FALSE, 'Personal loans for individual customers'),
('Online Loan', TRUE, 'Instant loan through online application');

INSERT INTO loan 
(type_id, customer_id, fixed_deposit_id, branch_id, status, loan_amount, loan_term, interest_rate, start_date)
VALUES 
(1, 1, NULL, 1, 'approved', 50000.00, 15, 5.50, '2024-10-05'),  
(2, 2, NULL, 2, 'approved', 20000.00, 6, 3.00, '2024-10-08'),  
(3, 3, 1, 3, 'approved', 12000.00, 10, 6.00, '2024-10-02'),     
(1, 4, NULL, 4, 'pending', 30000.00, 10, 4.50, '2024-10-20'),  
(2, 5, NULL, 5, 'pending', 10000.00, 3, 4.00, '2024-10-21'),   
(1, 1, NULL, 1, 'rejected', 40000.00, 15, 5.00, '2024-01-01'), 
(2, 2, NULL, 2, 'rejected', 8000.00, 12, 3.50, '2024-05-08');   

INSERT INTO account (account_number, account_type_id, customer_id, withdrawals_used, acc_balance, branch_id)
VALUES 
(10000001, 1, 1, 2, 1000.00, 1),  
(10000002, 2, 2, 0, 1500.00, 2),  
(10000003, 3, 3, 0, 5000.00, 3),  
(10000004, 4, 4, 0, 10000.00, 4), 
(10000005, 5, 3, 0, 20000.00, 5); 

INSERT INTO fixed_deposit (customer_id, account_number, amount, start_date, end_date)
VALUES 
(1, 10000001, 200000.00, '2024-01-01', '2024-07-01'), 
(2, 10000002, 50000.00, '2024-01-01', '2025-01-01'), 
(3, 10000003, 100000.00, '2024-01-01', '2027-01-01'); 

INSERT INTO transaction

INSERT INTO position (name, description)
VALUES 
('Branch Manager', 'Manager overseeing branch operations'),
('Teller', 'Responsible for day-to-day transactions'),
('Loan Officer', 'Handles loan applications and approvals'),
('Security Officer', 'Responsible for security and safety of the branch'),
('Operations Manager', 'Responsible for overall operations management'),
('Technician', 'Responsible for technical support');

INSERT INTO employee (first_name, last_name, address, phone, nic, email, username, password, position_id)
VALUES 
('Alice', 'Johnson', '101 Lakeview Rd, Hilltown', '0115556789', '567890123V', 'alice@example.com', 'alicejohnson', '$2a$10$AZUi6ySP0oW1VoNnPkRjnuqixJZd6Kf8d5WznprxoNN4oYaZFA9mS', 1), 
('Bob', 'Williams', '250 Oakwood Dr, Greenfield', '0115551122', '987654321V', 'bob@example.com', 'bobwilliams', '$2a$10$mBkCUg3kSI.jR1WfcJPZjORiuQmM3YdMKjZuPnTLUXasmMp67lxiO', 1), 
('Charlie', 'Brown', '762 Cedar Ave, Roseville', '0115553344', '741258963V', 'charlie@example.com', 'charlieb', '$2a$10$tNjDCIrYTYpvNC.pOFOnUOUzqDN2GyM1Yek6ioVLC5ok5cvAOubWu', 1), 
('Diana', 'Smith', '333 Birch Ln, Maple Grove', '0115552233', '852741963V', 'diana@example.com', 'dianasmith', '$2a$10$dpvMriQ6oC20lvisTqVAlOsq2bYzbWOA5vBoWVnn1oh1XF95GIEUe', 1), 
('Edward', 'Johnson', '890 Pine Ridge St, Brookfield', '0115556677', '963258741V', 'edward@example.com', 'edwardjohnson', '$2a$10$akFR0k9YwkB1i8Go/xTfGuuizdEo3AIF.m7HKpyiHn9vbMCyBXhAy', 1), 
('Frank', 'White', '445 Aspen Ct, Silver Springs', '0115554455', '951753486V', 'frank@example.com', 'frankwhite', '$2a$10$AYq3gUc7hokkAaTlBgSCE.APRHc1YVbXXotYqgZqQbxBVun/8e3be', 2), 
('George', 'Adams', '567 Willow St, Elmwood', '0115558899', '789654123V', 'george@example.com', 'georgeadams', '$2a$10$7KS5PwgeLvmrrEzT8SggpeSNO8l3VZxqprG.NHmYBJrvbIIVA2glm', 2), 
('Henry', 'Miller', '789 Spruce Hill Rd, Sunnydale', '0115555566', '852456789V', 'henry@example.com', 'henrymiller', '$2a$10$29wqYcZodno6mit/hc2XNer.VvwG.4i5EpHto4krKNKLFewrX8NbG', 2), 
('Ivy', 'Brown', '120 Forest Creek Dr, Pinewood', '0115557788', '963741852V', 'ivy@example.com', 'ivybrown', '$2a$10$Oi1kd0WAEo5SikWuBYD30.1AoAnGtrzaStGEhI.MgvMjsaNElvmBO', 3), 
('Jack', 'Smith', '982 Magnolia Dr, Riverdale', '0115553344', '147258369V', 'jack@example.com', 'jacksmith', '$2a$10$.Z9FeGcSPUytEjSD5G6hEeqsjGj1VtlhXEEE0V0R2i54SRC5/XNyC', 3), 
('Kate', 'Moore', '348 Evergreen Blvd, Stonebridge', '0115559911', '654321789V', 'kate@example.com', 'katemoore', '$2a$10$o4Fif.wvnuTQRsHY58VQ5OzeXt8yccLo7XEbufR9RBCiDlKs1Mde', 2), 
('Liam', 'Stone', '576 Cherry Blossom Ln, Kingsport', '0115552277', '321654987V', 'liam@example.com', 'liamstone', '$2a$10$VLbACW1gEyqxY6UMLGucXe6aX0eV/DR9Wsl2aVqRqtVk9lG2qyR3i', 2), 
('Michael', 'Parker', '823 Redwood St, Palm Beach', '0115554477', '741852963V', 'michael@example.com', 'michaelparker', '$2a$10$kd0N175zLRVxVRES04EaCuMe8eGb5QVMhoN.ZwKK99HuAD/FVCGbC', 4), 
('Nancy', 'Davis', '104 Mountain View Ave, Clearbrook', '0115555599', '963258147V', 'nancy@example.com', 'nancydavis', '$2a$10$TLKZvY/fyl8Dr.njG0CZ3emI2R9LMDLFcryEfjDcHuFSMyGbETkRO', 4), 
('Oscar', 'Wright', '679 Gardenia Ln, Meadowbrook', '0115556622', '258741963V', 'oscar@example.com', 'oscarwright', '$2a$10$IBN3Lxv6d31aCSxLR0mWUu6d/KndlqsQas9v66CFrpobEMXqNAl4O', 5), 
('Pamela', 'Evans', '234 Sunflower Dr, Sunnyside', '0115558822', '369258147V', 'pamela@example.com', 'pamelaevans', '$2a$10$4Q02H3dYwlU243OwBQnyPO2tGEHtjRF/8qpXWn2lMVfx4FSZHSsbG', 6), 
('Quinn', 'Fisher', '456 Rosewood Ave, Woodland', '0115551122', '147963258V', 'quinn@example.com', 'quinnfisher', '$2a$10$OyDSi7r34ZoBkRpj7npd8e0BZxTLzGZCLLwcRRGUl8N6GZyBVP.9G', 6); 

INSERT INTO manager_employee (manager_id, branch_id)
VALUES 
(1, 1), 
(2, 2), 
(3, 3), 
(4, 4), 
(5, 5); 

INSERT INTO general_employee (employee_id, branch_id, supervisor_id)
VALUES 
(6, 1, 1), 
(7, 2, 2), 
(8, 3, 3), 
(9, 4, 4), 
(10, 5, 5), 
(11, 1, 6), 
(12, 2, 7), 
(13, 3, 8), 
(14, 4, 9), 
(15, 5, 10), 
(16, 1, 6), 
(17, 2, 7); 

INSERT INTO action (action_name, description)
VALUES 
('Approve Loan', 'Approve a loan application'),
('Deny Loan', 'Deny a loan application'),
('Transfer Funds', 'Transfer funds between accounts.'),
('Physical Security Check', 'Perform a physical security check at the branch'),
('Manage Operations', 'Manage day-to-day operations at the branch'),
('Technical Support', 'Provide technical support for branch systems');

INSERT INTO position_action (position_id, action_id) 
VALUES 
(1, 1), 
(1, 2), 
(1, 5), 
(3, 1), 
(3, 2), 
(2, 3), 
(4, 4), 
(6, 6);

UPDATE loan_installment 
SET next_due_date = '2024-09-10', paid = 0
WHERE id = 1;

UPDATE loan_installment 
SET next_due_date = '2024-09-15', paid = 0
WHERE id = 2;

UPDATE loan_installment 
SET next_due_date = '2024-08-30', paid = 0
WHERE id = 3;

UPDATE loan_installment 
SET next_due_date = '2024-09-25', paid = 0
WHERE id = 4;

UPDATE loan_installment 
SET next_due_date = '2024-10-01', paid = 0
WHERE id = 5;
