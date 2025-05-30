-- 1. Veritaban�n� olu�tur
CREATE DATABASE okulDB;
GO

-- 2. Veritaban�n� kullan
USE okulDB;
GO

-- 3. ��renciler tablosunu olu�tur
CREATE TABLE ogrenciler (
    id INT PRIMARY KEY IDENTITY(1,1),
    ad NVARCHAR(50),
    soyad NVARCHAR(50),
    dogum_tarihi DATE,
    telefon NVARCHAR(20)
);
GO

-- 4. �rnek veri ekle
INSERT INTO ogrenciler (ad, soyad, dogum_tarihi, telefon) VALUES
('Mert', 'Can', '2000-10-20', '05311234567'),
('Ay�e', 'Y�lmaz', '2001-05-10', '05001234567'),
('Ali', 'Demir', '2002-03-15', '05551234567');
GO
-- DDL i�lemleri loglanacak tablo
CREATE TABLE ddl_log (
    id INT PRIMARY KEY IDENTITY(1,1),
    event_type NVARCHAR(100),
    object_name NVARCHAR(100),
    event_time DATETIME
);
GO

-- Mirroring i�in database'i FULL backup ile yedekleyip yedek sunucuya restore etmek gerekir
BACKUP DATABASE okulDB TO DISK = 'C:\\SQLBackups\\okulDB.bak';

USE master;
GO
RESTORE DATABASE okulDB FROM DISK = 'C:\\backup\\okulDB.bak' WITH NORECOVERY;

-- Mirror sunucuda restore (WITH NORECOVERY):
RESTORE DATABASE okulDB FROM DISK = 'C:\backup\okulDB.bak' WITH NORECOVERY;
-- Partner ayar� (PRIMARY �zerinde):
ALTER DATABASE okulDB SET PARTNER = 'TCP://sql02:5022';
-- Mirror �zerinde:
ALTER DATABASE okulDB SET PARTNER = 'TCP://sql01:5022';
-- Witness sunucu ayar�:
ALTER DATABASE okulDB SET WITNESS = 'TCP://witnessServer:5022';
