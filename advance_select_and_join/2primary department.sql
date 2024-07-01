use leetcode;

drop table if EXISTS employees;

create table employees(
    employee_id int,
    department_id int,
    primary_flag char(1)
        check(primary_flag in ('Y', 'N'))
);

bulk insert employees
from 'D:\ITCOurses\click\MyProjects\github\leetcode\files\employee.txt'
WITH(
    firstrow=2,
    fieldterminator= ',',
    rowterminator='\n'
);

delete from employees;

select * from employees;

select 
    employee_id,
    department_id
from employees
WHERE   
    primary_flag='y'

union all

SELECT
    employee_id,
    department_id
from employees
WHERE   
    primary_flag='n'
    AND
    employee_id in (
        select 
            employee_id 
        from 
            employees 
        group by 
            employee_id 
        having COUNT(employee_id)=1
    );
