use leetcode;
drop table if EXISTS employees;


create table employees(
    employee_id int,
    department_id int,
    primary_flag char(1)
        -- check(primary_flag in ('Y', 'N'))
);

--this text document data works however not a good way
-- employee_id | department_id | primary_flag 
-- 1 | 59                      |N
-- 2 | 44                      |N
-- 3 | 27                      |N
-- 4 | 29                      |N
-- 5 | 40                      |Y

--this wont work
-- employee_id | department_id | primary_flag 
-- 1           | 59            |N            
-- 2           | 44            |N            
-- 3           | 27            |N            
-- 4           | 29            |N            
-- 5           | 40            |Y 

-- so cleaning data is best approach, the following one works pretty well and is best approach 
--remove whitespace
--remove the enter from the last row i.e row 5 in this case

-- employee_id , department_id , primary_flag 
-- 1,59,N
-- 2,44,N
-- 3,27,N
-- 4,29,N
-- 5,40,Y

bulk insert employees
from 'D:\ITCOurses\click\MyProjects\github\leetcode\files\employee.txt'
WITH(
    firstrow=2,
    fieldterminator= ',',
    rowterminator='\n'
);
delete from employees;
select * from employees;

