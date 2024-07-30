use github_leetcode;

drop table if EXISTS customer;

create table customer(
    customer_id int
    , name varchar (50)
    , visited_on DATE
    , amount INT
    , primary key (customer_id, visited_on)
);

INSERT INTO Customer (customer_id, name, visited_on, amount) 
VALUES
(1, 'Jhon', '2019-01-01', 100),
(2, 'Daniel', '2019-01-02', 110),
(3, 'Jade', '2019-01-03', 120),
(4, 'Khaled', '2019-01-04', 130),
(5, 'Winston', '2019-01-05', 110),
(6, 'Elvis', '2019-01-06', 140),
(7, 'Anna', '2019-01-07', 150),
(8, 'Maria', '2019-01-08', 80),
(9, 'Jaze', '2019-01-09', 110),
(1, 'Jhon', '2019-01-10', 130),
(3, 'Jade', '2019-01-10', 150);

select * from Customer;

with cte as (
    select 
        visited_on
        ,count(visited_on) over (order by visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) [date_count]
        ,sum(amount) over (order by visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) [amount]
        ,convert(decimal(18,2),avg(amount*1.0) over (order by visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) [average_amount]
    from 
    (
        select 
            visited_on
            ,sum(amount) [amount]
        from Customer 
        group by visited_on
    ) a
)

select 
    visited_on 
    ,amount
    ,average_amount
from 
    cte
where 
    date_count = 7;
