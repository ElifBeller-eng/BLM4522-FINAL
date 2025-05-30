BACKUP DATABASE localhouse TO DISK = 'C:\\SQLBackups\\localhouse.bak';
-- Ayn� isimle geri y�kleme (�zerine yazmak i�in):
USE master;
GO
ALTER DATABASE localhouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
RESTORE DATABASE localhouse FROM DISK = 'C:\\SQLBackups\\localhouse.bak' WITH REPLACE;
ALTER DATABASE localhouse SET MULTI_USER;

-- Yeni isimle restore (test i�in):
USE master;
GO
RESTORE DATABASE localhouse_test FROM DISK = 'C:\\SQLBackups\\localhouse.bak' 
WITH MOVE 'localhouse' TO 'C:\\SQLBackups\\localhouse_test.mdf',
     MOVE 'localhouse_log' TO 'C:\\SQLBackups\\localhouse_test.ldf';
