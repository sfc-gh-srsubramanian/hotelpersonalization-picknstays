-- ============================================================================
-- Hotel Personalization - Schema-Level Setup
-- ============================================================================
-- Creates all tables across Bronze, Silver, and Gold layers
-- Implements medallion architecture for data processing
-- 
-- Requires:
--   - Account-level setup completed (01_account_setup.sql)
--   - Database and schemas already created
-- 
-- Session variables (set by deploy.sh):
--   $FULL_PREFIX (e.g., HOTEL_PERSONALIZATION or DEV_HOTEL_PERSONALIZATION)
-- ============================================================================

USE ROLE IDENTIFIER($PROJECT_ROLE);
USE DATABASE IDENTIFIER($FULL_PREFIX);

-- ============================================================================
-- BRONZE LAYER: Raw Data Tables
-- ============================================================================
-- Raw data ingestion from source systems (PMS, booking platforms, amenities)
-- Minimal transformation, preserves source data structure
-- ============================================================================

USE SCHEMA BRONZE;

-- ----------------------------------------------------------------------------
-- Guest Profiles (Core guest information)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE guest_profiles (
    guest_id STRING PRIMARY KEY,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone STRING,
    date_of_birth DATE,
    gender STRING,
    nationality STRING,
    language_preference STRING,
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    state_province STRING,
    postal_code STRING,
    country STRING,
    registration_date TIMESTAMP,
    last_updated TIMESTAMP,
    marketing_opt_in BOOLEAN,
    communication_preferences VARIANT,
    emergency_contact VARIANT
);

-- ----------------------------------------------------------------------------
-- Booking History (All booking transactions)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE booking_history (
    booking_id STRING PRIMARY KEY,
    guest_id STRING,
    hotel_id STRING,
    booking_date TIMESTAMP,
    check_in_date DATE,
    check_out_date DATE,
    num_nights INTEGER,
    num_adults INTEGER,
    num_children INTEGER,
    room_type STRING,
    rate_code STRING,
    total_amount DECIMAL(10,2),
    currency STRING,
    booking_channel STRING,
    booking_status STRING,
    cancellation_date TIMESTAMP,
    advance_booking_days INTEGER,
    special_requests VARIANT,
    promo_code STRING,
    payment_method STRING,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- Stay History (Detailed stay records)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE stay_history (
    stay_id STRING PRIMARY KEY,
    booking_id STRING,
    guest_id STRING,
    hotel_id STRING,
    room_number STRING,
    actual_check_in TIMESTAMP,
    actual_check_out TIMESTAMP,
    room_type STRING,
    floor_number INTEGER,
    view_type STRING,
    bed_type STRING,
    total_charges DECIMAL(10,2),
    room_charges DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    incidental_charges DECIMAL(10,2),
    no_show BOOLEAN,
    early_departure BOOLEAN,
    late_checkout BOOLEAN,
    guest_satisfaction_score INTEGER,
    staff_notes VARIANT,
    created_at TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- Room Preferences (Guest room preferences)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE room_preferences (
    preference_id STRING PRIMARY KEY,
    guest_id STRING,
    room_type_preference STRING,
    floor_preference STRING,
    view_preference STRING,
    bed_type_preference STRING,
    smoking_preference BOOLEAN,
    accessibility_needs BOOLEAN,
    temperature_preference INTEGER,
    lighting_preference STRING,
    pillow_type_preference STRING,
    room_amenities VARIANT,
    noise_level_preference STRING,
    last_updated TIMESTAMP,
    created_at TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- Service Preferences (Dining, spa, amenities preferences)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE service_preferences (
    preference_id STRING PRIMARY KEY,
    guest_id STRING,
    dining_preferences VARIANT,
    spa_services VARIANT,
    fitness_preferences VARIANT,
    business_services VARIANT,
    transportation_preferences VARIANT,
    entertainment_preferences VARIANT,
    housekeeping_preferences VARIANT,
    concierge_services VARIANT,
    preferred_communication_method STRING,
    preferred_check_in_time TIME,
    preferred_check_out_time TIME,
    last_updated TIMESTAMP,
    created_at TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- Social Media Activity (Guest social media interactions)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE social_media_activity (
    activity_id STRING PRIMARY KEY,
    guest_id STRING,
    platform STRING,
    activity_type STRING,
    content VARIANT,
    sentiment_score DECIMAL(3,2),
    engagement_metrics VARIANT,
    location_tag STRING,
    hotel_mention BOOLEAN,
    brand_mention BOOLEAN,
    activity_date TIMESTAMP,
    processed_at TIMESTAMP,
    created_at TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- Loyalty Program (Loyalty tier and points data)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE loyalty_program (
    loyalty_id STRING PRIMARY KEY,
    guest_id STRING,
    program_name STRING,
    member_number STRING,
    tier_level STRING,
    points_balance INTEGER,
    lifetime_points INTEGER,
    tier_qualification_date DATE,
    next_tier_threshold INTEGER,
    expiration_date DATE,
    benefits VARIANT,
    referral_count INTEGER,
    status STRING,
    last_activity_date DATE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- Feedback Reviews (Guest reviews and ratings)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE feedback_reviews (
    review_id STRING PRIMARY KEY,
    guest_id STRING,
    stay_id STRING,
    hotel_id STRING,
    overall_rating INTEGER,
    room_rating INTEGER,
    service_rating INTEGER,
    cleanliness_rating INTEGER,
    amenities_rating INTEGER,
    location_rating INTEGER,
    value_rating INTEGER,
    review_text STRING,
    review_date TIMESTAMP,
    platform STRING,
    verified_stay BOOLEAN,
    helpful_votes INTEGER,
    management_response STRING,
    response_date TIMESTAMP,
    sentiment_analysis VARIANT,
    created_at TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- Payment Methods (Guest payment preferences)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE payment_methods (
    payment_id STRING PRIMARY KEY,
    guest_id STRING,
    payment_type STRING,
    card_brand STRING,
    last_four_digits STRING,
    expiry_month INTEGER,
    expiry_year INTEGER,
    billing_address VARIANT,
    is_default BOOLEAN,
    is_active BOOLEAN,
    created_at TIMESTAMP,
    last_used TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- Special Requests (Custom requests and accommodations)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE special_requests (
    request_id STRING PRIMARY KEY,
    guest_id STRING,
    booking_id STRING,
    stay_id STRING,
    request_category STRING,
    request_description STRING,
    request_date TIMESTAMP,
    fulfillment_status STRING,
    fulfillment_notes STRING,
    cost_impact DECIMAL(10,2),
    staff_assigned STRING,
    completion_date TIMESTAMP,
    guest_satisfaction INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- Hotel Properties (Hotel information for reference)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE hotel_properties (
    hotel_id STRING PRIMARY KEY,
    hotel_name STRING,
    brand STRING,
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    state_province STRING,
    postal_code STRING,
    country STRING,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    phone STRING,
    email STRING,
    star_rating INTEGER,
    total_rooms INTEGER,
    amenities VARIANT,
    room_types VARIANT,
    check_in_time TIME,
    check_out_time TIME,
    timezone STRING,
    opened_date DATE,
    last_renovation_date DATE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- Amenity Transactions (Paid amenity service transactions)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE amenity_transactions (
    transaction_id STRING PRIMARY KEY,
    stay_id STRING,
    guest_id STRING,
    amenity_category STRING,
    service_name STRING,
    transaction_date TIMESTAMP,
    amount DECIMAL(10,2),
    quantity INTEGER,
    location STRING,
    guest_satisfaction INTEGER,
    service_type STRING DEFAULT 'paid',
    service_subcategory STRING,
    is_premium_service BOOLEAN,
    is_repeat_service BOOLEAN,
    duration_minutes INTEGER,
    staff_id STRING,
    hotel_id STRING,
    booking_id STRING
);

-- ----------------------------------------------------------------------------
-- Amenity Usage (Free and paid amenity usage tracking)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE amenity_usage (
    usage_id STRING PRIMARY KEY,
    stay_id STRING,
    guest_id STRING,
    amenity_category STRING,
    amenity_name STRING,
    usage_start_time TIMESTAMP,
    usage_end_time TIMESTAMP,
    usage_duration_minutes INTEGER,
    location STRING,
    device_info STRING,
    usage_type STRING,
    guest_satisfaction INTEGER,
    usage_frequency INTEGER DEFAULT 1,
    data_consumed_mb INTEGER,
    channels_accessed VARIANT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- SILVER LAYER: Cleaned and Standardized Data
-- ============================================================================
-- Data quality improvements, standardization, and enrichment
-- Business logic applied, derived attributes calculated
-- ============================================================================

USE SCHEMA SILVER;

-- ----------------------------------------------------------------------------
-- Guests Standardized (Cleaned guest profiles with derived attributes)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE guests_standardized AS
SELECT 
    guest_id,
    TRIM(UPPER(first_name)) as first_name,
    TRIM(UPPER(last_name)) as last_name,
    LOWER(TRIM(email)) as email,
    REGEXP_REPLACE(phone, '[^0-9+]', '') as phone_cleaned,
    date_of_birth,
    DATEDIFF(year, date_of_birth, CURRENT_DATE()) as age,
    CASE 
        WHEN age < 25 THEN 'Gen Z'
        WHEN age < 40 THEN 'Millennial'
        WHEN age < 55 THEN 'Gen X'
        ELSE 'Boomer'
    END as generation,
    gender,
    nationality,
    language_preference,
    TRIM(address_line1) || COALESCE(' ' || TRIM(address_line2), '') as full_address,
    city,
    state_province,
    postal_code,
    country,
    registration_date,
    DATEDIFF(day, registration_date, CURRENT_DATE()) as days_since_registration,
    marketing_opt_in,
    communication_preferences,
    emergency_contact,
    last_updated,
    CURRENT_TIMESTAMP() as processed_at
FROM BRONZE.guest_profiles
WHERE email IS NOT NULL 
    AND email LIKE '%@%'
    AND first_name IS NOT NULL
    AND last_name IS NOT NULL;

-- ----------------------------------------------------------------------------
-- Bookings Enriched (Enhanced booking data with business metrics)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE bookings_enriched AS
SELECT 
    bh.booking_id,
    bh.guest_id,
    bh.hotel_id,
    hp.hotel_name,
    hp.brand,
    hp.city as hotel_city,
    hp.state_province as hotel_state,
    bh.booking_date,
    bh.check_in_date,
    bh.check_out_date,
    bh.num_nights,
    bh.num_adults,
    bh.num_children,
    (bh.num_adults + bh.num_children) as total_guests,
    bh.room_type,
    bh.rate_code,
    bh.total_amount,
    bh.currency,
    ROUND(bh.total_amount / bh.num_nights, 2) as avg_daily_rate,
    ROUND(bh.total_amount / (bh.num_adults + COALESCE(bh.num_children, 0)), 2) as cost_per_person,
    bh.booking_channel,
    bh.booking_status,
    bh.cancellation_date,
    bh.advance_booking_days,
    CASE 
        WHEN bh.advance_booking_days <= 1 THEN 'Last Minute'
        WHEN bh.advance_booking_days <= 7 THEN 'Short Term'
        WHEN bh.advance_booking_days <= 30 THEN 'Medium Term'
        ELSE 'Long Term'
    END as booking_lead_time_category,
    DAYNAME(bh.check_in_date) as check_in_day_of_week,
    MONTHNAME(bh.check_in_date) as check_in_month,
    QUARTER(bh.check_in_date) as check_in_quarter,
    YEAR(bh.check_in_date) as check_in_year,
    CASE 
        WHEN DAYNAME(bh.check_in_date) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END as check_in_weekend_flag,
    CASE 
        WHEN bh.num_nights = 1 THEN 'Single Night'
        WHEN bh.num_nights <= 3 THEN 'Short Stay'
        WHEN bh.num_nights <= 7 THEN 'Medium Stay'
        ELSE 'Extended Stay'
    END as stay_length_category,
    bh.special_requests,
    bh.promo_code,
    CASE WHEN bh.promo_code IS NOT NULL THEN TRUE ELSE FALSE END as used_promo,
    bh.payment_method,
    lp.tier_level as loyalty_tier,
    lp.points_balance as loyalty_points,
    bh.created_at,
    bh.updated_at,
    CURRENT_TIMESTAMP() as processed_at
FROM BRONZE.booking_history bh
LEFT JOIN BRONZE.hotel_properties hp ON bh.hotel_id = hp.hotel_id
LEFT JOIN BRONZE.loyalty_program lp ON bh.guest_id = lp.guest_id
WHERE bh.guest_id IS NOT NULL
    AND bh.hotel_id IS NOT NULL
    AND bh.check_in_date IS NOT NULL
    AND bh.check_out_date IS NOT NULL
    AND bh.total_amount > 0;

-- ----------------------------------------------------------------------------
-- Stays Processed (Processed stay data with satisfaction metrics)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE stays_processed AS
SELECT 
    sh.stay_id,
    sh.booking_id,
    sh.guest_id,
    sh.hotel_id,
    sh.room_number,
    sh.actual_check_in,
    sh.actual_check_out,
    DATEDIFF(minute, sh.actual_check_in, sh.actual_check_out) / (24 * 60.0) as actual_nights,
    be.check_in_date as scheduled_check_in,
    be.check_out_date as scheduled_check_out,
    DATEDIFF(hour, be.check_in_date::TIMESTAMP, sh.actual_check_in) as check_in_variance_hours,
    DATEDIFF(hour, be.check_out_date::TIMESTAMP, sh.actual_check_out) as check_out_variance_hours,
    sh.room_type,
    sh.floor_number,
    CASE 
        WHEN sh.floor_number <= 3 THEN 'Low'
        WHEN sh.floor_number <= 7 THEN 'Mid'
        ELSE 'High'
    END as floor_category,
    sh.view_type,
    sh.bed_type,
    sh.total_charges,
    sh.room_charges,
    sh.tax_amount,
    sh.incidental_charges,
    ROUND(sh.incidental_charges / sh.total_charges * 100, 2) as incidental_percentage,
    sh.no_show,
    sh.early_departure,
    sh.late_checkout,
    sh.guest_satisfaction_score,
    CASE 
        WHEN sh.guest_satisfaction_score >= 5 THEN 'Excellent'
        WHEN sh.guest_satisfaction_score >= 4 THEN 'Good'
        WHEN sh.guest_satisfaction_score >= 3 THEN 'Average'
        WHEN sh.guest_satisfaction_score >= 2 THEN 'Poor'
        ELSE 'Very Poor'
    END as satisfaction_category,
    sh.staff_notes,
    CASE 
        WHEN sh.guest_satisfaction_score <= 2 
            OR sh.early_departure = TRUE 
            OR (sh.staff_notes IS NOT NULL AND CONTAINS(sh.staff_notes:notes[0]::STRING, 'Complained'))
        THEN TRUE 
        ELSE FALSE 
    END as had_service_issues,
    ROUND(sh.total_charges / GREATEST(actual_nights, 1), 2) as revenue_per_night,
    sh.created_at,
    CURRENT_TIMESTAMP() as processed_at
FROM BRONZE.stay_history sh
JOIN bookings_enriched be ON sh.booking_id = be.booking_id
WHERE sh.actual_check_in IS NOT NULL
    AND sh.actual_check_out IS NOT NULL
    AND sh.total_charges > 0;

-- ----------------------------------------------------------------------------
-- Preferences Consolidated (Unified preference profiles)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE preferences_consolidated AS
SELECT 
    rp.guest_id,
    rp.room_type_preference,
    rp.floor_preference,
    rp.view_preference,
    rp.bed_type_preference,
    rp.smoking_preference,
    rp.accessibility_needs,
    rp.temperature_preference,
    CASE 
        WHEN rp.temperature_preference <= 70 THEN 'Cool'
        WHEN rp.temperature_preference <= 74 THEN 'Moderate'
        ELSE 'Warm'
    END as temperature_category,
    rp.lighting_preference,
    rp.pillow_type_preference,
    rp.room_amenities,
    rp.noise_level_preference,
    sp.dining_preferences,
    sp.spa_services,
    sp.fitness_preferences,
    sp.business_services,
    sp.transportation_preferences,
    sp.entertainment_preferences,
    sp.housekeeping_preferences,
    sp.concierge_services,
    sp.preferred_communication_method,
    sp.preferred_check_in_time,
    sp.preferred_check_out_time,
    (CASE WHEN rp.room_type_preference IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN rp.floor_preference != 'no_preference' THEN 1 ELSE 0 END +
     CASE WHEN rp.view_preference != 'no_preference' THEN 1 ELSE 0 END +
     CASE WHEN rp.bed_type_preference != 'no_preference' THEN 1 ELSE 0 END +
     CASE WHEN sp.dining_preferences IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN sp.spa_services IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN sp.fitness_preferences IS NOT NULL THEN 1 ELSE 0 END) as preference_completeness_score,
    GREATEST(rp.last_updated, COALESCE(sp.last_updated, rp.last_updated)) as last_updated,
    CURRENT_TIMESTAMP() as processed_at
FROM BRONZE.room_preferences rp
LEFT JOIN BRONZE.service_preferences sp ON rp.guest_id = sp.guest_id;

-- ----------------------------------------------------------------------------
-- Engagement Metrics (Social media engagement analytics)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE engagement_metrics AS
SELECT 
    sma.guest_id,
    COUNT(*) as total_activities,
    COUNT(DISTINCT sma.platform) as platforms_used,
    COUNT(DISTINCT DATE(sma.activity_date)) as active_days,
    AVG(sma.sentiment_score) as avg_sentiment,
    CASE 
        WHEN AVG(sma.sentiment_score) >= 0.5 THEN 'Positive'
        WHEN AVG(sma.sentiment_score) >= 0 THEN 'Neutral'
        ELSE 'Negative'
    END as overall_sentiment,
    SUM(CASE WHEN sma.hotel_mention THEN 1 ELSE 0 END) as hotel_mentions,
    SUM(CASE WHEN sma.brand_mention THEN 1 ELSE 0 END) as brand_mentions,
    SUM(sma.engagement_metrics:likes::INT) as total_likes,
    SUM(sma.engagement_metrics:shares::INT) as total_shares,
    SUM(sma.engagement_metrics:comments::INT) as total_comments,
    SUM(sma.engagement_metrics:likes::INT + sma.engagement_metrics:shares::INT + sma.engagement_metrics:comments::INT) as total_engagement,
    COUNT(CASE WHEN sma.activity_type = 'Post' THEN 1 END) as posts_count,
    COUNT(CASE WHEN sma.activity_type = 'Review' THEN 1 END) as reviews_count,
    COUNT(CASE WHEN sma.activity_type = 'Check-in' THEN 1 END) as checkins_count,
    MAX(sma.activity_date) as last_activity_date,
    MIN(sma.activity_date) as first_activity_date,
    DATEDIFF(day, MIN(sma.activity_date), MAX(sma.activity_date)) + 1 as activity_span_days,
    ROUND(COUNT(*) / GREATEST(DATEDIFF(day, MIN(sma.activity_date), MAX(sma.activity_date)) + 1, 1), 2) as avg_activities_per_day,
    CASE 
        WHEN total_activities >= 50 THEN 'High'
        WHEN total_activities >= 20 THEN 'Medium'
        WHEN total_activities >= 5 THEN 'Low'
        ELSE 'Minimal'
    END as engagement_level,
    CURRENT_TIMESTAMP() as processed_at
FROM BRONZE.social_media_activity sma
GROUP BY sma.guest_id;

-- ----------------------------------------------------------------------------
-- Amenity Spending Enriched (Enriched amenity transactions)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE amenity_spending_enriched AS
SELECT
    at.*,
    CASE
        WHEN amenity_category = 'spa' THEN 'Wellness'
        WHEN amenity_category IN ('bar', 'restaurant') THEN 'Food & Beverage'
        WHEN amenity_category = 'room_service' THEN 'In-Room Dining'
        WHEN amenity_category IN ('wifi', 'smart_tv') THEN 'Technology Services'
        WHEN amenity_category = 'pool_services' THEN 'Recreation Services'
        ELSE 'Other Services'
    END as service_group,
    
    CASE
        WHEN amount <= 25 THEN 'Low Spend'
        WHEN amount <= 100 THEN 'Medium Spend'
        ELSE 'High Spend'
    END as spend_category,
    
    EXTRACT(HOUR FROM transaction_date) as transaction_hour,
    DAYNAME(transaction_date) as transaction_day,
    DATE_TRUNC('month', transaction_date) as transaction_month,
    
    CASE
        WHEN guest_satisfaction >= 5 THEN 'Excellent Experience'
        WHEN guest_satisfaction >= 4 THEN 'Good Experience'
        WHEN guest_satisfaction >= 3 THEN 'Average Experience'
        ELSE 'Poor Experience'
    END as experience_category,
    
    CASE
        WHEN amount > (
            SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount)
            FROM BRONZE.amenity_transactions at2
            WHERE at2.amenity_category = at.amenity_category
        ) THEN 'Premium Service'
        ELSE 'Standard Service'
    END as service_tier,
    
    CURRENT_TIMESTAMP() as processed_at
    
FROM BRONZE.amenity_transactions at;

-- ----------------------------------------------------------------------------
-- Amenity Usage Enriched (Enriched amenity usage data)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE amenity_usage_enriched AS
SELECT
    au.*,
    CASE
        WHEN amenity_category IN ('wifi', 'smart_tv') THEN 'Technology'
        WHEN amenity_category = 'pool' THEN 'Recreation'
        WHEN amenity_category = 'spa' THEN 'Wellness'
        WHEN amenity_category IN ('bar', 'restaurant') THEN 'Food & Beverage'
        WHEN amenity_category = 'room_service' THEN 'In-Room Dining'
        ELSE 'Other'
    END as usage_category,
    
    CASE
        WHEN usage_duration_minutes >= 120 AND usage_frequency >= 3 THEN 'High Engagement'
        WHEN usage_duration_minutes >= 60 OR usage_frequency >= 2 THEN 'Medium Engagement'
        ELSE 'Low Engagement'
    END as engagement_level,
    
    EXTRACT(HOUR FROM usage_start_time) as usage_hour,
    DAYNAME(usage_start_time) as usage_day,
    CASE
        WHEN EXTRACT(HOUR FROM usage_start_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM usage_start_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM usage_start_time) BETWEEN 18 AND 22 THEN 'Evening'
        ELSE 'Night'
    END as usage_period,
    
    CASE
        WHEN amenity_category = 'wifi' AND usage_type = 'paid' THEN 'Tech Adopter'
        WHEN amenity_category = 'smart_tv' AND usage_type = 'paid' THEN 'Entertainment Enthusiast'
        WHEN amenity_category IN ('wifi', 'smart_tv') AND usage_type = 'free' THEN 'Basic User'
        ELSE 'Non-Tech'
    END as tech_profile,
    
    CASE
        WHEN amenity_category = 'wifi' AND data_consumed_mb >= 500 THEN 'Heavy Data User'
        WHEN amenity_category = 'wifi' AND data_consumed_mb >= 200 THEN 'Moderate Data User'
        WHEN amenity_category = 'wifi' AND data_consumed_mb > 0 THEN 'Light Data User'
        ELSE 'No Data Tracking'
    END as data_usage_pattern,
    
    CASE
        WHEN guest_satisfaction = 5 THEN 'Excellent'
        WHEN guest_satisfaction = 4 THEN 'Good'
        WHEN guest_satisfaction = 3 THEN 'Neutral'
        WHEN guest_satisfaction = 2 THEN 'Poor'
        ELSE 'Very Poor'
    END as satisfaction_level,
    
    CASE
        WHEN usage_type = 'paid' THEN TRUE
        ELSE FALSE
    END as is_premium_usage,
    
    CASE
        WHEN usage_type = 'paid' AND amenity_category = 'wifi' THEN usage_duration_minutes * 0.10
        WHEN usage_type = 'paid' AND amenity_category = 'smart_tv' THEN usage_duration_minutes * 0.08
        ELSE 0
    END as estimated_session_value
    
FROM BRONZE.amenity_usage au;

-- ============================================================================
-- GOLD LAYER: Analytics-Ready Aggregations
-- ============================================================================
-- Business intelligence ready tables with ML scoring
-- Complete guest profiles and performance metrics
-- ============================================================================

USE SCHEMA GOLD;

-- ----------------------------------------------------------------------------
-- Guest 360 View Enhanced (Complete guest profile with amenity data)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE guest_360_view_enhanced AS
SELECT
    g.guest_id,
    g.first_name,
    g.last_name,
    g.email,
    g.age,
    g.generation,
    g.gender,
    g.nationality,
    g.language_preference,
    g.city,
    g.state_province,
    g.country,
    lp.tier_level as loyalty_tier,
    lp.points_balance as loyalty_points,
    lp.lifetime_points,
    g.marketing_opt_in,
    
    -- Booking metrics
    COALESCE(COUNT(DISTINCT be.booking_id), 0) as total_bookings,
    COALESCE(SUM(be.total_amount), 0) as total_revenue,
    COALESCE(AVG(be.total_amount), 0) as avg_booking_value,
    COALESCE(AVG(be.num_nights), 0) as avg_stay_length,
    
    -- Customer segment (simplified for initial load)
    CASE 
        WHEN total_revenue >= 10000 THEN 'High Value'
        WHEN total_revenue >= 5000 THEN 'Premium'
        WHEN total_bookings >= 5 THEN 'Regular'
        WHEN total_revenue >= 1000 THEN 'Developing'
        ELSE 'New Guest'
    END as customer_segment,
    
    CASE 
        WHEN MAX(be.check_in_date) IS NULL THEN 'Unknown'
        WHEN DATEDIFF(day, MAX(be.check_in_date), CURRENT_DATE()) > 365 THEN 'High Risk'
        WHEN DATEDIFF(day, MAX(be.check_in_date), CURRENT_DATE()) > 180 THEN 'Medium Risk'
        WHEN DATEDIFF(day, MAX(be.check_in_date), CURRENT_DATE()) > 90 THEN 'Low Risk'
        ELSE 'Active'
    END as churn_risk,
    
    -- Amenity spending metrics
    COALESCE(SUM(ase.amount), 0) as total_amenity_spend,
    COALESCE(AVG(ase.amount), 0) as avg_amenity_per_transaction,
    COALESCE(SUM(CASE WHEN ase.amenity_category = 'spa' THEN ase.amount ELSE 0 END), 0) as total_spa_spend,
    COALESCE(SUM(CASE WHEN ase.amenity_category = 'restaurant' THEN ase.amount ELSE 0 END), 0) as total_restaurant_spend,
    COALESCE(SUM(CASE WHEN ase.amenity_category = 'bar' THEN ase.amount ELSE 0 END), 0) as total_bar_spend,
    COALESCE(SUM(CASE WHEN ase.amenity_category = 'room_service' THEN ase.amount ELSE 0 END), 0) as total_room_service_spend,
    COALESCE(SUM(CASE WHEN ase.amenity_category = 'wifi' THEN ase.amount ELSE 0 END), 0) as total_wifi_spend,
    COALESCE(SUM(CASE WHEN ase.amenity_category = 'smart_tv' THEN ase.amount ELSE 0 END), 0) as total_smart_tv_spend,
    COALESCE(SUM(CASE WHEN ase.amenity_category = 'pool_services' THEN ase.amount ELSE 0 END), 0) as total_pool_services_spend,
    
    -- Amenity usage patterns
    COUNT(DISTINCT CASE WHEN ase.amenity_category = 'spa' THEN ase.transaction_id END) as spa_visits,
    COUNT(DISTINCT CASE WHEN ase.amenity_category = 'bar' THEN ase.transaction_id END) as bar_visits,
    COUNT(DISTINCT CASE WHEN ase.amenity_category = 'restaurant' THEN ase.transaction_id END) as restaurant_visits,
    COUNT(DISTINCT CASE WHEN ase.amenity_category = 'room_service' THEN ase.transaction_id END) as room_service_orders,
    COUNT(DISTINCT CASE WHEN ase.amenity_category = 'wifi' THEN ase.transaction_id END) as wifi_upgrades,
    COUNT(DISTINCT CASE WHEN ase.amenity_category = 'smart_tv' THEN ase.transaction_id END) as smart_tv_upgrades,
    COUNT(DISTINCT CASE WHEN ase.amenity_category = 'pool_services' THEN ase.transaction_id END) as pool_service_purchases,
    
    -- Amenity engagement
    COUNT(DISTINCT ase.amenity_category) as amenity_diversity_score,
    COALESCE(AVG(ase.guest_satisfaction), 0) as avg_amenity_satisfaction,
    
    -- Infrastructure usage metrics
    COALESCE(COUNT(DISTINCT CASE WHEN aue.amenity_category = 'wifi' THEN aue.usage_id END), 0) as total_wifi_sessions,
    COALESCE(COUNT(DISTINCT CASE WHEN aue.amenity_category = 'smart_tv' THEN aue.usage_id END), 0) as total_smart_tv_sessions,
    COALESCE(COUNT(DISTINCT CASE WHEN aue.amenity_category = 'pool' THEN aue.usage_id END), 0) as total_pool_sessions,
    COALESCE(AVG(CASE WHEN aue.amenity_category = 'wifi' THEN aue.usage_duration_minutes END), 0) as avg_wifi_duration,
    COALESCE(AVG(CASE WHEN aue.amenity_category = 'smart_tv' THEN aue.usage_duration_minutes END), 0) as avg_smart_tv_duration,
    COALESCE(AVG(CASE WHEN aue.amenity_category = 'pool' THEN aue.usage_duration_minutes END), 0) as avg_pool_duration,
    COALESCE(SUM(CASE WHEN aue.amenity_category = 'wifi' THEN aue.data_consumed_mb END), 0) as total_wifi_data_mb,
    COALESCE(AVG(CASE WHEN aue.amenity_category IN ('wifi', 'smart_tv', 'pool') THEN aue.guest_satisfaction END), 0) as avg_infrastructure_satisfaction,
    
    -- Technology adoption
    CASE
        WHEN COUNT(DISTINCT CASE WHEN aue.amenity_category = 'wifi' AND aue.usage_type = 'paid' THEN aue.usage_id END) > 0 THEN 'Premium Tech User'
        WHEN COUNT(DISTINCT CASE WHEN aue.amenity_category IN ('wifi', 'smart_tv') THEN aue.usage_id END) > 5 THEN 'High Tech User'
        WHEN COUNT(DISTINCT CASE WHEN aue.amenity_category IN ('wifi', 'smart_tv') THEN aue.usage_id END) > 0 THEN 'Basic Tech User'
        ELSE 'Non-Tech User'
    END as tech_adoption_profile,
    
    -- Infrastructure engagement score
    LEAST(100, GREATEST(0, 
        (COUNT(DISTINCT CASE WHEN aue.amenity_category IN ('wifi', 'smart_tv', 'pool') THEN aue.usage_id END) * 5) +
        (COALESCE(AVG(CASE WHEN aue.amenity_category IN ('wifi', 'smart_tv', 'pool') THEN aue.usage_duration_minutes END), 0) / 10) +
        (COUNT(DISTINCT CASE WHEN aue.usage_type = 'paid' THEN aue.usage_id END) * 15)
    )) as infrastructure_engagement_score,
    
    -- Amenity spending category
    CASE
        WHEN COALESCE(SUM(ase.amount), 0) > 1000 THEN 'Premium Amenity Spender'
        WHEN COALESCE(SUM(ase.amount), 0) > 200 THEN 'High Amenity Spender'
        WHEN COALESCE(SUM(ase.amount), 0) > 50 THEN 'Medium Amenity Spender'
        WHEN COALESCE(SUM(ase.amount), 0) > 0 THEN 'Low Amenity Spender'
        ELSE 'No Amenity Usage'
    END as amenity_spending_category,
    
    CURRENT_TIMESTAMP() as processed_at
    
FROM SILVER.guests_standardized g
LEFT JOIN BRONZE.loyalty_program lp ON g.guest_id = lp.guest_id
LEFT JOIN SILVER.bookings_enriched be ON g.guest_id = be.guest_id
LEFT JOIN SILVER.amenity_spending_enriched ase ON g.guest_id = ase.guest_id
LEFT JOIN SILVER.amenity_usage_enriched aue ON g.guest_id = aue.guest_id
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16;

-- ----------------------------------------------------------------------------
-- Personalization Scores Enhanced (ML scoring with amenity intelligence)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE personalization_scores_enhanced AS
SELECT
    gve.guest_id,
    gve.customer_segment,
    gve.loyalty_tier,
    
    -- Personalization readiness score (0-100)
    LEAST(100, GREATEST(0, ROUND(
        (gve.total_bookings * 10) +
        (gve.avg_amenity_satisfaction * 12) +
        (gve.amenity_diversity_score * 8) +
        (CASE WHEN gve.marketing_opt_in THEN 10 ELSE 0 END) +
        (CASE WHEN gve.total_amenity_spend > 500 THEN 15 ELSE gve.total_amenity_spend / 30 END) +
        (gve.infrastructure_engagement_score * 0.3)
    ))) as personalization_readiness_score,
    
    -- Upsell propensity score (0-100)
    LEAST(100, GREATEST(0, ROUND(
        (gve.avg_booking_value / 12) +
        (CASE WHEN gve.customer_segment = 'High Value' THEN 20
              WHEN gve.customer_segment = 'Premium' THEN 15
              WHEN gve.customer_segment = 'Regular' THEN 12 ELSE 8 END) +
        (gve.total_amenity_spend / 60) +
        (gve.amenity_diversity_score * 4) +
        (gve.infrastructure_engagement_score * 0.2)
    ))) as upsell_propensity_score,
    
    -- Spa upsell propensity (0-100)
    LEAST(100, GREATEST(0, ROUND(
        (gve.total_spa_spend / 10) +
        (gve.spa_visits * 15) +
        (CASE WHEN gve.loyalty_tier = 'Diamond' THEN 30 
              WHEN gve.loyalty_tier = 'Gold' THEN 20 ELSE 0 END) +
        (gve.avg_amenity_satisfaction * 5)
    ))) as spa_upsell_propensity,
    
    -- Dining upsell propensity (0-100)
    LEAST(100, GREATEST(0, ROUND(
        ((gve.total_restaurant_spend + gve.total_bar_spend) / 10) +
        (gve.restaurant_visits * 10) +
        (gve.bar_visits * 8) +
        (CASE WHEN gve.loyalty_tier IN ('Diamond', 'Gold') THEN 25 ELSE 0 END)
    ))) as dining_upsell_propensity,
    
    -- Loyalty propensity score (0-100)
    LEAST(100, GREATEST(0, ROUND(
        (gve.total_bookings * 8) +
        (CASE WHEN gve.loyalty_tier = 'Diamond' THEN 30
              WHEN gve.loyalty_tier = 'Gold' THEN 20
              WHEN gve.loyalty_tier = 'Silver' THEN 10 ELSE 0 END) +
        (CASE WHEN gve.churn_risk = 'Low Risk' THEN 20
              WHEN gve.churn_risk = 'Medium Risk' THEN 10 ELSE 0 END) +
        (gve.avg_amenity_satisfaction * 10)
    ))) as loyalty_propensity_score,
    
    -- Amenity engagement score (0-100)
    LEAST(100, GREATEST(0, ROUND(
        (gve.spa_visits * 10) +
        (gve.bar_visits * 5) +
        (gve.restaurant_visits * 8) +
        (gve.room_service_orders * 7) +
        (gve.amenity_diversity_score * 15)
    ))) as amenity_engagement_score,
    
    -- Technology upsell propensity (0-100)
    LEAST(100, GREATEST(0, ROUND(
        (gve.total_wifi_sessions * 3) +
        (gve.total_smart_tv_sessions * 4) +
        (gve.wifi_upgrades * 20) +
        (gve.smart_tv_upgrades * 15) +
        (gve.total_wifi_data_mb / 100) +
        (CASE WHEN gve.tech_adoption_profile = 'Premium Tech User' THEN 30
              WHEN gve.tech_adoption_profile = 'High Tech User' THEN 20
              WHEN gve.tech_adoption_profile = 'Basic Tech User' THEN 10 ELSE 0 END)
    ))) as tech_upsell_propensity,
    
    -- Pool services upsell propensity (0-100)
    LEAST(100, GREATEST(0, ROUND(
        (gve.total_pool_sessions * 8) +
        (gve.pool_service_purchases * 25) +
        (gve.avg_pool_duration / 5) +
        (CASE WHEN gve.loyalty_tier IN ('Diamond', 'Gold') THEN 20 ELSE 0 END) +
        (gve.avg_infrastructure_satisfaction * 8)
    ))) as pool_services_upsell_propensity,
    
    -- Infrastructure engagement score
    gve.infrastructure_engagement_score,
    
    CURRENT_TIMESTAMP() as calculated_at
    
FROM guest_360_view_enhanced gve;

-- ----------------------------------------------------------------------------
-- Amenity Analytics (Unified amenity performance metrics)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE amenity_analytics AS
WITH transaction_metrics AS (
    SELECT
        DATE_TRUNC('month', at.transaction_date) as metric_month,
        at.amenity_category,
        CASE
            WHEN at.amenity_category = 'spa' THEN 'Wellness'
            WHEN at.amenity_category IN ('bar', 'restaurant') THEN 'Food & Beverage'
            WHEN at.amenity_category = 'room_service' THEN 'In-Room Dining'
            WHEN at.amenity_category IN ('wifi', 'smart_tv') THEN 'Technology Services'
            WHEN at.amenity_category = 'pool_services' THEN 'Recreation Services'
            ELSE 'Other Services'
        END as service_group,
        at.location,
        COUNT(DISTINCT at.transaction_id) as total_transactions,
        COUNT(DISTINCT at.guest_id) as unique_guests,
        SUM(at.amount) as total_revenue,
        AVG(at.amount) as avg_transaction_value,
        AVG(at.guest_satisfaction) as avg_satisfaction,
        ROUND(AVG(at.guest_satisfaction) / 5 * 100, 2) as satisfaction_rate,
        COUNT(CASE WHEN at.is_premium_service = TRUE THEN at.transaction_id END) as premium_transactions,
        ROUND(
            COUNT(CASE WHEN at.is_premium_service = TRUE THEN at.transaction_id END) / 
            NULLIF(COUNT(DISTINCT at.transaction_id), 0) * 100, 2
        ) as premium_service_rate,
        0 as total_usage_sessions,
        0 as total_usage_minutes,
        0 as avg_session_duration,
        0 as total_data_consumed_mb
    FROM BRONZE.amenity_transactions at
    GROUP BY 1,2,3,4
),
usage_metrics AS (
    SELECT
        DATE_TRUNC('month', au.usage_start_time) as metric_month,
        au.amenity_category,
        CASE
            WHEN au.amenity_category IN ('wifi', 'smart_tv') THEN 'Technology Services'
            WHEN au.amenity_category = 'pool' THEN 'Recreation Services'
            ELSE 'Other Services'
        END as service_group,
        au.location,
        0 as total_transactions,
        COUNT(DISTINCT au.guest_id) as unique_guests,
        0 as total_revenue,
        0 as avg_transaction_value,
        AVG(au.guest_satisfaction) as avg_satisfaction,
        ROUND(AVG(au.guest_satisfaction) / 5 * 100, 2) as satisfaction_rate,
        0 as premium_transactions,
        0 as premium_service_rate,
        COUNT(DISTINCT au.usage_id) as total_usage_sessions,
        SUM(au.usage_duration_minutes) as total_usage_minutes,
        ROUND(AVG(au.usage_duration_minutes), 2) as avg_session_duration,
        COALESCE(SUM(au.data_consumed_mb), 0) as total_data_consumed_mb
    FROM BRONZE.amenity_usage au
    GROUP BY 1,2,3,4
)
SELECT
    COALESCE(tm.metric_month, um.metric_month) as metric_month,
    COALESCE(tm.amenity_category, um.amenity_category) as amenity_category,
    COALESCE(tm.service_group, um.service_group) as service_group,
    COALESCE(tm.location, um.location) as location,
    COALESCE(tm.total_transactions, 0) + COALESCE(um.total_transactions, 0) as total_transactions,
    GREATEST(COALESCE(tm.unique_guests, 0), COALESCE(um.unique_guests, 0)) as unique_guests,
    COALESCE(tm.total_revenue, 0) + COALESCE(um.total_revenue, 0) as total_revenue,
    CASE 
        WHEN COALESCE(tm.total_transactions, 0) > 0 THEN tm.avg_transaction_value
        ELSE 0
    END as avg_transaction_value,
    COALESCE(tm.avg_satisfaction, um.avg_satisfaction, 0) as avg_satisfaction,
    COALESCE(tm.satisfaction_rate, um.satisfaction_rate, 0) as satisfaction_rate,
    COALESCE(tm.premium_transactions, 0) as premium_transactions,
    COALESCE(tm.premium_service_rate, 0) as premium_service_rate,
    COALESCE(um.total_usage_sessions, 0) as total_usage_sessions,
    COALESCE(um.total_usage_minutes, 0) as total_usage_minutes,
    COALESCE(um.avg_session_duration, 0) as avg_session_duration,
    COALESCE(um.total_data_consumed_mb, 0) as total_data_consumed_mb,
    CURRENT_TIMESTAMP() as processed_at
FROM transaction_metrics tm
FULL OUTER JOIN usage_metrics um 
    ON tm.metric_month = um.metric_month 
    AND tm.amenity_category = um.amenity_category 
    AND tm.location = um.location;

-- ============================================================================
-- Summary
-- ============================================================================
SELECT 'Schema setup completed successfully!' AS STATUS;
SELECT 
    'Tables created across BRONZE, SILVER, and GOLD schemas' AS RESULT,
    'Ready for data generation' AS NEXT_STEP;

