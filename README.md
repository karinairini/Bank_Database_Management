# Banking Database Management System

## Overview

This project focuses on the development and management of a relational database for a banking system. The project aims to provide a secure, efficient, and scalable database solution that handles crucial banking operations, such as customer account management, transactions, loans, payments, and employee performance tracking.

The system is designed to ensure data integrity, security, and recovery through the implementation of various mechanisms such as constraints, triggers, stored procedures, and scheduled jobs.

## Features

### 1. Database Structure
The database is designed to reflect the main entities and relationships in a modern financial institution, including:
- **Clients**
- **Accounts**
- **Cards**
- **Transfers**
- **Employees**
- **Credits**

### 2. Key Relations
- **Client and Account**: M:N relationship through a join table.
- **Client and Card**: 1:N relationship, where one client can have multiple cards.
- **Account and Credit**: 1:N relationship, as one account can have multiple credits.
- **Employee and Payment**: 1:N relationship for employees processing payments.

### 3. Views
- **AccountClients**: Displays account details with their respective account holders.
- **TransferDetails**: Provides details on transfers between accounts, including the involved clients.
- **CreditPaymentSummary**: A summary of active credits and payments made.
- **EmployeePerformanceSummary**: Analyzes employee performance in processing payments.

### 4. Stored Procedures
- **AddClient**: Adds a new client to the database.
- **UpdateCardState**: Updates the status of a card (e.g., to block it).
- **ExecuteTransfer**: Executes and processes a transfer between accounts.
- **DeleteExpiredCards**: Deletes expired cards from the database.
- **InsertTransfer**: Inserts a new transfer and processes it.

### 5. Functions
- **GetAccountBalanceByCardAndPin**: Returns the account balance using a card number and PIN.
- **GetAverageAnnualPayment**: Calculates the average annual payment for an account with associated credits.
- **CalculateUpdatedSum**: Calculates the updated loan amount, including simple interest.
- **CalculateMonthlyRate**: Computes the monthly rate for a loan or credit.
- **GetTransfersByClient**: Retrieves transfers made by a specific client.

### 6. Triggers (DML and DDL)
- **trg_UpdateAmount_OnInsertCredit**: Updates the credit amount and monthly rate after inserting a new credit.
- **trg_UpdateCreditStatus**: Updates the status of a credit after a payment is recorded.
- **trg_DeleteAccount**: Prevents the deletion of accounts with pending credits or transfers.
- **trg_LogDDLChanges**: Logs DDL changes like CREATE, ALTER, and DROP operations on tables.
- **trg_PreventDropSensitiveTables**: Prevents the deletion of critical tables like Credit and Account.

### 7. Cursors
- **ClientAccountCursor**: Iterates through client and account data, providing account balances and types.
- **CreditCursor**: Updates active credits with new interest rates.
- **SalaryCursor**: Updates employee salaries based on inflation.
- **RejectedCreditCursor**: Removes rejected credits from the database.
- **ClientCursor**: Combines data from multiple tables to display detailed client information.

### 8. Users and Permissions
- **Administrator**: Full control over the database (GRANT CONTROL).
- **Employee**: Limited permissions for executing specific procedures (e.g., AddClient, DeleteExpiredCards).
- **Client**: Limited access to personal data and procedures (e.g., GetAccountBalanceByCardAndPin).

### 9. SQL Jobs
- **CountPaymentsJob**: Counts payments made on the previous day and logs them in a PaymentLog table.
- **BackupTablesJob**: Creates daily backups of essential tables to ensure data recovery.

### 10. Backup and Restore
- **Full Backup**: Creates a complete backup of the database with an option to overwrite existing files.
- **Differential Backup**: Backs up only the changes made since the last full backup.
- **Restore**: Restores the database from a full or differential backup, ensuring recovery.
