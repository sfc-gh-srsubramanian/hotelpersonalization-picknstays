-- =====================================================================
-- Script: 03b_intelligence_hub_data_generation.sql
-- Purpose: Generate synthetic Bronze data for Intelligence Hub
--          ~40,500 records across 4 tables with 18-month history
-- =====================================================================

-- Database and schema context set by deploy script

-- =====================================================================
-- 1. SERVICE_CASES (~5,000 records - 12.5% of completed stays)
-- =====================================================================
-- Date range: Last 18 months with recency bias
--   - Last 6 months: 60% (~3,000 cases)
--   - 6-12 months: 25% (~1,250 cases)
--   - 12-18 months: 15% (~750 cases)
-- =====================================================================

INSERT INTO BRONZE.service_cases
WITH completed_stays AS (
    -- Get all completed stays from stay_history
    SELECT 
        stay_id,
        guest_id,
        hotel_id,
        actual_check_in,
        actual_check_out
    FROM BRONZE.stay_history
    WHERE actual_check_out < CURRENT_TIMESTAMP()
),
eligible_stays AS (
    -- Select stays from last 18 months
    SELECT 
        stay_id,
        guest_id,
        hotel_id,
        actual_check_in,
        actual_check_out,
        DATEDIFF(day, actual_check_out, CURRENT_TIMESTAMP()) as days_ago,
        ROW_NUMBER() OVER (ORDER BY UNIFORM(0, 1000000, RANDOM())) as rn
    FROM completed_stays
    WHERE actual_check_out >= DATEADD(month, -18, CURRENT_TIMESTAMP())
),
selected_stays AS (
    -- Select ~12.5% of stays for service cases with recency bias
    SELECT *,
        CASE 
            WHEN days_ago <= 180 THEN 0.15  -- Last 6 months: 15% chance
            WHEN days_ago <= 365 THEN 0.10  -- 6-12 months: 10% chance
            ELSE 0.08  -- 12-18 months: 8% chance
        END as selection_probability
    FROM eligible_stays
    WHERE UNIFORM(0, 100, RANDOM()) < (selection_probability * 100)
    LIMIT 5000
),
case_data AS (
    SELECT 
        'CASE_' || LPAD(ROW_NUMBER() OVER (ORDER BY actual_check_out DESC)::VARCHAR, 6, '0') as case_id,
        stay_id,
        guest_id,
        hotel_id,
        -- Case type distribution (realistic hospitality benchmarks)
        CASE 
            WHEN rn % 100 < 40 THEN 'billing'
            WHEN rn % 100 < 65 THEN 'room_readiness'
            WHEN rn % 100 < 80 THEN 'noise'
            WHEN rn % 100 < 90 THEN 'amenity'
            ELSE ['staff', 'cleanliness', 'tech'][rn % 3]
        END as case_type,
        -- Severity distribution
        CASE 
            WHEN rn % 100 < 60 THEN 'low'
            WHEN rn % 100 < 90 THEN 'medium'
            WHEN rn % 100 < 98 THEN 'high'
            ELSE 'critical'
        END as severity,
        -- Reported during stay or shortly after
        DATEADD(hour, UNIFORM(0, 48, RANDOM()), actual_check_out) as reported_at,
        rn,
        actual_check_out
    FROM selected_stays
)
SELECT 
    case_id,
    stay_id,
    guest_id,
    hotel_id,
    case_type,
    severity,
    reported_at,
    -- Resolution time based on severity
    DATEADD(minute, 
        CASE severity
            WHEN 'critical' THEN UNIFORM(120, 480, RANDOM())
            WHEN 'high' THEN UNIFORM(60, 240, RANDOM())
            WHEN 'medium' THEN UNIFORM(30, 120, RANDOM())
            ELSE UNIFORM(15, 60, RANDOM())
        END,
        reported_at
    ) as resolved_at,
    DATEDIFF(minute, reported_at, resolved_at) as resolution_time_minutes,
    -- Channel distribution
    ['front_desk', 'phone', 'app', 'email'][rn % 4] as channel,
    'resolved' as status,
    -- Guest impact (higher for severity)
    CASE severity
        WHEN 'critical' THEN UNIFORM(7, 10, RANDOM())
        WHEN 'high' THEN UNIFORM(5, 8, RANDOM())
        WHEN 'medium' THEN UNIFORM(3, 6, RANDOM())
        ELSE UNIFORM(1, 4, RANDOM())
    END as guest_impact_score,
    -- Description templates
    CASE case_type
        WHEN 'billing' THEN 'Guest reported billing discrepancy'
        WHEN 'room_readiness' THEN 'Room not ready at check-in time'
        WHEN 'noise' THEN 'Noise disturbance reported'
        WHEN 'amenity' THEN 'Issue with hotel amenity'
        WHEN 'staff' THEN 'Guest service concern'
        WHEN 'cleanliness' THEN 'Housekeeping issue reported'
        ELSE 'Technical issue in room'
    END as description,
    'Issue resolved. Guest satisfied.' as resolution_notes,
    reported_at as created_at,
    resolved_at as updated_at
FROM case_data;

-- =====================================================================
-- 2. ISSUE_TRACKING (~7,500 records - 1.5 avg per case)
-- =====================================================================

INSERT INTO BRONZE.issue_tracking
WITH case_issues AS (
    SELECT 
        sc.case_id,
        sc.hotel_id,
        hp.brand,
        hp.region,
        sc.case_type,
        sc.severity,
        -- Generate 1-3 issues per case
        ROW_NUMBER() OVER (PARTITION BY sc.case_id ORDER BY UNIFORM(0, 1000, RANDOM())) as issue_num,
        UNIFORM(1, 3, RANDOM()) as total_issues_for_case,
        UNIFORM(0, 1000000, RANDOM()) as rn
    FROM service_cases sc
    JOIN hotel_properties hp ON sc.hotel_id = hp.hotel_id
),
expanded_issues AS (
    SELECT *
    FROM case_issues
    WHERE issue_num <= total_issues_for_case
)
SELECT 
    'ISSUE_' || LPAD(ROW_NUMBER() OVER (ORDER BY case_id)::VARCHAR, 6, '0') as issue_id,
    case_id,
    hotel_id,
    brand,
    region,
    case_type as issue_category,
    -- Issue drivers by category
    CASE case_type
        WHEN 'billing' THEN ['late checkout charges', 'minibar discrepancy', 'rate mismatch', 'promotional code not applied', 'double charge'][rn % 5]
        WHEN 'room_readiness' THEN ['housekeeping delay', 'maintenance incomplete', 'wrong room type', 'missing amenities', 'room not cleaned'][rn % 5]
        WHEN 'noise' THEN ['neighboring room', 'construction', 'HVAC noise', 'street noise', 'event noise'][rn % 5]
        WHEN 'amenity' THEN ['pool closed', 'gym equipment broken', 'restaurant wait time', 'spa fully booked', 'WiFi not working'][rn % 5]
        WHEN 'staff' THEN ['slow check-in', 'unresponsive service', 'rude behavior', 'language barrier', 'incorrect information'][rn % 5]
        WHEN 'cleanliness' THEN ['bathroom not clean', 'towels not replaced', 'trash not emptied', 'stains on linens', 'dust in room'][rn % 5]
        ELSE ['TV not working', 'AC malfunction', 'plumbing issue', 'electrical problem', 'key card not working'][rn % 5]
    END as issue_driver,
    -- Impact on satisfaction (higher impact for severe issues)
    CASE severity
        WHEN 'critical' THEN UNIFORM(4, 5, RANDOM())
        WHEN 'high' THEN UNIFORM(3, 5, RANDOM())
        WHEN 'medium' THEN UNIFORM(2, 4, RANDOM())
        ELSE UNIFORM(1, 3, RANDOM())
    END as impact_on_satisfaction,
    -- Followup required for high severity
    severity IN ('high', 'critical') as requires_followup,
    -- 20% of issues are recurring
    rn % 5 = 0 as recurring_issue_flag,
    'Corrective action documented and completed' as corrective_action_taken,
    -- Responsible department by issue type
    CASE case_type
        WHEN 'billing' THEN 'front_desk'
        WHEN 'room_readiness' THEN 'housekeeping'
        WHEN 'noise' THEN 'management'
        WHEN 'amenity' THEN 'facilities'
        WHEN 'staff' THEN 'management'
        WHEN 'cleanliness' THEN 'housekeeping'
        ELSE 'maintenance'
    END as responsible_department,
    -- Priority based on severity
    CASE severity
        WHEN 'critical' THEN 'urgent'
        WHEN 'high' THEN 'high'
        WHEN 'medium' THEN 'medium'
        ELSE 'low'
    END as priority,
    CURRENT_TIMESTAMP() as created_at,
    CURRENT_TIMESTAMP() as updated_at
FROM expanded_issues;

-- =====================================================================
-- 3. SENTIMENT_DATA (~24,000 records - 60% of completed stays)
-- =====================================================================

INSERT INTO BRONZE.sentiment_data
WITH completed_stays AS (
    -- Get all completed stays from stay_history
    SELECT 
        stay_id,
        guest_id,
        hotel_id,
        actual_check_out
    FROM BRONZE.stay_history
    WHERE actual_check_out < CURRENT_TIMESTAMP()
),
eligible_stays AS (
    SELECT 
        stay_id,
        guest_id,
        hotel_id,
        actual_check_out,
        UNIFORM(0, 1000000, RANDOM()) as rn
    FROM completed_stays
    WHERE actual_check_out >= DATEADD(month, -18, CURRENT_TIMESTAMP())
),
selected_stays AS (
    -- Select 60% of stays for sentiment data
    SELECT *
    FROM eligible_stays
    WHERE rn % 10 < 6
),
sentiment_base AS (
    SELECT 
        'SENT_' || LPAD(ROW_NUMBER() OVER (ORDER BY actual_check_out DESC)::VARCHAR, 7, '0') as sentiment_id,
        ss.guest_id,
        ss.stay_id,
        ss.hotel_id,
        ss.actual_check_out,
        ss.rn,
        -- Check if guest had a service case (correlate sentiment)
        sc.case_id is not null as had_service_case,
        sc.severity
    FROM selected_stays ss
    LEFT JOIN service_cases sc ON ss.stay_id = sc.stay_id
)
SELECT 
    sentiment_id,
    guest_id,
    stay_id,
    hotel_id,
    -- Source distribution
    ['review', 'survey', 'social', 'feedback', 'app_rating'][rn % 5] as source,
    -- Sentiment score: if had service case, skew negative, else skew positive
    CASE 
        WHEN had_service_case AND severity IN ('high', 'critical') THEN UNIFORM(-100, -20, RANDOM())
        WHEN had_service_case THEN UNIFORM(-50, 20, RANDOM())
        ELSE UNIFORM(40, 100, RANDOM())
    END as sentiment_score,
    CASE 
        WHEN sentiment_score < -20 THEN 'negative'
        WHEN sentiment_score < 40 THEN 'neutral'
        ELSE 'positive'
    END as sentiment_label,
    -- Sample text snippets
    CASE 
        WHEN sentiment_score >= 80 THEN 'Excellent stay! Highly recommend.'
        WHEN sentiment_score >= 40 THEN 'Good experience overall.'
        WHEN sentiment_score >= 0 THEN 'Average stay, nothing special.'
        WHEN sentiment_score >= -50 THEN 'Some issues, but resolved.'
        ELSE 'Very disappointed with service.'
    END as text_snippet,
    -- Topics (positive or negative based on score)
    CASE 
        WHEN sentiment_score >= 40 THEN PARSE_JSON('["staff", "cleanliness", "amenities", "location"]')
        ELSE PARSE_JSON('["billing", "noise", "maintenance", "service"]')
    END as topics,
    'English' as language,
    ['TripAdvisor', 'Google', 'Booking.com', 'Yelp', 'Facebook'][rn % 5] as platform,
    DATEADD(day, UNIFORM(1, 14, RANDOM()), actual_check_out) as posted_at,
    rn % 2 = 0 as verified,
    rn % 3 = 0 as response_provided,
    CASE WHEN response_provided THEN 'Thank you for your feedback!' ELSE NULL END as response_text,
    UNIFORM(0, 100, RANDOM()) as helpfulness_score,
    posted_at as created_at,
    posted_at as updated_at
FROM sentiment_base;

-- =====================================================================
-- 4. SERVICE_RECOVERY_ACTIONS (~4,000 records - 80% of medium/high/critical)
-- =====================================================================

INSERT INTO BRONZE.service_recovery_actions
WITH recovery_eligible AS (
    SELECT 
        sc.case_id,
        sc.guest_id,
        sc.hotel_id,
        sc.stay_id,
        sc.severity,
        sc.resolved_at,
        UNIFORM(0, 1000000, RANDOM()) as rn,
        -- Simulate LTV based on guest_id pattern (20% are VIPs)
        CASE WHEN (CAST(SUBSTR(sc.guest_id, -3) AS INTEGER) % 5) = 0 
             THEN UNIFORM(10000, 50000, RANDOM()) 
             ELSE UNIFORM(1000, 9999, RANDOM()) 
        END as ltv
    FROM service_cases sc
    WHERE sc.severity IN ('medium', 'high', 'critical')
),
recovery_cases AS (
    -- 80% of eligible cases receive recovery
    SELECT *
    FROM recovery_eligible
    WHERE rn % 10 < 8
)
SELECT 
    'RECOVERY_' || LPAD(ROW_NUMBER() OVER (ORDER BY resolved_at)::VARCHAR, 6, '0') as recovery_id,
    case_id,
    guest_id,
    hotel_id,
    stay_id,
    -- Recovery type distribution
    CASE 
        WHEN rn % 100 < 35 THEN 'points_credit'
        WHEN rn % 100 < 60 THEN 'room_upgrade'
        WHEN rn % 100 < 80 THEN 'comp_service'
        WHEN rn % 100 < 95 THEN 'discount'
        ELSE 'apology'
    END as recovery_type,
    -- Recovery value (higher for VIPs)
    CASE recovery_type
        WHEN 'points_credit' THEN UNIFORM(500, 5000, RANDOM()) * (CASE WHEN ltv > 10000 THEN 2 ELSE 1 END)
        WHEN 'room_upgrade' THEN UNIFORM(50, 200, RANDOM())
        WHEN 'comp_service' THEN UNIFORM(25, 150, RANDOM())
        WHEN 'discount' THEN UNIFORM(20, 100, RANDOM())
        ELSE 0
    END as recovery_value_usd,
    recovery_type || ' offered as service recovery' as recovery_description,
    resolved_at as offered_at,
    -- Guest response (VIPs more likely to accept)
    CASE 
        WHEN ltv > 10000 AND rn % 100 < 75 THEN 'accepted'
        WHEN rn % 100 < 60 THEN 'accepted'
        WHEN rn % 100 < 85 THEN 'no_response'
        ELSE 'declined'
    END as guest_response,
    CASE WHEN guest_response = 'accepted' THEN DATEADD(hour, UNIFORM(1, 24, RANDOM()), offered_at) ELSE NULL END as accepted_at,
    -- Repeat booking more likely if recovery accepted
    CASE 
        WHEN guest_response = 'accepted' THEN rn % 100 < 85
        ELSE rn % 100 < 40
    END as repeat_booking_after,
    CASE WHEN repeat_booking_after THEN UNIFORM(30, 180, RANDOM()) ELSE NULL END as days_to_next_booking,
    UNIFORM(2, 3, RANDOM()) as satisfaction_before,
    CASE 
        WHEN guest_response = 'accepted' THEN UNIFORM(4, 5, RANDOM())
        ELSE UNIFORM(2, 4, RANDOM())
    END as satisfaction_after,
    ['Property Manager', 'Front Desk Manager', 'General Manager'][rn % 3] as authorized_by,
    'Service Recovery Fund' as cost_center,
    'Recovery action documented and tracked for effectiveness' as notes,
    offered_at as created_at,
    COALESCE(accepted_at, offered_at) as updated_at
FROM recovery_cases;

-- =====================================================================
-- Validation Queries
-- =====================================================================

-- Service cases summary
SELECT 
    '1. Service Cases' as table_name,
    COUNT(*) as total_records,
    COUNT(DISTINCT hotel_id) as properties_affected,
    COUNT(DISTINCT guest_id) as guests_affected,
    MIN(reported_at) as earliest_case,
    MAX(reported_at) as latest_case
FROM service_cases
UNION ALL
SELECT 
    '2. Issue Tracking',
    COUNT(*),
    COUNT(DISTINCT hotel_id),
    NULL,
    MIN(created_at),
    MAX(created_at)
FROM issue_tracking
UNION ALL
SELECT 
    '3. Sentiment Data',
    COUNT(*),
    COUNT(DISTINCT hotel_id),
    COUNT(DISTINCT guest_id),
    MIN(posted_at),
    MAX(posted_at)
FROM sentiment_data
UNION ALL
SELECT 
    '4. Service Recovery',
    COUNT(*),
    COUNT(DISTINCT hotel_id),
    COUNT(DISTINCT guest_id),
    MIN(offered_at),
    MAX(offered_at)
FROM service_recovery_actions;

-- Case severity distribution
SELECT severity, COUNT(*) as count, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as pct
FROM service_cases
GROUP BY severity
ORDER BY CASE severity 
    WHEN 'critical' THEN 1 
    WHEN 'high' THEN 2 
    WHEN 'medium' THEN 3 
    WHEN 'low' THEN 4 
END;

-- Sentiment distribution
SELECT sentiment_label, COUNT(*) as count, ROUND(AVG(sentiment_score), 1) as avg_score
FROM sentiment_data
GROUP BY sentiment_label
ORDER BY CASE sentiment_label 
    WHEN 'positive' THEN 1 
    WHEN 'neutral' THEN 2 
    WHEN 'negative' THEN 3 
END;

-- Recovery effectiveness
SELECT 
    recovery_type,
    COUNT(*) as offered,
    SUM(CASE WHEN guest_response = 'accepted' THEN 1 ELSE 0 END) as accepted,
    ROUND(accepted * 100.0 / NULLIF(offered, 0), 1) as acceptance_rate_pct,
    SUM(CASE WHEN repeat_booking_after THEN 1 ELSE 0 END) as repeat_bookings,
    ROUND(repeat_bookings * 100.0 / NULLIF(accepted, 0), 1) as repeat_rate_pct
FROM service_recovery_actions
GROUP BY recovery_type
ORDER BY offered DESC;

SELECT '✅ Bronze data generation complete - ' || 
       (SELECT COUNT(*) FROM service_cases)::VARCHAR || ' cases, ' ||
       (SELECT COUNT(*) FROM issue_tracking)::VARCHAR || ' issues, ' ||
       (SELECT COUNT(*) FROM sentiment_data)::VARCHAR || ' sentiment records, ' ||
       (SELECT COUNT(*) FROM service_recovery_actions)::VARCHAR || ' recovery actions'
       as status;
