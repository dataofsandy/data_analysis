use github_leetcode;


select * from logs;

with abc as (
    select 
        id , num , 
        id - dense_rank() over(partition by num order by id) as rn from logs
)
select  distinct num as consecutivenums from abc 
group by num, rn
having count(rn) >=3;

with cte as (
select
    id, num,
    DENSE_RANK() over (partition by num order by id) as dr,
    id-DENSE_RANK() over (partition by num order by id) as rn

from 
    logs

)
select distinct num as consecutive_num from cte
group by rn, num
having count(1) >=3


select 
        id , num ,  dense_rank() over(partition by num order by id),
        id - dense_rank() over(partition by num order by id) as rn from logs