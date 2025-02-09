USE Bank;

DROP TABLE IF EXISTS ClientAccount;
DROP TABLE IF EXISTS Transfer;
DROP TABLE IF EXISTS Card;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Credit;
DROP TABLE IF EXISTS Client;
DROP TABLE IF EXISTS Account;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS ChangesLog;
DROP TABLE IF EXISTS PaymentLog;

-- Se creează tabelul Client pentru stocarea informațiilor personale ale clientului
CREATE TABLE Client (
    Cnp NCHAR(13) PRIMARY KEY,
    FirstName NVARCHAR(255) NOT NULL,
    LastName NVARCHAR(255) NOT NULL,
    Address NVARCHAR(255) NOT NULL,
    PhoneNumber NVARCHAR(255) NOT NULL,
    Email NVARCHAR(255) NOT NULL
);

-- Numărul de telefon trebuie să fie exact 10 caractere
ALTER TABLE Client
ADD CONSTRAINT CHK_PhoneNumber_Length_Client CHECK (LEN(PhoneNumber) = 10);

-- Emailul trebuie să respecte formatul corect
ALTER TABLE Client
ADD CONSTRAINT CHK_Email_Format_Client CHECK (Email LIKE '%_@__%.__%');

-- Numărul de telefon este unic în cadrul clienților
ALTER TABLE Client
ADD CONSTRAINT UQ_Phone_Number_Client UNIQUE (PhoneNumber);

-- Se crează un index unic pe email pentru a impune unicitatea acestuia
CREATE UNIQUE INDEX IDX_Unique_Email_Client ON Client(Email);

-- Index pe Prenume și Nume pentru a îmbunătăți căutările
CREATE INDEX IDX_FirstName_LastName_Client ON Client(FirstName, LastName);




-- Se creează tabelul Account pentru conturile clienților
CREATE TABLE Account (
    Iban NCHAR(34) PRIMARY KEY,
    Type NVARCHAR(50) NOT NULL,
    Sold DECIMAL(18, 2) NOT NULL,
    OpenDate DATE NOT NULL
);

-- Data deschiderii contului nu poate fi într-o dată viitoare
ALTER TABLE Account
ADD CONSTRAINT CHK_OpenDate_Account CHECK (OpenDate <= GETDATE());

-- Soldul contului trebuie să fie pozitiv
ALTER TABLE Account
ADD CONSTRAINT CHK_Sold_Account CHECK (Sold >= 0);

-- Tipul contului trebuie să fie unul dintre valorile predefinite
ALTER TABLE Account
ADD CONSTRAINT CHK_AccountType CHECK (Type IN ('Saving', 'Current', 'Joint'));




-- Se crează tabelul ClientAccount pentru a lega clienții de conturile lor
CREATE TABLE ClientAccount (
    CnpClient NCHAR(13) NOT NULL,
    IbanAccount NCHAR(34) NOT NULL
    PRIMARY KEY (CnpClient, IbanAccount)
);

ALTER TABLE ClientAccount
ADD CONSTRAINT FK_ClientAccount_Client FOREIGN KEY (CnpClient) REFERENCES Client(Cnp);

ALTER TABLE ClientAccount
ADD CONSTRAINT FK_ClientAccount_Account FOREIGN KEY (IbanAccount) REFERENCES Account(Iban);




-- Se creează tabelul Card pentru stocarea informațiilor despre cardurile emise
CREATE TABLE Card (
    CardNumber NCHAR(16) PRIMARY KEY,
    Cvv NCHAR(3) NOT NULL,
    Pin NCHAR(4) NOT NULL,
    State NVARCHAR(50) NOT NULL,
    EmissionDate DATE NOT NULL,
    ExpirationDate DATE NOT NULL,
    Iban NCHAR(34) NOT NULL
);

ALTER TABLE Card
ADD CONSTRAINT FK_Iban_Account_Card FOREIGN KEY (Iban) REFERENCES Account(Iban);

-- CVV-ul trebuie să fie format doar din 3 cifre
ALTER TABLE Card
ADD CONSTRAINT CHK_Cvv_OnlyDigits CHECK (Cvv LIKE '[0-9][0-9][0-9]');

-- PIN-ul trebuie să fie format doar din 4 cifre
ALTER TABLE Card
ADD CONSTRAINT CHK_Pin_OnlyDigits CHECK (Pin LIKE '[0-9][0-9][0-9][0-9]');

-- Data de emitere a cardului nu poate fi într-o dată viitoare
ALTER TABLE Card
ADD CONSTRAINT CHK_EmissionDate_Card CHECK (EmissionDate < GETDATE());

-- Data de expirare a cardului nu poate fi mai mare de 5 ani de la data de emitere
ALTER TABLE Card
ADD CONSTRAINT CHK_ExpirationDate_Card CHECK (ExpirationDate <= DATEADD(YEAR, 5, EmissionDate));

-- Starea cardului trebuie să fie una dintre valorile predefinite
ALTER TABLE Card
ADD CONSTRAINT CHK_State_Card CHECK (State IN ('Active', 'Inactive'));

-- Se creează un index unic pe numărul cardului pentru a impune unicitatea acestuia
CREATE UNIQUE INDEX IDX_Unique_CardNumber ON Card(CardNumber);

-- Se creează un index unic pe IBAN pentru a impune unicitatea acestuia
CREATE UNIQUE INDEX IDX_Iban_Card ON Card(Iban);




-- Se creează tabelul Transfer pentru stocarea informațiilor despre transferurile de bani
CREATE TABLE Transfer (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Amount DECIMAL(18, 2) NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    IbanAccountSource NCHAR(34) NOT NULL,
    IbanAccountDestination NCHAR(34) NOT NULL
);

ALTER TABLE Transfer
ADD CONSTRAINT FK_IbanAccountSource_Transfer FOREIGN KEY (IbanAccountSource) REFERENCES Account(Iban);

ALTER TABLE Transfer
ADD CONSTRAINT FK_IbanAccountDestination_Transfer FOREIGN KEY (IbanAccountDestination) REFERENCES Account(Iban);

-- Suma transferată trebuie să fie pozitivă
ALTER TABLE Transfer
ADD CONSTRAINT CHK_Amount_Positive_Tranfer CHECK (Amount > 0);

-- Starea transferului trebuie să fie una dintre valorile predefinite
ALTER TABLE Transfer
ADD CONSTRAINT CHK_TransferStatus CHECK (Status IN ('Pending', 'Completed', 'Failed'));

-- Conturile sursă și destinație trebuie să fie diferite
ALTER TABLE Transfer
ADD CONSTRAINT CHK_Iban_Different_Transfer CHECK (IbanAccountSource <> IbanAccountDestination);

-- Se creează un index pe conturile sursă și destinație pentru a îmbunătăți căutările
CREATE INDEX IDX_Unique_IbanAccounts_Transfer ON Transfer(IbanAccountSource, IbanAccountDestination);




-- Se creează tabelul Employee pentru stocarea informațiilor despre angajați
CREATE TABLE Employee (
    Cnp NCHAR(13) PRIMARY KEY,
    FirstName NVARCHAR(255) NOT NULL,
    LastName NVARCHAR(255) NOT NULL,
    Address NVARCHAR(255) NOT NULL,
    PhoneNumber NCHAR(10) NOT NULL UNIQUE,
    Email NVARCHAR(255) NOT NULL,
    Salary DECIMAL(18, 2) NOT NULL,
    HireDate DATE NOT NULL,
    EmploymentStatus NVARCHAR(100) NOT NULL
);

-- Numărul de telefon trebuie să fie exact 10 caractere
ALTER TABLE Employee
ADD CONSTRAINT CHK_PhoneNumber_Length_Employee CHECK (LEN(PhoneNumber) = 10);

-- Numărul de telefon trebuie să fie unic în cadrul angajaților
ALTER TABLE Client
ADD CONSTRAINT UQ_Phone_Number_Employee UNIQUE (PhoneNumber);

-- Emailul trebuie să respecte formatul corect
ALTER TABLE Employee
ADD CONSTRAINT CHK_Email_Format_Employee CHECK (Email LIKE '%_@__%.__%');

-- Salariul angajatului trebuie să fie mai mare sau egal cu minimul pe economie
ALTER TABLE Employee
ADD CONSTRAINT CHK_Salary_Employee CHECK (Salary >= 4050);

-- Data de angajare nu poate fi într-o dată viitoare
ALTER TABLE Employee
ADD CONSTRAINT CHK_HireDate_Employee CHECK (HireDate < GETDATE());

-- Starea angajatului trebuie să fie una dintre valorile predefinite
ALTER TABLE Employee
ADD CONSTRAINT CHK_EmploymentStatus CHECK (EmploymentStatus IN ('Active', 'On Leave'));

-- Se creează un index unic pe email pentru a impune unicitatea acestuia
CREATE UNIQUE INDEX IDX_Unique_Email_Employee ON Client(Email);

-- Index pe Prenume și Nume pentru a îmbunătăți căutările
CREATE INDEX IDX_FirstName_LastName_Employee ON Client(FirstName, LastName);

-- Crează un index unic pe email pentru angajații activi
CREATE UNIQUE INDEX IDX_Unique_Email_Active_Employee 
ON Employee(Email) 
WHERE EmploymentStatus = 'Active';




-- Se creează tabelul Credit pentru stocarea informațiilor despre creditele acordate
CREATE TABLE Credit (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IbanAccount NCHAR(34) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    MonthlyRate DECIMAL(18,2) NOT NULL,
    Interest DECIMAL(18,2) NOT NULL,
    Period INT NOT NULL,
    OpenDate DATE NOT NULL,
    Status NVARCHAR(50) NOT NULL
);

ALTER TABLE Credit
ADD CONSTRAINT FK_IbanAccount_Credit FOREIGN KEY (IbanAccount) REFERENCES Account(Iban);

-- Starea creditului trebuie să fie una dintre valorile predefinite
ALTER TABLE Credit
ADD CONSTRAINT CHK_Status_Credit CHECK (Status IN ('Pending', 'Active', 'Rejected', 'Completed'));

-- Data deschiderii creditului nu poate fi în viitor
ALTER TABLE Credit
ADD CONSTRAINT CHK_OpenDate_Credit CHECK (OpenDate <= GETDATE());

-- Crează un index pe IBAN-ul contului asociat creditului
CREATE INDEX IDX_IbanAccount_Credit ON Credit(IbanAccount);




-- Se creează tabelul Payment pentru stocarea informațiilor despre plățile efectuate pentru credite
CREATE TABLE Payment(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdCredit INT NOT NULL,
    CnpEmployee NCHAR(13) NOT NULL,
    Amount DECIMAL(18, 2) NOT NULL,
    DepositDate DATE NOT NULL
);

ALTER TABLE Payment
ADD CONSTRAINT FK_CnpEmployee_Payment FOREIGN KEY (CnpEmployee) REFERENCES Employee(Cnp);

ALTER TABLE Payment
ADD CONSTRAINT FK_IdCredit_Payment FOREIGN KEY (IdCredit) REFERENCES Credit(Id) ON DELETE CASCADE;

-- Data depunerii plății nu poate fi în viitor
ALTER TABLE Payment
ADD CONSTRAINT CHK_DepositDate_Payment CHECK (DepositDate <= GETDATE());

-- Suma plătită trebuie să fie pozitivă
ALTER TABLE Payment
ADD CONSTRAINT CHK_Amount_Positive_Payment CHECK (Amount >= 0);

-- Crează un index pe ID-ul creditului pentru a îmbunătăți căutările
CREATE INDEX IDX_IdCredit_Payment ON Payment(IdCredit);




-- Se creează tabelul ChangesLog pentru stocarea informațiilor despre modificările efectuate în baza de date
CREATE TABLE ChangesLog (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    EventType NVARCHAR(50),
    TableName NVARCHAR(255),
    UserName NVARCHAR(255),
    Timestamp DATE
);




-- Se creează tabelul PaymentLog pentru stocarea informațiilor despre plățile efectuate
CREATE TABLE PaymentLog (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    DepositDate DATE NOT NULL,
    NumberOfPayments INT NOT NULL
);
