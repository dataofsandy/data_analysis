create database sql_practice;

create table student(
    course varchar(10),
    mark int,
    name VARCHAR(10)
);

INSERT INTO student (course, mark, name)
VALUES 
('Maths', 60, 'Thulile'),
('Maths', 60, 'Pritha'),
('Maths', 70, 'Voitto'),
('Maths', 55, 'Chun'),
('Biology', 60, 'Bilal'),
('Biology', 70, 'Roger');

select * from student;

SELECT
    *,
    RANK() over (partition by course order by mark desc) [RANK],
    DENSE_RANK() over (partition by course order by mark desc) [DENSE_RANK],
    ROW_NUMBER() over (partition by course order by mark desc) [ROW_NUMBER]
from
    student
ORDER BY
    course,
    mark desc;

