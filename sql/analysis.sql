use insurance_policy;


--lets check duplicates or not
SELECT
    count(1)[real],
    count(distinct policyId)
FROM
    policy_detail
--so there is some anomaly i.e. either duplicates or something


select 
    policyId,
    count(1)
from 
    policy_detail
group BY
    policyId;  --so there is 1 null value 
-- HAVING
--     count(1) > 1

--obtain the null value id
select * from policy_detail where policyId is null;

--now delete null value
delete from policy_detail where policyId is null;

--lets check duplicates status
select
    count (distinct policyId) [distinct],
    count (policyId)
FROM
    policy_detail;
--now its okay

SELECT
    a.policyId,
    b.*
into insurance_policy.dbo.policy_riskRatingInfo
FROM
    policy_riskRating a
inner JOIN
    riskRating b
on 
    a.riskRating=b.riskRating

/*----------------------------
    Qno.1 ans
*/--------------------------

select 
    *
into #region_east 
FROM    
    policy_detail
WHERE
    region='East'

select 
    a.*,
    b.[description] as Risk_Rating 
from 
    #region_east a
inner JOIN
    policy_riskRatingInfo b
ON
    a.policyId=b.policyId
where 
    b.[description]='low'


/*----------------------------
    Qno.2 ans
*/-----------------------------
----------------------------------------------
with BusinessTypeCount as(
    SELECT
        BusinessType,
        YEAR(StartDate) AS PolicyYear,
        MONTH(StartDate) AS PolicyMonth,
        COUNT(*) AS PolicyCount
    FROM
        Policy_Detail
    GROUP BY
        BusinessType,
        YEAR(StartDate),
        MONTH(StartDate)
)
,
BusinessTypeCount_LAG as(
    select 
        * 
        -- , LAG(PolicyCount) OVER (PARTITION BY BusinessType ORDER BY PolicyYear, PolicyMonth) AS Previous_Policy_Count
        , LAG(PolicyCount, 1, 0) OVER (PARTITION BY BusinessType ORDER BY PolicyYear, PolicyMonth) AS Previous_Policy_Count
    from 
        BusinessTypeCount
)

select
    businessType
    , Previous_Policy_Count
    , PolicyCount,
    --Calculate month-on-month growth/decline percentage
    case
        when Previous_Policy_Count= 0 then 0 --handling divide by zero error
        else (PolicyCount-Previous_Policy_Count) * 100.0/ Previous_Policy_Count
    end as [Percentage_Change]

from    
    BusinessTypeCount_LAG;

--Alternative way
with BusinessTypeCount as(
    SELECT
        BusinessType,
        YEAR(StartDate) AS PolicyYear,
        MONTH(StartDate) AS PolicyMonth,
        COUNT(*) AS PolicyCount
    FROM
        Policy_Detail
    GROUP BY
        BusinessType,
        YEAR(StartDate),
        MONTH(StartDate)
)
,
BusinessTypeCount_LAG as(
    select 
        * 
        -- , LAG(PolicyCount) OVER (PARTITION BY BusinessType ORDER BY PolicyYear, PolicyMonth) AS Previous_Policy_Count
        , LAG(PolicyCount, 1, 0) OVER (PARTITION BY BusinessType ORDER BY PolicyYear, PolicyMonth) AS Previous_Policy_Count,
        --Now calculating percentage change
        case
            when LAG(PolicyCount, 1, 0) OVER (PARTITION BY BusinessType ORDER BY PolicyYear, PolicyMonth)= 0 
                then Null
            else 
                (PolicyCount-LAG(PolicyCount, 1, 0) OVER (PARTITION BY BusinessType ORDER BY PolicyYear, PolicyMonth)) * 100.00
                / 
                LAG(PolicyCount, 1, 0) OVER (PARTITION BY BusinessType ORDER BY PolicyYear, PolicyMonth)
        end  as  [Percentage_Change]
    from 
        BusinessTypeCount
)

select
    businessType
    , Previous_Policy_Count
    , PolicyCount
    ,Percentage_Change
    , ISNULL(Percentage_Change, 0) [Final_Percentage_Change]

from    
    BusinessTypeCount_LAG    


/*----------------------------
    Qno.3 ans
*/--------------------------
-- What type of construction is the least and most affected by natural disasters ? 
-- (use query to return the answer)
select  
    construction,
    sum(earthquake + flood) [totalNaturalDisaster]
from 
    policy_detail
group BY
    construction
order by
    totalNaturalDisaster;
--I can see
--metal clad is the least affected construction
--Frame is the most affected construction 
--this solution is based on looking after the all data from the result



--so to do automation 
--we can use following logics::
/*------------------------------------------------------------
            logic number 1
*/------------------------------------------------------------
select top 1
    construction,
    sum(earthquake + flood) [NaturalDisaster]
from 
    policy_detail
group BY
    construction
order by
    NaturalDisaster;
-- this is in ascending order so  this gives the least value
--Metal clad is the least affected

select top 1
    construction,
    sum(earthquake + flood) [NaturalDisaster]
from 
    policy_detail
group BY
    construction
order by
    NaturalDisaster desc;
--this gives the max value at first record
--so Frame is the max affected

/*------------------------------------------------------------
            logic number 2
*/------------------------------------------------------------

select  
    construction,
    sum(earthquake + flood) [totalNaturalDisaster]
into #tmp
from 
    policy_detail
group BY
    construction;

--for max
select 
    *
from 
    #tmp
where totalNaturalDisaster= (select max(totalNaturalDisaster) from #tmp)

--for min
SELECT
    *
from 
    #tmp
WHERE
    totalNaturalDisaster=(select MIN(totalNaturalDisaster) from #tmp)


-- Qno. 4 solution
--Which region is the second least affected by natural disasters ? 
--(use window function to return the answer) 
--->Ans:
--we can use either Rank() or Row_Number() window function
WITH Disasters AS (
    SELECT 
        region
        , SUM(Earthquake + flood) AS totalNaturalDisaster
        , RANK() OVER (ORDER BY sum(earthquake + flood) ASC) AS DisasterRank
        -- , ROW_NUMBER() OVER (ORDER BY sum(earthquake + flood) ASC) AS DisasterRanks
    FROM 
        policy_detail
    GROUP BY 
        region
)
SELECT 
    *
FROM 
    Disasters
where 
    DisasterRank=2;
--so the answer is northeast


/*------------------------------------------------------------
            Question no. 5 answer
*/------------------------------------------------------------
-- Step 1: Create the necessary CTEs for joining and calculating the YearlyPremium
WITH PolicyPremium AS (
    SELECT
        pd.*,
        pr.RiskRating,
        rr.PremiumAdjustment
    FROM 
        Policy_Detail pd
    INNER JOIN 
        Policy_RiskRating pr ON pd.PolicyID = pr.PolicyID
    INNER JOIN 
        RiskRating rr ON pr.RiskRating = rr.RiskRating
)

-- Step 2: Select the final result with the YearlyPremium
SELECT 
    *,
    case 
        when premiumAdjustment=0.8 then
            -- (insuredValue * premiumAdjustment)-(0.2*(insuredValue * premiumAdjustment))
            (insuredValue * premiumAdjustment) * (1-0.2)
        when premiumAdjustment=1.0 then
            insuredValue * premiumAdjustment
        when premiumAdjustment=1.2 then
            -- (insuredValue * premiumAdjustment) + (0.2 * (insuredValue * premiumAdjustment))
            (insuredValue * premiumAdjustment) * (1 + 0.2)
        else
            'I am sorry'
    end  [YearlyPremium]    
FROM 
    PolicyPremium;