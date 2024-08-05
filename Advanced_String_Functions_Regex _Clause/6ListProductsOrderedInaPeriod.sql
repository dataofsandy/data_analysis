use github_leetcode;
CREATE TABLE Products_asf (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    product_category VARCHAR(255) NOT NULL
);
CREATE TABLE Orders (
    product_id INT,
    order_date DATE,
    unit INT,
    FOREIGN KEY (product_id) REFERENCES Products_asf (product_id)
);

INSERT INTO Products_asf (product_id, product_name, product_category) VALUES
(1, 'Leetcode Solutions', 'Book'),
(2, 'Jewels of Stringology', 'Book'),
(3, 'HP', 'Laptop'),
(4, 'Lenovo', 'Laptop'),
(5, 'Leetcode Kit', 'T-shirt');

INSERT INTO Orders (product_id, order_date, unit) VALUES
(1, '2020-02-05', 60),
(1, '2020-02-10', 70),
(2, '2020-01-18', 30),
(2, '2020-02-11', 80),
(3, '2020-02-17', 2),
(3, '2020-02-24', 3),
(4, '2020-03-01', 20),
(4, '2020-03-04', 30),
(4, '2020-03-04', 60),
(5, '2020-02-25', 50),
(5, '2020-02-27', 50),
(5, '2020-03-01', 50);


with cte as (
    select
        product_name
        , product_category
        , order_date
        , unit
    from
        Orders a
    inner JOIN
        Products_asf b
    ON
        a.product_id=b.product_id   
    WHERE
        order_date BETWEEN '2020-02-01' AND '2020-02-29'

)
SELECT
    product_name
    , sum(unit) [unit]
from
    cte
GROUP BY
    product_name
HAVING
    SUM(unit) >=100;
    




select
    product_name
    , product_category
    , order_date
    , unit
from
    Orders a
inner JOIN
    Products_asf b
ON
    a.product_id=b.product_id