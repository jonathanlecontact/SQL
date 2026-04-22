CREATE VIEW hospital_general_clean AS
SELECT
  "Facility ID",
  "Facility Name",
  "City/Town"        AS city,
  "State"            AS state,
  "ZIP Code"         AS zip_code,
  "Hospital Type"    AS hospital_type,
  "Hospital Ownership" AS hospital_ownership,
  "Emergency Services" AS emergency_services,
  CASE WHEN "Hospital overall rating" = 'Not Available' THEN NULL
       ELSE "Hospital overall rating"::INTEGER
  END AS overall_rating
FROM hospital_general;

CREATE VIEW readmissions_clean AS
SELECT
  "Facility ID",
  "Facility Name",
  "State",
  "Measure Name",
  CASE WHEN "Number of Discharges" = 'N/A' THEN NULL
       ELSE "Number of Discharges"::INTEGER END AS number_of_discharges,
  CASE WHEN "Excess Readmission Ratio" = 'Not Available' THEN NULL
       ELSE "Excess Readmission Ratio"::NUMERIC END AS excess_readmission_ratio,
  CASE WHEN "Predicted Readmission Rate" = 'Not Available' THEN NULL
       ELSE "Predicted Readmission Rate"::NUMERIC END AS predicted_readmission_rate,
  CASE WHEN "Expected Readmission Rate" = 'Not Available' THEN NULL
       ELSE "Expected Readmission Rate"::NUMERIC END AS expected_readmission_rate,
  CASE WHEN "Number of Readmissions"
    IN ('Not Available','Too Few to Report') THEN NULL
       ELSE "Number of Readmissions"::INTEGER END AS number_of_readmissions
FROM readmissions;

CREATE VIEW timely_care_clean AS
SELECT
  "Facility ID",
  "Facility Name",
  "State",
  "Condition",
  "Measure ID",
  "Measure Name",
  CASE WHEN "Score" IN ('Not Available','') THEN NULL
       ELSE "Score" END AS score,
  "Start Date"::DATE AS start_date,
  "End Date"::DATE   AS end_date
FROM timely_care
WHERE "Score" NOT IN ('Not Available','');

SELECT COUNT(*) FROM hospital_general_clean;
SELECT COUNT(*) FROM readmissions_clean;
SELECT COUNT(*) FROM timely_care_clean;

DROP VIEW readmissions_clean;

CREATE VIEW readmissions_clean AS
SELECT
  "Facility ID",
  "Facility Name",
  "State",
  "Measure Name",
  CASE WHEN "Number of Discharges" IN ('N/A','Not Available','') THEN NULL
       ELSE "Number of Discharges"::INTEGER END AS number_of_discharges,
  CASE WHEN "Excess Readmission Ratio" IN ('N/A','Not Available','') THEN NULL
       ELSE "Excess Readmission Ratio"::NUMERIC END AS excess_readmission_ratio,
  CASE WHEN "Predicted Readmission Rate" IN ('N/A','Not Available','') THEN NULL
       ELSE "Predicted Readmission Rate"::NUMERIC END AS predicted_readmission_rate,
  CASE WHEN "Expected Readmission Rate" IN ('N/A','Not Available','') THEN NULL
       ELSE "Expected Readmission Rate"::NUMERIC END AS expected_readmission_rate,
  CASE WHEN "Number of Readmissions" IN ('N/A','Not Available','Too Few to Report','') THEN NULL
       ELSE "Number of Readmissions"::INTEGER END AS number_of_readmissions
FROM readmissions;