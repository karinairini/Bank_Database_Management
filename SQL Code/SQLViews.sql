USE Bank;

DROP VIEW IF EXISTS AccountClients;

GO

CREATE VIEW AccountClients AS
-- Acest view adună informații despre conturile bancare și titularii acestora.
-- Afișează IBAN-ul contului, o listă cu numele titularilor, tipul contului,
-- data deschiderii contului și detaliile de contact ale principalului titular.
SELECT 
    a.Iban,
    a.Type,
    a.Sold,
    a.OpenDate,
    CASE 
        WHEN a.Type = 'Joint' THEN STRING_AGG(CONCAT(cl.FirstName, ' ', cl.LastName), ', ') 
        ELSE MAX(CONCAT(cl.FirstName, ' ', cl.LastName))
    END AS Owners
FROM 
    Account a
LEFT JOIN 
    ClientAccount ca ON a.Iban = ca.IbanAccount
LEFT JOIN 
    Client cl ON ca.CnpClient = cl.Cnp
GROUP BY 
    a.Iban, a.Type, a.Sold, a.OpenDate;

GO

DROP VIEW IF EXISTS TransferDetails;

GO 

CREATE VIEW TransferDetails AS
-- Acest view oferă detalii despre transferurile de bani între conturi,
-- inclusiv ID-ul transferului, suma transferată, statusul acestuia,
-- IBAN-urile conturilor sursă și destinație și email-urile titularilor.
SELECT 
    t.Id AS Id,
    t.Amount AS Amount,
    t.Status AS Status,
    t.IbanAccountSource AS SourceAccountIban,
    t.IbanAccountDestination AS DestinationAccountIban,
    (
        SELECT STRING_AGG(cl1.Email, ', ')
        FROM ClientAccount ca1
        INNER JOIN Client cl1 ON ca1.CnpClient = cl1.Cnp
        WHERE ca1.IbanAccount = t.IbanAccountSource
    ) AS SourceAccountHolderEmails,
    (
        SELECT STRING_AGG(cl2.Email, ', ')
        FROM ClientAccount ca2
        INNER JOIN Client cl2 ON ca2.CnpClient = cl2.Cnp
        WHERE ca2.IbanAccount = t.IbanAccountDestination
    ) AS DestinationAccountHolderEmails
FROM 
    Transfer t
INNER JOIN Account a1 ON t.IbanAccountSource = a1.Iban
INNER JOIN Account a2 ON t.IbanAccountDestination = a2.Iban;

GO

DROP VIEW IF EXISTS CreditPaymentSummary;

GO

CREATE VIEW CreditPaymentSummary AS
-- Acest view sumarizează informațiile despre creditele active și plățile efectuate pentru fiecare credit activ.
-- Afișează ID-ul creditului, suma creditului, rata lunară, perioada creditului,
-- data deschiderii și suma totală plătită până la momentul actual
SELECT 
    cr.Id AS Id,
    cr.IbanAccount AS Iban,
    cr.Amount ASAmount,
    cr.MonthlyRate,
    cr.Period,
    cr.OpenDate,
    ISNULL(SUM(p.Amount), 0) AS TotalPaid
FROM 
    Credit cr
LEFT JOIN 
    Payment p ON cr.Id = p.IdCredit
WHERE cr.Status = 'Active'
GROUP BY 
    cr.Id, cr.IbanAccount, cr.Amount, cr.MonthlyRate, cr.Interest, cr.Period, cr.OpenDate, cr.Status;

GO

DROP VIEW IF EXISTS ClientCards;

GO 

CREATE VIEW ClientCards AS
-- Acest view oferă informații despre cardurile active emise pentru clienți.
-- Afișează CNP-ul clientului, numele acestuia, numărul de telefon, detalii despre cardul activ
-- (număr card, dată de expirare, stare), precum și informațiile contului bancar asociat.
SELECT 
    cl.Cnp AS Cnp,
    CONCAT(cl.FirstName, ' ', cl.LastName) AS Client,
    cl.PhoneNumber AS PhoneNumber,
    c.CardNumber AS CardNumber,
    c.ExpirationDate AS CardExpirationDate,
    c.State AS CardState,
    a.Iban AS Iban,
    a.OpenDate AS AccountOpenDate
FROM 
    Client cl
INNER JOIN 
    ClientAccount ca ON cl.Cnp = ca.CnpClient
INNER JOIN 
    Account a ON ca.IbanAccount = a.Iban
INNER JOIN 
    Card c ON a.Iban = c.Iban
WHERE 
    c.State = 'Active';

GO

DROP VIEW IF EXISTS ClientCreditSummary;

GO

DROP VIEW IF EXISTS EmployeePerformanceSummary;

GO

CREATE VIEW EmployeePerformanceSummary AS
-- Acest view sumarizează performanța angajaților în procesarea plăților.
-- Afișează CNP-ul angajatului, numele acestuia, numărul total de plăți procesate
-- și suma totală procesată de acesta.
SELECT 
    e.Cnp AS Cnp,
    CONCAT(e.FirstName, ' ', e.LastName) AS Employee,
    COUNT(p.Id) AS PaymentsProcessed,
    SUM(p.Amount) AS AmountProcessed
FROM 
    Employee e
JOIN 
    Payment p ON e.Cnp = p.CnpEmployee
GROUP BY 
    e.Cnp, e.FirstName, e.LastName;
