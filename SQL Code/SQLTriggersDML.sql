USE Bank;

GO

DROP TRIGGER IF EXISTS trg_UpdateAmount_OnInsertCredit;

GO

-- Crearea unui trigger care va actualiza suma și rata lunară după fiecare inserare într-un credit
CREATE TRIGGER trg_UpdateAmount_OnInsertCredit
ON Credit
AFTER INSERT
AS
BEGIN
    DECLARE @InitialAmount DECIMAL(18, 2);
    DECLARE @Interest DECIMAL(18, 2);
    DECLARE @Period INT;
    DECLARE @UpdatedAmount DECIMAL(18, 2);
    DECLARE @UpdatedMonthlyRate DECIMAL(18,2);

    -- Se obțin valorile inițiale ale creditului din înregistrarea inserată
    SELECT 
        @InitialAmount = Amount,
        @Interest = Interest,
        @Period = Period
    FROM INSERTED;

    -- Se calculează suma actualizată folosind funcția CalculateUpdatedSum
    SET @UpdatedAmount = dbo.CalculateUpdatedSum(@InitialAmount, @Interest, @Period);
    SET @UpdatedMonthlyRate = dbo.CalculateMonthlyRate(@UpdatedAmount, @Period);

    -- Se actualizează valoarea în tabelul Credit
    UPDATE Credit
    SET Amount = @UpdatedAmount, MonthlyRate = @UpdatedMonthlyRate
    WHERE Id = (SELECT Id FROM INSERTED);
END;

GO

DROP TRIGGER IF EXISTS trg_UpdateCreditStatus;

GO

-- Crearea unui trigger care va actualiza statusul creditului după fiecare inserare în tabelul Payment
CREATE TRIGGER trg_UpdateCreditStatus
ON Payment
AFTER INSERT
AS
BEGIN
    DECLARE @TotalPaid DECIMAL(18, 2);
    DECLARE @CreditId INT;
    DECLARE @Amount DECIMAL(18, 2);

    -- Se obține ID-ul creditului și suma plătită din înregistrarea inserată
    SELECT @CreditId = IdCredit, @Amount = Amount
    FROM INSERTED;

    -- Se calculează suma totală plătită pentru creditul respectiv
    SELECT @TotalPaid = SUM(Amount)
    FROM Payment
    WHERE IdCredit = @CreditId;

    -- Dacă suma totală plătită este mai mare sau egală cu suma totală a creditului, schimbăm statusul creditului
    IF @TotalPaid >= (SELECT Amount FROM Credit WHERE Id = @CreditId)
    BEGIN
        -- Se actualizează statusul creditului în 'Completed'
        UPDATE Credit
        SET Status = 'Completed'
        WHERE Id = @CreditId;
    END
END;

GO

DROP TRIGGER IF EXISTS trg_DeleteAccount;

GO

-- Crearea unui trigger care va șterge contul și datele asociate după fiecare tentativă de ștergere a unui cont
CREATE TRIGGER trg_DeleteAccount
ON Account
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @Iban NCHAR(34);

    -- Se preiau CNP-ul clientului și IBAN-ul contului șters
    SELECT @Iban = Iban FROM DELETED;

    -- Se verifică dacă există credite nefinalizate (status diferit de 'Completed') pentru clientul respectiv
    IF EXISTS (
        SELECT 1
        FROM Credit
        WHERE IbanAccount = @Iban AND Status <> 'Completed'
    )
    BEGIN
        -- Dacă există credite nefinalizate, nu se permite ștergerea contului
        PRINT 'Cannot delete the account because there are non-completed credits.';
    END
    ELSE
    BEGIN
        -- Dacă nu există credite nefinalizate, se verifică dacă există transferuri în curs (status 'Pending')
        IF EXISTS (
            SELECT 1
            FROM Transfer
            WHERE (IbanAccountSource = @Iban OR IbanAccountDestination = @Iban) 
            AND Status = 'Pending'
        )
        BEGIN
            -- Dacă există transferuri în așteptare, nu se permite ștergerea contului
            PRINT 'Cannot delete the account because there are pending transfers.';
        END
        ELSE
        BEGIN
            -- Dacă nu sunt credite nefinalizate și nu există transferuri în așteptare, se poate șterge contul și datele asociate

            -- Se șterge legătura dintre client și cont
            DELETE FROM ClientAccount
            WHERE IbanAccount = @Iban;

            -- Se șterg transferurile legate de acest cont
            DELETE FROM Transfer
            WHERE (IbanAccountSource = @Iban OR IbanAccountDestination = @Iban);

            -- Se șterg plățile asociate creditelor clientului
            DELETE FROM Payment
            WHERE IdCredit IN (
                SELECT Id FROM Credit WHERE IbanAccount = @Iban
            );
            
            -- Se șterg creditele clientului
            DELETE FROM Credit
            WHERE IbanAccount = @Iban;
            
            -- Se șterg cardurile asociate acestui cont
            DELETE FROM Card
            WHERE Iban = @Iban;

            -- Se șterge contul propriu-zis
            DELETE FROM Account
            WHERE Iban = @Iban;

            PRINT 'Account and associated data have been deleted successfully.';
        END
    END
END;
