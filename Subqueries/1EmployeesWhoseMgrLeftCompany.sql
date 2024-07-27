use github_leetcode;

drop table if exists Employees;
create table employees(
    employee_id int primary key,
    name VARCHAR(50),
    manager_id int null,
    salary int
    -- ,constraint fk_manager
    --     foreign key (manager_id) 
    --     REFERENCES employees (employee_id)
);

insert into employees(employee_id, name, manager_id, salary)
VALUES
(3, 'Mila', 9, 60301),
(12, 'Antonella', NULL, 31000),
(13, 'Emery', NULL, 67084),
(1, 'Kalel', 11, 21241),
(9, 'Mikaela', NULL, 50937),
(11, 'Joziah', 6, 28485);

select * from employees;

SELECT
    employee_id
from
    employees
where 
    salary < 30000
    AND
    manager_id not in (select employee_id from employees)
    AND
    manager_id is not NULL