DROP DATABASE `bank_system`;
CREATE DATABASE `bank_system`;
USE `bank_system`;

CREATE TABLE `account_type` (
  `id` INT AUTO_INCREMENT,
  `name` VARCHAR(50),
  `interest_rate` DECIMAL(4,2),
  `minimum_amount` DECIMAL(10,2),
  `withdrawal_limit` INT,
  `description` VARCHAR(255),
  PRIMARY KEY (`id`),
  UNIQUE KEY (`name`)
);

CREATE TABLE `branch` (
  `id` INT AUTO_INCREMENT,
  `name` VARCHAR(255),
  `branch_address` VARCHAR(255),
  `contact_number` VARCHAR(50),
  PRIMARY KEY (`id`),
  UNIQUE KEY (`name`),
  UNIQUE KEY (`branch_address`),
  UNIQUE KEY (`contact_number`)
);

CREATE TABLE `customer_type` (
  `id` INT AUTO_INCREMENT,
  `type_name` VARCHAR(50),
  `description` VARCHAR(255),
  PRIMARY KEY (`id`),
  UNIQUE KEY (`type_name`)
);

CREATE TABLE `customer` (
  `id` INT AUTO_INCREMENT,
  `nic` VARCHAR(12),
  `customer_type_id` INT,
  `first_name` VARCHAR(255),
  `last_name` VARCHAR(255),
  `address` VARCHAR(255),
  `phone` VARCHAR(10),
  `email` VARCHAR(255),
  `username` VARCHAR(50),
  `password` VARCHAR(255),
  `date_of_birth_or_origin` DATE,
  PRIMARY KEY (`id`),
  UNIQUE KEY(`email`), 
  UNIQUE KEY (`username`)
);

CREATE TABLE `loan_type` (
  `id` INT AUTO_INCREMENT,
  `type_name` VARCHAR(50),
  `is_online` BOOLEAN,
  `description` VARCHAR(255),
  PRIMARY KEY (`id`),
  UNIQUE KEY (`type_name`)
);

CREATE TABLE `loan` (
  `id` INT AUTO_INCREMENT,
  `type_id` INT,
  `customer_id` INT,
  `fixed_deposit_id` INT NULL,
  `branch_id` INT,
  `status` ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
  `loan_amount` DECIMAL(15,2),
  `loan_term` INT,
  `interest_rate` DECIMAL(4,2),
  `start_date` DATE,
  PRIMARY KEY (`id`)
);

CREATE TABLE `account` (
  `account_number` INT(8) ZEROFILL AUTO_INCREMENT,
  `account_type_id` INT,
  `customer_id` INT,
  `withdrawals_used` INT default 0,
  `acc_balance` DECIMAL(15,2),
  `branch_id` INT,
  CHECK (`withdrawals_used` BETWEEN 0 AND 5),
  CHECK (`acc_balance` >= 500),
  PRIMARY KEY (`account_number`)
);

CREATE TABLE `loan_installment` (
  `id` INT AUTO_INCREMENT,
  `loan_id` INT,
  `installment_amount` DECIMAL(15,2),
  `paid` DECIMAL(15,2),
  `next_due_date` DATE,
  PRIMARY KEY (`id`)
);

CREATE TABLE `fixed_deposit` (
  `id` INT AUTO_INCREMENT,
  `customer_id` INT,
  `account_number` INT(8) ZEROFILL,
  `amount` DECIMAL(15,2),
  `start_date` DATE,
  `end_date` DATE,
  PRIMARY KEY (`id`)
);

CREATE TABLE `transaction_type` (
  `id` INT AUTO_INCREMENT,
  `name` VARCHAR(50),
  `description` VARCHAR(255),
  PRIMARY KEY (`id`),
  UNIQUE KEY (`name`)
);

CREATE TABLE `transaction` (
  `id` INT AUTO_INCREMENT,
  `customer_id` INT,
  `from_account_number` INT(8) ZEROFILL,
  `to_account_number` INT(8) ZEROFILL,
  `amount` DECIMAL(15,2),
  `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `transaction_type_id` INT,
  `beneficiary_name` VARCHAR(255),
  `receiver_reference` VARCHAR(255),
  `my_reference` VARCHAR(255),
  PRIMARY KEY (`id`)
);

CREATE TABLE `position` (
  `id` INT AUTO_INCREMENT,
  `name` VARCHAR(50),
  `description` VARCHAR(255),
  PRIMARY KEY (`id`),
  UNIQUE KEY (`name`)
);

CREATE TABLE `employee` (
  `id` INT AUTO_INCREMENT,
  `first_name` VARCHAR(255),
  `last_name` VARCHAR(255),
  `address` VARCHAR(255),
  `phone` VARCHAR(10),
  `nic` VARCHAR(12),
  `email` VARCHAR(255),
  `username` VARCHAR(50),
  `password` VARCHAR(255),
  `position_id` INT,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`nic`), 
  UNIQUE KEY (`email`), 
  UNIQUE KEY (`username`)
);

CREATE TABLE `manager_employee` (
  `manager_id` INT,
  `branch_id` INT,
  PRIMARY KEY (`manager_id`)
);

CREATE TABLE `general_employee` (
  `employee_id` INT,
  `branch_id` INT,
  `supervisor_id` INT,
  PRIMARY KEY (`employee_id`)
);

CREATE TABLE `action` (
  `id` INT AUTO_INCREMENT,
  `action_name` VARCHAR(50),
  `description` VARCHAR(255),
  PRIMARY KEY (`id`),
  UNIQUE KEY (`action_name`)
);

CREATE TABLE `position_action` (
  `position_id` INT,
  `action_id` INT,
  PRIMARY KEY (`position_id`, `action_id`)
);


ALTER TABLE `customer`
ADD FOREIGN KEY (`customer_type_id`) REFERENCES `customer_type`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `loan`
ADD FOREIGN KEY (`customer_id`) REFERENCES `customer`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`type_id`) REFERENCES `loan_type`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`branch_id`) REFERENCES `branch`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `account`
ADD FOREIGN KEY (`customer_id`) REFERENCES `customer`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`branch_id`) REFERENCES `branch`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`account_type_id`) REFERENCES `account_type`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `loan_installment`
ADD FOREIGN KEY (`loan_id`) REFERENCES `loan`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `fixed_deposit`
ADD FOREIGN KEY (`customer_id`) REFERENCES `customer`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`account_number`) REFERENCES `account`(`account_number`)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `transaction`
ADD FOREIGN KEY (`from_account_number`) REFERENCES `account`(`account_number`)
ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`to_account_number`) REFERENCES `account`(`account_number`)
ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`transaction_type_id`) REFERENCES `transaction_type`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `employee`
ADD FOREIGN KEY (`position_id`) REFERENCES `position`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `manager_employee`
ADD FOREIGN KEY (`branch_id`) REFERENCES `branch`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `general_employee`
ADD FOREIGN KEY (`branch_id`) REFERENCES `branch`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`supervisor_id`) REFERENCES `employee`(`id`)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `position_action`
ADD FOREIGN KEY (`position_id`) REFERENCES `position`(`id`) 
ON DELETE CASCADE ON UPDATE CASCADE,
ADD FOREIGN KEY (`action_id`) REFERENCES `action`(`id`) 
ON DELETE CASCADE ON UPDATE CASCADE;


CREATE VIEW customer_details AS
SELECT `id`, `address`, `date_of_birth_or_origin`, `email`, `first_name`, `last_name`, `nic`, `phone`
FROM `customer`;

CREATE VIEW `employee_details` AS
SELECT `id`,`address`, `email`, `first_name`, `last_name`, `phone`, `nic`, `position_id`
FROM `employee`;


CREATE INDEX idx_loan_status ON `loan`(`status`);

CREATE INDEX idx_transaction_timestamp ON `transaction`(`timestamp`);

CREATE INDEX idx_loan_installment_due_date ON `loan_installment`(`next_due_date`);


DELIMITER $$

CREATE TRIGGER generate_loan_installments
AFTER INSERT ON `loan`
FOR EACH ROW
BEGIN
  DECLARE num_installments INT;
  DECLARE monthly_payment DECIMAL(15,2);
  DECLARE total_amount DECIMAL(15,2);
  DECLARE installment_due_date DATE;
  DECLARE monthly_interest_rate DECIMAL(4,2);
  DECLARE next_due_date DATE;

  IF NEW.status = 'approved' THEN
    SET monthly_interest_rate = NEW.interest_rate / 12;

    SET total_amount = NEW.loan_amount + (NEW.loan_amount * monthly_interest_rate / 100 * NEW.loan_term);

    SET monthly_payment = total_amount / NEW.loan_term;

    SET num_installments = NEW.loan_term;

    SET installment_due_date = DATE_ADD(NEW.start_date, INTERVAL 1 MONTH);

    WHILE num_installments > 0 DO
      IF num_installments = 1 THEN
        SET next_due_date = NULL;
      ELSE
        SET next_due_date = DATE_ADD(installment_due_date, INTERVAL 1 MONTH);
      END IF;

      INSERT INTO loan_installment (loan_id, installment_amount, paid, next_due_date)
      VALUES (NEW.id, monthly_payment, 0, next_due_date);

      SET installment_due_date = next_due_date;

      SET num_installments = num_installments - 1;
    END WHILE;
  END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE `branch_wise_transaction_details_last_month`(IN branchId INT)
BEGIN
  SELECT t.id AS transaction_id, t.customer_id, t.from_account_number, t.to_account_number, 
         t.amount, t.timestamp, tt.name AS transaction_type
  FROM transaction t
  JOIN account a ON t.from_account_number = a.account_number OR t.to_account_number = a.account_number
  JOIN transaction_type tt ON t.transaction_type_id = tt.id
  WHERE a.branch_id = branchId
    AND t.timestamp >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
  ORDER BY t.timestamp DESC;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE get_branch_transactions(
    IN emp_id INT,
    IN start_date DATE,
    IN end_date DATE
)
BEGIN
    DECLARE branchId INT;

    SELECT branch_id INTO branchId 
    FROM manager_employee 
    WHERE manager_id = emp_id;

    SELECT branchId AS fetched_branch_id;

    IF branchId IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Branch not found for the provided employee.';
    END IF;

    SELECT 
        t.id AS transaction_id,
        t.timestamp AS transaction_time,
        t.from_account_number,
        t.to_account_number,
        t.amount,
        tt.name AS transaction_type,
        t.beneficiary_name,
        t.receiver_reference,
        t.my_reference
    FROM 
        transaction t
    JOIN 
        account a ON t.from_account_number = a.account_number 
                   OR t.to_account_number = a.account_number
    JOIN 
        transaction_type tt ON t.transaction_type_id = tt.id
    WHERE 
        a.branch_id = branchId
        AND t.timestamp BETWEEN start_date AND end_date
    ORDER BY 
        t.timestamp DESC;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE branch_wise_late_installments(
    IN emp_id INT
)
BEGIN
    DECLARE branchId INT;

    SELECT branch_id INTO branchId 
    FROM manager_employee 
    WHERE manager_id = emp_id;

    SELECT branchId AS fetched_branch_id;

    IF branchId IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Branch not found for the provided employee.';
    END IF;

    SELECT 
        l.id AS loan_id, 
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
        AND li.next_due_date < CURDATE()
        AND li.paid = 0
    ORDER BY 
        li.next_due_date ASC;
END $$

DELIMITER ;


DELIMITER $$
CREATE PROCEDURE get_recent_transactions_by_branch(IN emp_id INT)
BEGIN
    DECLARE branchId INT;
    
    SELECT branch_id INTO branchId 
    FROM general_employee 
    WHERE employee_id = emp_id;

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
DELIMETER ;


DELIMITER $$

CREATE PROCEDURE `get_recent_transactions_for_branch`(IN empId INT)
BEGIN
    DECLARE branchId INT;

    SELECT branch_id INTO branchId 
    FROM general_employee 
    WHERE employee_id = empId;

    IF branchId IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid employee ID or branch not found.';
    END IF;

    SELECT 
        t.id AS transaction_id, 
        t.timestamp, 
        CONCAT(c.first_name, ' ', c.last_name) AS account_holder_name, 
        tt.name AS transaction_type, 
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
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE GetCustomerAccountSummary(IN custId INT)
BEGIN
    SELECT 
        a.account_number,
        at.name AS account_type,
        a.acc_balance
    FROM account a
    JOIN account_type at ON a.account_type_id = at.id
    WHERE a.customer_id = custId;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE DoTransaction(
    IN p_customerId INT,
    IN p_fromAccount VARCHAR(20),
    IN p_toAccount VARCHAR(20),
    IN p_beneficiaryName VARCHAR(255),
    IN p_amount DECIMAL(10,2),
    IN p_receiverReference VARCHAR(255),
    IN p_myReference VARCHAR(255)
)
BEGIN
    DECLARE v_fromAccountBalance DECIMAL(10,2);

    START TRANSACTION;

    SELECT acc_balance INTO v_fromAccountBalance
    FROM account
    WHERE account_number = p_fromAccount
    FOR UPDATE;  

    IF v_fromAccountBalance IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'From account not found';
    ELSEIF v_fromAccountBalance < p_amount THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient balance';
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

        COMMIT;
    END IF;
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE GetLoanDetails(
    IN p_customerId INT,
    IN p_loanId INT
)
BEGIN
    SELECT l.id AS loanId, 
           lt.type_name AS loanType, 
           l.status AS loanStatus, 
           l.start_date AS applicationDate
    FROM loan l
    JOIN loan_type lt ON l.type_id = lt.id
    WHERE l.customer_id = p_customerId 
      AND l.id = p_loanId;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE GetPendingLoans()
BEGIN
    SELECT loan.id AS loanId, 
           loan_type.type_name AS loanType, 
           loan.loan_amount, 
           loan.loan_term, 
           CONCAT(customer.first_name, ' ', customer.last_name) AS customerName, 
           loan.status
    FROM loan
    JOIN loan_type ON loan.type_id = loan_type.id
    JOIN customer ON loan.customer_id = customer.id
    WHERE loan.status = 'pending';
END $$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE UpdateLoanStatus(IN p_loanId INT, IN p_newStatus VARCHAR(50))
BEGIN
    UPDATE loan
    SET 
      status = p_newStatus,
      start_date = CURDATE()
    WHERE id = p_loanId AND status = 'pending';
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER process_online_loan
AFTER UPDATE ON `loan`
FOR EACH ROW
BEGIN
  DECLARE fd_amount DECIMAL(15,2);
  DECLARE max_loan_amount_by_fd DECIMAL(15,2);
  DECLARE deposit_amount DECIMAL(15,2);
  DECLARE fd_account_number INT;
  DECLARE savings_account_number INT;
  DECLARE online_loan_limit DECIMAL(15,2) DEFAULT 500000;

  IF NEW.status = 'approved' AND NEW.fixed_deposit_id IS NOT NULL AND NEW.type_id = (
      SELECT id FROM loan_type WHERE is_online = TRUE LIMIT 1) THEN

    SELECT amount, account_number INTO fd_amount, fd_account_number
    FROM fixed_deposit
    WHERE id = NEW.fixed_deposit_id;

    SET max_loan_amount_by_fd = CAST(fd_amount * 0.60 AS DECIMAL(15,2));

    IF NEW.loan_amount <= max_loan_amount_by_fd AND NEW.loan_amount <= online_loan_limit THEN
      SELECT account_number INTO savings_account_number
      FROM account
      WHERE customer_id = NEW.customer_id AND account_type_id = (
          SELECT id FROM account_type WHERE name LIKE 'Savings%' LIMIT 1);

      UPDATE account
      SET acc_balance = acc_balance + NEW.loan_amount
      WHERE account_number = savings_account_number;
      
    ELSE
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Requested loan exceeds the maximum allowed loan limit based on the FD amount';
    END IF;

  END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE GetBranchAccountSummaries(IN empId INT)
BEGIN
    DECLARE branchId INT;

    SELECT branch_id INTO branchId 
    FROM general_employee 
    WHERE employee_id = empId;

    IF branchId IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid employee ID or branch not found.';
    END IF;

    SELECT 
        a.account_number, 
        CONCAT(c.first_name, ' ', c.last_name) AS account_holder_name, 
        at.name AS account_type, 
        a.acc_balance
    FROM 
        account a
    JOIN 
        customer c ON a.customer_id = c.id
    JOIN 
        account_type at ON a.account_type_id = at.id
    WHERE 
        a.branch_id = branchId
    ORDER BY 
        a.account_number;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE RequestLoan (
    IN p_customerId INT,
    IN p_loanTypeId INT,
    IN p_loanAmount DECIMAL(10, 2),
    IN p_loanDuration INT
)
BEGIN
    DECLARE v_fdAmount DECIMAL(15, 2);
    DECLARE v_fdAccountNumber INT;
    DECLARE v_maxLoanAmount DECIMAL(15, 2);
    DECLARE v_savingsAccountNumber INT;
    DECLARE v_status ENUM('approved', 'rejected');

    SELECT amount, account_number
    INTO v_fdAmount, v_fdAccountNumber
    FROM fixed_deposit
    WHERE customer_id = p_customerId
    LIMIT 1;

    SELECT account_number
    INTO v_savingsAccountNumber
    FROM account
    WHERE customer_id = p_customerId
      AND account_type_id IN (
          SELECT id FROM account_type WHERE name LIKE 'Savings%'
      )
    LIMIT 1;

    IF v_fdAmount IS NULL THEN
        SET v_status = 'rejected';
    ELSE
        SET v_maxLoanAmount = LEAST(v_fdAmount * 0.60, 500000);

        IF p_loanAmount <= v_maxLoanAmount THEN
            SET v_status = 'approved';

            INSERT INTO loan (
                customer_id, type_id, fixed_deposit_id, branch_id,
                status, loan_amount, loan_term, interest_rate, start_date
            ) VALUES (
                p_customerId, p_loanTypeId, v_fdAccountNumber,
                (SELECT branch_id FROM account WHERE account_number = v_savingsAccountNumber),
                v_status, p_loanAmount, p_loanDuration, 5.00, CURDATE()
            );

            UPDATE account
            SET acc_balance = acc_balance + p_loanAmount
            WHERE account_number = v_savingsAccountNumber;

        ELSE
            SET v_status = 'rejected';

            INSERT INTO loan (
                customer_id, type_id, fixed_deposit_id, branch_id,
                status, loan_amount, loan_term, interest_rate, start_date
            ) VALUES (
                p_customerId, p_loanTypeId, v_fdAccountNumber,
                (SELECT branch_id FROM account WHERE account_number = v_savingsAccountNumber),
                v_status, p_loanAmount, p_loanDuration, 5.00, CURDATE()
            );
        END IF;
    END IF;
END $$


DELIMITER ;

DELIMITER $$

CREATE FUNCTION calculate_loan_amount(
    loan_id INT 
) RETURNS DECIMAL(15,2) 
DETERMINISTIC 
BEGIN
    DECLARE principal DECIMAL(15,2); 
    DECLARE rate DECIMAL(5,2); 
    DECLARE total DECIMAL(15,2); 

    SELECT loan_amount, interest_rate 
    INTO principal, rate
    FROM loan 
    WHERE id = loan_id;

    IF principal IS NULL OR rate IS NULL THEN
        RETURN 0;
    END IF;

    SET total = principal + (principal * rate / 100);

    RETURN total;
END $$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION withdrawals_left(
    acc_number INT 
) RETURNS INT 
DETERMINISTIC 
BEGIN
    DECLARE used_withdrawals INT DEFAULT 0; 
    DECLARE limit_per_month INT DEFAULT 5; 
    DECLARE remaining_withdrawals INT; 
    DECLARE account_count INT; 

    SELECT COUNT(*) INTO account_count 
    FROM account 
    WHERE account_number = acc_number; 

    IF account_count > 1 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'More than one account found with the given account number';
    END IF;

    SELECT withdrawals_used 
    INTO used_withdrawals 
    FROM account 
    WHERE account_number = acc_number 
    LIMIT 1;

    SET remaining_withdrawals = limit_per_month - used_withdrawals;

    IF remaining_withdrawals < 0 THEN
        SET remaining_withdrawals = 0;
    END IF;

    RETURN remaining_withdrawals;
END $$

DELIMITER ;


DELIMITER $$

CREATE EVENT reset_withdrawals_used
ON SCHEDULE EVERY 1 MONTH
STARTS (LAST_DAY(CURRENT_DATE) + INTERVAL 1 DAY)
DO
BEGIN
    UPDATE account
    SET withdrawals_used = 0;
END $$

DELIMITER ;


INSERT INTO `account_type` (`name`, `interest_rate`, `minimum_amount`, `withdrawal_limit`, `description`)
VALUES 
('Savings - Children', 12.00, 0, 5, 'Savings account for children with high interest and no minimum balance'),
('Savings - Teen', 11.00, 500, 5, 'Savings account for teenagers with moderate interest and a minimum balance'),
('Savings - Adult', 10.00, 1000, 5, 'Savings account for adults with moderate interest and a minimum balance of 1000'),
('Savings - Senior', 13.00, 1000, 5, 'Savings account for seniors with high interest and a minimum balance of 1000'),
('Fixed Deposit - 6 months', 13.00, 5000, 0, '6-month Fixed Deposit account'),
('Fixed Deposit - 1 year', 14.00, 5000, 0, '1-year Fixed Deposit account'),
('Fixed Deposit - 3 years', 15.00, 5000, 0, '3-year Fixed Deposit account');

INSERT INTO `branch` (`name`, `branch_address`, `contact_number`)
VALUES 
('Head Office', '123 Main St, Capital City', '111-222-3333'),
('North Branch', '45 North St, Uptown', '222-333-4444'),
('South Branch', '67 South St, Downtown', '333-444-5555'),
('East Branch', '123 East St, City', '444-555-6666'),
('West Branch', '456 West St, Suburbs', '555-666-7777');

INSERT INTO `customer_type` (`type_name`, `description`)
VALUES 
('Individual', 'Personal banking for individual customers'),
('Organization', 'Banking services for corporate organizations');

INSERT INTO `customer` (`nic`, `customer_type_id`, `first_name`, `last_name`, `address`, `phone`, `email`, `username`, `password`, `date_of_birth_or_origin`)
VALUES 
('123456789V', 1, 'Alice', 'Smith', '456 Elm St', '0115551234', 'alice@example.com', 'alice01', '$2a$10$r997wlXuZyphF2FmjVKleesT7557JQqbFEJMdMXjjFogPSvz2MQhG', '2010-04-15'), 
('987654321V', 1, 'John', 'Doe', '789 Oak St', '0115555678', 'john@example.com', 'john01', '$2a$10$gLl8smHkhUK7xNpAXh62Vut9tt9I8TnwoWePLSdtmiuCAeU0.Goqu', '2005-09-25'), 
('543216789V', 1, 'Sam', 'Adams', '789 Pine St', '0115559876', 'sam@example.com', 'samadams', '$2a$10$DsMGDeS3a/OdcuC59CxkoegWaloDv5hNiquW/pwv7LBmXUYcGb1Ee', '1975-11-30'), 
('321654987V', 1, 'Elder', 'John', '1010 Maple St', '0115550001', 'elderjohn@example.com', 'elderjohn', '$2a$10$oeE4rvCaCldkxBMcrGRJrOc2yxJEbRN7kxWIk8d.Herty1xMSfkje', '1955-03-10'), 
('852963741V', 2, 'XYZ Corp', 'Ltd', '22 Corporate Ave', '0115559876', 'xyzcorp@example.com', 'xyzcorp', '$2a$10$X1aSzbnckesYHrGObXSbReMtWNusBTLGbycKg/wtNzEIK7P6rH8me', '1985-06-10'); 

INSERT INTO `loan_type` (`type_name`, `is_online`, `description`)
VALUES 
('Business Loan', FALSE, 'Loans for businesses and organizations'),
('Personal Loan', FALSE, 'Personal loans for individual customers'),
('Online Loan', TRUE, 'Instant loan through online application');

INSERT INTO `loan` 
(`type_id`, `customer_id`, `fixed_deposit_id`, `branch_id`, `status`, `loan_amount`, `loan_term`, `interest_rate`, `start_date`)
VALUES 
(1, 1, NULL, 1, 'approved', 50000.00, 15, 5.50, '2024-10-05'),  
(2, 2, NULL, 2, 'approved', 20000.00, 6, 3.00, '2024-10-08'),  
(3, 3, 1, 3, 'approved', 12000.00, 10, 6.00, '2024-10-02'),     

(1, 4, NULL, 4, 'pending', 30000.00, 10, 4.50, '2024-10-20'),  
(2, 5, NULL, 5, 'pending', 10000.00, 3, 4.00, '2024-10-21'),   

(1, 1, NULL, 1, 'rejected', 40000.00, 15, 5.00, '2024-01-01'), 
(2, 2, NULL, 2, 'rejected', 8000.00, 12, 3.50, '2024-05-08');   

INSERT INTO `account` (`account_number`, `account_type_id`, `customer_id`, `withdrawals_used`, `acc_balance`, `branch_id`)
VALUES 
(10000001, 1, 1, 2, 1000.00, 1),  
(10000002, 2, 2, 0, 1500.00, 2),  
(10000003, 3, 3, 0, 5000.00, 3),  
(10000004, 4, 4, 0, 10000.00, 4), 
(10000005, 5, 3, 0, 20000.00, 5); 

INSERT INTO `fixed_deposit` (`customer_id`, `account_number`, `amount`, `start_date`, `end_date`)
VALUES 
(1, 10000001, 200000.00, '2024-01-01', '2024-07-01'), 
(2, 10000002, 50000.00, '2024-01-01', '2025-01-01'), 
(3, 10000003, 100000.00, '2024-01-01', '2027-01-01'); 

INSERT INTO `transaction_type` (`name`, `description`)
VALUES 
('Deposit', 'Deposit money into an account.'),
('Withdrawal', 'Withdraw money from an account.'),
('Transfer', 'Transfer money between accounts.');

INSERT INTO `transaction` (`customer_id`, `from_account_number`, `to_account_number`, `amount`, `transaction_type_id`, `beneficiary_name`, `receiver_reference`, `my_reference`, `timestamp`)
VALUES 
(1, 10000001, 10000002, 500.00, 1, 'John Doe', 'ABC123', 'XYZ987', '2024-07-10 17:57:39'),  
(2, 10000002, 10000003, 1000.00, 2, 'Sam Adams', 'DEF456', 'XYZ654', '2024-08-02 17:57:39'),  
(3, 10000003, 10000001, 2000.00, 3, 'Alice Smith', 'GHI789', 'XYZ321', '2024-09-25 17:57:39'),  
(4, 10000004, 10000002, 750.00, 1, 'Elder John', 'JKL012', 'XYZ876', '2024-09-21 17:57:39'),  
(5, 10000005, 10000003, 1200.00, 2, 'XYZ Corp', 'MNO345', 'XYZ543', '2024-09-14 17:57:39'),  
(1, 10000001, 10000002, 2500.00, 1, 'John Doe', 'ABC123', 'XYZ987', '2024-09-24 17:57:39'),  
(2, 10000002, 10000003, 3500.00, 2, 'Sam Adams', 'DEF456', 'XYZ654', '2024-10-27 17:57:39'),  
(3, 10000003, 10000001, 5000.00, 3, 'Alice Smith', 'GHI789', 'XYZ321', '2024-10-18 17:57:39'),  
(4, 10000004, 10000002, 7500.00, 1, 'Elder John', 'JKL012', 'XYZ876', '2024-10-12 17:57:39'),  
(5, 10000005, 10000003, 12000.00, 2, 'XYZ Corp', 'MNO345', 'XYZ543', '2024-10-16 17:57:39');  

INSERT INTO `position` (`name`, `description`)
VALUES 
('Branch Manager', 'Manager overseeing branch operations'),
('Teller', 'Responsible for day-to-day transactions'),
('Loan Officer', 'Handles loan applications and approvals'),
('Security Officer', 'Responsible for security and safety of the branch'),
('Operations Manager', 'Responsible for overall operations management'),
('Technician', 'Responsible for technical support');

INSERT INTO `employee` (`first_name`, `last_name`, `address`, `phone`, `nic`, `email`, `username`, `password`, `position_id`)
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
('Kate', 'Moore', '348 Evergreen Blvd, Stonebridge', '0115559911', '654321789V', 'kate@example.com', 'katemoore', '$2a$10$o4Fif.wvnuTQRsHY58VQ5OzeXt8yccLo7XEbufR9xRBCiDlKs1Mde', 2), 
('Liam', 'Stone', '576 Cherry Blossom Ln, Kingsport', '0115552277', '321654987V', 'liam@example.com', 'liamstone', '$2a$10$VLbACW1gEyqxY6UMLGucXe6aX0eV/DR9Wsl2aVqRqtVk9lG2qyR3i', 2), 
('Michael', 'Parker', '823 Redwood St, Palm Beach', '0115554477', '741852963V', 'michael@example.com', 'michaelparker', '$2a$10$kd0N175zLRVxVRES04EaCuMe8eGb5QVMhoN.ZwKK99HuAD/FVCGbC', 4), 
('Nancy', 'Davis', '104 Mountain View Ave, Clearbrook', '0115555599', '963258147V', 'nancy@example.com', 'nancydavis', '$2a$10$TLKZvY/fyl8Dr.njG0CZ3emI2R9LMDLFcryEfjDcHuFSMyGbETkRO', 4), 
('Oscar', 'Wright', '679 Gardenia Ln, Meadowbrook', '0115556622', '258741963V', 'oscar@example.com', 'oscarwright', '$2a$10$IBN3Lxv6d31aCSxLR0mWUu6d/KndlqsQas9v66CFrpobEMXqNAl4O', 5), 
('Pamela', 'Evans', '234 Sunflower Dr, Sunnyside', '0115558822', '369258147V', 'pamela@example.com', 'pamelaevans', '$2a$10$4Q02H3dYwlU243OwBQnyPO2tGEHtjRF/8qpXWn2lMVfx4FSZHSsbG', 6), 
('Quinn', 'Fisher', '456 Rosewood Ave, Woodland', '0115551122', '147963258V', 'quinn@example.com', 'quinnfisher', '$2a$10$OyDSi7r34ZoBkRpj7npd8e0BZxTLzGZCLLwcRRGUl8N6GZyBVP.9G', 6); 

INSERT INTO `manager_employee` (`manager_id`, `branch_id`)
VALUES 
(1, 1), 
(2, 2), 
(3, 3), 
(4, 4), 
(5, 5); 

INSERT INTO `general_employee` (`employee_id`, `branch_id`, `supervisor_id`)
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

INSERT INTO `action` (`action_name`, `description`)
VALUES 
('Approve Loan', 'Approve a loan application'),
('Deny Loan', 'Deny a loan application'),
('Transfer Funds', 'Transfer funds between accounts.'),
('Physical Security Check', 'Perform a physical security check at the branch'),
('Manage Operations', 'Manage day-to-day operations at the branch'),
('Technical Support', 'Provide technical support for branch systems');

INSERT INTO `position_action` (`position_id`, `action_id`) 
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
