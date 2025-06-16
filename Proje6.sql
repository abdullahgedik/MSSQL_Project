-- Veri Taban� Y�kseltme Plan�
-- Yedekleme: Y�kseltme �ncesi t�m veri tabanlar�n�n tam yede�i al�nmal�d�r.
BACKUP DATABASE pubs TO DISK = 'C:\Backup\pubs_pre_upgrade.bak';


-- S�r�m Y�netimi (Schema Version Control)

-- DDL Triggers ile �ema De�i�ikliklerini �zleme

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

-- Gerekli Kay�t Tablosu: Bu sayede kim, ne zaman, hangi yap�sal de�i�ikli�i yapt� detayl�ca izlenebilir.
CREATE TABLE ddl_log (
    id INT IDENTITY(1,1) PRIMARY KEY,
    event_time DATETIME,
    user_name NVARCHAR(100),
    event_type NVARCHAR(100),
    object_name NVARCHAR(100),
    t_sql NVARCHAR(MAX)
);


-- Test ve Geri D�n�� Plan�
-- Rollback Stratejisi: Geri d�n�lebilirlik i�in y�kseltmeden �nce al�nan yedek dosyas� saklan�r


RESTORE DATABASE pubs FROM DISK = 'C:\Backup\pubs_pre_upgrade.bak' 
WITH REPLACE;
