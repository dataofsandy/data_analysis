use github_leetcode;


create TABLE employee_asf(
    id int primary KEY,
    salary int
)

delete from employee_asf;
insert into employee_asf(id, salary)
VALUES
(1, 100),
(2, 200),
(3, 300);


--using subqueries
select 
    max(salary) [SecondHighestSalary]
FROM
    employee_asf
WHERE
    salary < (select max(salary) from employee_asf)


--using window function
--handling null if there is no second highest salary

WITH SalaryRank AS (
    SELECT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS rank
    FROM employee_asf
)
select 
    max(
        case
            when rank=2 then salary
        END
     ) [SecondHighestSalary]
from 
    SalaryRank;

-- SELECT 
--     CASE
--         WHEN EXISTS (SELECT 1 FROM SalaryRank WHERE rank = 2) 
--         THEN (SELECT salary FROM SalaryRank WHERE rank = 2)
--         ELSE NULL
--     END AS SecondHighestSalary;