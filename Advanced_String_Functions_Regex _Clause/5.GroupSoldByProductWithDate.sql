use github_leetcode;

CREATE TABLE Activities (
    sell_date DATE,
    product VARCHAR(255)
);

INSERT INTO Activities (sell_date, product) VALUES
('2020-05-30', 'Headphone'),
('2020-06-01', 'Pencil'),
('2020-06-02', 'Mask'),
('2020-05-30', 'Basketball'),
('2020-06-01', 'Bible'),
('2020-06-02', 'Mask'),
('2020-05-30', 'T-Shirt');


select * from Activities order by sell_date;


--STRING_AGG function is used to concatenate values from multiple rows into a single string
--The ORDER BY clause within WITHIN GROUP allows you to sort the values before they are concatenated.
-- The order of the concatenated values is not guaranteed unless you explicitly specify the order using 
-- WITHIN GROUP (ORDER BY ...).
WITH cte AS (
    SELECT 
        DISTINCT * 
    FROM 
        Activities
)
select  
    sell_date
    , count(product) as num_sold
    , STRING_AGG(product, ',') [products]
from 
    cte 
GROUP BY
    sell_date
order BY
    sell_date;

with cte as (
    select distinct * from Activities
)
SELECT
    sell_date
    , count(*) [num_sold]
    , STRING_AGG(product, ',') WITHIN GROUP (ORDER by product) [products] 
from 
    cte
GROUP BY
    sell_date
ORDER BY
    sell_date;



