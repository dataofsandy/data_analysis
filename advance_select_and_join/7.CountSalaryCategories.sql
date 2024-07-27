use github_leetcode;

CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    income INT NOT NULL
);

INSERT INTO Accounts (account_id, income) 
VALUES 
(3, 108939),
(2, 12747),
(8, 87709),
(6, 91796);

select * from Accounts;

with cte as (
    SELECT
        *
        ,case 
            when income < 20000 then 'Low Salary'
            when income between 20000 and 50000 then 'Average Salary'
            when income > 50000 then 'High Salary'
            else 
                'Not matched'
        END [category]
    FROM
        Accounts
)
,categories as (
    select 'Low Salary' as category
    union ALL
    select 'High Salary' as category
    union ALL
    select 'Average Salary' as category
)
SELECT
    a.category
    ,sum(
        case 
            when b.category is null then 0 
            else   1
        end
    ) [accounts_count]
    
from 
    categories a
left JOIN
    cte b
ON
    a.category=b.category
GROUP BY
    a.category;

--second method
SELECT
    'Low Salary' as category,
    count (1) as accounts_count

FROM
    Accounts
WHERE
    income <20000

union all

SELECT
    'Average Salary' as category,
    count (1) as accounts_count

FROM
    Accounts
WHERE
    income between 20000 and 50000

union ALL

SELECT
    'High Salary' as category,
    count (1) as accounts_count

FROM
    Accounts
WHERE
    income >50000;