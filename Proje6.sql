-- Veri Tabaný Yükseltme Planý
-- Yedekleme: Yükseltme öncesi tüm veri tabanlarýnýn tam yedeði alýnmalýdýr.
BACKUP DATABASE pubs TO DISK = 'C:\Backup\pubs_pre_upgrade.bak';


-- Sürüm Yönetimi (Schema Version Control)

-- DDL Triggers ile Þema Deðiþikliklerini Ýzleme

CREATE TRIGGER ddl_audit_trigger
ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN
    INSERT INTO ddl_log (event_time, user_name, event_type, object_name, t_sql)
    SELECT 
        GETDATE(),
        SYSTEM_USER,
        EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(100)'),
        EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'nvarchar(max)');
END;

-- Gerekli Kayýt Tablosu: Bu sayede kim, ne zaman, hangi yapýsal deðiþikliði yaptý detaylýca izlenebilir.
CREATE TABLE ddl_log (
    id INT IDENTITY(1,1) PRIMARY KEY,
    event_time DATETIME,
    user_name NVARCHAR(100),
    event_type NVARCHAR(100),
    object_name NVARCHAR(100),
    t_sql NVARCHAR(MAX)
);


-- Test ve Geri Dönüþ Planý
-- Rollback Stratejisi: Geri dönülebilirlik için yükseltmeden önce alýnan yedek dosyasý saklanýr


RESTORE DATABASE pubs FROM DISK = 'C:\Backup\pubs_pre_upgrade.bak' 
WITH REPLACE;
