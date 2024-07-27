--this example can also be used  for cumulative weight using join
use github_leetcode;

drop table if exists queue;
create table Queue (
    person_id int PRIMARY KEY,
    person_name VARCHAR(255) not NULL,
    [weight] int not NULL,
    turn int not NULL
);

insert into Queue (person_id, person_name, [weight], turn)
VALUES
(5, 'Alice', 250, 1),
(3, 'Alex', 350, 2),
(6, 'John Cena', 400, 3);

insert into Queue (person_id, person_name, [weight], turn)
VALUES
(5, 'Alice', 250, 1),
(4, 'Bob', 175, 5),
(3, 'Alex', 350, 2),
(6, 'John Cena', 400, 3),
(1, 'Winston', 500, 6),
(2, 'Marie', 200, 4);

delete from Queue;

select * from Queue;

--solution using join bit lengthy 
with cumulative_weight as (
    SELECT
        q2.turn,
        q2.person_id,
        q2.person_name,
        q2.weight,
        sum(q1.weight) as Total_Weight
    from
        Queue q1
    inner JOIN
        Queue q2
    ON
        q2.turn >=q1.turn
    group BY
        q2.person_id, q2.person_name, q2.turn, q2.weight
    -- order by 
    --     turn
)
SELECT
    -- *
    -- top 1 *
    top 1 person_name
FROM
    cumulative_weight
WHERE
    Total_Weight<=1000
ORDER by 
    Total_Weight desc


--solution using window function
--too easy 
with cumulative_weight as(
    SELECT
        *,
        sum(weight) over (order by turn asc) [cumulative_weight]

    from
        Queue
)
select
    -- *
    -- top 1 *
    top 1 person_name
FROM
    cumulative_weight
WHERE
    cumulative_weight <=1000
order by 
    cumulative_weight DESC
