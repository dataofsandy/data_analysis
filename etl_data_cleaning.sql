-- after successful bulk insert checking the record of PostCovidConditions Table
select
    *
from
    PostCovidConditions;

--so we have total of 17235 records 
-- now before proceeding lets check duplicates

/*--------------------------------------------------------

checking duplicates

------------------------------------------------------------
 */
-- as this record doesnot have id, we check duplicates for all columns where all columns are identical
with
    cte
    as
    (
        select
            *
            ,ROW_NUMBER() over (
                partition by
                    Indicator,
                    [Group],
                    [state],
                    subgroup,
                    phase,
                    TimePeriod,
                    TimePeriodLabel,
                    TimePeriodStartDate,
                    TimePeriodEndDate,
                    [value],
                    LowCI,
                    HighCI,
                    ConfidenceInterval,
                    QuartileRange,
                    QuartileNumber,
                    SuppressionFlag
                order BY
                    (
                        select
                            NULL
                    )
            ) as RN
        FROM
            PostCovidConditions
    )
select
    *
from
    cte
where
    RN > 1;

-- so there is a duplicate value
/*--------------------------------------------------------

removing duplicates

------------------------------------------------------------*/
-- Now, lets delete the duplciate records
with
    cte
    as
    (
        select
            *
            ,ROW_NUMBER() over (
                partition by
                    Indicator,
                    [Group],
                    [state],
                    subgroup,
                    phase,
                    TimePeriod,
                    TimePeriodLabel,
                    TimePeriodStartDate,
                    TimePeriodEndDate,
                    [value],
                    LowCI,
                    HighCI,
                    ConfidenceInterval,
                    QuartileRange,
                    QuartileNumber,
                    SuppressionFlag
                order BY
                    (
                        select
                            NULL
                    )
            ) as RN
        FROM
            PostCovidConditions
    )
delete from cte
where
    RN > 1;

/*--------------------------------------------------------

Choosing the demographic groups
from group and subgroup 

----------------------------------------------------------*/
--observing the dataset
-- my focus is on group and subgroup first 
-- to know the output of this block check readme.md  3. Distinct Group and 4. Distinct Subgroup

--distinct group
select distinct
    [Group]
FROM
    PostCovidConditions;

-- Output: 9 records

--distinct subgroup
select distinct
    [subgroup]
FROM
    PostCovidConditions;

-- Output: 78 records

-- Observation::
-- Demographic groups of column Group list (distinct) looks fine
-- however distinct subgroup list is looking messy
-- I can see lots of states name in the distinct subgroup list
-- I have decided to  analyse demographic of long covid rates on a national level
-- so i am not including by state demographic group from the column Group and column Subgroup

-- Lets see the group and subgroup after not including By State demographic

--group
SELECT distinct
    [Group]
from
    PostCovidConditions
WHERE
    [Group] <> 'By state'
--output: 8 records


--subgroup
SELECT distinct
    subgroup
from
    PostCovidConditions
WHERE
    [Group] <> 'By State'
-- output: 27 records


-- Seems good to start analyzing
-- Subgroup contains all demographic information in relation to Long covid rates in the value column
-- But stil the information from the subroup column is hard to read. 
-- As groups of age, sex, gender_identity, ... of indicator is all in the subgroup column
-- To improve data clarity and cleanliness, I am seperating demographic groups of subgroup column in the individual column to make demographic factors like age, sex, race, ...
/*------------------------------------------------
    7.
    Transformation, Pivoting and Normalizing
    Subgroup Column 
    
--------------------------------------------------*/
drop table if exists #longcovidprevalencesummary;

with
    cte
    as
    (
        SELECT
            TimePeriodStartDate
            ,Indicator
            ,case
                When subgroup = 'united states' then 'national'
                else Null --explicitly stating if something else then give null for the clarity (my intention)
            end as national_estimate
            ,case
                when subgroup = '18 - 29 years' then '18 - 29'
                when subgroup = '30 - 39 years' then '30 - 39'
                when subgroup = '40 - 49 years' then '40 - 49'
                when subgroup = '50 - 59 years' then '50 - 59'
                when subgroup = '60 - 69 years' then '60 - 69'
                when subgroup = '70 - 79 years' then '70 - 79'
                when subgroup = '80 years and above' then '80+'
                else Null
            end as age_group
            ,case
                when subgroup = 'male' then 'Male'
                when subgroup = 'female ' then 'Female'
                else null
            end as sex
            ,case
                when subgroup in ('cis-gender male', 'cis-gender female') then 'cisgender'
                -- when subgroup= 'cis-gender male' then 'cisgender'
                -- when subgroup= 'cis-gender female' then 'cisgender'
                when subgroup = 'Transgender' then 'Transgender'
                else null
            end as gender_identity
            ,case
                when subgroup = 'straight' then 'heterosexual'
                when subgroup in ('gay or lesbian', 'bisexual') then 'non-heterosexual'
                else null
            end as sexuality
            ,case
                when subgroup = 'hispanic or latino' then 'hispanic'
                when subgroup = 'non-hispanic white, single race' then 'white'
                when subgroup = 'non-hispanic black, single race' then 'black'
                when subgroup = 'non-hispanic asian, single race' then 'asian'
                when subgroup = 'non-hispanic, other races and multiple races' then 'mixed/other'
                else null
            end as Race
            ,case
                when subgroup = 'bachelor''s degree or higher' then 'college_graduate'
                when subgroup in (
                    'less than high school diploma',
                    'some college/associates degree',
                    'high school diploma or ged'
                ) then 'non_college_graduate'
                else null
            end as education_level 
            ,case
                when subgroup = 'with disability' then 'disabled'
                when subgroup = 'without disability' then 'not_disable'
                else null
            end as disability_status
            ,[value]
        from
            PostCovidConditions
    )
SELECT
    TimePeriodStartDate
    ,[Indicator]
    ,national_estimate
    ,age_group
    ,sex
    ,gender_identity
    ,sexuality
    ,Race
    ,education_level
    ,disability_status
    ,Round(AVG([value]), 2) as Average_Precentage --in our dataset indicator reflects value column is percentage
into #LongCovidPrevalenceSummary
FROM
    cte
group BY
    TimePeriodStartDate,
    [Indicator],
    national_estimate,
    age_group,
    sex,
    gender_identity,
    sexuality,
    Race,
    education_level,
    disability_status;

/*------------------------------------------------------------
    8.
    Transformation, Pivoting and Normalizing
    above  table #LongCovidPrevalenceSummary::
        Making step 7. data more informative by grouping.
            First, It summarizes above prevalence data by demographic groups and categories 
                i.e. each demographics inforamtion: groups like timeperiodstart, indicator AND categories like national, 18-29, 30-39, male, female, cisgender, transgener, college_graduate, Non_college_graduate, ...
            Second, this step is the preference
                Max: If interested in peak value within the categories
                Avg:  suitable to understand typical prevalence across all entries
--------------------------------------------------------------------------*/
drop table if exists #LongCovidPrevalenceSummaryByDemographics;

select
    TimePeriodStartDate --demographic groups

    ,Indicator --demographic groups
    --all of the belows data are demographic categories

    ,MAX(
        case
            when national_estimate = 'national' then Average_Precentage
        end
    ) as [national_avg % ]
    ,MAX(
        case
            when age_group = '18 - 29' then Average_Precentage
        end
    ) as [18-29 %]
    ,MAX(
        case
            when age_group = '30 - 39' then Average_Precentage
        end
    ) as [30-39 %]
    ,MAX(
        case
            when age_group = '40 - 49' then Average_Precentage
        end
    ) as [40-49 %]
    ,MAX(
        case
            when age_group = '50 - 59' then Average_Precentage
        end
    ) as [50-59 %]
    ,MAX(
        case
            when age_group = '60 - 69' then Average_Precentage
        end
    ) as [60-69 %]
    ,MAX(
        case
            when age_group = '70 - 79' then Average_Precentage
        end
    ) as [70-79 %]
    ,MAX(
        case
            when age_group = '80+' then Average_Precentage
        end
    ) as [80+ %]
    ,MAX(
        case
            when sex = 'male' then Average_Precentage
        end
    ) as [Male %]
    ,MAX(
        case
            when sex = 'female' then Average_Precentage
        end
    ) as [Female %]
    ,MAX(
        case
            when gender_identity = 'cisgender' then Average_Precentage
        end
    ) as [cisgender %]
    ,max(
        case
            when gender_identity = 'transgender' then Average_Precentage
        end
    ) as [transgender %]
    ,max(
        case
            when sexuality = 'heterosexual' then Average_Precentage
        end
    ) as [heterosexual %]
    ,max(
        case
            when sexuality = 'non-heterosexual' then Average_Precentage
        end
    ) as [non_heterosexual %]
    ,max(
        case
            when Race = 'asian' then Average_Precentage
        end
    ) as [Asian %]
    ,max(
        case
            when Race = 'black' then Average_Precentage
        end
    ) as [Black %]
    ,max(
        case
            when race = 'hispanic' then Average_Precentage
        end
    ) as [Hispanic %]
    ,max(
        case
            when race = 'mixed/other' then Average_Precentage
        end
    ) as [ Mixed/other %]
    ,max(
        case
            when Race = 'white' then Average_Precentage
        end
    ) as [white %]
    ,max(
        case
            when education_level = 'college_graduate' then Average_Precentage
        end
    ) as [College_graduate %]
    ,max(
        case
            when education_level = 'non_collge_graduate' then Average_Precentage
        end
    ) as [non_college_graduate %]
    ,MAX(
        case
            when disability_status = 'disabled' then Average_Precentage
        end
    ) as [disabled %]
    ,MAX(
        case
            when disability_status = 'not_disable' then Average_Precentage
        end
    ) as [not_disabled %]
into #LongCovidPrevalenceSummaryByDemographics
from
    #LongCovidPrevalenceSummary
group BY
    TimePeriodStartDate,
    Indicator
order BY
    TimePeriodStartDate;

--inserting the dataset from temporary table #LongCovidPrevalenceSummaryByDemographics into LongCovidPrevalenceSummaryByDemographics;

drop table if exists LongCovidPrevalenceSummaryByDemographics;

select
    *
into LongCovidPrevalenceSummaryByDemographics
FROM
    #LongCovidPrevalenceSummaryByDemographics;

--Final table
select
    *
from
    LongCovidPrevalenceSummaryByDemographics;


/*----------------------------------------------------

9. Null checks in final table obtained from step 8.

---------------------------------------------------------*/

--checking if null is present in all the 23 columns in our final table
select
    *
from
    LongCovidPrevalenceSummaryByDemographics
WHERE
    [national_avg % ] IS NULL
    AND [18-29 %] IS NULL
    AND [30-39 %] IS NULL
    AND [40-49 %] IS NULL
    AND [50-59 %] IS NULL
    AND [60-69 %] IS NULL
    AND [70-79 %] IS NULL
    AND [80+ %] IS NULL
    AND [Male %] IS NULL
    AND [Female %] IS NULL
    AND [cisgender %] IS NULL
    AND [transgender %] IS NULL
    AND [heterosexual %] IS NULL
    AND [non_heterosexual %] IS NULL
    AND [Asian %] IS NULL
    AND [Black %] IS NULL
    AND [Hispanic %] IS NULL
    AND [ Mixed/other %] IS NULL
    AND [white %] IS NULL
    AND [College_graduate %] IS NULL
    AND [non_college_graduate %] IS NULL
    AND [disabled %] IS NULL
    AND [not_disabled %] IS NULL;

-- so 23 records have null values in all the demographics categories

/*-----------------------------

10. Delete Null values we get from step 9.

------------------------------------*/
-- so deleting all 23 records from LongCovidPrevalenceSummaryByDemographics
delete from LongCovidPrevalenceSummaryByDemographics
WHERE
    [national_avg % ] IS NULL
    AND [18-29 %] IS NULL
    AND [30-39 %] IS NULL
    AND [40-49 %] IS NULL
    AND [50-59 %] IS NULL
    AND [60-69 %] IS NULL
    AND [70-79 %] IS NULL
    AND [80+ %] IS NULL
    AND [Male %] IS NULL
    AND [Female %] IS NULL
    AND [cisgender %] IS NULL
    AND [transgender %] IS NULL
    AND [heterosexual %] IS NULL
    AND [non_heterosexual %] IS NULL
    AND [Asian %] IS NULL
    AND [Black %] IS NULL
    AND [Hispanic %] IS NULL
    AND [ Mixed/other %] IS NULL
    AND [white %] IS NULL
    AND [College_graduate %] IS NULL
    AND [non_college_graduate %] IS NULL
    AND [disabled %] IS NULL
    AND [not_disabled %] IS NULL;

select
    *
from
    LongCovidPrevalenceSummaryByDemographics;

/*-----------------------------------------------------

11. Analysis: Maximum national maximum percentage for each indicator along with survey date

-------------------------------------------------*/
-- Analysis:: 
-- Finding maximum national_average percentage of each distinct indicator along with timeperiodstart date through out the dataset period 
-- lets see maximum national_average % in the indicator and at which timestartdate it was maximum?
with cte_max as(
    SELECT
        Indicator,
        MAX([national_avg % ]) as [Max national_avg %]
    from
        LongCovidPrevalenceSummaryByDemographics
    group BY
        Indicator
)
SELECT
    a.TimePeriodStartDate,
    a.Indicator,
    b.[Max national_avg %]
from 
    LongCovidPrevalenceSummaryByDemographics a
inner JOIN
    cte_max b
on
    a.Indicator=b.Indicator and
    a.[national_avg % ]=b.[Max national_avg %]
order BY
    b.[Max national_avg %] desc;