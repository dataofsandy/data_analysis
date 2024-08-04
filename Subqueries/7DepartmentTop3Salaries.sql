use github_leetcode;

-- Create Department table
CREATE TABLE Department (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

-- Create Employee table
drop table if exists employee;
CREATE TABLE Employee (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    salary INT,
    departmentId INT,
    FOREIGN KEY (departmentId) REFERENCES Department(id)
);
-- Insert data into Department table
INSERT INTO Department (id, name)
VALUES
    (1, 'IT'),
    (2, 'Sales');

-- Insert data into Employee table
INSERT INTO Employee (id, name, salary, departmentId)
VALUES
(1, 'Joe', 85000, 1),
(2, 'Henry', 80000, 2),
(3, 'Sam', 60000, 2),
(4, 'Max', 90000, 1),
(5, 'Janet', 69000, 1),
(6, 'Randy', 85000, 1),
(7, 'Will', 70000, 1);



select * from Department;
select * from employee;


--solution using subquery
select 
    b.name [department]
    ,a.name [employee]
    ,a.salary
    
from
    Employee a
inner JOIN
    Department b
ON
    a.departmentId=b.id
WHERE
    a.salary in (
        select
            distinct
            top 3 
            salary
        from
            Employee
        where
            departmentId=a.departmentId
        order by
            salary desc
            
    )
order by
    department, salary desc;


--solution using window function
WITH RankedEmployees AS (
    SELECT 
        e.id AS employee_id,
        e.name AS employee,
        e.salary,
        e.departmentId,
        d.name AS department,
        DENSE_RANK() OVER (PARTITION BY e.departmentId ORDER BY e.salary DESC) AS salary_rank
    FROM 
        Employee e
    JOIN 
        Department d 
    ON 
        e.departmentId = d.id
)
SELECT 
    department
    ,employee
    salary
FROM 
    RankedEmployees
WHERE 
    salary_rank <= 3;


    SELECT 
        e.id AS employee_id,
        e.name AS employee,
        e.salary,
        e.departmentId,
        d.name AS department,
        DENSE_RANK() OVER (PARTITION BY e.departmentId ORDER BY e.salary DESC) AS salary_rank
        ,rank() over (partition by e.departmentId order by e.salary desc) [salary_rank_rank]
    FROM 
        Employee e
    JOIN 
        Department d 
    ON 
        e.departmentId = d.id

------------------


-- SELECT
--     e.id AS employee_id,
--     e.name AS employee_name,
--     e.salary,
--     d.name AS department_name
-- FROM
--     Employee e
-- JOIN
--     Department d ON e.departmentId = d.id
-- WHERE
--     e.salary IN (
--         SELECT DISTINCT
--             es.salary
--         FROM
--             Employee es
--         WHERE
--             es.departmentId = e.departmentId
--         ORDER BY
--             es.salary DESC
--         OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY
--     )
-- ORDER BY
--     d.name, e.salary DESC;

    ---

-- select * from Employee;
-- select * from Department;


-- with RankedEmployees as(
--     SELECT
--     b.name [department]
--     ,a.name [employee]
--     ,a.salary
--     ,DENSE_RANK() OVER(partition by a.departmentId order by salary desc) [salary_rank]

--     from 
--         Employee a
--     inner JOIN
--         Department b
--     ON
--         a.departmentId=b.id

-- )
-- SELECT
--     department
--     ,employee
--     ,salary
-- from
--     RankedEmployees
-- where
--     salary_rank <=3;