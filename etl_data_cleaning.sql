-- after successful bulk insert checking the record of PostCovidConditions Table
select * from PostCovidConditions;

--so we have total of 17235 records 

-- now before proceeding lets check duplicates
/*--------------------------------------------------------

    checking duplicates

------------------------------------------------------------
*/
-- as this record doesnot have id, we check duplicates for all columns where all columns are identical

with cte as (
    select 
        *
    , ROW_NUMBER() over (
                            partition by 
                                    Indicator, [Group], [state], subgroup, phase, TimePeriod, 
                                    TimePeriodLabel, TimePeriodStartDate, TimePeriodEndDate, 
                                    [value], LowCI, HighCI, ConfidenceInterval, 
                                    QuartileRange, QuartileNumber, SuppressionFlag
                            order BY
                                (select NULL) 
                        ) as RN

    FROM
        PostCovidConditions
)

select 
    * 
from 
    cte
where RN >1;
-- so there is a duplicate value

/*--------------------------------------------------------

    removing duplicates

------------------------------------------------------------
*/
-- Now, lets delete the duplciate records
with cte as (
    select 
        *
    , ROW_NUMBER() over (
                            partition by 
                                    Indicator, [Group], [state], subgroup, phase, TimePeriod, 
                                    TimePeriodLabel, TimePeriodStartDate, TimePeriodEndDate, 
                                    [value], LowCI, HighCI, ConfidenceInterval, 
                                    QuartileRange, QuartileNumber, SuppressionFlag
                            order BY
                                (select NULL) 
                        ) as RN

    FROM
        PostCovidConditions
)

delete
from 
    cte
where RN >1;


/*--------------------------------------------------------

    Choosing the demographic factor from group 
                and its subfactor from subgroup 

----------------------------------------------------------
*/

--observing the dataset
-- my focus is on group and subgroup first 
-- to know the output of this block check readme.md  3. Distinct Group and 4. Distinct Subgroup
select
    distinct [Group]
FROM
    PostCovidConditions; -- Output: 9 records

select
    distinct [subgroup]
FROM
    PostCovidConditions; -- Output: 78 records

-- Observation:
-- Demographic factors of distinct group list looks fine
-- however distinct subgroup list is looking messy
-- I can see lots of states name in the distinct subgroup list
-- I have decided to  analyse demographic of long covid rates at the national level
-- so i am not including by state demographic factor from the Group and its Subgroup
-- Lets see the group and subgroup after not including By State factor

SELECT
    distinct [Group]
from
    PostCovidConditions
WHERE
    [Group] <> 'By state' --output: 8 records

SELECT
    distinct subgroup
from
    PostCovidConditions
WHERE
    [Group] <> 'By State' -- output: 27 records

-- Seems good to analyze at the national level
