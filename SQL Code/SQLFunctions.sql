USE Bank;

GO

DROP FUNCTION IF EXISTS GetAccountBalanceByCardAndPin;

GO

CREATE FUNCTION GetAccountBalanceByCardAndPin
(
    @CardNumber NCHAR(16),
    @Pin NCHAR(4)
)
RETURNS DECIMAL(18, 2) -- Returnează soldul contului în funcție de numărul de card și PIN-ul introduse
AS
BEGIN
    DECLARE @IbanAccount NCHAR(34);
    DECLARE @CorrectPin NCHAR(4);
    DECLARE @AccountBalance DECIMAL(18, 2);

    -- Se obține IBAN-ul și PIN-ul corect din tabelul Card pe baza numărului de card
    SELECT @IbanAccount = Iban, @CorrectPin = Pin
    FROM Card
    WHERE CardNumber = @CardNumber;

    -- Dacă nu se găsește cardul, se returnează NULL
    IF @IbanAccount IS NULL
    BEGIN
        RETURN NULL;
    END

    -- Se verifică dacă PIN-ul introdus este corect
    IF @CorrectPin <> @Pin
    BEGIN
        RETURN NULL; -- Dacă PIN-ul nu este corect, se returnează NULL
    END

    -- Dacă PIN-ul este corect, se obține soldul contului asociat cardului
    SELECT @AccountBalance = a.Sold
    FROM Account a
    INNER JOIN Card c ON a.Iban = c.Iban
    WHERE c.CardNumber = @CardNumber;

    -- Se returnează soldul contului
    RETURN @AccountBalance;
END;

GO

DROP FUNCTION IF EXISTS GetAverageAnnualPayment;

GO

CREATE FUNCTION GetAverageAnnualPayment (@IbanAccount NCHAR(34)) 
RETURNS DECIMAL(18,2) -- Returnează valoarea medie anuală plătită într-un cont care are credite
AS
BEGIN
    DECLARE @TotalAmount DECIMAL(18, 2);
    DECLARE @YearsCount INT;
    DECLARE @AverageAnnualPayment DECIMAL(18, 2);
    
    -- Se calculează suma totală plătită pentru client pe baza creditelor
    SELECT @TotalAmount = SUM(p.Amount)
    FROM Payment p
    INNER JOIN Credit cr ON p.IdCredit = cr.Id
    WHERE cr.IbanAccount = @IbanAccount;
    
    -- Se calculează numărul de ani pentru care au fost efectuate plăți
    SELECT @YearsCount = DATEDIFF(YEAR, MIN(p.DepositDate), MAX(p.DepositDate)) + 1
    FROM Payment p
    INNER JOIN Credit cr ON p.IdCredit = cr.Id
    WHERE cr.IbanAccount = @IbanAccount;
    
    -- Se calculează plata anuală medie
    IF @YearsCount > 0
    BEGIN
        SET @AverageAnnualPayment = @TotalAmount / @YearsCount;
    END
    ELSE
    BEGIN
        SET @AverageAnnualPayment = 0; -- Dacă nu sunt plăți, se returnează 0
    END
    
    -- Se returnează plata anuală medie
    RETURN @AverageAnnualPayment;
END;

GO

DROP FUNCTION IF EXISTS CalculateUpdatedSum;

GO

CREATE FUNCTION CalculateUpdatedSum (
    @InitialAmount DECIMAL(18, 2),
    @Interest DECIMAL(18, 2),
    @Period INT
)
RETURNS DECIMAL(18, 2) -- Returnează suma actualizată
AS
BEGIN
    DECLARE @UpdatedAmount DECIMAL(18, 2);

    -- Se calculează suma actualizată folosind formula dobânzii simple
    SET @UpdatedAmount = @InitialAmount + @InitialAmount * @Interest / 100 * @Period;

    -- Se returnează suma actualizată
    RETURN @UpdatedAmount;
END;

GO

DROP FUNCTION IF EXISTS CalculateMonthlyRate;

GO

CREATE FUNCTION CalculateMonthlyRate (
    @Amount DECIMAL(18, 2),
    @Period INT
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @MonthlyRate DECIMAL(18, 2);

    -- Se calculează rata lunară împărțind suma totală la numărul total de luni
    SET @MonthlyRate = @Amount / (@Period * 12);

    -- Se returnează rata lunară
    RETURN @MonthlyRate;
END;

GO

DROP FUNCTION IF EXISTS GetTransfersByClient;

GO

CREATE FUNCTION GetTransfersByClient (
    @CnpClient NCHAR(13)
)
RETURNS TABLE -- Returnează un set de rezultate cu transferurile efectuate de client
AS
RETURN
(
    SELECT t.Id, t.Amount, t.Status, t.IbanAccountDestination
    FROM Transfer t
    INNER JOIN ClientAccount ca ON t.IbanAccountSource = ca.IbanAccount
    WHERE ca.CnpClient = @CnpClient
);
