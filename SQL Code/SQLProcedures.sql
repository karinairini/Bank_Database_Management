USE Bank;

GO

DROP PROCEDURE IF EXISTS AddClient;

GO

CREATE PROCEDURE AddClient
    @Cnp NCHAR(13),
    @FirstName NVARCHAR(255),
    @LastName NVARCHAR(255),
    @Address NVARCHAR(255),
    @PhoneNumber NVARCHAR(255), 
    @Email NVARCHAR(255)
AS
BEGIN
    PRINT 'Inserting new client into the Client table...';
    
    -- Inserarea unui nou client în tabelul Client
    INSERT INTO Client (Cnp, FirstName, LastName, Address, PhoneNumber, Email)
    VALUES (@Cnp, @FirstName, @LastName, @Address, @PhoneNumber, @Email);

    PRINT 'Client added successfully.';
END;

GO

DROP PROCEDURE IF EXISTS UpdateCardState;

GO

CREATE PROCEDURE UpdateCardState
    @CardNumber NCHAR(16),
    @NewState NVARCHAR(50)
AS
BEGIN
    PRINT 'Updating card state...';
    
    -- Actualizăm starea cardului în tabelul Card
    UPDATE Card
    SET State = @NewState
    WHERE CardNumber = @CardNumber;

    PRINT 'Card state updated successfully.';
END;

GO

DROP PROCEDURE IF EXISTS GetTransfersAsDestination;

GO

CREATE PROCEDURE GetTransfersAsDestination
    @CnpClient NCHAR(13)
AS
BEGIN
    PRINT 'Fetching transfer records as destination for client...';

    -- Selectăm transferurile unde clientul este destinația și le afișăm
    SELECT t.Id, 
        t.Amount, 
        t.Status, 
        t.IbanAccountSource, 
        t.IbanAccountDestination,
        a.Type AS AccountType,
        a.Sold AS AccountBalance
    FROM Transfer t
    INNER JOIN Account a ON t.IbanAccountDestination = a.Iban
    INNER JOIN ClientAccount ca ON a.Iban = ca.IbanAccount
    WHERE ca.CnpClient = @CnpClient
    ORDER BY t.Id DESC;

    PRINT 'Transfer records fetched successfully.';
END;

GO

DROP PROCEDURE IF EXISTS DeleteExpiredCards;

GO

CREATE PROCEDURE DeleteExpiredCards
AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Deleting expired cards...';

    -- Ștergem cardurile care au data de expirare mai mică decât data curentă
    DELETE FROM Card
    WHERE ExpirationDate < GETDATE();

    PRINT 'Expired cards deleted successfully.';
END;

GO

DROP PROCEDURE IF EXISTS ExecuteTransfer;

GO

CREATE PROCEDURE ExecuteTransfer (@TransferId INT)
AS
BEGIN
    DECLARE @Amount DECIMAL(18,2);
    DECLARE @SourceIban NCHAR(34);
    DECLARE @DestinationIban NCHAR(34);
    DECLARE @Status NVARCHAR(50);

    -- Obținem informațiile despre transfer din tabelul Transfer
    SELECT 
        @Amount = Amount, 
        @SourceIban = IbanAccountSource, 
        @DestinationIban = IbanAccountDestination,
        @Status = Status
    FROM Transfer
    WHERE Id = @TransferId;

    -- Dacă transferul este în starea 'Pending', îl procesăm
    IF @Status = 'Pending'
    BEGIN
        BEGIN TRANSACTION;

        DECLARE @SourceBalance DECIMAL(18,2);
        SELECT @SourceBalance = Sold FROM Account WHERE Iban = @SourceIban;

        -- Verificăm dacă există suficient fonduri în contul sursă
        IF @SourceBalance >= @Amount
        BEGIN
            -- Actualizăm soldul contului sursă și al contului destinație
            UPDATE Account
            SET Sold = Sold - @Amount
            WHERE Iban = @SourceIban;

            UPDATE Account
            SET Sold = Sold + @Amount
            WHERE Iban = @DestinationIban;

            -- Actualizăm starea transferului ca 'Completed'
            UPDATE Transfer
            SET Status = 'Completed'
            WHERE Id = @TransferId;

            COMMIT TRANSACTION;
        END
        ELSE
        BEGIN
            -- Dacă fondurile nu sunt suficiente, actualizăm starea transferului ca 'Failed'
            UPDATE Transfer
            SET Status = 'Failed'
            WHERE Id = @TransferId;

            ROLLBACK TRANSACTION;
        END
    END
    ELSE
    BEGIN
        PRINT 'Transfer is not in Pending state';
    END
END;

GO

DROP PROCEDURE IF EXISTS InsertTransfer;

GO

CREATE PROCEDURE InsertTransfer
    @Amount DECIMAL(18, 2),
    @IbanAccountSource NCHAR(34),
    @IbanAccountDestination NCHAR(34)
AS
BEGIN
    PRINT 'Inserting new transfer into Transfer table...';

    -- Verificăm dacă sursa și destinația sunt aceleași, ceea ce nu este permis
    IF @IbanAccountSource = @IbanAccountDestination
    BEGIN
        PRINT 'Source and destination accounts must be different!';
        RETURN;
    END

    -- Inserăm transferul în tabelul Transfer cu statusul 'Pending'
    INSERT INTO Transfer (Amount, Status, IbanAccountSource, IbanAccountDestination)
    VALUES (@Amount, 'Pending', @IbanAccountSource, @IbanAccountDestination);
    
    PRINT 'Transfer added successfully.';

    -- Obținem ID-ul transferului inserat
    DECLARE @TransferId INT;
    SET @TransferId = SCOPE_IDENTITY();

    -- Apelează procedura ExecuteTransfer pentru a procesa transferul
    EXEC ExecuteTransfer @TransferId;
    
END;
