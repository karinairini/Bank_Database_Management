-- Backup complet al bazei de date
BACKUP DATABASE Bank
TO DISK = 'C:\Projects\ABD\Bank_full.bak'
WITH FORMAT,  -- Se formatează fișierul de backup înainte de a crea backup-ul
     INIT,  -- Se suprascrie fișierul de backup existent dacă acesta există
     NAME = 'Full backup of Bank database',  -- Se setează numele backup-ului
     STATS = 10;  -- Se afișează progresul la fiecare 10 procente de completare a backup-ului

-- Backup diferențial al bazei de date, care conține modificările de la ultimul backup complet
BACKUP DATABASE Bank
TO DISK = 'C:\Projects\ABD\Bank_diff.bak'
WITH DIFFERENTIAL,  -- Se realizează un backup diferențial
     INIT,  -- Se suprascrie fișierul de backup existent dacă acesta există
     NAME = 'Differential backup of Bank database',  -- Se setează numele backup-ului diferențial
     STATS = 10;  -- Se afișează progresul la fiecare 10 procente de completare a backup-ului

-- Restaurarea bazei de date din backup-ul complet
RESTORE DATABASE Bank
FROM DISK = 'C:\Projects\ABD\Bank_full.bak'
WITH RECOVERY;  -- Se permite recuperarea bazei de date și o face disponibilă pentru utilizare

-- Restaurarea bazei de date din backup-ul diferențial
RESTORE DATABASE Bank
FROM DISK = 'C:\Projects\ABD\Bank_diff.bak'
WITH RECOVERY;  -- Se permite recuperarea bazei de date și o face disponibilă pentru utilizare
