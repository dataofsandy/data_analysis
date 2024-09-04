-- after successful bulk insert checking the record of PostCovidConditions Table
select * from PostCovidConditions;

--so we have total of 17235 records 

-- now before proceeding lets check duplicates
/*
    checking duplicates:
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
