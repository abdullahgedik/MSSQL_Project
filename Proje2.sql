---- Proje 2: Veri Tabaný Yedekleme ve Felaketten Kurtarma Planý

--- Tam (Full) Yedekleme:

BACKUP DATABASE Pubs TO DISK = 'C:\Backup\Pubs_FULL.bak' WITH FORMAT, INIT;

--- Fark (Differential) Yedekleme:

BACKUP DATABASE Pubs TO DISK = 'C:\Backup\Pubs_DIFF.bak' WITH DIFFERENTIAL;

--- Artýk (Transaction Log) Yedekleme:

ALTER DATABASE Pubs SET RECOVERY FULL; -- Log kaydý alabilmek için veri tabaný FULL RECOVERY modunda olmalý
BACKUP LOG Pubs TO DISK = 'C:\Backup\Pubs_LOG.trn';

--- Felaketten Kurtarma (Disaster Recovery):

RESTORE DATABASE Pubs FROM DISK = 'C:\Backup\Pubs_FULL.bak' WITH NORECOVERY; -- Önce tam yedek restore edilir 

RESTORE DATABASE Pubs FROM DISK = 'C:\Backup\Pubs_DIFF.bak' WITH NORECOVERY; -- Ardýndan fark yedeði yüklenir


RESTORE LOG Pubs FROM DISK = 'C:\Backup\Pubs_LOG.trn'  -- Son olarak log yedeðiyle belirli zamana dönülür
WITH STOPAT = '2025-04-23 13:45:00', RECOVERY;

--- Test Yedekleri:

RESTORE DATABASE Pubs_Test FROM DISK = 'C:\Backup\Pubs_FULL.bak' -- Yedeði farklý bir isimle restore etmek
WITH MOVE 'pubs' TO 'C:\Backup\Pubs_Test_Data.mdf',
     MOVE 'pubs_log' TO 'C:\Backup\Pubs_Test_Log.ldf',
     REPLACE;