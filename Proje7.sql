-- SQL Server Agent ile Otomatik Yedekleme

-- T-SQL Komutu (Full Backup):
DECLARE @BackupPath NVARCHAR(500)
SET @BackupPath = 'C:\Backup\pubs_full_' + CONVERT(VARCHAR(8), GETDATE(), 112) + '.bak'

BACKUP DATABASE pubs
TO DISK = @BackupPath
WITH INIT, COMPRESSION, STATS = 10;
--GETDATE(), 112 ifadesi ile yedeðin adýnda tarih bilgisi yer alýr (20250528 formatýnda).

-- Son Yedeklemeyi Kontrol Eden T-SQL Sorgusu:
SELECT 
    database_name, 
    MAX(backup_finish_date) AS last_backup_date,
    DATEDIFF(HOUR, MAX(backup_finish_date), GETDATE()) AS hours_since_last_backup
FROM msdb.dbo.backupset
WHERE type = 'D'
GROUP BY database_name;

-- Otomatik Uyarý Sistemi
-- SQL Server Database Mail Ayarý (tek seferlik yapýlandýrma):
-- Database Mail'i aktif et
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'Database Mail XPs', 1; RECONFIGURE;

-- Operatör Tanýmý:
USE msdb;
EXEC msdb.dbo.sp_add_operator  
    @name = N'AdminOperator',  
    @email_address = N'dba@example.com';

-- Alert Tanýmý:
EXEC msdb.dbo.sp_add_alert
    @name = N'Backup Failure Alert',
    @message_id = 18210,  -- Backup failure error code
    @severity = 016,
    @enabled = 1,
    @notification_message = N'Backup job failed!',
    @include_event_description_in = 1;

-- Operatöre Bildirim:
EXEC msdb.dbo.sp_add_notification
    @alert_name = N'Backup Failure Alert',
    @operator_name = N'AdminOperator',
    @notification_method = 1; -- 1 = Email
