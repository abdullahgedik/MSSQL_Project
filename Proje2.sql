---- Proje 2: Veri Taban� Yedekleme ve Felaketten Kurtarma Plan�

--- Tam (Full) Yedekleme:

BACKUP DATABASE Pubs TO DISK = 'C:\Backup\Pubs_FULL.bak' WITH FORMAT, INIT;

--- Fark (Differential) Yedekleme:

BACKUP DATABASE Pubs TO DISK = 'C:\Backup\Pubs_DIFF.bak' WITH DIFFERENTIAL;

--- Art�k (Transaction Log) Yedekleme:

ALTER DATABASE Pubs SET RECOVERY FULL; -- Log kayd� alabilmek i�in veri taban� FULL RECOVERY modunda olmal�
BACKUP LOG Pubs TO DISK = 'C:\Backup\Pubs_LOG.trn';

--- Felaketten Kurtarma (Disaster Recovery):

RESTORE DATABASE Pubs FROM DISK = 'C:\Backup\Pubs_FULL.bak' WITH NORECOVERY; -- �nce tam yedek restore edilir 

RESTORE DATABASE Pubs FROM DISK = 'C:\Backup\Pubs_DIFF.bak' WITH NORECOVERY; -- Ard�ndan fark yede�i y�klenir


RESTORE LOG Pubs FROM DISK = 'C:\Backup\Pubs_LOG.trn'  -- Son olarak log yede�iyle belirli zamana d�n�l�r
WITH STOPAT = '2025-04-23 13:45:00', RECOVERY;

--- Test Yedekleri:

RESTORE DATABASE Pubs_Test FROM DISK = 'C:\Backup\Pubs_FULL.bak' -- Yede�i farkl� bir isimle restore etmek
WITH MOVE 'pubs' TO 'C:\Backup\Pubs_Test_Data.mdf',
     MOVE 'pubs_log' TO 'C:\Backup\Pubs_Test_Log.ldf',
     REPLACE;