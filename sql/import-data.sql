create database card_demo; --database for our new project credit card approval analysis

use card_demo;


--creating table application_record
drop table if EXISTS ApplicationRecord;

create table ApplicationRecord(
    ID INT,
    CODE_GENDER CHAR(1),
    FLAG_OWN_CAR CHAR(1),
    FLAG_OWN_REALTY CHAR(1),
    CNT_CHILDREN INT,
    AMT_INCOME_TOTAL DECIMAL(18,2),
    NAME_INCOME_TYPE VARCHAR (50),
    NAME_EDUCATION_TYPE VARCHAR (50),
    NAME_FAMILY_STATUS VARCHAR (50),
    NAME_HOUSING_TYPE VARCHAR (50),
    DAYS_BIRTH INT,
    DAYS_EMPLOYED INT,
    FLAG_MOBIL BIT,
    FLAG_WORK_PHONE BIT,
    FLAG_PHONE BIT,
    FLAG_EMAIL BIT,
    OCCUPATION_TYPE VARCHAR (50),
    CNT_FAM_MEMBERS int
);


--creating another table credit_record 
drop table if exists CreditRecord;

create table CreditRecord(
    ID INT ,
    MONTHS_BALANCE INT,
    STATUS CHAR (1)
);



/*-------------------------------------------------------------------------
            this is the transfer/download files between rds and s3
*/-------------------------------------------------------------------------

--we are downloadiing application record to rds db instance
--tyhis is the stored procedures to download and upload files between s3 and rds db instance.
--we can also list and delete files on the rds instance
exec msdb.dbo.rds_download_from_s3
 @s3_arn_of_file='arn:aws:s3:::mssqlserver-bulk-insert/application_record_filtered.csv',
 @rds_file_path='D:\S3\mssqlserver-bulk-insert\application_record_filtered.csv',
 @overwrite_file=1; --0 means dont overwrite, 1 means overwrite

--bulk inserting application record
bulk insert ApplicationRecord 
from 'D:\S3\mssqlserver-bulk-insert\application_record_filtered.csv'
with (
    FORMAT = 'CSV',
    firstrow = 2,           --specify the row number to star importing from
    fieldterminator = ',',  --specify the field terminator
    rowterminator = '0x0a'  --specify row terminator
    -- rowterminator = '\n'  --specify row terminator
    -- codepage ='acp'         --specify the code page of the data file
    -- DATAFILETYPE = 'char',
);



--we are downloadiing credit record to rds db instance
exec msdb.dbo.rds_download_from_s3
 @s3_arn_of_file='arn:aws:s3:::mssqlserver-bulk-insert/credit_record.csv',
 @rds_file_path='D:\S3\mssqlserver-bulk-insert\credit_record.csv',
 @overwrite_file=1;

--bulk inserting credit record
bulk insert CreditRecord
from 'D:\S3\mssqlserver-bulk-insert\credit_record.csv'
with (
    FORMAT = 'CSV',
    firstrow = 2,           --specify the row number to star importing from
    fieldterminator = ',',  --specify the field terminator
    rowterminator = '\n'  --specify row terminator
);

/*--------------------------------------------------------------------
    this is end of transfer/download files between rds and s3 block
*/-------------------------------------------------------------------

/*-----------------
after merging all the records 
i will delete ApplicationRecord and CreditRecord table 
to save space in aws rds
*/-----------------


select  top 30 * from ApplicationRecord;
select top 30 * from CreditRecord;
