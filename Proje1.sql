---- Proje 1: Veri Tabaný Performans Optimizasyonu ve Ýzleme


--- En çok kaynak tüketen ilk 5 sorguyu bulmak:

SELECT TOP 5
    qs.total_elapsed_time / qs.execution_count AS [Average Time],
    qs.execution_count,
    qs.total_logical_reads, 
    qs.total_logical_writes,
    st.text AS [SQL Text]
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY [Average Time] DESC;


--- Ýndeks Yönetimi

SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('authors');

--- Önerilen Ýndeksler

SELECT 
    migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) AS impact,
    mid.statement AS TableName,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM sys.dm_db_missing_index_groups mig
JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
ORDER BY impact DESC;


--- Gereksiz Ýndeksleri Bulma

SELECT 
    OBJECT_NAME(i.object_id) AS TableName, i.name AS IndexName, i.index_id,
    user_seeks, user_scans, user_lookups, user_updates
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE OBJECTPROPERTY(s.object_id,'IsUserTable') = 1
ORDER BY user_seeks + user_scans DESC;

--- Sorgu Sürelerinin Ölçülmesi

SET STATISTICS TIME ON;
						-- Sorgu buraya girilir
SET STATISTICS TIME OFF;

--- Rol Oluþturma

CREATE ROLE DatabaseAdmin 
GRANT SELECT ON sales TO DatabaseAdmin  --Sales tablosu için 
GRANT SELECT ON titles TO DatabaseAdmin  --Titles tablosu için

GRANT INSERT, UPDATE ON sales TO DatabaseAdmin 
GRANT INSERT, UPDATE ON titles TO DatabaseAdmin

--- Yeni Kullanýcý Oluþturma

CREATE LOGIN DatabaseAdmin WITH PASSWORD = 'password';
CREATE USER new_admin FOR LOGIN DatabaseAdmin;
EXEC sp_addrolemember DatabaseAdmin, new_admin;

--- Rol Atama

EXEC sp_addrolemember 'db_datareader', 'ornekKullanici';
