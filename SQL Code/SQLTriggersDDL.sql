USE Bank;
GO 

DROP TRIGGER IF EXISTS trg_LogDDLChanges;

GO

-- Trigger pentru logarea modificărilor de tip DDL
CREATE TRIGGER trg_LogDDLChanges
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    DECLARE @EventType NVARCHAR(50);
    DECLARE @TableName NVARCHAR(255);
    DECLARE @Timestamp DATE;
    
    -- Se extrage tipul evenimentului (creare, modificare sau ștergere de tabel)
    SET @EventType = EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(50)');

    -- Se preia numele tabelului afectat de eveniment
    SET @TableName = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(255)');

    -- Se stabilește momentul în care a avut loc evenimentul
    SET @Timestamp = GETDATE();

    -- Se inserează informațiile despre eveniment în tabela ChangesLog pentru urmărirea modificărilor
    INSERT INTO ChangesLog (EventType, TableName, UserName, Timestamp)
    VALUES (@EventType, @TableName, SYSTEM_USER, @Timestamp);
END;
GO

DROP TRIGGER IF EXISTS trg_PreventDropSensitiveTables;

GO

-- Trigger pentru prevenirea ștergerii anumitor tabele sensibile
CREATE TRIGGER trg_PreventDropSensitiveTables
ON DATABASE
FOR DROP_TABLE
AS
BEGIN
    DECLARE @TableName NVARCHAR(255);
    
    -- Se extrage numele tabelului care urmează să fie șters
    SET @TableName = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(255)');

    -- Dacă tabelul este 'Credit' sau 'Account', se blochează ștergerea
    IF @TableName IN ('Credit', 'Account')
    BEGIN
        RAISERROR ('Deleting the table %s is not allowed!', 16, 1, @TableName)
        ROLLBACK;
    END
END;
GO
