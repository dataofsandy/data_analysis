use github_leetcode;

create table users_ASF(
    user_id int primary key,
    name VARCHAR(250)
)

insert into users_ASF (user_id, name)
VALUES
(1, 'aLice'),
(2, 'bOB');

/*______________Solution_______________________*/
SELECT
    user_id
    , upper(LEFT(name, 1)) + LOWER(SUBSTRING(name, 2, len(name)))  [name]
from
    users_ASF
ORDER BY
    user_id
/*__________________________________________________________*/



--just for practice exploring each block of above function
SELECT
    name,
    UPPER(LEFT(name, 1)) + LOWER(SUBSTRING(name, 2, LEN(name))) AS nam
    ,upper(name) [upper]
    --Extract 1 character from a string (starting from left)
    ,LEFT(name, 1) [extract_first_from_string]

    --Extract 3 characters from a string, starting in position 2:
    --SUBSTRING(string,starting_position, length)
    -- SELECT SUBSTRING('SQL Tutorial', 1, 3) AS ExtractString;
    ,SUBSTRING(name,2, LEN(name)) [substring]

    
from
    users_ASF


