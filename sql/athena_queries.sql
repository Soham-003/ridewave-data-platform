SELECT
    city,
    COUNT(*)                   AS total_rides,
    ROUND(SUM(fare_amount), 2) AS total_revenue
FROM ridewave_raw_soham.rides
WHERE fare_amount IS NOT NULL
GROUP BY city
ORDER BY total_rides DESC;

SELECT
    ride_status,
    COUNT(*) AS count
FROM ridewave_raw_soham.rides
GROUP BY ride_status
ORDER BY count DESC;

SELECT
    driver_id,
    COUNT(*)                   AS total_rides,
    ROUND(SUM(fare_amount), 2) AS total_earned
FROM ridewave_raw_soham.rides
WHERE fare_amount IS NOT NULL
GROUP BY driver_id
ORDER BY total_earned DESC
LIMIT 5;

SELECT
    driver_id,
    city,
    ROUND(SUM(fare_amount), 2) AS total_fare,
    RANK() OVER (
        PARTITION BY city
        ORDER BY SUM(fare_amount) DESC
    ) AS city_rank
FROM ridewave_raw_soham.rides
WHERE fare_amount IS NOT NULL
GROUP BY driver_id, city;

WITH monthly AS (
    SELECT
        DATE_TRUNC('month', CAST(ride_date AS DATE)) AS month,
        COUNT(*) AS ride_count
    FROM ridewave_raw_soham.rides
    GROUP BY 1
)
SELECT
    month,
    ride_count,
    LAG(ride_count) OVER (ORDER BY month) AS prev_month_count,
    ride_count - LAG(ride_count)
        OVER (ORDER BY month)              AS change
FROM monthly
ORDER BY month;

WITH completed_counts AS (
    SELECT driver_id, COUNT(*) AS total_rides
    FROM ridewave_raw_soham.rides
    GROUP BY driver_id
    HAVING COUNT(*) > 5
),
completed_status AS (
    SELECT DISTINCT driver_id
    FROM ridewave_raw_soham.rides
    WHERE ride_status = 'completed'
)
SELECT
    cc.driver_id,
    cc.total_rides,
    CASE WHEN cs.driver_id IS NOT NULL
         THEN 1 ELSE 0 END AS has_completed
FROM completed_counts cc
LEFT JOIN completed_status cs ON cc.driver_id = cs.driver_id
ORDER BY cc.total_rides DESC;