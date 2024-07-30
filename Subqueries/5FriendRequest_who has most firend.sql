use github_leetcode;

CREATE TABLE RequestAccepted (
    requester_id INT,
    accepter_id INT,
    accept_date DATE,
    PRIMARY KEY (requester_id, accepter_id)
);


INSERT INTO RequestAccepted (requester_id, accepter_id, accept_date) 
VALUES
(1, 2, '2016-06-03'),
(1, 3, '2016-06-08'),
(2, 3, '2016-06-08'),
(3, 4, '2016-06-09');

SELECT * from RequestAccepted;

--solution using subquery only no cte


--as requester and accepter id is primary key we i did not check for null
select 
    top 1
    id,
    COUNT(1) as num
from(
    SELECT
        requester_id [id]
    from 
        RequestAccepted

    union ALL

    SELECT  
        accepter_id [id]
    from 
        RequestAccepted
) a
group BY
    id
order BY
    num DESC

--same solution with cte
with cte as(
    SELECT
        requester_id [id]
    from 
        RequestAccepted

    union ALL

    SELECT  
        accepter_id [id]
    from 
        RequestAccepted

)
select
    top 1
    id
    , count(1) as num
from
    cte
group BY
    id
order BY
    num DESC;
