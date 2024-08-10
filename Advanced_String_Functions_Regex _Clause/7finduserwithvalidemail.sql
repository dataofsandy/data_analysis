use github_leetcode;


drop table if exists Users_asf;
-- Create the Users table
CREATE TABLE Users_asf (
    user_id INT PRIMARY KEY,
    name VARCHAR(255),
    mail VARCHAR(255)
);

-- Insert the dataset into the Users table
INSERT INTO Users_asf (user_id, name, mail) 
VALUES
(1, 'Winston', 'winston@leetcode.com'),
(2, 'Jonathan', 'jonathanisgreat'),
(3, 'Annabelle', 'bella-@leetcode.com'),
(4, 'Sally', 'sally.come@leetcode.com'),
(5, 'Marwan', 'quarz#2020@leetcode.com'),
(6, 'David', 'david69@gmail.com'),
(7, 'Shapiro', '.shapo@leetcode.com');

SELECT
    *
from 
    Users_asf;


SELECT
    *
from 
    Users_asf
WHERE
    mail like '[a-zA-Z]%@leetcode.com'
    AND
    LEFT(mail, LEN(mail)-13) not like '%[^a-zA-z_.-]%';

/*------------------
--Here first LIKE checks that the mail starts with letter and ends with @leetcode.com, 
the second LIKE checks that the first part of the mail does not contain any symbol except allowed.

  --LEFT(mail, LEN(mail) - LEN('@leetcode.com')) NOT LIKE '%[^a-zA-Z0-9._-]%': This condition ensures that the 
    --prefix part of the email only contains valid characters (letters, digits, _, ., and -). 
    --The [^...] pattern inside LIKE is used to match any character that is not in the allowed set, 
    --and NOT LIKE ensures there are no invalid characters.
-------------------*/