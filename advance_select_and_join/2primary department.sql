use github_leetcode;

drop table if EXISTS employee;

create table employee(
    employee_id int,
    department_id int,
    primary_flag char(1)
        check(primary_flag in ('Y', 'N'))
);

bulk insert employee
from 'D:\ITCOurses\click\MyProjects\github\leetcode\files\employee.txt'
WITH(
    firstrow=2,
    fieldterminator= ',',
    rowterminator='\n'
);

delete from employee;

select * from employee;

select 
    employee_id,
    department_id
from employee
WHERE   
    primary_flag='y'

union all

SELECT
    employee_id,
    department_id
from employee
WHERE   
    primary_flag='n'
    AND
    employee_id in (
        select 
            employee_id 
        from 
            employee
        group by 
            employee_id 
        having COUNT(employee_id)=1
    );
