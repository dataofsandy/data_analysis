use github_leetcode;

CREATE TABLE Movies (
    movie_id INT PRIMARY KEY,
    title VARCHAR(255)
);

INSERT INTO Movies (movie_id, title) 
VALUES
(1, 'Avengers'),
(2, 'Frozen 2'),
(3, 'Joker');


CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    name VARCHAR(255)
);


INSERT INTO Users (user_id, name) VALUES
(1, 'Daniel'),
(2, 'Monica'),
(3, 'Maria'),
(4, 'James'),
(5, 'papppa');

select * from Users;


CREATE TABLE MovieRating (
    movie_id INT,
    user_id INT,
    rating INT,
    created_at DATE,
    PRIMARY KEY (movie_id, user_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

INSERT INTO MovieRating (movie_id, user_id, rating, created_at) VALUES
(1, 1, 3, '2020-01-12'),
(1, 2, 4, '2020-02-11'),
(1, 3, 2, '2020-02-12'),
(1, 4, 1, '2020-01-01'),
(2, 1, 5, '2020-02-17'),
(2, 2, 2, '2020-02-01'),
(2, 3, 2, '2020-03-01'),
(3, 1, 3, '2020-02-22'),
(3, 2, 4, '2020-02-25');

--real solution is at the bottom
--this is just practice part by part
--lets join all tables
SELECT
    a.*,
    b.title
    ,c.name
into #temp
from
    MovieRating a
left JOIN
    Movies b
ON
    a.movie_id=b.movie_id
left JOIN
    Users c
ON  
    a.user_id=c.user_id

select * from #temp;

--find the user who has rated greatest number of movies
SELECT
    -- user_id
    -- ,[name]
    -- , COUNT(1)
    top 1
    name [results]

from
    #temp
group BY
    user_id
    , [name]
order BY
    count(1) desc
    , [name]

--find the movies with highest average rating in feb 2020
SELECT
    -- movie_id,
    -- title,
    -- AVG(rating * 1.0)
    top 1
    title [results]

from
    #temp
WHERE
    created_at >= '2020-02-01'
    AND
    created_at < '2020-03-01'
group BY
    movie_id,
    title
order BY
    AVG(rating *1.0) desc,
    title 

--real solution of this question
--using cte, left join, subquery

with cte as(
    SELECT
        a.*,
        b.title
        , c.name
    from
        MovieRating a
    LEFT join 
        Movies b
    on 
        a.movie_id=b.movie_id
    left join
        Users c
    on
        a.user_id=c.user_id

)
select
    results
from (
    select
        top 1
        name [results]
    from 
        cte
    GROUP BY
        user_id,
        name
    ORDER BY
        COUNT(1) DESC,
        name
) a

union ALL

select 
    results
from(
    SELECT
        top 1
        title [results]
    from 
        cte
    WHERE
        created_at >= '2020-02-01'
        AND
        created_at < '2020-03-01'
    group BY
        movie_id,
        title
    order BY
        AVG(rating * 1.0) desc,
        title 
) b;

