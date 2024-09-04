# Introduction
This is a ETL Data cleaning project on long covid dataset. To explore the knowledge of data analytics I am doing this project. As ETL plays vital role in data analytics. As MS Sql is popular in the industry. I am using MS Sql

#Analysing
### 1. Finding Duplicates
This data has no id so we need to check all columns for finding duplicates. I used the window function to find and remove duplicates which is quick and handy to remove duplicates.

Output:
![finding duplicates] (/assets/find_duplicates.jpg)

### 2. Removing Duplicates
As we know there is duplicates from the above step 1. We use window function to delete the duplicates. easy
![remove duplicates] (/asssets/delete_duplicates.jpg)