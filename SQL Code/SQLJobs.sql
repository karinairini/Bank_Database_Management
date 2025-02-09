USE Bank;
GO

-- Crearea unui job numit 'CountPaymentsJob' care va număra plățile din ziua precedentă
EXEC sp_add_job
    @job_name = 'CountPaymentsJob';
GO

-- Adăugarea unui pas în jobul 'CountPaymentsJob' care rulează cod pentru a număra plățile efectuate în ziua precedentă
EXEC sp_add_jobstep
    @job_name = 'CountPaymentsJob',
    @step_name = 'CountPaymentsStep',
    @subsystem = 'TSQL',
    @command = '
        DECLARE @Yesterday DATE = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE);
        DECLARE @NumberOfPayments INT;

        SELECT @NumberOfPayments = COUNT(*)
        FROM Payment
        WHERE DepositDate = @Yesterday;
	
        INSERT INTO PaymentLog (DepositDate, NumberOfPayments)
        VALUES (@Yesterday, @NumberOfPayments);
    ',
    @database_name = 'Bank',
    @retry_attempts = 0,
    @retry_interval = 0;
GO

-- Crearea unui program care va executa jobul zilnic
EXEC sp_add_schedule
    @schedule_name = 'DailyPaymentCountSchedule',
    @enabled = 1,
    @freq_type = 4, -- Tipul frecvenței este zilnic
    @freq_interval = 1, -- Intervale zilnice
    @active_start_time = 000000; -- Ora de început este la miezul nopții

-- Atașarea programului 'DailyPaymentCountSchedule' la jobul 'CountPaymentsJob'
EXEC sp_attach_schedule
    @job_name = 'CountPaymentsJob',
    @schedule_name = 'DailyPaymentCountSchedule';
GO

-- Pornirea jobului 'CountPaymentsJob'
EXEC sp_start_job @job_name = 'CountPaymentsJob';
GO

USE Bank_System;
GO

-- Crearea unui job numit 'BackupTablesJob' care va face backup pentru tabelele din baza de date
EXEC sp_add_job
    @job_name = 'BackupTablesJob';
GO

-- Adaugarea unui pas în jobul 'BackupTablesJob' care execută backup pentru mai multe tabele
EXEC sp_add_jobstep
    @job_name = 'BackupTablesJob',
    @step_name = 'BackupStep',
    @subsystem = 'TSQL',
    @command = '
        DECLARE @BackupPath NVARCHAR(255) = ''C:\Backup\    '';
        DECLARE @Today NVARCHAR(10) = CONVERT(NVARCHAR, GETDATE(), 112);

        BACKUP TABLE Client TO DISK = @BackupPath + ''ClientBackup_'' + @Today + ''.bak'';
        BACKUP TABLE Account TO DISK = @BackupPath + ''AccountBackup_'' + @Today + ''.bak'';
        BACKUP TABLE Employee TO DISK = @BackupPath + ''EmployeeBackup_'' + @Today + ''.bak'';
        BACKUP TABLE Credit TO DISK = @BackupPath + ''CreditBackup_'' + @Today + ''.bak'';
        BACKUP TABLE Payment TO DISK = @BackupPath + ''PaymentBackup_'' + @Today + ''.bak'';
    ',
    @database_name = 'Bank',
    @retry_attempts = 0,
    @retry_interval = 0;
GO

-- Crearea unui program care va executa jobul de backup zilnic
EXEC sp_add_schedule
    @schedule_name = 'DailyBackupSchedule',
    @enabled = 1,
    @freq_type = 4, -- Tipul frecvenței este zilnic
    @freq_interval = 1, -- Intervale zilnice
    @active_start_time = 020000; -- Ora de început este la 02:00 AM

-- Atașarea programului'DailyBackupSchedule' la jobul 'BackupTablesJob'
EXEC sp_attach_schedule
    @job_name = 'BackupTablesJob',
    @schedule_name = 'DailyBackupSchedule';
GO

-- Pornirea jobului 'BackupTablesJob'
EXEC sp_start_job @job_name = 'BackupTablesJob';
GO
