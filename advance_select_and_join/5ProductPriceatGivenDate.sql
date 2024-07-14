use github_leetcode;
CREATE table products(
    product_id int,
    new_price int,
    change_date date
);

INSERT INTO products (product_id, new_price, change_date)
VALUES
(1, 20, '2019-08-14'),
(2, 50, '2019-08-14'),
(1, 30, '2019-08-15'),
(1, 35, '2019-08-16'),
(2, 65, '2019-08-17'),
(3, 20, '2019-08-18');

select * from products;

with latestPrice as (
    SELECT
        product_id,
        new_price,
        change_date,
        ROW_NUMBER() OVER (partition by product_id order by change_date desc) [rn]
    FROM
        products
    WHERE
        change_date <= '2019-08-16'
)
SELECT
    product_id,
    new_price
FROM
    latestPrice
where rn=1

union all

SELECT
    distinct product_id,
    10 [new_price]
from
    products
WHERE
    product_id not in (select product_id from latestPrice);





