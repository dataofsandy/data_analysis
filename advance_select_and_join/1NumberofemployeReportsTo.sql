-- Write a solution to report the ids and the names of all managers, the number of employees who report directly to them, 
-- and the average age of the reports rounded to the nearest integer.
use leetcode;
drop table if exists l_employee;
CREATE TABLE l_Employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(50),
    reports_to INT NULL,
    age INT
    -- FOREIGN KEY (reports_to) REFERENCES Employees(employee_id)
);
INSERT INTO l_Employees (employee_id, name, reports_to, age) 
VALUES
(1, 'Michael', NULL, 45),
(2, 'Alice', 1, 38),
(3, 'Bob', 1, 42),
(4, 'Charlie', 2, 34),
(5, 'David', 2, 40),
(6, 'Eve', 3, 37),
(7, 'Frank', NULL, 50),
(8, 'Grace', NULL, 48);

select 
    m.employee_id,
    m.name,
    count(e.employee_id) [reports_count],
    round(AVG(e.age * 1.0),0) [average_age]
from 
    l_Employees e
inner JOIN
    l_Employees m
on 
    e.reports_to=m.employee_id
group BY
    m.employee_id, m.name
order BY
    m.employee_id

