BACKUP DATABASE localhouse
TO DISK = 'C:\yedekler\localhouse_upgrade_backup.bak';

RESTORE DATABASE localhouse
FROM DISK = 'C:\yedekler\localhouse_upgrade_backup.bak'
WITH MOVE 'localhouse' TO 'C:\yedekler\localhouse_new.mdf',
     MOVE 'localhouse_log' TO 'C:\yedekler\localhouse_new_log.ldf',
     RECOVERY;

	 ---6.madde
USE master;
GO

ALTER DATABASE localhouse
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

BACKUP DATABASE localhouse
TO DISK = 'C:\Yedekler\localhouse_2025.bak'
WITH FORMAT, INIT;

USE master;
GO
ALTER DATABASE localhouse
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
RESTORE DATABASE localhouse
FROM DISK = 'C:\Yedekler\localhouse_2025.bak'
WITH REPLACE;
GO
ALTER DATABASE localhouse
SET MULTI_USER;
GO

USE master;
GO
ALTER DATABASE localhouse
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

BACKUP DATABASE localhouse
TO DISK = 'C:\Yedekler\localhouse_2025.bak'
WITH FORMAT, INIT;


USE master;
GO
RESTORE DATABASE localhouse
FROM DISK = 'C:\Yedekler\localhouse_2025.bak'
WITH REPLACE;
GO


ALTER DATABASE localhouse
SET MULTI_USER;
GO

--(Opsiyonel) Þema Deðiþikliklerini Ýzlemek Ýçin DDL Trigger Tanýmlama:
CREATE TRIGGER ddl_trigger_log
ON DATABASE
FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN
    INSERT INTO ddl_log_table(event_type, object_name, event_time)
    VALUES (EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
            EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(100)'),
            GETDATE());
END;


RESTORE DATABASE localhouse
FROM DISK = 'C:\Yedekler\localhouse_2025.bak'
WITH REPLACE;


USE master;
GO
ALTER DATABASE localhouse
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
RESTORE DATABASE localhouse
FROM DISK = 'C:\Yedekler\localhouse_upgrade_backup.bak'
WITH REPLACE;
ALTER DATABASE localhouse
SET MULTI_USER;
GO