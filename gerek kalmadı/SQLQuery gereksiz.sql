CREAT DATABASE eTicaretDB;
GO

--express kulland���m i�in olmad�
USE master;
EXEC sp_replicationdboption 
    @dbname = N'eTicaretDB', 
    @optname = N'publish', 
    @value = N'true';
--olmad�

BACKUP DATABASE localhouse
TO DISK = 'C:\yedekler\localhouse.bak';

RESTORE DATABASE localhouse_readonly
FROM DISK = 'C:\yedekler\localhouse.bak'
WITH MOVE 'localhouse' TO 'C:\yedekler\localhouse_readonly.mdf',
     MOVE 'localhouse_log' TO 'C:\yedekler\localhouse_readonly_log.ldf',
     STANDBY = 'C:\yedekler\standby_file.tuf';



