-- Preview tables
SELECT * FROM hospital_general LIMIT 5;
SELECT * FROM readmissions LIMIT 5;
SELECT * FROM timely_care LIMIT 5;

-- Distinct hospital types and ownership
SELECT DISTINCT "Hospital Type" FROM hospital_general ORDER BY 1;
SELECT DISTINCT "Hospital Ownership" FROM hospital_general ORDER BY 1;

-- Distinct conditions in readmissions
SELECT DISTINCT "Measure Name" FROM readmissions ORDER BY 1;

-- Distinct conditions in timely_care
SELECT DISTINCT "Condition" FROM timely_care ORDER BY 1;

-- How many N/A values in key readmissions columns
SELECT
  COUNT(*) AS total,
  SUM(CASE WHEN "Excess Readmission Ratio" = 'Not Available' THEN 1 ELSE 0 END) AS not_available_ratio,
  SUM(CASE WHEN "Number of Readmissions" = 'Too Few to Report' THEN 1 ELSE 0 END) AS too_few
FROM readmissions;

-- Check hospital overall rating values
SELECT DISTINCT "Hospital overall rating" FROM hospital_general ORDER BY 1;