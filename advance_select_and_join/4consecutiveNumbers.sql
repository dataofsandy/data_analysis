-- 180. Consecutive Numbers
--Find all numbers that appear at least three times consecutively.
use github_leetcode;

drop table if exists logs;
create table logs(
    id int,
    num VARCHAR(255)
)

insert into logs (id, num)
VALUES
(1, '1'),
(2, '1'),
(4, '1'),
(5, '1'),
(6, '2'),
(7, '1');

delete from logs;
insert into logs(id,num)
values
(1, '1'),
(2, '1'),
(3, '1'),
(4, '2'),
(5, '1'),
(6, '2'),
(7, '2');

select * from logs;
delete from logs;

--for at least three we need three rows
--consider l1 as row1, l2 as row2 and l3 as row3
--which means two joins is needed
SELECT 
    DISTINCT l1.num AS ConsecutiveNums
FROM 
    Logs l1
INNER JOIN 
    Logs l2 
ON 
    l2.id = l1.id + 1
INNER JOIN 
    Logs l3 
ON 
    l3.id = l1.id + 2
WHERE 
    l1.num = l2.num 
    AND 
    l1.num = l3.num;


-- solution using window function
with abc as (
    select 
        id , num , 
        id - dense_rank() over(partition by num order by id) as rn from logs
)
select  distinct num as consecutivenums from abc 
group by num, rn
having count(rn) >=3;

-- select 
--     id , 
--     num , 
--     dense_rank() over(partition by num order by id) as rn,
--     id-dense_rank() over(partition by num order by id) as rn1 
-- from logs;