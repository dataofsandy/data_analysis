use github_leetcode;

create table Seat(
    id int PRIMARY KEY,
    student varchar(50)
)

INSERT INTO seat (id, student) VALUES
(1, 'Abbot'),
(2, 'Doris'),
(3, 'Emerson'),
(4, 'Green'),
(5, 'Jeames');


--solution using window function
select
    ROW_NUMBER() OVER(
        order by(
            CASE
                WHEN id%2=0 then id-1
                else id+1
            END
        )
    ) [id]
    ,student
from
    Seat
order by 
    id;


--using case and subquery
/* Write your T-SQL query statement below */
SELECT
    case
        when id = (select MAX(id) from Seat) and id%2 <>0 then id
        when id %2 = 0 then id-1
        -- when id %2 <>0 then id+1
        else id+1

    end [id],
    student
from 
    Seat
order by id;
