-- =============================================
-- QUERY 1: Which states have the highest readmission rates?
-- Business question: Where geographically are hospitals
-- struggling most with patients being readmitted?
-- Chart: Filled map in Tableau (State → Color)
-- =============================================
SELECT
  "State",
  ROUND(AVG(excess_readmission_ratio), 3) AS avg_excess_ratio,
  COUNT(*) AS total_records
FROM readmissions_clean
WHERE excess_readmission_ratio IS NOT NULL  -- exclude missing values
GROUP BY "State"
ORDER BY avg_excess_ratio DESC;             -- highest readmission states first

-- =============================================
-- QUERY 2: Which medical conditions drive the most readmissions?
-- Business question: Should hospitals focus resources on
-- heart failure, pneumonia, hip/knee replacements, etc.?
-- Chart: Horizontal bar chart in Tableau
-- =============================================
SELECT
  "Measure Name",                                        -- the condition (e.g. heart failure)
  COUNT(*) AS hospital_count,                            -- how many hospitals report this
  ROUND(AVG(excess_readmission_ratio), 3) AS avg_excess_ratio  -- avg readmission rate
FROM readmissions_clean
WHERE excess_readmission_ratio IS NOT NULL
GROUP BY "Measure Name"
ORDER BY avg_excess_ratio DESC;                          -- worst conditions first


-- =============================================
-- QUERY 3: Do higher-rated hospitals have lower readmission rates?
-- Business question: Does a hospital's star rating actually
-- reflect better patient outcomes?
-- Chart: Bar chart (Rating 1-5 on X, avg ratio on Y)
-- Note: This uses a JOIN to combine ratings from
-- hospital_general_clean with readmission data
-- =============================================
SELECT
  g.overall_rating,                                      -- star rating 1-5
  COUNT(*) AS hospital_count,
  ROUND(AVG(r.excess_readmission_ratio), 3) AS avg_excess_ratio
FROM readmissions_clean r                                -- r is an alias for readmissions_clean
JOIN hospital_general_clean g                            -- g is an alias for hospital_general_clean
  ON r."Facility ID" = g."Facility ID"                  -- join the two tables on matching Facility ID
WHERE g.overall_rating IS NOT NULL                       -- exclude hospitals with no rating
  AND r.excess_readmission_ratio IS NOT NULL
GROUP BY g.overall_rating
ORDER BY g.overall_rating;                               -- sort 1 through 5


-- =============================================
-- QUERY 4: How does hospital ownership affect readmission rates?
-- Business question: Do non-profit hospitals perform better
-- than for-profit or government-owned hospitals?
-- Chart: Horizontal bar chart (Ownership on Rows, ratio on Columns)
-- =============================================
SELECT
  g.hospital_ownership,                                  -- e.g. Voluntary non-profit, Proprietary, Government
  COUNT(DISTINCT g."Facility ID") AS hospital_count,     -- distinct so we don't double count
  ROUND(AVG(r.excess_readmission_ratio), 3) AS avg_excess_ratio
FROM readmissions_clean r
JOIN hospital_general_clean g
  ON r."Facility ID" = g."Facility ID"
WHERE r.excess_readmission_ratio IS NOT NULL
GROUP BY g.hospital_ownership
ORDER BY avg_excess_ratio DESC;                          -- highest readmission ownership type first


-- =============================================
-- QUERY 5: Which states have the longest ER wait times?
-- Business question: Where are patients waiting the longest
-- in emergency departments across the country?
-- Chart: Bar chart ranked by avg wait time, or second map
-- Note: Filtering to a specific measure that returns
-- numeric scores (door-to-provider time in minutes)
-- =============================================
SELECT
  g.state,
  t."Measure Name",
  ROUND(AVG(t.score::NUMERIC), 1) AS avg_minutes,       -- cast score to numeric for averaging
  COUNT(*) AS hospital_count
FROM timely_care_clean t
JOIN hospital_general_clean g
  ON t."Facility ID" = g."Facility ID"
WHERE t."Condition" = 'Emergency Department'             -- filter to ER only
  AND t."Measure Name" = 'Left before being seen'        -- specific numeric measure
  AND t.score IS NOT NULL
GROUP BY g.state, t."Measure Name"
ORDER BY avg_minutes DESC;                               -- longest wait states first