/*----------
In SQL, (x, y, z) is the primary key column for this table.
Each row of this table contains the lengths of three line segments.
 

Report for every three line segments whether they can form a triangle.
-----------*/
use github_leetcode;

drop table if EXISTS triangle;
create table triangle(
    x int,
    y int,
    z int
)

insert into triangle (x, y, z)
VALUES
(13, 15, 30),
(10, 20, 15);

select * from triangle;

select 
    x,
    y,
    z, 
    case 
        when x+y>z then 'Yes'
        else 'No'
    end [triangle]    
from 
    triangle;

