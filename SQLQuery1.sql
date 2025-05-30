SELECT * FROM ogrenciler
WHERE ad LIKE '%m%' AND soyad LIKE '%a%';

CREATE NONCLUSTERED INDEX IX_ogrenciler_ad_soyad
ON ogrenciler (ad, soyad);

UPDATE STATISTICS ogrenciler;

-- Fragmentasyon d�zeyini g�rmek i�in
SELECT 
  dbschemas.[name] as 'Schema',
  dbtables.[name] as 'Table',
  indexstats.index_type_desc AS 'Index Type',
  indexstats.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
WHERE indexstats.avg_fragmentation_in_percent > 20;

-- E�er > 30% ise:
ALTER INDEX IX_ogrenciler_ad_soyad ON ogrenciler REBUILD;
-- E�er 10-30% aras� ise:
ALTER INDEX IX_ogrenciler_ad_soyad ON ogrenciler REORGANIZE;


BACKUP DATABASE okulDB
TO DISK = 'C:\yedekler\okulDB_full.bak'
WITH INIT;

BACKUP DATABASE localhouse
TO DISK = 'C:\yedekler\localhouse_FULL.bak'
WITH INIT;

--Veritaban�n�n Recovery Model�i SIMPLE oldu�u i�in BACKUP LOG komutu kullanamay�z.
BACKUP LOG localhouse
TO DISK = 'C:\yedekler\localhouse_LOG.trn';
--Sadece FULL veya BULK_LOGGED recovery modelinde BACKUP LOG komutu kullan�labilir.

--��z�m: Recovery Model�i De�i�tirmek
-- BACKUP LOG komutu kullanmak i�in veritaban�n� FULL recovery moduna almal�y�z.
ALTER DATABASE localhouse SET RECOVERY FULL;
-- Sonra yeniden bir tam yedek al�r�z.
BACKUP DATABASE localhouse
TO DISK = 'C:\yedekler\localhouse_FULL.bak'
WITH INIT;
-- Ard�ndan tekrar log yede�ini alabiliriz.
BACKUP LOG localhouse
TO DISK = 'C:\yedekler\localhouse_LOG.trn';

-- �localhouse veritaban� h�l� bu oturum (senin a��k SSMS penceresi) taraf�ndan kullan�l�yor, bu y�zden geri y�kleme (RESTORE) yap�lamaz.�
-- Master a ge�mek laz�m
ALTER DATABASE localhouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE localhouse
FROM DISK = 'C:\yedekler\localhouse_FULL.bak'
WITH NORECOVERY;

RESTORE LOG localhouse
FROM DISK = 'C:\yedekler\localhouse_LOG.trn'
WITH RECOVERY;

ALTER DATABASE localhouse SET MULTI_USER;
--localhousedan Mastera ge�i�
--The tail of the log for the database 'localhouse' has not been backed up.�
--mevcut localhouse veritaban�nda h�l� kay�tl� i�lem verileri (log) var ve SQL Server bu veriler silinmeden (ya da yedeklenmeden) bu veritaban�n�n �zerine yazman�za izin vermiyor.
--��z�m 1: E�er veri kayb� �nemli de�ilse (�rne�in test ortam�ysa)
ALTER DATABASE localhouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
RESTORE DATABASE localhouse
FROM DISK = 'C:\yedekler\localhouse_FULL.bak'
--�nemli
WITH NORECOVERY, REPLACE;
--�nemli
RESTORE LOG localhouse
FROM DISK = 'C:\yedekler\localhouse_LOG.trn'
WITH RECOVERY;
ALTER DATABASE localhouse SET MULTI_USER;


-- Veritaban�n� tek kullan�c�ya al, a��k ba�lant�lar� kapat
ALTER DATABASE localhouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
-- Ana yede�i geri y�kle, veritaban�n� zorla �zerine yaz
RESTORE DATABASE localhouse
FROM DISK = 'C:\yedekler\localhouse_FULL.bak'
WITH NORECOVERY, REPLACE;
-- Log dosyas�n� geri y�kle
RESTORE LOG localhouse
FROM DISK = 'C:\yedekler\localhouse_LOG.trn'
WITH RECOVERY;
-- Veritaban�n� tekrar �ok kullan�c�ya a�
ALTER DATABASE localhouse SET MULTI_USER;

--Geri y�klemenin ba�ar�l� olup olmad���n� anlamak i�in
SELECT name, state_desc, recovery_model_desc
FROM sys.databases
WHERE name IN ('localhouse', 'localhouse_restore');
--E�er state_desc de�eri ONLINE ise, veritaban� ba�ar�yla geri y�klenmi� demektir.


RESTORE DATABASE localhouse_restore
FROM DISK = 'C:\yedekler\localhouse_FULL.bak'
WITH MOVE 'localhouse' TO 'C:\yedekler\localhouse_restore.mdf',
     MOVE 'localhouse_log' TO 'C:\yedekler\localhouse_restore.ldf',
     NORECOVERY;
RESTORE LOG localhouse_restore
FROM DISK = 'C:\yedekler\localhouse_LOG.trn'
WITH RECOVERY;
--kontrol:
--localhouse_restore	ONLINE ise i�lem tamamen ba�ar�l� olmu�tur.
SELECT name, state_desc
FROM sys.databases
WHERE name = 'localhouse_restore';

--4.MADDE

--6.MADDE
CREATE TRIGGER ddl_log_trigger
ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN
    INSERT INTO ddl_log (event_data, event_time)
    VALUES (EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'NVARCHAR(MAX)'), GETDATE());
END;


-- v1 s�r�m: ogrenciler tablosu
CREATE TABLE ogrenciler (
    id INT PRIMARY KEY,
    ad NVARCHAR(50),
    soyad NVARCHAR(50)
);
-- v2 s�r�m: e-posta eklendi
ALTER TABLE ogrenciler ADD email NVARCHAR(100);
--��RENC�LER ZTN VAR D�YE OLMADI, OLANI KULLANACA�IM

ALTER TABLE ogrenciler ADD email NVARCHAR(100);
CREATE TABLE surum_log (
    id INT IDENTITY PRIMARY KEY,
    surum NVARCHAR(20),
    aciklama NVARCHAR(200),
    tarih DATETIME DEFAULT GETDATE()
);
INSERT INTO surum_log (surum, aciklama)
VALUES ('v2.0', 'ogrenciler tablosuna email s�tunu eklendi'); 
--OLMADI


--Versiyon kontrol i�in tablo olu�tur (loglama)
CREATE TABLE surum_log (
    id INT IDENTITY,
    surum NVARCHAR(20),
    aciklama NVARCHAR(200),
    tarih DATETIME DEFAULT GETDATE()
);
-- v1 sonras�
INSERT INTO surum_log (surum, aciklama) VALUES ('v1.0', 'ogrenciler tablosu olu�turuldu');
-- v2 sonras�
INSERT INTO surum_log (surum, aciklama) VALUES ('v2.0', 'email s�tunu eklendi');


