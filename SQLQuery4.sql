BACKUP DATABASE localhouse TO DISK = 'C:\\SQLBackups\\localhouse.bak';
-- Ayný isimle geri yükleme (üzerine yazmak için):
USE master;
GO
ALTER DATABASE localhouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
RESTORE DATABASE localhouse FROM DISK = 'C:\\SQLBackups\\localhouse.bak' WITH REPLACE;
ALTER DATABASE localhouse SET MULTI_USER;

-- Yeni isimle restore (test için):
USE master;
GO
RESTORE DATABASE localhouse_test FROM DISK = 'C:\\SQLBackups\\localhouse.bak' 
WITH MOVE 'localhouse' TO 'C:\\SQLBackups\\localhouse_test.mdf',
     MOVE 'localhouse_log' TO 'C:\\SQLBackups\\localhouse_test.ldf';
