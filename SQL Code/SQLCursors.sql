USE Bank;

GO

-- Cursor pentru afișarea clienților și a soldului conturilor lor
DECLARE @CnpClient NCHAR(13);
DECLARE @FullName NVARCHAR(510);
DECLARE @Sold DECIMAL(18,2);
DECLARE @Type NVARCHAR(50);

-- Se creează cursorul pentru a parcurge clienții și conturile asociate
DECLARE ClientAccountCursor CURSOR FOR
SELECT cl.Cnp, CONCAT(cl.FirstName, ' ', cl.LastName), a.Sold, a.Type
FROM Client cl
JOIN ClientAccount ca ON cl.Cnp = ca.CnpClient
JOIN Account a ON ca.IbanAccount = a.Iban;

OPEN ClientAccountCursor;

-- Se citește prima înregistrare
FETCH NEXT FROM ClientAccountCursor INTO @CnpClient, @FullName, @Sold, @Type;

-- Parcurgerea tuturor înregistrărilor din cursor
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Se afișează numele clientului și soldul contului său
    PRINT 'Client: ' + @FullName + ' | Sold: ' + CAST(@Sold AS NVARCHAR(50)) + ' | Type: ' + @Type;

    -- Se citește următoarea înregistrare
    FETCH NEXT FROM ClientAccountCursor INTO @CnpClient, @FullName, @Sold, @Type;
END;

-- Se închide și se eliberează cursorul
CLOSE ClientAccountCursor;
DEALLOCATE ClientAccountCursor;

GO

-- Cursor pentru actualizarea dobânzilor creditelor active
DECLARE @CreditId INT;
DECLARE @InitialAmount DECIMAL(18, 2);
DECLARE @Interest DECIMAL(18, 2); 
DECLARE @Period INT;
DECLARE @UpdatedAmount DECIMAL(18, 2);
DECLARE @MonthlyRate DECIMAL(18, 2);
DECLARE @InterestIncrease DECIMAL(18, 2) = 0.5;

-- Se creează cursorul pentru creditele active
DECLARE CreditCursor CURSOR FOR
SELECT Id, Amount, Interest, Period
FROM Credit
WHERE Status = 'Active';

OPEN CreditCursor;

-- Se citește prima înregistrare
FETCH NEXT FROM CreditCursor INTO @CreditId, @InitialAmount, @Interest, @Period;

-- Parcurgerea tuturor creditelor active
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Se aplică o creștere de dobândă
    SET @Interest = @Interest + @InterestIncrease;

    -- Se calculează noua sumă a creditului folosind o funcție definită în baza de date
    SET @UpdatedAmount = dbo.CalculateUpdatedSum(@InitialAmount, @Interest, @Period);

    -- Se calculează noua rată lunară
    SET @MonthlyRate = dbo.CalculateMonthlyRate(@UpdatedAmount, @Period);

    -- Se actualizează creditul cu noua sumă, rată lunară și dobândă
    UPDATE Credit
    SET Amount = @UpdatedAmount,
        MonthlyRate = @MonthlyRate,
        Interest = @Interest
    WHERE Id = @CreditId;

    -- Se citește următoarea înregistrare
    FETCH NEXT FROM CreditCursor INTO @CreditId, @InitialAmount, @Interest, @Period;
END;

-- Se închide și se eliberează cursorul
CLOSE CreditCursor;
DEALLOCATE CreditCursor;

GO

-- Cursor pentru actualizarea salariilor angajaților activi pe baza inflației
DECLARE @Cnp NCHAR(13);
DECLARE @Salary DECIMAL(18, 2);
DECLARE @InflationRate DECIMAL(18, 2) = 3;

-- Se creează cursorul pentru angajații activi
DECLARE SalaryCursor CURSOR FOR
SELECT Cnp, Salary
FROM Employee
WHERE EmploymentStatus = 'Active';

OPEN SalaryCursor;

-- Se citește prima înregistrare
FETCH NEXT FROM SalaryCursor INTO @Cnp, @Salary;

-- Parcurgerea înregistrărilor și actualizarea salariilor
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Se actualizează salariul angajatului în funcție de inflație
    UPDATE Employee
    SET Salary = Salary + (Salary * @InflationRate / 100)
    WHERE Cnp = @Cnp;

    -- Se citește următoarea înregistrare
    FETCH NEXT FROM SalaryCursor INTO @Cnp, @Salary;
END;

-- Se închide și se eliberează cursorul
CLOSE SalaryCursor;
DEALLOCATE SalaryCursor;

GO

-- Cursor pentru ștergerea creditelor respinse
DECLARE @CreditId INT;
DECLARE @CreditStatus NVARCHAR(50);

-- Se creează cursorul pentru creditele cu status 'Rejected'
DECLARE RejectedCreditCursor CURSOR FOR
SELECT Id, Status
FROM Credit
WHERE Status = 'Rejected';

-- Deschiderea cursorului
OPEN RejectedCreditCursor;

-- Se citește prima înregistrare
FETCH NEXT FROM RejectedCreditCursor INTO @CreditId, @CreditStatus;

-- Se parcurg creditele și se șterg cele cu status 'Rejected'
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Ștergerea creditului respins
    DELETE FROM Credit WHERE Id = @CreditId;

    -- Se citește următoarea înregistrare
    FETCH NEXT FROM RejectedCreditCursor INTO @CreditId, @CreditStatus;
END;

-- Se închide și se eliberează cursorul
CLOSE RejectedCreditCursor;
DEALLOCATE RejectedCreditCursor;

GO

-- Cursor pentru afișarea detaliilor complete ale clienților, conturilor, cardurilor și creditelor
DECLARE @CnpClient NCHAR(13);
DECLARE @FullName NVARCHAR(510);
DECLARE @IbanAccount NCHAR(34);
DECLARE @AccountType NVARCHAR(50);
DECLARE @CardNumber NCHAR(16);
DECLARE @CreditId INT;
DECLARE @CreditAmount DECIMAL(18, 2);
DECLARE @CreditStatus NVARCHAR(50);

-- Se creează cursorul pentru a parcurge clienții și detaliile asociate
DECLARE ClientCursor CURSOR FOR
SELECT 
    cl.Cnp,
    CONCAT(cl.FirstName, ' ', cl.LastName) AS Client,
    a.Iban AS Iban,
    a.Type AS AccountType,
    c.CardNumber AS CardNumber,
    cr.Id AS CreditId,
    cr.Amount AS CreditAmount,
    cr.Status AS CreditStatus
FROM Client cl
LEFT JOIN ClientAccount ca ON cl.Cnp = ca.CnpClient
LEFT JOIN Account a ON ca.IbanAccount = a.Iban
LEFT JOIN Card c ON a.Iban = c.Iban
LEFT JOIN Credit cr ON ca.IbanAccount = cr.IbanAccount;

OPEN ClientCursor;

-- Se citește prima înregistrare
FETCH NEXT FROM ClientCursor INTO @CnpClient, @FullName, @IbanAccount, @AccountType, @CardNumber, @CreditId, @CreditAmount, @CreditStatus;

-- Parcurgerea și afișarea tuturor înregistrărilor din cursor
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Client: ' + @FullName;
    PRINT 'Account IBAN: ' + ISNULL(@IbanAccount, 'No Account');
    PRINT 'Account Type: ' + ISNULL(@AccountType, 'N/A');
    PRINT 'Card Number: ' + ISNULL(@CardNumber, 'No Card');
    PRINT 'Credit ID: ' + ISNULL(CAST(@CreditId AS NVARCHAR), 'No Credit');
    PRINT 'Credit Amount: ' + ISNULL(CAST(@CreditAmount AS NVARCHAR), 'N/A');
    PRINT 'Credit Status: ' + ISNULL(@CreditStatus, 'N/A');
    PRINT '-------------------------------------------';

    FETCH NEXT FROM ClientCursor INTO @CnpClient, @FullName, @IbanAccount, @AccountType, @CardNumber, @CreditId, @CreditAmount, @CreditStatus;
END;

CLOSE ClientCursor;
DEALLOCATE ClientCursor;
