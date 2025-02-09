USE Bank;

INSERT INTO Client (Cnp, FirstName, LastName, Address, PhoneNumber, Email)
VALUES 
    ('1970508400023', 'Andrei', 'Popescu', 'Strada Mihai Viteazu 12', '0712345678', 'andrei.popescu@gmail.com'),
    ('2980613200043', 'Maria', 'Ionescu', 'Bdul. Unirii 45', '0723456789', 'maria.ionescu@gmail.com'),
    ('1960724200057', 'Ion', 'Popa', 'Strada Calea Dorobanților 89', '0734567890', 'ion.popa@gmail.com'),
    ('2780836300012', 'Elena', 'Georgescu', 'Strada Lascăr Catargiu 33', '0745678901', 'elena.georgescu@gmail.com'),
    ('1860917400034', 'Vasile', 'Dumitru', 'Strada Nicolae Titulescu 56', '0756789012', 'vasile.dumitru@gmail.com');

INSERT INTO Account (Iban, Type, Sold, OpenDate)
VALUES 
    ('RO12BTR0000061234567890', 'Saving', 10000.00, '2022-01-01'),
    ('RO12BTR0000061234567891', 'Current', 500.00, '2023-03-15'),
    ('RO12BTR0000061234567892', 'Joint', 1500.00, '2021-07-20'),
    ('RO12BTR0000061234567893', 'Saving', 2000.00, '2020-12-10'),
    ('RO12BTR0000061234567894', 'Current', 300.00, '2024-05-05');

INSERT INTO ClientAccount (CnpClient, IbanAccount)
VALUES 
    ('1970508400023', 'RO12BTR0000061234567890'),
    ('2980613200043', 'RO12BTR0000061234567891'),
    ('1960724200057', 'RO12BTR0000061234567892'),
    ('2980613200043', 'RO12BTR0000061234567892'),
    ('2780836300012', 'RO12BTR0000061234567893'),
    ('1860917400034', 'RO12BTR0000061234567894');

INSERT INTO Card (CardNumber, Cvv, Pin, State, EmissionDate, ExpirationDate, Iban)
VALUES 
    ('1234567812345678', '123', '1234', 'Active', '2021-01-01', '2025-01-01', 'RO12BTR0000061234567890'),
    ('2345678923456789', '234', '2345', 'Active', '2022-02-02', '2026-02-02', 'RO12BTR0000061234567891'),
    ('3456789034567890', '345', '3456', 'Inactive', '2021-06-15', '2025-06-15', 'RO12BTR0000061234567892'),
    ('4567890145678901', '456', '4567', 'Active', '2020-12-01', '2024-12-01', 'RO12BTR0000061234567893'),
    ('5678901256789012', '567', '5678', 'Active', '2023-04-20', '2027-04-20', 'RO12BTR0000061234567894');

INSERT INTO Transfer (Amount, Status, IbanAccountSource, IbanAccountDestination)
VALUES 
    (100.00, 'Pending', 'RO12BTR0000061234567890', 'RO12BTR0000061234567891'),
    (200.00, 'Completed', 'RO12BTR0000061234567892', 'RO12BTR0000061234567893'),
    (300.00, 'Failed', 'RO12BTR0000061234567894', 'RO12BTR0000061234567890'),
    (50.00, 'Pending', 'RO12BTR0000061234567891', 'RO12BTR0000061234567892'),
    (150.00, 'Completed', 'RO12BTR0000061234567893', 'RO12BTR0000061234567894');

INSERT INTO Employee (Cnp, FirstName, LastName, Address, PhoneNumber, Email, Salary, HireDate, EmploymentStatus)
VALUES 
    ('1970508400012', 'Gabriel', 'Vasile', 'Strada Dacia 15', '0721122334', 'gabriel.vasile@gmail.com', 5000.00, '2020-02-01', 'Active'),
    ('2890613200031', 'Ioana', 'Mihăilescu', 'Bdul. Ștefan cel Mare 32', '0732233445', 'ioana.mihăilescu@gmail.com', 6000.00, '2021-03-15', 'Active'),
    ('1950724200078', 'Petru', 'Lupu', 'Strada Călărași 44', '0743344556', 'petru.lupu@gmail.com', 4100.00, '2019-08-10', 'On Leave'),
    ('2860836300045', 'Larisa', 'Popa', 'Strada Apusului 28', '0754455667', 'larisa.popa@gmail.com', 5500.00, '2022-11-20', 'Active'),
    ('1760917400020', 'Florin', 'Dima', 'Strada Iancu 55', '0765566778', 'florin.dima@gmail.com', 4500.00, '2023-05-25', 'On Leave');

INSERT INTO Credit (IbanAccount, Amount, MonthlyRate, Interest, Period, OpenDate, Status)
VALUES 
    ('RO12BTR0000061234567890', 7450.00, 88.70, 7, 7, '2023-07-01', 'Active'),
    ('RO12BTR0000061234567891', 3630.00, 100.83, 7, 3, '2023-03-01', 'Completed'),
    ('RO12BTR0000061234567892', 17000.00, 141.66, 7, 10, '2023-10-01', 'Pending'),
    ('RO12BTR0000061234567893', 2280.00, 95.00, 7, 2, '2024-02-01', 'Rejected'),
    ('RO12BTR0000061234567894', 11700.00, 121.87, 7, 8, '2023-08-01', 'Active'),
    ('RO12BTR0000061234567890', 13040.00, 120.74, 7, 9, '2023-09-01', 'Active');


INSERT INTO Payment (IdCredit, CnpEmployee, Amount, DepositDate)
VALUES 
    (1, '1970508400012', 150.00, '2023-04-15'),
    (1, '2890613200031', 100.00, '2023-05-20'),
    (4, '2890613200031', 200.00, '2023-06-01'),
    (4, '2860836300045', 150.00, '2023-07-10'),
    (5, '1970508400012', 250.00, '2023-06-05'),
    (5, '2860836300045', 150.00, '2023-07-15');