-- =====================================================
-- Cyclistic Case Study - Process Phase Queries
-- Data Cleaning and Preparation
-- =====================================================

-- A. Combine Monthly Datasets
-- =====================================================

-- 1) Combine the 12 monthly datasets into one raw table
DROP TABLE IF EXISTS trips;

CREATE TABLE trips AS
SELECT * FROM "202501_divvy_tripdata"
UNION ALL
SELECT * FROM "202502_divvy_tripdata"
UNION ALL
SELECT * FROM "202503_divvy_tripdata"
UNION ALL
SELECT * FROM "202504_divvy_tripdata"
UNION ALL
SELECT * FROM "202505_divvy_tripdata"
UNION ALL
SELECT * FROM "202506_divvy_tripdata"
UNION ALL
SELECT * FROM "202507_divvy_tripdata"
UNION ALL
SELECT * FROM "202508_divvy_tripdata"
UNION ALL
SELECT * FROM "202509_divvy_tripdata"
UNION ALL
SELECT * FROM "202510_divvy_tripdata"
UNION ALL
SELECT * FROM "202511_divvy_tripdata"
UNION ALL
SELECT * FROM "202512_divvy_tripdata";


-- B. Initial Dataset Check
-- =====================================================

-- 2) Initial row count check
SELECT COUNT(*) AS total_rows
FROM trips;


-- C. Raw Data Quality Checks
-- =====================================================

-- 3) Data quality checks on the raw dataset

-- 3.1 Check for missing values in key columns
SELECT
    SUM(CASE WHEN ride_id IS NULL OR ride_id = '' THEN 1 ELSE 0 END) AS missing_ride_id,
    SUM(CASE WHEN started_at IS NULL OR started_at = '' THEN 1 ELSE 0 END) AS missing_started_at,
    SUM(CASE WHEN ended_at IS NULL OR ended_at = '' THEN 1 ELSE 0 END) AS missing_ended_at,
    SUM(CASE WHEN member_casual IS NULL OR member_casual = '' THEN 1 ELSE 0 END) AS missing_member_casual
FROM trips;

-- 3.2 Check for duplicate ride IDs
SELECT
    ride_id,
    COUNT(*) AS duplicate_count
FROM trips
GROUP BY ride_id
HAVING COUNT(*) > 1;

-- 3.3 Validate user type values
SELECT
    member_casual,
    COUNT(*) AS rides
FROM trips
GROUP BY member_casual;

-- 3.4 Validate bike type values
SELECT
    rideable_type,
    COUNT(*) AS rides
FROM trips
GROUP BY rideable_type;

-- 3.5 Check the date range to detect any inconsistency
SELECT
    MIN(started_at) AS min_started_at,
    MAX(started_at) AS max_started_at,
    MIN(ended_at) AS min_ended_at,
    MAX(ended_at) AS max_ended_at
FROM trips;


-- D. Timestamp Correction
-- =====================================================

-- 4) Correct timestamp inconsistency before feature engineering
--    Some records were labeled as January 2026 instead of 2025
UPDATE trips
SET started_at = datetime(started_at, '-1 year')
WHERE started_at >= '2026-01-01'
  AND started_at < '2026-02-01';

UPDATE trips
SET ended_at = datetime(ended_at, '-1 year')
WHERE ended_at >= '2026-01-01'
  AND ended_at < '2026-02-01';

-- 4.1 Recheck date range after correction
SELECT
    MIN(started_at) AS min_started_at,
    MAX(started_at) AS max_started_at,
    MIN(ended_at) AS min_ended_at,
    MAX(ended_at) AS max_ended_at
FROM trips;


-- E. Create Cleaned Dataset and Engineer Features
-- =====================================================

-- 5) Create the cleaned dataset with standardized data types
--    and engineered features
DROP TABLE IF EXISTS trips_cleaned;

CREATE TABLE trips_cleaned AS
SELECT
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    CAST(start_lat AS REAL) AS start_lat,
    CAST(start_lng AS REAL) AS start_lng,
    CAST(end_lat AS REAL) AS end_lat,
    CAST(end_lng AS REAL) AS end_lng,
    member_casual,

    -- Ride duration in minutes
    ROUND((julianday(ended_at) - julianday(started_at)) * 24 * 60, 2) AS ride_length,

    -- Extract day of week: 0 = Sunday, 6 = Saturday
    CAST(strftime('%w', started_at) AS INTEGER) AS day_of_week,

    -- Extract ride starting hour: 0–23
    CAST(strftime('%H', started_at) AS INTEGER) AS ride_hour,

    -- Extract month number: 1–12
    CAST(strftime('%m', started_at) AS INTEGER) AS ride_month

FROM trips
WHERE ride_id IS NOT NULL
  AND ride_id <> ''
  AND started_at IS NOT NULL
  AND started_at <> ''
  AND ended_at IS NOT NULL
  AND ended_at <> ''
  AND member_casual IN ('member', 'casual')
  AND rideable_type IN ('classic_bike', 'electric_bike');


-- F. Remove Invalid Ride Durations
-- =====================================================

-- 6) Identify and remove invalid ride durations
--    Remove rides with zero or negative duration
SELECT COUNT(*) AS invalid_duration_rides
FROM trips_cleaned
WHERE ride_length <= 0;

DELETE FROM trips_cleaned
WHERE ride_length <= 0;


-- G. Final Validation Checks
-- =====================================================

-- 7) Final validation checks on the cleaned dataset

-- 7.1 Final number of valid rows
SELECT COUNT(*) AS cleaned_total_rows
FROM trips_cleaned;

-- 7.2 Validate ride duration range
SELECT
    MIN(ride_length) AS min_ride_length,
    MAX(ride_length) AS max_ride_length,
    AVG(ride_length) AS avg_ride_length
FROM trips_cleaned;

-- 7.3 Validate derived time variables
SELECT
    MIN(day_of_week) AS min_day_of_week,
    MAX(day_of_week) AS max_day_of_week,
    MIN(ride_hour) AS min_ride_hour,
    MAX(ride_hour) AS max_ride_hour,
    MIN(ride_month) AS min_ride_month,
    MAX(ride_month) AS max_ride_month
FROM trips_cleaned;

-- 7.4 Final validation of user types
SELECT
    member_casual,
    COUNT(*) AS rides
FROM trips_cleaned
GROUP BY member_casual;

-- 7.5 Final validation of bike types
SELECT
    rideable_type,
    COUNT(*) AS rides
FROM trips_cleaned
GROUP BY rideable_type;