USE Bank;

DROP USER IF EXISTS Employee;
DROP USER IF EXISTS Client;
DROP USER IF EXISTS Administrator;

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Employee')
    DROP LOGIN Employee;

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Client')
    DROP LOGIN Client;

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Administrator')
    DROP LOGIN Administrator;

-- Se creează un nou login pentru Administrator
CREATE LOGIN Administrator WITH PASSWORD = 'admin1234';
USE Bank;
-- Se creează un utilizator pentru Administrator în baza de date Bank, asociat login-ului creat
CREATE USER Administrator FOR LOGIN Administrator;
-- Se acordă control complet asupra bazei de date Bank pentru Administrator
GRANT CONTROL ON DATABASE::Bank TO Administrator;

-- Se creează un nou login pentru Employee
CREATE LOGIN Employee WITH PASSWORD = 'employee';
USE Bank;
-- Se creează un utilizator pentru Employee în baza de date Bank, asociat login-ului creat
CREATE USER Employee FOR LOGIN Employee;
-- Se acordă permisiuni de execuție asupra anumitor proceduri pentru Employee
GRANT EXECUTE ON OBJECT::dbo.AddClient TO Employee; 
GRANT EXECUTE ON OBJECT::dbo.DeleteExpiredCards TO Employee;

-- Se creează un nou login pentru Client
CREATE LOGIN Client WITH PASSWORD = 'client';
USE Bank;
-- Se creează un utilizator pentru Client în baza de date Bank, asociat login-ului creat
CREATE USER Client FOR LOGIN Client;
-- Se acordă permisiuni de execuție asupra anumitor obiecte pentru Client
GRANT EXECUTE ON OBJECT::dbo.GetAccountBalanceByCardAndPin TO Client;
GRANT EXECUTE ON OBJECT::dbo.GetTransfersAsDestination TO Client;
