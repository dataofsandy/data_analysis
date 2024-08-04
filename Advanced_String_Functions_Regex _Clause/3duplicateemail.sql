use github_leetcode;
CREATE TABLE Person_asf (
    id INT PRIMARY KEY,
    email NVARCHAR(255)
);

delete from Person_asf;

INSERT INTO Person_asf (id, email) 
VALUES
(1, 'john@example.com'),
(2, 'bob@example.com'),
(3, 'john@example.com');


--deleting duplicate email using join, keeping only one unique email with the smallest id.
delete a
from 
    Person_asf a
inner JOIN
    Person_asf b
on 
    a.email=b.email
WHERE   
    a.id >b.id  -- question need small id so deleting big id


--removing duplicates email using window function
with cte as(
    select 
        *
        ,ROW_NUMBER() over(partition by email order by id) as rn 
    from 
        Person_asf
)
delete from Person_asf
where id in (
    select 
        id
    from 
        cte
    where 
        rn >1

)

-- select * from Person_asf;

-- SELECT
--     id
--     ,email
--     ,ROW_NUMBER() over(partition by email order by id) as rn
-- from
--     Person_asf

-- --using cross join, cartisan product
-- delete
--  p1
-- from 
--     Person_asf p1
--     ,Person_asf p2
-- where
--     p1.email=p2.email
-- AND
--     p1.id>p2.id;
