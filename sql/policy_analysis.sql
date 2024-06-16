use insurance_policy;


--check duplicates or not
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
    count (distinct policyId) [distinctId],
    count (policyId)
FROM
    policy_detail;
--now its okay

/*--------------------------------
    NOW THE SOLUTION STARTS
*/---------------------------------------

--Lets join the three tables
DROP TABLE IF EXISTS insurance_policy.dbo.policy_detail_risk;

SELECT
    a.*,
    b.riskRating,
    c.[description],
    c.premiumAdjustment
into insurance_policy.dbo.policy_detail_risk
FROM
    policy_detail a
Inner JOIN
    policy_riskRating b
ON
    a.policyId=b.policyId
inner JOIN
    riskRating c
on 
    b.riskRating=c.riskRating

select * from policy_detail_risk;
/*----------------------------
    Qno.1 ans
*/--------------------------

select 
    policyId,
    startDate,
    [location],
    [state],
    region,
    insuredValue,
    construction,
    businessType,
    earthquake,
    flood
from 
    policy_detail_risk
where 
    [description]='low' 
    and 
    region ='east';


/*----------------------------
    Qno.2 ans
*/-----------------------------
----------------------------------------------

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
        MONTH(StartDate);

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

/*----------------------------
    Qno.3 ans
*/--------------------------
-- What type of construction is the least and most affected by natural disasters ? 
-- (use query to return the answer)

--to do automation 
--we can use following logics::
--Metal clad is the least affected
--so Frame is the max affected

select top 1
    construction,
    sum(earthquake + flood) [NaturalDisaster]
from 
    policy_detail
group BY
    construction
order by
    NaturalDisaster;
-- this is in ascending order so  this gives the least value in first row
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