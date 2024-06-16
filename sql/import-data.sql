create database insurance_policy;

use insurance_policy;


--create table policy_detail
drop table if exists policy_detail;

CREATE table policy_detail(
    policyId bigint,
    startDate DATETIME,
    location VARCHAR(50),
    state VARCHAR(10),
    region varchar(20),
    insuredValue money,
    construction varchar(50),
    businessType varchar(50),
    earthquake int,
    flood int
)

bulk insert policy_detail
from 'D:\ITCOurses\click\MyProjects\InsurancePolicy\data\Policy_Detail.csv'
with(
    format='csv',
    firstrow=2,
    fieldterminator = ',',
    rowterminator ='0x0a'
)

select top 10 * from policy_detail;

create table policy_riskRating(
    policyId bigint,
    riskRating VARCHAR(10)
)

bulk insert policy_riskRating
from 'D:\ITCOurses\click\MyProjects\InsurancePolicy\data\Policy_RiskRating.csv'
with(
    FORMAT='csv',
    firstrow=2,
    fieldterminator=',',
    rowterminator='\n'
)

create table riskRating(
    riskRating varchar(10),
    [description] varchar(100),
    premiumAdjustment decimal (5,4)
)

bulk insert riskRating
from 'D:\ITCOurses\click\MyProjects\InsurancePolicy\data\RiskRating.csv'
with(
    FORMAT='csv',
    firstrow=2,
    fieldterminator=',',
    rowterminator='\n'
)


select top 10 * FROM policy_detail;
select top 10 * FROM policy_riskRating;
select top 10 * FROM riskRating;
