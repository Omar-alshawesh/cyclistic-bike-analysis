-- =====================================================
-- Cyclistic Case Study - Analyze Phase Queries
-- =====================================================

-- A. Dataset Overview
-- =====================================================

-- 1) Total number of rides in the cleaned dataset
SELECT COUNT(*) AS total_rides
FROM trips_cleaned;

-- 2) Number of rides by user type (casual vs member)
SELECT member_casual, COUNT(*) AS rides
FROM trips_cleaned
GROUP BY member_casual;

-- 3) Number of rides by bike type
SELECT rideable_type, COUNT(*) AS rides
FROM trips_cleaned
GROUP BY rideable_type;


-- B. Ride Duration and Outlier Check
-- =====================================================

-- 4) Average ride duration by user type before handling outliers
SELECT 
    member_casual,
    AVG(ride_length) AS avg_duration
FROM trips_cleaned
GROUP BY member_casual;

-- 5) Percentage of outlier rides (rides longer than 150 minutes)
SELECT 
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM trips_cleaned) AS pct_outliers
FROM trips_cleaned
WHERE ride_length > 150;

-- 6) Average ride duration by user type after excluding rides longer than 150 minutes
SELECT 
    member_casual,
    AVG(ride_length) AS avg_duration_clean
FROM trips_cleaned
WHERE ride_length <= 150
GROUP BY member_casual;


-- C. Ride Count Patterns Over Time
-- =====================================================

-- 7) Number of rides by month for each user type
-- Used to analyze seasonal patterns
SELECT 
    member_casual,
    ride_month,
    COUNT(*) AS rides
FROM trips_cleaned
GROUP BY member_casual, ride_month
ORDER BY member_casual, ride_month;

-- 8) Number of rides by day of week for each user type
-- Note: 0 = Sunday, 6 = Saturday
SELECT 
    member_casual,
    day_of_week,
    COUNT(*) AS rides
FROM trips_cleaned
GROUP BY member_casual, day_of_week
ORDER BY member_casual, day_of_week;

-- 9) Number of rides by hour of day for each user type
-- Used to identify peak usage hours
SELECT 
    member_casual,
    ride_hour,
    COUNT(*) AS rides
FROM trips_cleaned
GROUP BY member_casual, ride_hour
ORDER BY member_casual, ride_hour;


-- D. Ride Duration Patterns Over Time
-- =====================================================

-- 10) Average Ride Duration by Month (excluding outliers)
-- Used to analyze seasonal behavior in ride duration
SELECT
    member_casual,
    ride_month,
    AVG(ride_length) AS avg_ride_length
FROM trips_cleaned
WHERE ride_length <= 150
GROUP BY member_casual, ride_month
ORDER BY member_casual, ride_month;

-- 11) Average ride duration by day of week after excluding outliers
-- Helps compare weekday and weekend ride behavior
SELECT
    member_casual,
    day_of_week,
    AVG(ride_length) AS avg_ride_length
FROM trips_cleaned
WHERE ride_length <= 150
GROUP BY member_casual, day_of_week
ORDER BY member_casual, day_of_week;

-- 12) Average Ride Duration by Hour
SELECT
    member_casual,
    ride_hour,
    AVG(ride_length) AS avg_duration
FROM trips_cleaned
WHERE ride_length <= 150
GROUP BY member_casual, ride_hour;


-- E. User Behavior and Preferences
-- =====================================================

-- 13) Number of rides by bike type for each user type
-- Used to compare bike preferences between casual riders and members
SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS rides
FROM trips_cleaned
GROUP BY member_casual, rideable_type
ORDER BY member_casual, rides DESC;

-- 14) Ride Duration Distribution by User Type
SELECT
    member_casual,
    CASE 
        WHEN ride_length < 10 THEN '0-10'
        WHEN ride_length < 20 THEN '10-20'
        WHEN ride_length < 40 THEN '20-40'
        ELSE '40+'
    END AS duration_group,
    COUNT(*) AS rides
FROM trips_cleaned
WHERE ride_length <= 150
GROUP BY member_casual, duration_group;