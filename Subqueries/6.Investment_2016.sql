use github_leetcode;

CREATE TABLE Insurance (
    pid INT PRIMARY KEY,
    tiv_2015 FLOAT,
    tiv_2016 FLOAT,
    lat FLOAT NOT NULL,
    lon FLOAT NOT NULL
);

drop table if EXISTS Insurance;

CREATE TABLE Insurance (
    pid INT PRIMARY KEY,
    tiv_2015 FLOAT,
    tiv_2016 FLOAT,
    lat FLOAT NOT NULL,
    lon FLOAT NOT NULL
);
INSERT INTO Insurance (pid, tiv_2015, tiv_2016, lat, lon)
VALUES
(1, 10, 5, 10, 10),
(2, 20, 20, 20, 20),
(3, 10, 30, 20, 20),
(4, 10, 40, 40, 40);

with location as(
    SELECT
        CONCAT(lat,lon) [KEY]
    from
        Insurance
    group BY
        CONCAT(lat, lon)
    HAVING
        COUNT(1)= 1
)
, tiv_2015 as(
    SELECT
        tiv_2015
    from
        Insurance
    group BY
        tiv_2015
    HAVING  
        COUNT(1) > 1

)
SELECT
    round(sum(tiv_2016),2) [tiv_2016]
from
    Insurance
where
    tiv_2015 in (select tiv_2015 from tiv_2015)
    and
    CONCAT(lat,lon) in (select [key] from location)
    