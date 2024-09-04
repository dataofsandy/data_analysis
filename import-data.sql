--  To explore the knowledge in data analytics and ms sql, I am doing this projects.
--  Data source is from : 
--     https://www.cdc.gov/nchs/covid19/pulse/long-covid.htm
--     https://data.cdc.gov/NCHS/Post-COVID-Conditions/gsea-w83j/about_data

--creating database
create database etl_cleaning;
use etl_cleaning;

--my excel has mdy format so 
SET DATEFORMAT mdy;

drop table if EXISTS PostCovidConditions;
-- i am using camelcase naming convention0 for column name
create table PostCovidConditions(
    Indicator varchar (255),
    [Group] VARCHAR (50),
    [state] varchar(50),
    subgroup varchar(50),
    phase DECIMAL(3,1),
    TimePeriod int,
    TimePeriodLabel varchar(50),
    TimePeriodStartDate DATE,
    TimePeriodEndDate Date,
    [value] decimal (4,1),
    LowCI decimal (4,1),
    HighCI decimal (4,1),
    ConfidenceInterval VARCHAR(50),
    QuartileRange varchar(50),
    QuartileNumber int,
    SuppressionFlag int
);

--bulk insert covid data from excel to our ms sql table
bulk insert PostCovidConditions
from 'D:\ITCOurses\click\MyProjects\github\ETL and Data Cleaning-Long Covid Dataset\dataset\Post-COVID_Conditions_20240902.csv'
with (
    format = 'csv',
    firstrow=2,
    fieldterminator= ',',
    rowterminator = '\n'
);
-----------------------------------------------------
