SELECT * FROM ogrenciler
WHERE ad LIKE '%m%' AND soyad LIKE '%a%';

CREATE NONCLUSTERED INDEX IX_ogrenciler_ad_soyad
ON ogrenciler (ad, soyad);

UPDATE STATISTICS ogrenciler;

-- Fragmentasyon düzeyini görmek için
SELECT 
  dbschemas.[name] as 'Schema',
  dbtables.[name] as 'Table',
  indexstats.index_type_desc AS 'Index Type',
  indexstats.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
WHERE indexstats.avg_fragmentation_in_percent > 20;

-- Eðer > 30% ise:
ALTER INDEX IX_ogrenciler_ad_soyad ON ogrenciler REBUILD;
-- Eðer 10-30% arasý ise:
ALTER INDEX IX_ogrenciler_ad_soyad ON ogrenciler REORGANIZE;


BACKUP DATABASE okulDB
TO DISK = 'C:\yedekler\okulDB_full.bak'
WITH INIT;

BACKUP DATABASE localhouse
TO DISK = 'C:\yedekler\localhouse_FULL.bak'
WITH INIT;

--Veritabanýnýn Recovery Model’i SIMPLE olduðu için BACKUP LOG komutu kullanamayýz.
BACKUP LOG localhouse
TO DISK = 'C:\yedekler\localhouse_LOG.trn';
--Sadece FULL veya BULK_LOGGED recovery modelinde BACKUP LOG komutu kullanýlabilir.

--Çözüm: Recovery Model’i Deðiþtirmek
-- BACKUP LOG komutu kullanmak için veritabanýný FULL recovery moduna almalýyýz.
ALTER DATABASE localhouse SET RECOVERY FULL;
-- Sonra yeniden bir tam yedek alýrýz.
BACKUP DATABASE localhouse
TO DISK = 'C:\yedekler\localhouse_FULL.bak'
WITH INIT;
-- Ardýndan tekrar log yedeðini alabiliriz.
BACKUP LOG localhouse
TO DISK = 'C:\yedekler\localhouse_LOG.trn';

-- “localhouse veritabaný hâlâ bu oturum (senin açýk SSMS penceresi) tarafýndan kullanýlýyor, bu yüzden geri yükleme (RESTORE) yapýlamaz.”
-- Master a geçmek lazým
ALTER DATABASE localhouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE localhouse
FROM DISK = 'C:\yedekler\localhouse_FULL.bak'
WITH NORECOVERY;

RESTORE LOG localhouse
FROM DISK = 'C:\yedekler\localhouse_LOG.trn'
WITH RECOVERY;

ALTER DATABASE localhouse SET MULTI_USER;
--localhousedan Mastera geçiþ
--The tail of the log for the database 'localhouse' has not been backed up.”
--mevcut localhouse veritabanýnda hâlâ kayýtlý iþlem verileri (log) var ve SQL Server bu veriler silinmeden (ya da yedeklenmeden) bu veritabanýnýn üzerine yazmanýza izin vermiyor.
--Çözüm 1: Eðer veri kaybý önemli deðilse (örneðin test ortamýysa)
ALTER DATABASE localhouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
RESTORE DATABASE localhouse
FROM DISK = 'C:\yedekler\localhouse_FULL.bak'
--önemli
WITH NORECOVERY, REPLACE;
--önemli
RESTORE LOG localhouse
FROM DISK = 'C:\yedekler\localhouse_LOG.trn'
WITH RECOVERY;
ALTER DATABASE localhouse SET MULTI_USER;


-- Veritabanýný tek kullanýcýya al, açýk baðlantýlarý kapat
ALTER DATABASE localhouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
-- Ana yedeði geri yükle, veritabanýný zorla üzerine yaz
RESTORE DATABASE localhouse
FROM DISK = 'C:\yedekler\localhouse_FULL.bak'
WITH NORECOVERY, REPLACE;
-- Log dosyasýný geri yükle
RESTORE LOG localhouse
FROM DISK = 'C:\yedekler\localhouse_LOG.trn'
WITH RECOVERY;
-- Veritabanýný tekrar çok kullanýcýya aç
ALTER DATABASE localhouse SET MULTI_USER;

--Geri yüklemenin baþarýlý olup olmadýðýný anlamak için
SELECT name, state_desc, recovery_model_desc
FROM sys.databases
WHERE name IN ('localhouse', 'localhouse_restore');
--Eðer state_desc deðeri ONLINE ise, veritabaný baþarýyla geri yüklenmiþ demektir.


RESTORE DATABASE localhouse_restore
FROM DISK = 'C:\yedekler\localhouse_FULL.bak'
WITH MOVE 'localhouse' TO 'C:\yedekler\localhouse_restore.mdf',
     MOVE 'localhouse_log' TO 'C:\yedekler\localhouse_restore.ldf',
     NORECOVERY;
RESTORE LOG localhouse_restore
FROM DISK = 'C:\yedekler\localhouse_LOG.trn'
WITH RECOVERY;
--kontrol:
--localhouse_restore	ONLINE ise iþlem tamamen baþarýlý olmuþtur.
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


-- v1 sürüm: ogrenciler tablosu
CREATE TABLE ogrenciler (
    id INT PRIMARY KEY,
    ad NVARCHAR(50),
    soyad NVARCHAR(50)
);
-- v2 sürüm: e-posta eklendi
ALTER TABLE ogrenciler ADD email NVARCHAR(100);
--ÖÐRENCÝLER ZTN VAR DÝYE OLMADI, OLANI KULLANACAÐIM

ALTER TABLE ogrenciler ADD email NVARCHAR(100);
CREATE TABLE surum_log (
    id INT IDENTITY PRIMARY KEY,
    surum NVARCHAR(20),
    aciklama NVARCHAR(200),
    tarih DATETIME DEFAULT GETDATE()
);
INSERT INTO surum_log (surum, aciklama)
VALUES ('v2.0', 'ogrenciler tablosuna email sütunu eklendi'); 
--OLMADI


--Versiyon kontrol için tablo oluþtur (loglama)
CREATE TABLE surum_log (
    id INT IDENTITY,
    surum NVARCHAR(20),
    aciklama NVARCHAR(200),
    tarih DATETIME DEFAULT GETDATE()
);
-- v1 sonrasý
INSERT INTO surum_log (surum, aciklama) VALUES ('v1.0', 'ogrenciler tablosu oluþturuldu');
-- v2 sonrasý
INSERT INTO surum_log (surum, aciklama) VALUES ('v2.0', 'email sütunu eklendi');


