---- Proje 3: Veri Tabaný Güvenliði ve Eriþim Kontrolü

--- SQL Server Authentication ile Kullanýcý Oluþturma:

CREATE LOGIN loginProcess WITH PASSWORD = 'password';
CREATE USER newUser FOR LOGIN loginProcess;
EXEC sp_addrolemember 'db_datareader', 'newUser';

--- Windows Authentication (AD hesabý ile eriþim):

CREATE LOGIN [DOMAIN\username] FROM WINDOWS; -- Domain ortamlarýnda kullanýlýr
CREATE USER [DOMAIN\username] FOR LOGIN [DOMAIN\username];
EXEC sp_addrolemember 'db_owner', [DOMAIN\username];

--- TDE Ýçin Anahtar ve Sertifika Oluþturma

USE master;
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'password';

CREATE CERTIFICATE TDESertifikasi WITH SUBJECT = 'TDE Sertifikasi';

USE Pubs;
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDESertifikasi;

ALTER DATABASE Pubs SET ENCRYPTION ON;

--- SQL Injection Test Senaryolarý:


SELECT * FROM authors WHERE au_lname = 'White'; -- Normal sorgu (beklenen)

SELECT * FROM authors WHERE au_lname = '' OR 1=1 --'; -- Injection sorgusu (saldýrý)

--- Parametreli Sorgular (Stored Procedure):

CREATE PROCEDURE GetAuthorByLastName
    @lastname NVARCHAR(50)
AS
BEGIN
    SELECT * FROM authors WHERE au_lname = @lastname;
END
 Kullanýmý:
EXEC GetAuthorByLastName @lastname = 'White';

--- ORM Kullanýmý:

DECLARE @lname NVARCHAR(100) -- Örneðin sadece harf içeren giriþleri kabul et
SET @lname = 'White'

IF @lname NOT LIKE '%[^a-zA-Z ]%'
BEGIN
    EXEC GetAuthorByLastName @lname
END
ELSE
BEGIN
    PRINT 'Geçersiz karakter içeriyor'
END

--- Audit Loglarý Oluþturma:


USE master; -- Audit log’u almak için master database’ine geçiþ yapýlmasý gerekiyor
GO

CREATE SERVER AUDIT Audit_SQLInjection -- Basit audit örneði
TO FILE (FILEPATH = 'C:\AuditLogs\');

CREATE SERVER AUDIT SPECIFICATION AuditSelectStatements
FOR SERVER AUDIT Audit_SQLInjection
ADD (SCHEMA_OBJECT_ACCESS_GROUP);

ALTER SERVER AUDIT Audit_SQLInjection WITH (STATE = ON);
