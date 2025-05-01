---- Proje 3: Veri Taban� G�venli�i ve Eri�im Kontrol�

--- SQL Server Authentication ile Kullan�c� Olu�turma:

CREATE LOGIN loginProcess WITH PASSWORD = 'password';
CREATE USER newUser FOR LOGIN loginProcess;
EXEC sp_addrolemember 'db_datareader', 'newUser';

--- Windows Authentication (AD hesab� ile eri�im):

CREATE LOGIN [DOMAIN\username] FROM WINDOWS; -- Domain ortamlar�nda kullan�l�r
CREATE USER [DOMAIN\username] FOR LOGIN [DOMAIN\username];
EXEC sp_addrolemember 'db_owner', [DOMAIN\username];

--- TDE ��in Anahtar ve Sertifika Olu�turma

USE master;
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'password';

CREATE CERTIFICATE TDESertifikasi WITH SUBJECT = 'TDE Sertifikasi';

USE Pubs;
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDESertifikasi;

ALTER DATABASE Pubs SET ENCRYPTION ON;

--- SQL Injection Test Senaryolar�:


SELECT * FROM authors WHERE au_lname = 'White'; -- Normal sorgu (beklenen)

SELECT * FROM authors WHERE au_lname = '' OR 1=1 --'; -- Injection sorgusu (sald�r�)

--- Parametreli Sorgular (Stored Procedure):

CREATE PROCEDURE GetAuthorByLastName
    @lastname NVARCHAR(50)
AS
BEGIN
    SELECT * FROM authors WHERE au_lname = @lastname;
END
 Kullan�m�:
EXEC GetAuthorByLastName @lastname = 'White';

--- ORM Kullan�m�:

DECLARE @lname NVARCHAR(100) -- �rne�in sadece harf i�eren giri�leri kabul et
SET @lname = 'White'

IF @lname NOT LIKE '%[^a-zA-Z ]%'
BEGIN
    EXEC GetAuthorByLastName @lname
END
ELSE
BEGIN
    PRINT 'Ge�ersiz karakter i�eriyor'
END

--- Audit Loglar� Olu�turma:


USE master; -- Audit log�u almak i�in master database�ine ge�i� yap�lmas� gerekiyor
GO

CREATE SERVER AUDIT Audit_SQLInjection -- Basit audit �rne�i
TO FILE (FILEPATH = 'C:\AuditLogs\');

CREATE SERVER AUDIT SPECIFICATION AuditSelectStatements
FOR SERVER AUDIT Audit_SQLInjection
ADD (SCHEMA_OBJECT_ACCESS_GROUP);

ALTER SERVER AUDIT Audit_SQLInjection WITH (STATE = ON);
