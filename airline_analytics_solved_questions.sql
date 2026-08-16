-- Airline analytics solved SQL questions
-- Assumed tables:
--   flights(
--     flight_id,
--     airline,
--     departure_country,
--     departure_continent,
--     destination_country,
--     destination_continent,
--     status,              -- On Time / Delayed / Cancelled
--     duration_minutes,
--     batch_date           -- or flight_date
--   )
--
--   tickets(
--     ticket_id,
--     flight_id,
--     passenger_id,
--     class,               -- Economy / Business
--     price,
--     booking_status,      -- Confirmed / Pending / Cancelled
--     seat_number,
--     booking_date
--   )
--
--   passengers(
--     passenger_id,
--     nationality_country,
--     nationality_region,
--     gender,
--     age
--   )
--
-- Notes:
-- 1. Replace batch_date with your real date column if needed.
-- 2. Replace quoted identifiers/functions to match your SQL dialect.
-- 3. Revenue is based on confirmed tickets unless a query explicitly says otherwise.

WITH base AS (
    SELECT
        f.flight_id,
        f.airline,
        f.departure_country,
        f.departure_continent,
        f.destination_country,
        f.destination_continent,
        f.status,
        f.duration_minutes,
        f.batch_date,
        t.ticket_id,
        t.passenger_id,
        t.class,
        t.price,
        t.booking_status,
        t.seat_number,
        t.booking_date,
        p.nationality_country,
        p.nationality_region,
        p.gender,
        p.age,
        CASE
            WHEN f.departure_continent = f.destination_continent THEN 'Intra-Continent'
            ELSE 'Inter-Continent'
        END AS route_type,
        CASE
            WHEN f.duration_minutes >= 360 THEN 'Long-Haul'
            ELSE 'Short-Haul'
        END AS haul_type,
        CASE
            WHEN p.age < 18 THEN 'Under 18'
            WHEN p.age BETWEEN 18 AND 24 THEN '18-24'
            WHEN p.age BETWEEN 25 AND 34 THEN '25-34'
            WHEN p.age BETWEEN 35 AND 44 THEN '35-44'
            WHEN p.age BETWEEN 45 AND 54 THEN '45-54'
            WHEN p.age BETWEEN 55 AND 64 THEN '55-64'
            ELSE '65+'
        END AS age_band
    FROM flights f
    LEFT JOIN tickets t ON f.flight_id = t.flight_id
    LEFT JOIN passengers p ON t.passenger_id = p.passenger_id
)

-- 1. Total revenue generated across all flights, by continent and by class
SELECT
    destination_continent,
    class,
    SUM(price) AS total_revenue
FROM base
WHERE booking_status = 'Confirmed'
GROUP BY destination_continent, class
ORDER BY total_revenue DESC;

-- 2. Year-over-year (or batch-over-batch) revenue growth trend by route
SELECT
    departure_continent,
    destination_continent,
    DATE_TRUNC('year', batch_date) AS period,
    SUM(CASE WHEN booking_status = 'Confirmed' THEN price ELSE 0 END) AS revenue,
    LAG(SUM(CASE WHEN booking_status = 'Confirmed' THEN price ELSE 0 END))
        OVER (
            PARTITION BY departure_continent, destination_continent
            ORDER BY DATE_TRUNC('year', batch_date)
        ) AS previous_revenue
FROM base
GROUP BY departure_continent, destination_continent, DATE_TRUNC('year', batch_date)
ORDER BY departure_continent, destination_continent, period;

-- 3. Which continents/countries generate the highest average ticket price
SELECT
    destination_continent,
    destination_country,
    AVG(price) AS avg_ticket_price
FROM base
WHERE booking_status = 'Confirmed'
GROUP BY destination_continent, destination_country
ORDER BY avg_ticket_price DESC;

-- 4. Business vs. Economy revenue contribution split
SELECT
    class,
    SUM(price) AS revenue,
    100.0 * SUM(price) / SUM(SUM(price)) OVER () AS revenue_pct
FROM base
WHERE booking_status = 'Confirmed'
GROUP BY class
ORDER BY revenue DESC;

-- 5. Top 10 highest-revenue airlines in the dataset
SELECT
    airline,
    SUM(price) AS total_revenue
FROM base
WHERE booking_status = 'Confirmed'
GROUP BY airline
ORDER BY total_revenue DESC
LIMIT 10;

-- 6. Market share by airline (% of total flights operated)
SELECT
    airline,
    COUNT(DISTINCT flight_id) AS flights_operated,
    100.0 * COUNT(DISTINCT flight_id) / SUM(COUNT(DISTINCT flight_id)) OVER () AS market_share_pct
FROM base
GROUP BY airline
ORDER BY market_share_pct DESC;

-- 7. Revenue per passenger by nationality/region
SELECT
    nationality_region,
    nationality_country,
    SUM(price) AS total_revenue,
    SUM(price) / NULLIF(COUNT(DISTINCT passenger_id), 0) AS revenue_per_passenger
FROM base
WHERE booking_status = 'Confirmed'
GROUP BY nationality_region, nationality_country
ORDER BY revenue_per_passenger DESC;

-- 8. Intra-continent vs. inter-continent revenue comparison
SELECT
    route_type,
    SUM(price) AS total_revenue
FROM base
WHERE booking_status = 'Confirmed'
GROUP BY route_type
ORDER BY total_revenue DESC;

-- 9. Cancellation rate's estimated revenue impact
SELECT
    COUNT(*) FILTER (WHERE booking_status = 'Cancelled') AS cancelled_bookings,
    AVG(price) FILTER (WHERE booking_status = 'Confirmed') AS avg_confirmed_price,
    COUNT(*) FILTER (WHERE booking_status = 'Cancelled')
        * AVG(price) FILTER (WHERE booking_status = 'Confirmed') AS estimated_lost_revenue
FROM base;

-- 10. Which routes are most profitable
SELECT
    departure_continent,
    destination_continent,
    SUM(price) AS route_revenue
FROM base
WHERE booking_status = 'Confirmed'
GROUP BY departure_continent, destination_continent
ORDER BY route_revenue DESC;

-- 11. Customer base diversity: nationality distribution across all passengers
SELECT
    nationality_country,
    COUNT(DISTINCT passenger_id) AS passengers,
    100.0 * COUNT(DISTINCT passenger_id) / SUM(COUNT(DISTINCT passenger_id)) OVER () AS passenger_pct
FROM base
GROUP BY nationality_country
ORDER BY passengers DESC;

-- 12. Growth opportunity: underserved continents with low flight volume but high avg price
SELECT
    destination_continent,
    COUNT(DISTINCT flight_id) AS flight_volume,
    AVG(price) AS avg_price
FROM base
WHERE booking_status = 'Confirmed'
GROUP BY destination_continent
HAVING COUNT(DISTINCT flight_id) < (
    SELECT AVG(flight_count)
    FROM (
        SELECT COUNT(DISTINCT flight_id) AS flight_count
        FROM base
        GROUP BY destination_continent
    ) x
)
ORDER BY avg_price DESC, flight_volume ASC;

-- 13. Business class adoption rate trend
SELECT
    DATE_TRUNC('month', batch_date) AS period,
    100.0 * COUNT(*) FILTER (WHERE class = 'Business')
        / NULLIF(COUNT(*), 0) AS business_class_adoption_pct
FROM base
GROUP BY DATE_TRUNC('month', batch_date)
ORDER BY period;

-- 14. Competitive benchmarking: airline average price positioning
SELECT
    airline,
    AVG(price) AS avg_ticket_price,
    DENSE_RANK() OVER (ORDER BY AVG(price) DESC) AS price_rank
FROM base
WHERE booking_status = 'Confirmed'
GROUP BY airline
ORDER BY avg_ticket_price DESC;

-- 15. Total booking value vs. total potential value
SELECT
    SUM(CASE WHEN booking_status = 'Confirmed' THEN price ELSE 0 END) AS confirmed_value,
    SUM(price) AS potential_value,
    SUM(price) - SUM(CASE WHEN booking_status = 'Confirmed' THEN price ELSE 0 END) AS unrealized_value
FROM base;

-- 16. Long-haul vs. short-haul revenue mix
SELECT
    haul_type,
    SUM(price) AS revenue,
    100.0 * SUM(price) / SUM(SUM(price)) OVER () AS revenue_pct
FROM base
WHERE booking_status = 'Confirmed'
GROUP BY haul_type
ORDER BY revenue DESC;

-- 17. Brand exposure: flights per airline
SELECT
    airline,
    COUNT(DISTINCT flight_id) AS flight_count
FROM base
GROUP BY airline
ORDER BY flight_count DESC;

-- 18. Strategic route expansion candidates
SELECT
    departure_continent,
    destination_continent,
    COUNT(DISTINCT flight_id) AS flight_volume,
    AVG(price) AS avg_price
FROM base
WHERE booking_status = 'Confirmed'
GROUP BY departure_continent, destination_continent
ORDER BY avg_price DESC, flight_volume ASC;

-- 19. Age-group revenue contribution
SELECT
    age_band,
    SUM(price) AS total_revenue
FROM base
WHERE booking_status = 'Confirmed'
GROUP BY age_band
ORDER BY total_revenue DESC;

-- 20. Gender-based travel volume trends
SELECT
    DATE_TRUNC('month', batch_date) AS period,
    gender,
    COUNT(*) AS ticket_volume
FROM base
GROUP BY DATE_TRUNC('month', batch_date), gender
ORDER BY period, ticket_volume DESC;

-- 21. Overall on-time performance
SELECT
    status,
    COUNT(DISTINCT flight_id) AS flights,
    100.0 * COUNT(DISTINCT flight_id) / SUM(COUNT(DISTINCT flight_id)) OVER () AS flight_pct
FROM base
GROUP BY status
ORDER BY flights DESC;

-- 22. Highest-value customer segments
SELECT
    nationality_country,
    class,
    SUM(price) AS segment_revenue,
    AVG(price) AS avg_ticket_price
FROM base
WHERE booking_status = 'Confirmed'
GROUP BY nationality_country, class
ORDER BY segment_revenue DESC;

-- 23. Forecast projected revenue if cancellation rate is reduced by 10%
SELECT
    SUM(CASE WHEN booking_status = 'Confirmed' THEN price ELSE 0 END) AS current_revenue,
    COUNT(*) FILTER (WHERE booking_status = 'Cancelled') AS cancelled_bookings,
    AVG(price) FILTER (WHERE booking_status = 'Cancelled') AS cancelled_avg_price,
    SUM(CASE WHEN booking_status = 'Confirmed' THEN price ELSE 0 END)
      + (COUNT(*) FILTER (WHERE booking_status = 'Cancelled') * 0.10
      * AVG(price) FILTER (WHERE booking_status = 'Cancelled')) AS projected_revenue_10pct_reduction
FROM base;

-- 24. Comparative profitability by continent
SELECT
    destination_continent,
    SUM(price) AS revenue,
    AVG(price) AS avg_price
FROM base
WHERE booking_status = 'Confirmed'
GROUP BY destination_continent
ORDER BY revenue DESC;

-- 25. Overall network health score
SELECT
    ROUND(
        (
            0.5 * AVG(CASE WHEN status = 'On Time' THEN 1.0 ELSE 0.0 END) +
            0.3 * AVG(CASE WHEN class = 'Business' THEN 1.0 ELSE 0.0 END) +
            0.2 * (
                AVG(price) / NULLIF(MAX(AVG(price)) OVER (), 0)
            )
        ) * 100,
        2
    ) AS network_health_score
FROM base
WHERE booking_status = 'Confirmed';

-- 26. On-time vs delayed vs cancelled ratio, overall and by airline
SELECT
    airline,
    status,
    COUNT(DISTINCT flight_id) AS flights,
    100.0 * COUNT(DISTINCT flight_id)
        / SUM(COUNT(DISTINCT flight_id)) OVER (PARTITION BY airline) AS status_pct
FROM base
GROUP BY airline, status
ORDER BY airline, status_pct DESC;

-- 27. Airlines with the worst cancellation/delay rates
SELECT
    airline,
    AVG(CASE WHEN status IN ('Cancelled', 'Delayed') THEN 1.0 ELSE 0.0 END) AS disruption_rate
FROM base
GROUP BY airline
ORDER BY disruption_rate DESC;

-- 28. Continents/routes with the highest delay frequency
SELECT
    departure_continent,
    destination_continent,
    COUNT(DISTINCT flight_id) FILTER (WHERE status = 'Delayed') AS delayed_flights
FROM base
GROUP BY departure_continent, destination_continent
ORDER BY delayed_flights DESC;

-- 29. Average flight duration by route type
SELECT
    route_type,
    AVG(duration_minutes) AS avg_duration_minutes
FROM base
GROUP BY route_type
ORDER BY avg_duration_minutes DESC;

-- 30. Seat utilization patterns
SELECT
    seat_number,
    COUNT(*) AS bookings
FROM base
WHERE seat_number IS NOT NULL
GROUP BY seat_number
ORDER BY bookings DESC;

-- 31. Booking status funnel
SELECT
    booking_status,
    COUNT(*) AS bookings,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS booking_pct
FROM base
GROUP BY booking_status
ORDER BY bookings DESC;

-- 32. Route operational bottlenecks
SELECT
    departure_continent,
    destination_continent,
    COUNT(*) FILTER (WHERE booking_status = 'Cancelled') AS cancelled_bookings
FROM base
GROUP BY departure_continent, destination_continent
ORDER BY cancelled_bookings DESC;

-- 33. Class-wise cancellation rate
SELECT
    class,
    AVG(CASE WHEN booking_status = 'Cancelled' THEN 1.0 ELSE 0.0 END) AS cancellation_rate
FROM base
GROUP BY class
ORDER BY cancellation_rate DESC;

-- 34. Flight volume distribution across continents
SELECT
    destination_continent,
    COUNT(DISTINCT flight_id) AS flight_count
FROM base
GROUP BY destination_continent
ORDER BY flight_count DESC;

-- 35. Passenger-to-flight ratio by route
SELECT
    departure_continent,
    destination_continent,
    COUNT(DISTINCT passenger_id) * 1.0 / NULLIF(COUNT(DISTINCT flight_id), 0) AS passengers_per_flight
FROM base
GROUP BY departure_continent, destination_continent
ORDER BY passengers_per_flight DESC;

-- 36. Turnaround efficiency proxy: duration consistency by airline
SELECT
    airline,
    AVG(duration_minutes) AS avg_duration,
    STDDEV(duration_minutes) AS duration_stddev
FROM base
GROUP BY airline
ORDER BY duration_stddev ASC;

-- 37. Pending bookings aging
SELECT
    CURRENT_DATE - booking_date AS booking_age_days,
    COUNT(*) AS pending_bookings
FROM base
WHERE booking_status = 'Pending'
GROUP BY CURRENT_DATE - booking_date
ORDER BY booking_age_days DESC;

-- 38. Airline-level performance scorecard
SELECT
    airline,
    AVG(CASE WHEN status = 'On Time' THEN 1.0 ELSE 0.0 END) AS on_time_rate,
    AVG(price) AS avg_price,
    AVG(duration_minutes) AS avg_duration
FROM base
GROUP BY airline
ORDER BY on_time_rate DESC, avg_price DESC;

-- 39. Underperforming airlines on reliability
SELECT
    airline,
    AVG(CASE WHEN status IN ('Delayed', 'Cancelled') THEN 1.0 ELSE 0.0 END) AS unreliability_rate
FROM base
GROUP BY airline
HAVING AVG(CASE WHEN status IN ('Delayed', 'Cancelled') THEN 1.0 ELSE 0.0 END) > 0.30
ORDER BY unreliability_rate DESC;

-- 40. Route-level risk flags
SELECT
    departure_continent,
    destination_continent,
    AVG(CASE WHEN status = 'Delayed' THEN 1.0 ELSE 0.0 END) AS delay_rate,
    AVG(CASE WHEN booking_status = 'Cancelled' THEN 1.0 ELSE 0.0 END) AS cancellation_rate
FROM base
GROUP BY departure_continent, destination_continent
ORDER BY delay_rate DESC, cancellation_rate DESC;
