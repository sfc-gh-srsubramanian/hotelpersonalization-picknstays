-- =====================================================================
-- Script: 03a_future_bookings_enhancement.sql
-- Purpose: Add ~3,000 future bookings distributed daily across next 30 days
--          Enables arrival intelligence and VIP watchlist functionality
-- =====================================================================
-- This script generates future bookings for the Hotel Intelligence Hub
-- to support operational use cases like:
--   - "Next day check-ins"
--   - "Arrivals in next 0-7 days"
--   - VIP guest arrival preparation
--   - Service recovery for guests with past issues
-- =====================================================================

-- Database and schema context set by deploy script

-- =====================================================================
-- Generate Future Bookings (3,000-3,500 bookings for next 30 days)
-- =====================================================================

-- First, delete any existing future bookings to make this script idempotent
DELETE FROM BRONZE.booking_history 
WHERE check_in_date >= CURRENT_DATE() AND booking_id LIKE 'BOOKING_0%';

INSERT INTO BRONZE.booking_history
WITH future_dates AS (
    -- Generate 3,500 booking slots (100 properties × 30 days + weekend surge)
    SELECT 
        ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 as seq,
        DATEADD(day, (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1) % 30, CURRENT_DATE()) as check_in_date
    FROM TABLE(GENERATOR(ROWCOUNT => 3500))
),
existing_guests_pool AS (
    -- Create a pool of existing guests with their service case and loyalty info
    SELECT 
        g.guest_id,
        l.tier_level,
        COUNT(DISTINCT sc.case_id) as service_case_count,
        -- Prioritize guests with service cases and high loyalty tiers
        CASE 
            WHEN COUNT(DISTINCT sc.case_id) > 0 AND l.tier_level IN ('Gold', 'Silver') THEN 1
            WHEN COUNT(DISTINCT sc.case_id) > 0 THEN 2
            WHEN l.tier_level IN ('Gold', 'Silver') THEN 3
            ELSE 4
        END as priority,
        UNIFORM(1, 1000000, RANDOM()) as rand_order
    FROM BRONZE.guest_profiles g
    JOIN BRONZE.loyalty_program l ON g.guest_id = l.guest_id
    LEFT JOIN BRONZE.service_cases sc ON g.guest_id = sc.guest_id
    GROUP BY g.guest_id, l.tier_level
),
guest_selection AS (
    -- Select guests for future bookings, prioritizing those with service cases
    SELECT 
        guest_id,
        tier_level,
        service_case_count,
        ROW_NUMBER() OVER (ORDER BY priority, rand_order) - 1 as guest_seq
    FROM existing_guests_pool
    LIMIT 3500
),
booking_base AS (
    SELECT 
        -- Booking ID starts after existing 50,000 bookings
        'BOOKING_' || LPAD((50000 + fd.seq)::VARCHAR, 7, '0') as booking_id,
        
        -- Use existing guests from our selection pool
        gs.guest_id,
        gs.tier_level,
        gs.service_case_count,
        
        -- Distribute across all 100 properties
        'HOTEL_' || LPAD(((fd.seq % 100) + 1)::VARCHAR, 3, '0') as hotel_id,
        
        fd.check_in_date,
        
        -- Booking was made 7-30 days before check-in
        DATEADD(day, -1 * (7 + (fd.seq % 23)), fd.check_in_date) as booking_date,
        
        -- Check-out: 1-7 nights stay
        DATEADD(day, 1 + (fd.seq % 7), fd.check_in_date) as check_out_date,
        
        (1 + (fd.seq % 7)) as num_nights,
        
        ['Standard King', 'Standard Queen', 'Deluxe King', 'Suite', 'Executive'][fd.seq % 5] as room_type,
        
        -- Number of guests (1-4)
        1 + (fd.seq % 4) as num_guests,
        
        -- Realistic rate based on property, day of week, and room type
        CASE 
            -- Higher rates for luxury properties (HOTEL_000-HOTEL_019, HOTEL_050-HOTEL_059)
            WHEN (fd.seq % 100) < 20 OR ((fd.seq % 100) >= 50 AND (fd.seq % 100) < 60) THEN 
                CASE 
                    WHEN DAYOFWEEK(fd.check_in_date) IN (6, 7) THEN 450 + (fd.seq % 200)  -- Weekend
                    ELSE 350 + (fd.seq % 150)  -- Weekday
                END
            -- Standard rates for select service
            WHEN (fd.seq % 100) >= 20 AND (fd.seq % 100) < 50 THEN
                CASE 
                    WHEN DAYOFWEEK(fd.check_in_date) IN (6, 7) THEN 180 + (fd.seq % 80)
                    ELSE 140 + (fd.seq % 60)
                END
            -- Extended stay and urban rates
            ELSE
                CASE 
                    WHEN DAYOFWEEK(fd.check_in_date) IN (6, 7) THEN 160 + (fd.seq % 70)
                    ELSE 120 + (fd.seq % 50)
                END
        END as rate_per_night,
        
        -- Status: confirmed (ready for arrival)
        'confirmed' as status,
        
        -- Booking source distribution
        ['Website', 'Mobile App', 'Phone', 'Travel Agency', 'Corporate'][fd.seq % 5] as booking_source,
        
        -- Guest type
        CASE 
            WHEN fd.seq % 5 = 0 THEN 'Business'
            WHEN fd.seq % 5 IN (1, 2, 3) THEN 'Leisure'
            ELSE 'Group'
        END as guest_type,
        
        -- Payment method
        ['Credit Card', 'Debit Card', 'Corporate Account', 'Points Redemption'][fd.seq % 4] as payment_method,
        
        -- Special requests (40% of bookings)
        CASE 
            WHEN fd.seq % 5 = 0 THEN 'High floor, quiet room'
            WHEN fd.seq % 7 = 0 THEN 'Early check-in requested'
            WHEN fd.seq % 11 = 0 THEN 'Late check-out requested'
            WHEN fd.seq % 13 = 0 THEN 'Airport pickup'
            ELSE NULL
        END as special_requests,
        
        -- Cancellation allowed (80% yes)
        fd.seq % 5 != 0 as cancellation_allowed,
        
        -- Promotional code (30% of bookings)
        CASE 
            WHEN fd.seq % 10 < 3 THEN 'PROMO' || LPAD((fd.seq % 100)::VARCHAR, 2, '0')
            ELSE NULL
        END as promo_code,
        
        fd.seq
        
    FROM future_dates fd
    JOIN guest_selection gs ON fd.seq = gs.guest_seq
    -- Filter to ensure realistic distribution
    -- More bookings on weekends (Friday/Saturday check-ins)
    WHERE fd.seq < 3000 + (CASE WHEN DAYOFWEEK(fd.check_in_date) IN (5, 6) THEN 500 ELSE 0 END)
),
future_bookings AS (
    SELECT 
        booking_id,
        guest_id,
        hotel_id,
        booking_date,
        check_in_date,
        check_out_date,
        num_nights,
        room_type,
        num_guests,
        rate_per_night,
        -- Total amount
        (rate_per_night * num_nights) as total_amount,
        status,
        booking_source,
        guest_type,
        payment_method,
        special_requests,
        cancellation_allowed,
        promo_code,
        booking_date as created_at,
        booking_date as updated_at
    FROM booking_base
)
SELECT 
    booking_id,
    guest_id,
    hotel_id,
    booking_date,
    check_in_date,
    check_out_date,
    num_nights,
    num_guests as num_adults,  -- Map num_guests to num_adults
    0 as num_children,  -- Default to 0 children
    room_type,
    'BAR' as rate_code,  -- Best Available Rate
    total_amount,
    'USD' as currency,
    booking_source as booking_channel,
    status as booking_status,
    NULL as cancellation_date,  -- No cancellations for confirmed future bookings
    DATEDIFF(day, booking_date, check_in_date) as advance_booking_days,
    CASE WHEN special_requests IS NOT NULL THEN PARSE_JSON('["' || special_requests || '"]') ELSE NULL END as special_requests,
    promo_code,
    payment_method,
    created_at,
    updated_at
FROM future_bookings
ORDER BY check_in_date, hotel_id;

-- =====================================================================
-- Validation Queries
-- =====================================================================

-- Verify daily distribution
SELECT 
    DATE(check_in_date) as arrival_date,
    DAYNAME(check_in_date) as day_of_week,
    COUNT(*) as bookings_count,
    COUNT(DISTINCT hotel_id) as properties_with_arrivals,
    ROUND(AVG(total_amount / NULLIF(num_nights, 0)), 2) as avg_rate,
    SUM(total_amount) as total_revenue
FROM BRONZE.booking_history
WHERE check_in_date BETWEEN CURRENT_DATE() AND DATEADD(day, 30, CURRENT_DATE())
GROUP BY DATE(check_in_date), DAYNAME(check_in_date)
ORDER BY arrival_date
LIMIT 35;

-- Verify booking status distribution
SELECT 
    booking_status,
    COUNT(*) as booking_count,
    ROUND(AVG(total_amount), 2) as avg_total,
    COUNT(DISTINCT guest_id) as unique_guests
FROM BRONZE.booking_history
WHERE check_in_date >= CURRENT_DATE()
GROUP BY booking_status
ORDER BY booking_count DESC;

-- Verify property distribution
SELECT 
    hotel_id,
    COUNT(*) as future_bookings,
    MIN(check_in_date) as first_arrival,
    MAX(check_in_date) as last_arrival
FROM BRONZE.booking_history
WHERE check_in_date >= CURRENT_DATE()
GROUP BY hotel_id
ORDER BY hotel_id
LIMIT 20;

-- Check loyalty tier distribution for future bookings
SELECT 
    l.tier_level,
    COUNT(*) as booking_count,
    COUNT(DISTINCT b.guest_id) as unique_guests,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as percentage
FROM BRONZE.booking_history b
JOIN BRONZE.loyalty_program l ON b.guest_id = l.guest_id
WHERE b.check_in_date >= CURRENT_DATE()
GROUP BY l.tier_level
ORDER BY booking_count DESC;

-- Check how many future bookings are for guests with service history
SELECT 
    CASE 
        WHEN service_case_count > 0 THEN 'Guests with Past Service Cases'
        ELSE 'Guests without Service Cases'
    END as guest_category,
    COUNT(*) as booking_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as percentage
FROM BRONZE.booking_history b
LEFT JOIN (
    SELECT guest_id, COUNT(*) as service_case_count
    FROM BRONZE.service_cases
    GROUP BY guest_id
) sc ON b.guest_id = sc.guest_id
WHERE b.check_in_date >= CURRENT_DATE()
GROUP BY guest_category
ORDER BY booking_count DESC;

-- Show VIP guests with service history arriving soon (for agent testing)
SELECT 
    g.first_name,
    g.last_name,
    b.check_in_date,
    p.hotel_name,
    p.city,
    l.tier_level,
    COUNT(DISTINCT sc.case_id) as past_service_cases,
    MAX(sc.severity) as worst_severity
FROM BRONZE.booking_history b
JOIN BRONZE.guest_profiles g ON b.guest_id = g.guest_id
JOIN BRONZE.hotel_properties p ON b.hotel_id = p.hotel_id
JOIN BRONZE.loyalty_program l ON g.guest_id = l.guest_id
JOIN BRONZE.service_cases sc ON g.guest_id = sc.guest_id
WHERE b.check_in_date >= CURRENT_DATE()
  AND b.check_in_date <= CURRENT_DATE() + 7
  AND l.tier_level IN ('Gold', 'Silver')
  AND b.booking_status = 'Confirmed'
GROUP BY g.first_name, g.last_name, b.check_in_date, p.hotel_name, p.city, l.tier_level
ORDER BY l.tier_level DESC, COUNT(DISTINCT sc.case_id) DESC, b.check_in_date
LIMIT 10;

-- Summary statistics
SELECT 
    'Total Future Bookings' as metric,
    COUNT(*)::VARCHAR as value
FROM BRONZE.booking_history
WHERE check_in_date >= CURRENT_DATE()
UNION ALL
SELECT 
    'Date Range',
    MIN(check_in_date)::VARCHAR || ' to ' || MAX(check_in_date)::VARCHAR
FROM BRONZE.booking_history
WHERE check_in_date >= CURRENT_DATE()
UNION ALL
SELECT 
    'Unique Properties',
    COUNT(DISTINCT hotel_id)::VARCHAR
FROM BRONZE.booking_history
WHERE check_in_date >= CURRENT_DATE()
UNION ALL
SELECT 
    'Unique Guests',
    COUNT(DISTINCT guest_id)::VARCHAR
FROM BRONZE.booking_history
WHERE check_in_date >= CURRENT_DATE()
UNION ALL
SELECT 
    'Guests with Service History',
    COUNT(DISTINCT b.guest_id)::VARCHAR
FROM BRONZE.booking_history b
JOIN BRONZE.service_cases sc ON b.guest_id = sc.guest_id
WHERE b.check_in_date >= CURRENT_DATE()
UNION ALL
SELECT 
    'Total Projected Revenue',
    '$' || TO_CHAR(SUM(total_amount), '999,999,999')
FROM BRONZE.booking_history
WHERE check_in_date >= CURRENT_DATE();

SELECT '✅ Future bookings enhancement complete - ' || 
       COUNT(*)::VARCHAR || ' bookings added for next 30 days' as status
FROM BRONZE.booking_history
WHERE check_in_date >= CURRENT_DATE();
