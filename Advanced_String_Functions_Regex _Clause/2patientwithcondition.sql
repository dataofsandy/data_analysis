use github_leetcode;
CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    patient_name NVARCHAR(100),
    conditions NVARCHAR(255)
);

INSERT INTO Patients (patient_id, patient_name, conditions) 
VALUES
(1, 'Daniel', 'YFEV COUGH'),
(2, 'Alice', ''),
(3, 'Bob', 'DIAB100 MYOP'),
(4, 'George', 'ACNE DIAB100'),
(5, 'Alain', 'DIAB201');


SELECT
    *
FROM
    Patients
WHERE
    conditions like 'diab1%'
    OR
    conditions like '% diab1%';