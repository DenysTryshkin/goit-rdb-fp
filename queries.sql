-- Task 1. Create schema and import data

CREATE SCHEMA IF NOT EXISTS pandemic;
USE pandemic;

-- Import infectious_cases.csv using Table Data Import Wizard

SELECT COUNT(*) AS total_records
FROM pandemic.infectious_cases;

SELECT *
FROM pandemic.infectious_cases
LIMIT 10;


-- Task 2. Normalize to 3NF

CREATE TABLE pandemic.entities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Entity VARCHAR(255) NOT NULL,
    Code VARCHAR(20),
    UNIQUE (Entity, Code)
);

INSERT INTO pandemic.entities (Entity, Code)
SELECT DISTINCT
    Entity,
    Code
FROM pandemic.infectious_cases;

CREATE TABLE pandemic.infectious_cases_normalized (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT NOT NULL,
    Year INT,
    Number_yaws TEXT,
    polio_cases TEXT,
    cases_guinea_worm TEXT,
    Number_rabies TEXT,
    Number_malaria TEXT,
    Number_hiv TEXT,
    Number_tuberculosis TEXT,
    Number_smallpox TEXT,
    Number_cholera_cases TEXT,
    FOREIGN KEY (entity_id)
        REFERENCES pandemic.entities(id)
);

INSERT INTO pandemic.infectious_cases_normalized (
    entity_id,
    Year,
    Number_yaws,
    polio_cases,
    cases_guinea_worm,
    Number_rabies,
    Number_malaria,
    Number_hiv,
    Number_tuberculosis,
    Number_smallpox,
    Number_cholera_cases
)
SELECT
    e.id,
    c.Year,
    c.Number_yaws,
    c.polio_cases,
    c.cases_guinea_worm,
    c.Number_rabies,
    c.Number_malaria,
    c.Number_hiv,
    c.Number_tuberculosis,
    c.Number_smallpox,
    c.Number_cholera_cases
FROM pandemic.infectious_cases AS c
JOIN pandemic.entities AS e
    ON c.Entity = e.Entity
   AND c.Code <=> e.Code;

SELECT COUNT(*) AS total_entities
FROM pandemic.entities;

SELECT COUNT(*) AS normalized_records
FROM pandemic.infectious_cases_normalized;

SELECT
    e.Entity,
    e.Code,
    n.Year,
    n.polio_cases,
    n.Number_rabies
FROM pandemic.infectious_cases_normalized AS n
JOIN pandemic.entities AS e
    ON n.entity_id = e.id
LIMIT 10;


-- Task 3. Number_rabies statistics

SELECT
    e.Entity,
    e.Code,
    AVG(CAST(n.Number_rabies AS DECIMAL(20, 4))) AS avg_rabies,
    MIN(CAST(n.Number_rabies AS DECIMAL(20, 4))) AS min_rabies,
    MAX(CAST(n.Number_rabies AS DECIMAL(20, 4))) AS max_rabies,
    SUM(CAST(n.Number_rabies AS DECIMAL(20, 4))) AS sum_rabies
FROM pandemic.infectious_cases_normalized AS n
JOIN pandemic.entities AS e
    ON n.entity_id = e.id
WHERE n.Number_rabies IS NOT NULL
  AND TRIM(n.Number_rabies) <> ''
GROUP BY e.id, e.Entity, e.Code
ORDER BY avg_rabies DESC
LIMIT 10;


-- Task 4. Difference in years

SELECT
    Year,
    MAKEDATE(Year, 1) AS year_start_date,
    CURDATE() AS today_date,
    TIMESTAMPDIFF(
        YEAR,
        MAKEDATE(Year, 1),
        CURDATE()
    ) AS years_difference
FROM pandemic.infectious_cases_normalized
LIMIT 10;


-- Task 5. User-defined function

DELIMITER $$

CREATE FUNCTION pandemic.years_since_year(input_year INT)
RETURNS INT
NOT DETERMINISTIC
NO SQL
BEGIN
    RETURN TIMESTAMPDIFF(
        YEAR,
        MAKEDATE(input_year, 1),
        CURDATE()
    );
END $$

DELIMITER ;

SELECT
    Year,
    pandemic.years_since_year(Year) AS years_difference
FROM pandemic.infectious_cases_normalized
LIMIT 10;