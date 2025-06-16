--- Database Mirroring ile Y�k Dengeleme

-- Principal (SQLPRINCIPAL)
CREATE ENDPOINT [Mirroring]
    STATE=STARTED
    AS TCP (LISTENER_PORT=5022)
    FOR DATABASE_MIRRORING (ROLE=ALL);
-- Mirror (SQLMIRROR)
CREATE ENDPOINT [Mirroring]
    STATE=STARTED
    AS TCP (LISTENER_PORT=5022)
    FOR DATABASE_MIRRORING (ROLE=ALL);


-- Basit ortam i�in Windows Authentication kullanabilirsiniz (ayn� Domain �zerindeyse):
-- Principal
ALTER DATABASE pubs SET PARTNER = 'TCP://SQLMIRROR.domain.local:5022';

-- Mirror
ALTER DATABASE pubs SET PARTNER = 'TCP://SQLPRINCIPAL.domain.local:5022';

-- Otomatik failover i�in:
-- Principal

ALTER DATABASE pubs SET WITNESS = 'TCP://SQLWITNESS.domain.local:5022';

-- Mirroring�i Ba�latma:

-- Principal
ALTER DATABASE pubs SET SAFETY FULL;           -- SYNCHRONOUS
ALTER DATABASE pubs SET PARTNER SAFETY FULL;   -- G�venli failever

-- Mirror
-- (zaten yukar�da partner tan�mland�)

-- Mirroring: sys.database_mirroring_states DMV�si:

 SELECT DB_NAME(database_id) AS DBName, mirroring_state_desc, mirroring_role_desc
FROM sys.database_mirroring_states;

-- DMV�ler:
SELECT * FROM sys.dm_hadr_availability_replica_states;
SELECT * FROM sys.dm_hadr_database_replica_states;

