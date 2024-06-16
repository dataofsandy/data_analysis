/* -----------------------------------------------------------------------------
    Analysing Datasets and save into SQL server
*/ -----------------------------------------------------------------------------
create database card_demo;
use card_demo;

-- 1. get target variable [ is the loan bad or good ]

--creating default column 
--using status from creditRecord

drop table if exists #tmp;


select 
    id,
    case 
        when number_of_bad_months > 0 then 1 
        else 0 
    end as [Default]
into #tmp
from(
    select 
        id,
        -- ,sum(case when [status] in ('1','2','3','4','5') then 1 else 0 end ) [number_of_bad_months]
        sum(
            case 
                when [status] in ('2','3','4','5') then 1 
                else 0 
            end 
        ) [number_of_bad_months]
    from 
        CreditRecord
    group by    
        id
)a ;

select count (*) from #tmp;


-- 2. merget dataset (and removing duplicates)

/*---------------------------------------------------------------------- 
--this following window function just keeps executing in rds so we use windows function first in
--localhost and filtered rn=1 and saved the csv file and
--imported in ApplicationRecord table
*/---------------------------------------------------------------------------
select 
    *
    ,ROW_NUMBER() OVER (partition by id order by id) RN
into #RN
from 
    ApplicationRecord;

select 
    *
into #FilteredRN
FROM
    #rn
where RN=1;

ALTER TABLE #FilteredRN DROP COLUMN rn;


/*--as the aws keeps executing the following block of code we split the code of window function 
--did filter everythign separately in localhost: card-demo
 
select 
    a.*
    ,b.[Default]
into 
    merge
from 
    (
        --in order to remove duplicates record from ApplicationRecord
        --we use Row number
        --use analysis.sql for comprehensive detail about this block of code
        select 
            *
            ,ROW_NUMBER() OVER (partition by id order by id) RN
        from 
            ApplicationRecord 
    ) a 
inner join   
    tmp b 
on 
    a.ID = b.ID 
where 
    a.rn = 1; --filtering RN and only taking value RN=1
             --as RN=2 is the duplicate value


--after filtering and merging we
--dont want RN column now
--so removing that column
ALTER TABLE #merge DROP COLUMN rn;
*/

--this is the end of windows function we used in localhost: card-demo
/*-------------------------------------------------------------------------------------------*/

drop table if exists card_demo.dbo.RN;


select 
    a.*
    ,b.[Default]
into #merge
from 
    ApplicationRecord a     
inner join   
    #tmp b 
on 
    a.ID = b.ID;

SELECT top 10 * FROM #merge;

select 
    * 
into card_demo.dbo.[merge]
FROM
    #merge

--to save space in aws rds db instance
--i am going to delete ApplicationRecord and CreditRecord table


/*------------------------------------------------------------
    creating tables and inserting into the database
    
*/------------------------------------------------------------


/*------------------------------------------------------------------------
    Profile Analysis
*/---------------------------------------------------------------------------

--Table gender
-- CREATING gender table
-- Gender correlations
-- female performs slightly higher than male 

drop table if exists Gender;
select 
    CODE_GENDER
    ,count(1) as Vol,
    -- sum([Default])*1.0 / count(1) [DefaultRate], --this is the average so we can directly use average function
    AVG([Default]*1.0) [DefaultRate],
    count(1) as volume
into card_demo.dbo.Gender
from [merge]
group by 
    CODE_GENDER

--Table Age
--WE ARE CREATING Age table which contains
--AGE BIN [AgeBin], its volume, and averageDefaultRate
-- young people are bad
drop table if exists card_demo.dbo.Age;

with cte as (
    select 
        *
        ,case 
            --convering days into years and
            --categorizing their age 
            when abs(DAYS_BIRTH)/365 < 20 then '[1] less than 20'
            when abs(DAYS_BIRTH)/365 < 30 then '[2] 20-30'
            when abs(DAYS_BIRTH)/365 < 40 then '[3] 30-40'
            when abs(DAYS_BIRTH)/365 < 50 then '[4] 40-50'
            when abs(DAYS_BIRTH)/365 >= 50 then '[5] 50+'
        end as [AgeBin]
    from #merge 
)
select 
    AgeBin
    ,count(1) [Vol],
    -- sum([Default])*1.0/count(1) [DefaultRate], --we can calculate the average using sum in this way
    AVG([Default]*1.0) [AVerageDefaultRate] --or directly using average function
into card_demo.dbo.Age
from 
    cte
group by AgeBin
order by AgeBin ;


/*------------------------------------------------------------------------
    Assets Analysis
*/---------------------------------------------------------------------------
--table car
--Own car
-- default is slightly lower if applications own a car
drop table if exists card_demo.dbo.car;
select  
    FLAG_OWN_CAR,
    count(1) [Vol],
    -- sum([Default])*1.0 / count(1) [DefaultRate],  --we can calculate the average using sum in this way
    Avg([Default]*1.0) [AverageDefaultRate]    
into card_demo.dbo.car
from #merge
group BY
    FLAG_OWN_CAR

select * from car;
select * from #merge;


--table housingtype
--rented apartment is [best] followed by with parents [good]
--municipal apartment --[worse]
--we ignore office aparment and co-op apartment as it has least volume i.e. <500

drop table if EXISTS housingtype;

SELECT
    NAME_HOUSING_TYPE,
    count(1) [vol],
    AVG([Default]*1.0) [AverageDefaultRate]
into card_demo.dbo.HousingType
from #merge
group BY
    NAME_HOUSING_TYPE
HAVING
    count(1) >=500;
-- ORDER BY
    -- AverageDefaultRate desc



--table house
-- default rate is low if applicants own home 
--no own home means high defaultrate 
drop table if exists card_demo.dbo.house;

SELECT
    FLAG_OWN_REALTY,
    count(1) [vol],
    AVG([Default] * 1.0) [DefaultRate]
into card_demo.dbo.house
from #merge
GROUP BY
    FLAG_OWN_REALTY
order BY
    DefaultRate ;

--Assets is done

/*------------------------------------------------------------------------
    Family Analysis
*/---------------------------------------------------------------------------

select * from #merge;

--table children
--Those with 0 children are better
--as we have good volume of data 25K and default rate is also slightly similar to the others..
--however 
--if we just go through the default rate and chart then 1 children is better.
--high volume and less default means good.

drop table if exists children;

SELECT
    case 
        when CNT_CHILDREN >= 2 then '2+'
        else CAST(CNT_CHILDREN as varchar(10))
    end [CNT_CHILDREN],
    COUNT(1) [VOL],
    AVG([Default]*1.0) [DefaultRate]
into card_demo.dbo.children
-- into #childrencheck
from 
    #merge
group BY
    case 
        when CNT_CHILDREN >= 2 then '2+'
        else CAST(CNT_CHILDREN as varchar(10))
    end
order BY
    case 
        when CNT_CHILDREN >= 2 then '2+'
        else CAST(CNT_CHILDREN as varchar(10))
    end;


--table FamilyMembers
SELECT
    case
        when CNT_FAM_MEMBERS >= 4 then '4+'
        else cast (CNT_FAM_MEMBERS as varchar (10))
    end [CNT_FAM_MEMBERS], 
    -- case --same thing as above code
    --     when CNT_FAM_MEMBERS <4 then cast (CNT_FAM_MEMBERS as varchar (10))
    --     else '4+'
    -- end [CNT_FAM_MEMBERS], 
    COUNT(1) [vol],
    AVG([Default] * 1.0) [DefaultRate]
into card_demo.dbo.FamilyMembers
from #merge
GROUP BY
    case
        when CNT_FAM_MEMBERS >= 4 then '4+'
        else cast (CNT_FAM_MEMBERS as varchar (10))
    end
ORDER BY
    case
        when CNT_FAM_MEMBERS >= 4 then '4+'
        else cast (CNT_FAM_MEMBERS as varchar (10))
    end;


--table FamilyStatus
SELECT
    NAME_FAMILY_STATUS,
    count(1) [vol],
    AVG([Default]*1.0) [DefaultRate]
into card_demo.dbo.FamilyStatus
from #merge
group BY
    NAME_FAMILY_STATUS;


/*------------------------------------------------------------------------
    Career Analysis
*/---------------------------------------------------------------------------

--table EducationType
--secondary/secondary special
drop table if EXISTS EducationType;
SELECT
    NAME_EDUCATION_TYPE,
    COUNT(1) [vol],
    Avg([Default] * 1.0) [DefaultRate]
INTO card_demo.dbo.EducationType
from    
    #merge
GROUP BY
    NAME_EDUCATION_TYPE
HAVING
    count(1) >= 500;


--table OccupationType
--medicine staff
drop table if exists OccupationType;
SELECT
    OCCUPATION_TYPE,
    count(1) [vol],
    AVG([Default] * 1.0 ) [DefaultRate]
-- INTO card_demo.dbo.OccupationType
from 
    merge
WHERE 
    OCCUPATION_TYPE is not NULL
GROUP BY
    OCCUPATION_TYPE
having
    COUNT(1) >=500;

    select * from OccupationType;


/*------------------------------------------------------------------------
    Income Analysis
*/---------------------------------------------------------------------------

--table incometype
--state servant is better
--pensioner has high risk of default
drop table if exists incometype;
SELECT
    NAME_INCOME_TYPE,
    count(1) [vol],
    AVG([Default] * 1.0 ) [DefaultRate]
into card_demo.dbo.IncomeType
from #merge
group BY
    NAME_INCOME_TYPE
HAVING
    COUNT(1) >= 500
order BY
    [DefaultRate];


--table income
--not informative form input while filing by the user is wrong
drop table if EXISTS income;
with cte as(
    select
        *, --we are adding one more column income bin in the merge record so that we can have default value
        case
            when AMT_INCOME_TOTAL between 0 and 40000 then '[1] 0-40k'
            when AMT_INCOME_TOTAL between 40001 and 80000 then '[2] 40-80k'
            when AMT_INCOME_TOTAL between 100001 and 150000 then '[3] 100-150k'
            when AMT_INCOME_TOTAL between 150001 and 200000 then '[4] 150-200k'
            when AMT_INCOME_TOTAL between 200001 and 300000 then '[5] 200-300k'
            when AMT_INCOME_TOTAL > 300000 then '[6] 300k+'
            else 'UNKNOWN'
        end [IncomeBin]
    from 
        #merge  
)
SELECT
    IncomeBin,
    count (1) [vol],
    AVG([Default] * 1.0) [DefaultRate]
into card_demo.dbo.Income
from 
    cte
where
    IncomeBin != 'unknown'
GROUP BY
    IncomeBin
order by IncomeBin;


select * from #merge;


select @@VERSION;