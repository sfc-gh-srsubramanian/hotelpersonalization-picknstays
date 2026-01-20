



-- ============================================================================
-- Hotel Personalization - Refresh Silver and Gold Layers (03b)
-- ============================================================================
-- Rebuilds Silver and Gold tables after Bronze data is loaded
-- Run this AFTER 03_data_generation.sql to populate Silver and Gold layers
--
-- This script re-executes the CREATE OR REPLACE TABLE statements
-- from 02_schema_setup.sql for Silver and Gold layers with fresh Bronze data.
-- 
-- Session variables (set by deploy.sh):
--   $FULL_PREFIX, $PROJECT_ROLE
-- ============================================================================

-- USE ROLE IDENTIFIER($PROJECT_ROLE);  -- Role is set by deploy.sh
USE DATABASE HOTEL_PERSONALIZATION;

-- ============================================================================
-- SILVER LAYER: Rebuild Tables with Fresh Data
-- ============================================================================

USE SCHEMA SILVER;

-- ----------------------------------------------------------------------------
-- Guests Standardized (Cleaned guest profiles with derived attributes)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE guests_standardized AS
SELECT 
    g.guest_id,
    g.first_name,
    g.last_name,
    g.email,
    g.phone,
    g.date_of_birth,
    DATEDIFF(year, g.date_of_birth, CURRENT_DATE()) as age,
    CASE 
        WHEN DATEDIFF(year, g.date_of_birth, CURRENT_DATE()) < 27 THEN 'Gen Z'
        WHEN DATEDIFF(year, g.date_of_birth, CURRENT_DATE()) < 43 THEN 'Millennial'
        WHEN DATEDIFF(year, g.date_of_birth, CURRENT_DATE()) < 59 THEN 'Gen X'
        WHEN DATEDIFF(year, g.date_of_birth, CURRENT_DATE()) < 78 THEN 'Baby Boomer'
        ELSE 'Silent Generation'
    END as generation,
    g.gender,
    g.nationality,
    g.language_preference,
    g.address_line1,
    g.address_line2,
    g.city,
    g.state_province,
    g.postal_code,
    g.country,
    g.registration_date,
    g.last_updated,
    g.marketing_opt_in,
    g.communication_preferences,
    g.emergency_contact,
    CURRENT_TIMESTAMP() as processed_at
FROM BRONZE.guest_profiles g;

-- ----------------------------------------------------------------------------
-- Bookings Enriched (Bookings with calculated metrics)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE bookings_enriched AS
SELECT 
    bh.booking_id,
    bh.guest_id,
    bh.hotel_id,
    bh.booking_date,
    bh.check_in_date,
    bh.check_out_date,
    bh.num_nights,
    bh.num_adults,
    bh.num_children,
    bh.room_type,
    bh.rate_code,
    bh.total_amount,
    bh.currency,
    bh.booking_channel,
    bh.booking_status,
    bh.cancellation_date,
    bh.advance_booking_days,
    bh.special_requests,
    bh.promo_code,
    bh.payment_method,
    bh.created_at,
    bh.updated_at,
    CASE 
        WHEN bh.booking_status = 'cancelled' THEN TRUE 
        ELSE FALSE 
    END as is_cancelled,
    CASE 
        WHEN bh.advance_booking_days < 7 THEN 'Last Minute'
        WHEN bh.advance_booking_days < 30 THEN 'Short Lead'
        WHEN bh.advance_booking_days < 90 THEN 'Medium Lead'
        ELSE 'Long Lead'
    END as booking_lead_time_category,
    ROUND(bh.total_amount / NULLIF(bh.num_nights, 0), 2) as avg_daily_rate,
    DAYOFWEEK(bh.check_in_date) as check_in_day_of_week,
    CASE 
        WHEN DAYOFWEEK(bh.check_in_date) IN (6, 7) THEN TRUE 
        ELSE FALSE 
    END as is_weekend_checkin,
    QUARTER(bh.check_in_date) as booking_quarter,
    MONTHNAME(bh.check_in_date) as booking_month,
    YEAR(bh.check_in_date) as booking_year,
    CURRENT_TIMESTAMP() as processed_at
FROM BRONZE.booking_history bh;

-- ----------------------------------------------------------------------------
-- Stays Processed (Stay records with calculated metrics)
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
-- GOLD LAYER: Rebuild Analytics Tables
-- ============================================================================

USE SCHEMA GOLD;

-- ----------------------------------------------------------------------------
-- Guest 360 View Enhanced (Complete guest profile with amenity data)
-- FIX: Pre-aggregate to avoid cartesian product from multiple LEFT JOINs
-- ----------------------------------------------------------------------------

-- Pre-aggregate bookings data
CREATE OR REPLACE TEMPORARY TABLE temp_booking_agg AS
SELECT 
    guest_id,
    COUNT(DISTINCT booking_id) as total_bookings,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_booking_value,
    AVG(num_nights) as avg_stay_length,
    MAX(check_in_date) as last_check_in
FROM SILVER.bookings_enriched
GROUP BY guest_id;

-- Pre-aggregate amenity spending data
CREATE OR REPLACE TEMPORARY TABLE temp_amenity_spend_agg AS
SELECT 
    guest_id,
    SUM(amount) as total_amenity_spend,
    AVG(amount) as avg_amenity_per_transaction,
    SUM(CASE WHEN amenity_category = 'spa' THEN amount ELSE 0 END) as total_spa_spend,
    SUM(CASE WHEN amenity_category = 'restaurant' THEN amount ELSE 0 END) as total_restaurant_spend,
    SUM(CASE WHEN amenity_category = 'bar' THEN amount ELSE 0 END) as total_bar_spend,
    SUM(CASE WHEN amenity_category = 'room_service' THEN amount ELSE 0 END) as total_room_service_spend,
    SUM(CASE WHEN amenity_category = 'wifi' THEN amount ELSE 0 END) as total_wifi_spend,
    SUM(CASE WHEN amenity_category = 'smart_tv' THEN amount ELSE 0 END) as total_smart_tv_spend,
    SUM(CASE WHEN amenity_category = 'pool_services' THEN amount ELSE 0 END) as total_pool_services_spend,
    COUNT(DISTINCT CASE WHEN amenity_category = 'spa' THEN transaction_id END) as spa_visits,
    COUNT(DISTINCT CASE WHEN amenity_category = 'bar' THEN transaction_id END) as bar_visits,
    COUNT(DISTINCT CASE WHEN amenity_category = 'restaurant' THEN transaction_id END) as restaurant_visits,
    COUNT(DISTINCT CASE WHEN amenity_category = 'room_service' THEN transaction_id END) as room_service_orders,
    COUNT(DISTINCT CASE WHEN amenity_category = 'wifi' THEN transaction_id END) as wifi_upgrades,
    COUNT(DISTINCT CASE WHEN amenity_category = 'smart_tv' THEN transaction_id END) as smart_tv_upgrades,
    COUNT(DISTINCT CASE WHEN amenity_category = 'pool_services' THEN transaction_id END) as pool_service_purchases,
    COUNT(DISTINCT amenity_category) as amenity_diversity_score,
    AVG(guest_satisfaction) as avg_amenity_satisfaction
FROM SILVER.amenity_spending_enriched
GROUP BY guest_id;

-- Pre-aggregate amenity usage data
CREATE OR REPLACE TEMPORARY TABLE temp_amenity_usage_agg AS
SELECT 
    guest_id,
    COUNT(DISTINCT CASE WHEN amenity_category = 'wifi' THEN usage_id END) as total_wifi_sessions,
    COUNT(DISTINCT CASE WHEN amenity_category = 'smart_tv' THEN usage_id END) as total_smart_tv_sessions,
    COUNT(DISTINCT CASE WHEN amenity_category = 'pool' THEN usage_id END) as total_pool_sessions,
    AVG(CASE WHEN amenity_category = 'wifi' THEN usage_duration_minutes END) as avg_wifi_duration,
    AVG(CASE WHEN amenity_category = 'smart_tv' THEN usage_duration_minutes END) as avg_smart_tv_duration,
    AVG(CASE WHEN amenity_category = 'pool' THEN usage_duration_minutes END) as avg_pool_duration,
    SUM(CASE WHEN amenity_category = 'wifi' THEN data_consumed_mb ELSE 0 END) as total_wifi_data_mb,
    AVG(CASE WHEN amenity_category IN ('wifi', 'smart_tv', 'pool') THEN guest_satisfaction END) as avg_infrastructure_satisfaction,
    COUNT(DISTINCT CASE WHEN amenity_category = 'wifi' AND usage_type = 'paid' THEN usage_id END) as wifi_paid_sessions,
    COUNT(DISTINCT CASE WHEN amenity_category IN ('wifi', 'smart_tv') THEN usage_id END) as tech_sessions,
    COUNT(DISTINCT CASE WHEN amenity_category IN ('wifi', 'smart_tv', 'pool') THEN usage_id END) as infra_sessions,
    AVG(CASE WHEN amenity_category IN ('wifi', 'smart_tv', 'pool') THEN usage_duration_minutes END) as avg_infra_duration,
    COUNT(DISTINCT CASE WHEN usage_type = 'paid' THEN usage_id END) as paid_usage_sessions
FROM SILVER.amenity_usage_enriched
GROUP BY guest_id;

-- Pre-aggregate service case data
CREATE OR REPLACE TEMPORARY TABLE temp_service_case_agg AS
SELECT 
    guest_id,
    COUNT(DISTINCT case_id) as total_service_cases,
    COUNT(DISTINCT CASE WHEN reported_at >= DATEADD(day, -90, CURRENT_DATE()) 
        THEN case_id END) as recent_service_cases_90d,
    COUNT(DISTINCT CASE WHEN severity IN ('high', 'critical') 
        THEN case_id END) as high_severity_cases,
    MAX(reported_at) as last_service_case_date
FROM BRONZE.SERVICE_CASES
GROUP BY guest_id;

-- Now build GOLD table with pre-aggregated data (NO cartesian product!)
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
    COALESCE(ba.total_bookings, 0) as total_bookings,
    COALESCE(ba.total_revenue, 0) as total_revenue,
    COALESCE(ba.avg_booking_value, 0) as avg_booking_value,
    COALESCE(ba.avg_stay_length, 0) as avg_stay_length,
    CASE 
        WHEN COALESCE(ba.total_revenue, 0) >= 10000 THEN 'High Value'
        WHEN COALESCE(ba.total_revenue, 0) >= 5000 THEN 'Premium'
        WHEN COALESCE(ba.total_bookings, 0) >= 5 THEN 'Regular'
        WHEN COALESCE(ba.total_revenue, 0) >= 1000 THEN 'Developing'
        ELSE 'New Guest'
    END as customer_segment,
    CASE 
        WHEN ba.last_check_in IS NULL THEN 'Unknown'
        WHEN DATEDIFF(day, ba.last_check_in, CURRENT_DATE()) > 365 THEN 'High Risk'
        WHEN DATEDIFF(day, ba.last_check_in, CURRENT_DATE()) > 180 THEN 'Medium Risk'
        WHEN DATEDIFF(day, ba.last_check_in, CURRENT_DATE()) > 90 THEN 'Low Risk'
        ELSE 'Active'
    END as churn_risk,
    COALESCE(ase.total_amenity_spend, 0) as total_amenity_spend,
    COALESCE(ase.avg_amenity_per_transaction, 0) as avg_amenity_per_transaction,
    COALESCE(ase.total_spa_spend, 0) as total_spa_spend,
    COALESCE(ase.total_restaurant_spend, 0) as total_restaurant_spend,
    COALESCE(ase.total_bar_spend, 0) as total_bar_spend,
    COALESCE(ase.total_room_service_spend, 0) as total_room_service_spend,
    COALESCE(ase.total_wifi_spend, 0) as total_wifi_spend,
    COALESCE(ase.total_smart_tv_spend, 0) as total_smart_tv_spend,
    COALESCE(ase.total_pool_services_spend, 0) as total_pool_services_spend,
    COALESCE(ase.spa_visits, 0) as spa_visits,
    COALESCE(ase.bar_visits, 0) as bar_visits,
    COALESCE(ase.restaurant_visits, 0) as restaurant_visits,
    COALESCE(ase.room_service_orders, 0) as room_service_orders,
    COALESCE(ase.wifi_upgrades, 0) as wifi_upgrades,
    COALESCE(ase.smart_tv_upgrades, 0) as smart_tv_upgrades,
    COALESCE(ase.pool_service_purchases, 0) as pool_service_purchases,
    COALESCE(ase.amenity_diversity_score, 0) as amenity_diversity_score,
    COALESCE(ase.avg_amenity_satisfaction, 0) as avg_amenity_satisfaction,
    COALESCE(aue.total_wifi_sessions, 0) as total_wifi_sessions,
    COALESCE(aue.total_smart_tv_sessions, 0) as total_smart_tv_sessions,
    COALESCE(aue.total_pool_sessions, 0) as total_pool_sessions,
    COALESCE(aue.avg_wifi_duration, 0) as avg_wifi_duration,
    COALESCE(aue.avg_smart_tv_duration, 0) as avg_smart_tv_duration,
    COALESCE(aue.avg_pool_duration, 0) as avg_pool_duration,
    COALESCE(aue.total_wifi_data_mb, 0) as total_wifi_data_mb,
    COALESCE(aue.avg_infrastructure_satisfaction, 0) as avg_infrastructure_satisfaction,
    CASE 
        WHEN COALESCE(aue.wifi_paid_sessions, 0) > 0 THEN 'Premium Tech User'
        WHEN COALESCE(aue.tech_sessions, 0) > 5 THEN 'High Tech User'
        WHEN COALESCE(aue.tech_sessions, 0) > 0 THEN 'Basic Tech User'
        ELSE 'Non-Tech User'
    END as tech_adoption_profile,
    LEAST(100, GREATEST(0, 
        (COALESCE(aue.infra_sessions, 0) * 5) + 
        (COALESCE(aue.avg_infra_duration, 0) / 10) + 
        (COALESCE(aue.paid_usage_sessions, 0) * 15)
    )) as infrastructure_engagement_score,
    CASE 
        WHEN COALESCE(ase.total_amenity_spend, 0) > 1000 THEN 'Premium Amenity Spender'
        WHEN COALESCE(ase.total_amenity_spend, 0) > 200 THEN 'High Amenity Spender'
        WHEN COALESCE(ase.total_amenity_spend, 0) > 50 THEN 'Medium Amenity Spender'
        WHEN COALESCE(ase.total_amenity_spend, 0) > 0 THEN 'Low Amenity Spender'
        ELSE 'No Amenity Usage'
    END as amenity_spending_category,
    COALESCE(sca.total_service_cases, 0) as total_service_cases,
    COALESCE(sca.recent_service_cases_90d, 0) as recent_service_cases_90d,
    COALESCE(sca.high_severity_cases, 0) as high_severity_cases,
    sca.last_service_case_date,
    CURRENT_TIMESTAMP() as processed_at
FROM SILVER.guests_standardized g
LEFT JOIN BRONZE.loyalty_program lp ON g.guest_id = lp.guest_id
LEFT JOIN temp_booking_agg ba ON g.guest_id = ba.guest_id
LEFT JOIN temp_amenity_spend_agg ase ON g.guest_id = ase.guest_id
LEFT JOIN temp_amenity_usage_agg aue ON g.guest_id = aue.guest_id
LEFT JOIN temp_service_case_agg sca ON g.guest_id = sca.guest_id;

-- ----------------------------------------------------------------------------
-- Personalization Scores Enhanced (ML-powered scoring for personalization)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE personalization_scores_enhanced AS
SELECT
    g360.guest_id,
    g360.first_name,
    g360.last_name,
    g360.loyalty_tier,
    g360.customer_segment,
    g360.total_bookings,
    g360.total_revenue,
    g360.total_amenity_spend,
    LEAST(100, GREATEST(0, 
        (g360.total_bookings * 10) + 
        (g360.amenity_diversity_score * 15) + 
        (CASE WHEN g360.marketing_opt_in THEN 20 ELSE 0 END) +
        (g360.avg_amenity_satisfaction * 10)
    )) as personalization_readiness_score,
    LEAST(100, GREATEST(0,
        50 + 
        (g360.avg_booking_value / 100) +
        (g360.total_amenity_spend / 50) +
        (CASE WHEN g360.loyalty_tier IN ('Gold', 'Diamond') THEN 20 ELSE 0 END) -
        (CASE WHEN g360.churn_risk = 'High Risk' THEN 30 
              WHEN g360.churn_risk = 'Medium Risk' THEN 15 
              ELSE 0 END)
    )) as upsell_propensity_score,
    LEAST(100, GREATEST(0,
        40 + 
        (g360.total_spa_spend / 20) +
        (g360.spa_visits * 10) +
        (CASE WHEN g360.customer_segment IN ('High Value', 'Premium') THEN 25 ELSE 0 END)
    )) as spa_upsell_propensity,
    LEAST(100, GREATEST(0,
        45 + 
        (g360.total_restaurant_spend / 30) +
        (g360.restaurant_visits * 8) +
        (g360.bar_visits * 5) +
        (CASE WHEN g360.avg_stay_length > 2 THEN 15 ELSE 0 END)
    )) as dining_upsell_propensity,
    LEAST(100, GREATEST(0,
        35 + 
        (g360.infrastructure_engagement_score * 0.4) +
        (CASE WHEN g360.tech_adoption_profile IN ('Premium Tech User', 'High Tech User') THEN 30 ELSE 10 END) +
        (g360.avg_wifi_duration / 5)
    )) as tech_upsell_propensity,
    LEAST(100, GREATEST(0,
        40 + 
        (g360.total_pool_sessions * 8) +
        (g360.total_pool_services_spend / 15) +
        (CASE WHEN g360.generation IN ('Gen Z', 'Millennial') THEN 20 ELSE 5 END)
    )) as pool_services_upsell_propensity,
    LEAST(100, GREATEST(0,
        50 + 
        (g360.total_bookings * 5) +
        (g360.lifetime_points / 100) +
        (CASE WHEN g360.loyalty_tier = 'Diamond' THEN 25
              WHEN g360.loyalty_tier = 'Gold' THEN 15
              WHEN g360.loyalty_tier = 'Gold' THEN 5
              ELSE -10 END) -
        (CASE WHEN g360.churn_risk = 'High Risk' THEN 40 ELSE 0 END)
    )) as loyalty_propensity_score,
    g360.amenity_diversity_score as amenity_engagement_score,
    g360.infrastructure_engagement_score,
    CURRENT_TIMESTAMP() as processed_at
FROM GOLD.guest_360_view_enhanced g360;

-- ----------------------------------------------------------------------------
-- Amenity Analytics (Comprehensive amenity performance metrics)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE amenity_analytics AS
WITH transaction_metrics AS (
    SELECT
        DATE_TRUNC('month', at.transaction_date) as metric_month,
        at.amenity_category,
        'N/A' as amenity_name,
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
    GROUP BY 1,2,3,4,5
),
usage_metrics AS (
    SELECT
        DATE_TRUNC('month', au.usage_start_time) as metric_month,
        au.amenity_category,
        au.amenity_name,
        CASE
            WHEN au.amenity_category IN ('wifi', 'smart_tv') THEN 'Technology Services'
            WHEN au.amenity_category = 'pool' THEN 'Recreation Services'
            WHEN au.amenity_category = 'spa' THEN 'Wellness'
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
    GROUP BY 1,2,3,4,5
)
SELECT
    COALESCE(tm.metric_month, um.metric_month) as metric_month,
    COALESCE(tm.amenity_category, um.amenity_category) as amenity_category,
    COALESCE(tm.amenity_name, um.amenity_name) as amenity_name,
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
    AND tm.amenity_name = um.amenity_name
    AND tm.location = um.location;

-- ============================================================================
-- SILVER LAYER: Intelligence Hub Tables
-- ============================================================================
-- Enriched tables for executive intelligence with guest/property context
-- ============================================================================

USE SCHEMA SILVER;

-- ----------------------------------------------------------------------------
-- Service Cases Enriched (Service cases with full context)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE service_cases_enriched AS
WITH case_context AS (
    SELECT 
        sc.*,
        -- Guest context
        gp.first_name,
        gp.last_name,
        gp.email,
        gp.nationality,
        -- Loyalty context
        lm.tier_level,
        lm.points_balance,
        lm.lifetime_points,
        -- Property context
        hp.brand,
        hp.category,
        hp.region,
        hp.sub_region,
        hp.city,
        hp.country,
        -- Guest metrics from Bronze data
        g360.lifetime_value,
        g360.total_stays,
        g360.avg_satisfaction,
        -- Determine if VIP (Diamond/Gold + $10K+ LTV)
        CASE 
            WHEN lm.tier_level IN ('Diamond', 'Gold') AND g360.lifetime_value > 10000 THEN TRUE
            ELSE FALSE
        END as is_vip,
        -- Stay context
        cs.actual_check_in,
        cs.actual_check_out,
        cs.total_charges
    FROM BRONZE.service_cases sc
    LEFT JOIN BRONZE.guest_profiles gp ON sc.guest_id = gp.guest_id
    LEFT JOIN BRONZE.loyalty_program lm ON sc.guest_id = lm.guest_id
    LEFT JOIN BRONZE.hotel_properties hp ON sc.hotel_id = hp.hotel_id
    LEFT JOIN BRONZE.stay_history cs ON sc.stay_id = cs.stay_id
    LEFT JOIN (
        SELECT 
            guest_id,
            COUNT(DISTINCT stay_id) as total_stays,
            SUM(total_charges) as lifetime_value,
            AVG(guest_satisfaction_score) as avg_satisfaction
        FROM BRONZE.stay_history
        GROUP BY guest_id
    ) g360 ON sc.guest_id = g360.guest_id
),
case_counts AS (
    SELECT 
        guest_id,
        COUNT(*) as case_count_last_90_days
    FROM BRONZE.service_cases
    WHERE reported_at >= DATEADD(day, -90, CURRENT_DATE())
    GROUP BY guest_id
),
property_benchmarks AS (
    SELECT 
        hotel_id,
        AVG(resolution_time_minutes) as avg_resolution_time_property,
        STDDEV(resolution_time_minutes) as stddev_resolution_time
    FROM BRONZE.service_cases
    GROUP BY hotel_id
)
SELECT 
    cc.*,
    COALESCE(counts.case_count_last_90_days, 0) as case_count_last_90_days,
    pb.avg_resolution_time_property,
    CASE cc.severity
        WHEN 'critical' THEN cc.resolution_time_minutes - 240
        WHEN 'high' THEN cc.resolution_time_minutes - 120
        WHEN 'medium' THEN cc.resolution_time_minutes - 60
        ELSE cc.resolution_time_minutes - 30
    END as time_to_resolution_vs_target,
    cc.resolution_time_minutes - pb.avg_resolution_time_property as resolution_variance_from_property_avg,
    CURRENT_TIMESTAMP() as refreshed_at
FROM case_context cc
LEFT JOIN case_counts counts ON cc.guest_id = counts.guest_id
LEFT JOIN property_benchmarks pb ON cc.hotel_id = pb.hotel_id;

-- ----------------------------------------------------------------------------
-- Issue Drivers Aggregated (Rolled-up issue analytics)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE issue_drivers_aggregated AS
WITH issue_stats AS (
    SELECT 
        it.hotel_id,
        it.brand,
        it.region,
        it.issue_category,
        it.issue_driver,
        DATE_TRUNC('month', sc.reported_at) as month,
        COUNT(*) as issue_count,
        AVG(it.impact_on_satisfaction) as avg_impact_on_satisfaction,
        SUM(CASE WHEN it.recurring_issue_flag THEN 1 ELSE 0 END) as recurring_issue_count,
        COUNT(DISTINCT sc.guest_id) as guests_affected,
        COUNT(DISTINCT sc.case_id) as cases_affected
    FROM BRONZE.issue_tracking it
    JOIN BRONZE.service_cases sc ON it.case_id = sc.case_id
    GROUP BY 
        it.hotel_id,
        it.brand,
        it.region,
        it.issue_category,
        it.issue_driver,
        DATE_TRUNC('month', sc.reported_at)
),
prior_period AS (
    SELECT 
        hotel_id,
        brand,
        region,
        issue_category,
        issue_driver,
        month,
        issue_count,
        LAG(issue_count, 1) OVER (
            PARTITION BY hotel_id, issue_category, issue_driver 
            ORDER BY month
        ) as prior_month_count
    FROM issue_stats
)
SELECT 
    ist.*,
    pp.prior_month_count,
    CASE 
        WHEN pp.prior_month_count IS NULL THEN 'new'
        WHEN ist.issue_count > pp.prior_month_count * 1.2 THEN 'increasing'
        WHEN ist.issue_count < pp.prior_month_count * 0.8 THEN 'decreasing'
        ELSE 'stable'
    END as trend_vs_prior_period,
    ROUND((ist.issue_count - COALESCE(pp.prior_month_count, ist.issue_count)) * 100.0 / 
          NULLIF(pp.prior_month_count, 0), 1) as pct_change_vs_prior,
    CURRENT_TIMESTAMP() as refreshed_at
FROM issue_stats ist
LEFT JOIN prior_period pp ON 
    ist.hotel_id = pp.hotel_id AND
    ist.issue_category = pp.issue_category AND
    ist.issue_driver = pp.issue_driver AND
    ist.month = pp.month;

-- ----------------------------------------------------------------------------
-- Sentiment Processed (Sentiment with trend detection)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE sentiment_processed AS
WITH sentiment_context AS (
    SELECT 
        sd.*,
        gp.first_name,
        gp.last_name,
        gp.email,
        lm.tier_level,
        lm.lifetime_points,
        hp.brand,
        hp.category,
        hp.region,
        hp.sub_region,
        g360.lifetime_value,
        g360.total_stays,
        CASE 
            WHEN g360.lifetime_value > 10000 THEN TRUE
            ELSE FALSE
        END as high_value_guest_flag,
        CASE 
            WHEN sd.sentiment_score < -20 THEN TRUE
            ELSE FALSE
        END as negative_sentiment_flag
    FROM BRONZE.sentiment_data sd
    LEFT JOIN BRONZE.guest_profiles gp ON sd.guest_id = gp.guest_id
    LEFT JOIN BRONZE.loyalty_program lm ON sd.guest_id = lm.guest_id
    LEFT JOIN BRONZE.hotel_properties hp ON sd.hotel_id = hp.hotel_id
    LEFT JOIN (
        SELECT 
            guest_id,
            COUNT(DISTINCT stay_id) as total_stays,
            SUM(total_charges) as lifetime_value,
            AVG(guest_satisfaction_score) as avg_satisfaction
        FROM BRONZE.stay_history
        GROUP BY guest_id
    ) g360 ON sd.guest_id = g360.guest_id
),
guest_sentiment_trend AS (
    SELECT 
        sentiment_id,
        guest_id,
        sentiment_score,
        AVG(sentiment_score) OVER (
            PARTITION BY guest_id 
            ORDER BY posted_at
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) as sentiment_trend_avg,
        LAG(sentiment_score, 1) OVER (
            PARTITION BY guest_id 
            ORDER BY posted_at
        ) as prior_sentiment_score
    FROM BRONZE.sentiment_data
)
SELECT 
    sc.*,
    gst.sentiment_trend_avg,
    gst.prior_sentiment_score,
    CASE 
        WHEN gst.prior_sentiment_score IS NULL THEN 'first_feedback'
        WHEN sc.sentiment_score > gst.sentiment_trend_avg + 20 THEN 'improving'
        WHEN sc.sentiment_score < gst.sentiment_trend_avg - 20 THEN 'declining'
        ELSE 'stable'
    END as sentiment_trend,
    CASE 
        WHEN sc.high_value_guest_flag 
         AND (sc.negative_sentiment_flag OR gst.sentiment_trend_avg < 0)
        THEN TRUE
        ELSE FALSE
    END as at_risk_flag,
    CURRENT_TIMESTAMP() as refreshed_at
FROM sentiment_context sc
LEFT JOIN guest_sentiment_trend gst ON sc.sentiment_id = gst.sentiment_id;

-- ============================================================================
-- GOLD LAYER: Intelligence Hub Tables
-- ============================================================================
-- Executive analytics tables with portfolio KPIs and intelligence metrics
-- ============================================================================

USE SCHEMA GOLD;

-- ----------------------------------------------------------------------------
-- Portfolio Performance KPIs (Daily KPIs by hotel/brand/region)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE portfolio_performance_kpis AS
WITH date_series AS (
    -- Generate daily dates for past 12 months
    SELECT DISTINCT
        DATEADD(day, -SEQ4(), CURRENT_DATE()) as performance_date
    FROM TABLE(GENERATOR(ROWCOUNT => 365))
    WHERE DATEADD(day, -SEQ4(), CURRENT_DATE()) >= DATEADD(month, -12, CURRENT_DATE())
),
hotel_dates AS (
    -- Cross join hotels with dates
    SELECT 
        ds.performance_date,
        hp.hotel_id,
        hp.brand,
        hp.category,
        hp.region,
        hp.sub_region,
        hp.city,
        hp.country,
        hp.total_rooms
    FROM date_series ds
    CROSS JOIN BRONZE.hotel_properties hp
),
daily_occupancy AS (
    -- Count rooms occupied on each date (check_in <= date < check_out)
    SELECT 
        hd.performance_date,
        hd.hotel_id,
        COUNT(DISTINCT cs.stay_id) as rooms_occupied,
        -- Calculate revenue for that day (total charges / length of stay)
        SUM(cs.total_charges / NULLIF(DATEDIFF(day, cs.actual_check_in, cs.actual_check_out), 0)) as daily_revenue
    FROM hotel_dates hd
    LEFT JOIN BRONZE.stay_history cs 
        ON hd.hotel_id = cs.hotel_id
        AND hd.performance_date >= cs.actual_check_in
        AND hd.performance_date < cs.actual_check_out
    GROUP BY hd.performance_date, hd.hotel_id
),
daily_performance AS (
    SELECT 
        hd.performance_date,
        hd.hotel_id,
        hd.brand,
        hd.category,
        hd.region,
        hd.sub_region,
        hd.city,
        hd.country,
        hd.total_rooms,
        COALESCE(do.rooms_occupied, 0) as rooms_occupied,
        ROUND(COALESCE(do.rooms_occupied, 0) * 100.0 / NULLIF(hd.total_rooms, 0), 2) as occupancy_pct,
        -- ADR = daily revenue / rooms occupied
        ROUND(COALESCE(do.daily_revenue / NULLIF(do.rooms_occupied, 0), 0), 2) as adr,
        -- RevPAR = daily revenue / total available rooms
        ROUND(COALESCE(do.daily_revenue / NULLIF(hd.total_rooms, 0), 0), 2) as revpar,
        COALESCE(do.daily_revenue, 0) as total_revenue
    FROM hotel_dates hd
    LEFT JOIN daily_occupancy do ON hd.performance_date = do.performance_date AND hd.hotel_id = do.hotel_id
),
overall_repeat_rate AS (
    -- Calculate overall repeat rate using SAME METHOD as Loyalty Intelligence
    -- Start from ALL GUESTS (not just those with stays), then LEFT JOIN stays
    -- This correctly includes one-time guests AND guests with no stays in the denominator
    WITH all_guests AS (
        SELECT guest_id FROM BRONZE.guest_profiles
    ),
    guest_stay_counts AS (
        SELECT 
            guest_id,
            COUNT(DISTINCT stay_id) as total_stays
        FROM BRONZE.stay_history
        WHERE actual_check_in >= DATEADD(month, -12, CURRENT_DATE())
        GROUP BY guest_id
    ),
    guest_with_stays AS (
        SELECT 
            ag.guest_id,
            COALESCE(gsc.total_stays, 0) as total_stays,
            CASE 
                WHEN COALESCE(gsc.total_stays, 0) >= 2 THEN 1 
                ELSE 0 
            END as is_repeat_guest
        FROM all_guests ag
        LEFT JOIN guest_stay_counts gsc ON ag.guest_id = gsc.guest_id
    )
    SELECT 
        ROUND(
            SUM(is_repeat_guest) * 100.0 / 
            NULLIF(COUNT(DISTINCT guest_id), 0), 
            2
        ) as repeat_stay_rate_pct
    FROM guest_with_stays
),
repeat_stays_by_date AS (
    -- Use overall repeat rate for all dates (consistent metric)
    SELECT 
        cs.hotel_id,
        DATE(cs.actual_check_in) as performance_date,
        orr.repeat_stay_rate_pct
    FROM BRONZE.stay_history cs
    CROSS JOIN overall_repeat_rate orr
    WHERE cs.actual_check_in >= DATEADD(month, -12, CURRENT_DATE())
    GROUP BY cs.hotel_id, DATE(cs.actual_check_in), orr.repeat_stay_rate_pct
),
satisfaction_by_date AS (
    -- Aggregate satisfaction metrics by date (using check-in date)
    SELECT 
        cs.hotel_id,
        DATE(cs.actual_check_in) as performance_date,
        ROUND(AVG(cs.guest_satisfaction_score), 2) as satisfaction_index
    FROM BRONZE.stay_history cs
    WHERE cs.actual_check_in >= DATEADD(month, -12, CURRENT_DATE())
      AND cs.guest_satisfaction_score IS NOT NULL
    GROUP BY cs.hotel_id, DATE(cs.actual_check_in)
),
personalization_by_date AS (
    -- Aggregate personalization metrics by date (using check-in date)
    SELECT 
        cs.hotel_id,
        DATE(cs.actual_check_in) as performance_date,
        COUNT(DISTINCT CASE WHEN rp.preference_id IS NOT NULL THEN cs.stay_id END) as stays_with_preferences,
        COUNT(DISTINCT cs.stay_id) as total_stays,
        ROUND(stays_with_preferences * 100.0 / NULLIF(total_stays, 0), 2) as personalization_coverage_pct
    FROM BRONZE.stay_history cs
    LEFT JOIN BRONZE.room_preferences rp ON cs.guest_id = rp.guest_id
    WHERE cs.actual_check_in >= DATEADD(month, -12, CURRENT_DATE())
    GROUP BY cs.hotel_id, DATE(cs.actual_check_in)
),
service_cases_by_date AS (
    -- Aggregate service case metrics by date (using check-in date)
    SELECT 
        cs.hotel_id,
        DATE(cs.actual_check_in) as performance_date,
        COUNT(DISTINCT sc.case_id) as service_cases,
        COUNT(DISTINCT cs.stay_id) as total_stays,
        ROUND(service_cases * 1000.0 / NULLIF(total_stays, 0), 2) as service_case_rate_per_1000_stays
    FROM BRONZE.stay_history cs
    LEFT JOIN BRONZE.service_cases sc ON cs.stay_id = sc.stay_id
    WHERE cs.actual_check_in >= DATEADD(month, -12, CURRENT_DATE())
    GROUP BY cs.hotel_id, DATE(cs.actual_check_in)
),
sentiment_by_date AS (
    -- Aggregate sentiment scores by date
    SELECT 
        sd.hotel_id,
        DATE(sd.posted_at) as performance_date,
        ROUND(AVG(sd.sentiment_score), 1) as net_sentiment_score
    FROM BRONZE.sentiment_data sd
    WHERE sd.posted_at >= DATEADD(month, -12, CURRENT_DATE())
    GROUP BY sd.hotel_id, DATE(sd.posted_at)
)
SELECT 
    dp.*,
    COALESCE(rs.repeat_stay_rate_pct, 0) as repeat_stay_rate_pct,
    COALESCE(sm.satisfaction_index, 0) as satisfaction_index,
    COALESCE(pc.personalization_coverage_pct, 0) as personalization_coverage_pct,
    COALESCE(scr.service_case_rate_per_1000_stays, 0) as service_case_rate_per_1000_stays,
    COALESCE(ss.net_sentiment_score, 0) as net_sentiment_score,
    CURRENT_TIMESTAMP() as refreshed_at
FROM daily_performance dp
LEFT JOIN repeat_stays_by_date rs ON dp.hotel_id = rs.hotel_id AND dp.performance_date = rs.performance_date
LEFT JOIN satisfaction_by_date sm ON dp.hotel_id = sm.hotel_id AND dp.performance_date = sm.performance_date
LEFT JOIN personalization_by_date pc ON dp.hotel_id = pc.hotel_id AND dp.performance_date = pc.performance_date
LEFT JOIN service_cases_by_date scr ON dp.hotel_id = scr.hotel_id AND dp.performance_date = scr.performance_date
LEFT JOIN sentiment_by_date ss ON dp.hotel_id = ss.hotel_id AND dp.performance_date = ss.performance_date
WHERE dp.rooms_occupied > 0 OR dp.performance_date >= DATEADD(day, -30, CURRENT_DATE());

-- ----------------------------------------------------------------------------
-- Experience Service Signals (CX and service quality metrics)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE experience_service_signals AS
WITH service_metrics AS (
    SELECT 
        hp.hotel_id,
        hp.brand,
        hp.category,
        hp.region,
        hp.city,
        hp.country,
        hp.sub_region,
        COUNT(DISTINCT sc.case_id) as total_service_cases,
        COUNT(DISTINCT cs.stay_id) as total_stays,
        ROUND(total_service_cases * 1000.0 / NULLIF(total_stays, 0), 2) as service_case_rate,
        ROUND(AVG(sc.resolution_time_minutes) / 60.0, 2) as avg_resolution_time_hours,
        COUNT(DISTINCT CASE WHEN sc.severity IN ('high', 'critical') THEN sc.case_id END) as critical_cases
    FROM BRONZE.hotel_properties hp
    LEFT JOIN BRONZE.stay_history cs ON hp.hotel_id = cs.hotel_id 
        AND cs.actual_check_in >= DATEADD(day, -30, CURRENT_DATE())
    LEFT JOIN BRONZE.service_cases sc ON cs.stay_id = sc.stay_id
    GROUP BY hp.hotel_id, hp.brand, hp.category, hp.region, hp.city, hp.country, hp.sub_region
),
sentiment_analysis AS (
    SELECT 
        sd.hotel_id,
        COUNT(DISTINCT CASE WHEN sd.sentiment_label = 'negative' THEN sd.sentiment_id END) as negative_sentiments,
        COUNT(DISTINCT sd.sentiment_id) as total_sentiments,
        ROUND(negative_sentiments * 100.0 / NULLIF(total_sentiments, 0), 2) as negative_sentiment_rate_pct,
        ROUND(AVG(sd.sentiment_score), 1) as avg_sentiment_score
    FROM BRONZE.sentiment_data sd
    WHERE sd.posted_at >= DATEADD(day, -30, CURRENT_DATE())
    GROUP BY sd.hotel_id
),
service_recovery AS (
    SELECT 
        sra.hotel_id,
        COUNT(DISTINCT CASE WHEN sra.guest_response = 'accepted' THEN sra.recovery_id END) as successful_recoveries,
        COUNT(DISTINCT sra.recovery_id) as total_recovery_attempts,
        ROUND(successful_recoveries * 100.0 / NULLIF(total_recovery_attempts, 0), 2) as service_recovery_success_pct
    FROM BRONZE.service_recovery_actions sra
    WHERE sra.offered_at >= DATEADD(day, -30, CURRENT_DATE())
    GROUP BY sra.hotel_id
),
at_risk_guests AS (
    SELECT 
        hp.hotel_id,
        COUNT(DISTINCT CASE 
            WHEN sp.at_risk_flag 
             AND g360.lifetime_value > 10000 
            THEN sp.guest_id 
        END) as at_risk_high_value_guests_count
    FROM BRONZE.hotel_properties hp
    LEFT JOIN SILVER.sentiment_processed sp ON hp.hotel_id = sp.hotel_id
    LEFT JOIN (
        SELECT 
            guest_id,
            SUM(total_charges) as lifetime_value
        FROM BRONZE.stay_history
        GROUP BY guest_id
    ) g360 ON sp.guest_id = g360.guest_id
    WHERE sp.posted_at >= DATEADD(day, -30, CURRENT_DATE())
    GROUP BY hp.hotel_id
),
vip_watchlist AS (
    SELECT 
        hp.hotel_id,
        COUNT(DISTINCT CASE 
            WHEN sce.is_vip 
             AND sce.case_count_last_90_days >= 2 
            THEN sce.guest_id 
        END) as vip_watchlist_count
    FROM BRONZE.hotel_properties hp
    LEFT JOIN SILVER.service_cases_enriched sce ON hp.hotel_id = sce.hotel_id
    WHERE sce.reported_at >= DATEADD(day, -30, CURRENT_DATE())
    GROUP BY hp.hotel_id
),
issue_drivers AS (
    SELECT 
        it.hotel_id,
        ARRAY_AGG(DISTINCT it.issue_driver) WITHIN GROUP (ORDER BY it.issue_driver) as top_issue_drivers
    FROM BRONZE.issue_tracking it
    JOIN BRONZE.service_cases sc ON it.case_id = sc.case_id
    WHERE sc.reported_at >= DATEADD(day, -30, CURRENT_DATE())
    GROUP BY it.hotel_id
)
SELECT 
    sm.*,
    COALESCE(sa.negative_sentiment_rate_pct, 0) as negative_sentiment_rate_pct,
    COALESCE(sa.avg_sentiment_score, 0) as avg_sentiment_score,
    COALESCE(sr.service_recovery_success_pct, 0) as service_recovery_success_pct,
    COALESCE(arg.at_risk_high_value_guests_count, 0) as at_risk_high_value_guests_count,
    COALESCE(vw.vip_watchlist_count, 0) as vip_watchlist_count,
    id.top_issue_drivers[0]::STRING as top_issue_driver_1,
    id.top_issue_drivers[1]::STRING as top_issue_driver_2,
    id.top_issue_drivers[2]::STRING as top_issue_driver_3,
    CURRENT_TIMESTAMP() as refreshed_at
FROM service_metrics sm
LEFT JOIN sentiment_analysis sa ON sm.hotel_id = sa.hotel_id
LEFT JOIN service_recovery sr ON sm.hotel_id = sr.hotel_id
LEFT JOIN at_risk_guests arg ON sm.hotel_id = arg.hotel_id
LEFT JOIN vip_watchlist vw ON sm.hotel_id = vw.hotel_id
LEFT JOIN issue_drivers id ON sm.hotel_id = id.hotel_id;

-- ----------------------------------------------------------------------------
-- Loyalty Segment Intelligence (Loyalty metrics by tier + guest type)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE loyalty_segment_intelligence AS
WITH guest_stay_stats AS (
    -- Get stay statistics for each guest
    SELECT 
        sh.guest_id,
        COUNT(DISTINCT sh.stay_id) as stay_count,
        SUM(sh.total_charges) as total_spend,
        AVG(sh.total_charges) as avg_spend_per_stay,
        SUM(sh.room_charges) as room_revenue,
        MAX(sh.actual_check_out) as last_stay_date
    FROM BRONZE.stay_history sh
    GROUP BY sh.guest_id
),
loyalty_with_stays AS (
    -- Join ALL loyalty members with their stay stats (LEFT JOIN = includes members without stays)
    SELECT 
        lp.guest_id,
        lp.tier_level,
        'Leisure' as guest_type,  -- Simplified: all guests categorized as Leisure
        COALESCE(gss.stay_count, 0) as stay_count,
        COALESCE(gss.total_spend, 0) as total_spend,
        COALESCE(gss.avg_spend_per_stay, 0) as avg_spend_per_stay,
        COALESCE(gss.room_revenue, 0) as room_revenue,
        gss.last_stay_date,
        CASE 
            WHEN COALESCE(gss.stay_count, 0) >= 2 THEN 1 
            ELSE 0 
        END as is_repeat_guest
    FROM BRONZE.loyalty_program lp
    LEFT JOIN guest_stay_stats gss ON lp.guest_id = gss.guest_id
),
segment_metrics AS (
    -- Aggregate by tier + guest type
    SELECT 
        tier_level || ' - ' || guest_type as segment,
        tier_level as loyalty_tier,
        guest_type,
        COUNT(DISTINCT guest_id) as active_members,
        SUM(is_repeat_guest) as repeat_guests,
        ROUND(SUM(is_repeat_guest) * 100.0 / COUNT(DISTINCT guest_id), 2) as repeat_rate_pct,
        ROUND(AVG(CASE WHEN stay_count > 0 THEN avg_spend_per_stay ELSE 0 END), 0) as avg_spend_per_stay,
        ROUND(SUM(total_spend), 2) as total_revenue,
        -- Revenue mix breakdown
        ROUND(SUM(room_revenue) * 100.0 / NULLIF(SUM(total_spend), 0), 1) as room_revenue_pct,
        ROUND(SUM(total_spend - room_revenue) * 100.0 / NULLIF(SUM(total_spend), 0), 1) as other_revenue_pct
    FROM loyalty_with_stays
    GROUP BY tier_level, guest_type
),
amenity_affinity AS (
    -- Find top amenity per segment
    SELECT 
        lp.tier_level || ' - Leisure' as segment,
        au.amenity_category,
        COUNT(*) as usage_count,
        ROW_NUMBER() OVER (PARTITION BY lp.tier_level 
            ORDER BY COUNT(*) DESC) as rank
    FROM BRONZE.loyalty_program lp
    LEFT JOIN BRONZE.amenity_usage au ON lp.guest_id = au.guest_id
    GROUP BY lp.tier_level, au.amenity_category
)
SELECT 
    sm.segment,
    sm.loyalty_tier,
    sm.guest_type,
    sm.active_members,
    sm.repeat_guests,
    sm.repeat_rate_pct,
    sm.avg_spend_per_stay,
    sm.total_revenue,
    sm.room_revenue_pct,
    -- Amenity/incidental revenue breakdown (approximate)
    ROUND((100 - sm.room_revenue_pct) * 0.50, 1) as amenity_revenue_pct,
    ROUND((100 - sm.room_revenue_pct) * 0.30, 1) as fb_revenue_pct,
    ROUND((100 - sm.room_revenue_pct) * 0.15, 1) as spa_revenue_pct,
    ROUND((100 - sm.room_revenue_pct) * 0.05, 1) as other_revenue_pct,
    '' as top_friction_driver,  -- Placeholder
    0.00 as issue_rate_pct,  -- Placeholder
    COALESCE(aa.amenity_category, 'dining') as experience_affinity,
    'Engagement & Retention' as recommended_focus,
    CASE 
        WHEN sm.repeat_rate_pct < 30 THEN 'Dining Experiences'
        WHEN aa.amenity_category IN ('pool', 'spa') THEN 'Wellness Services'
        ELSE 'Premium Amenities'
    END as underutilized_opportunity,
    CURRENT_TIMESTAMP() as refreshed_at
FROM segment_metrics sm
LEFT JOIN amenity_affinity aa ON sm.segment = aa.segment AND aa.rank = 1;

-- Add non-member segment
INSERT INTO loyalty_segment_intelligence
WITH non_member_stats AS (
    SELECT 
        gp.guest_id,
        'Leisure' as guest_type,  -- Simplified: all guests categorized as Leisure
        COUNT(DISTINCT sh.stay_id) as stay_count,
        SUM(sh.total_charges) as total_spend,
        AVG(sh.total_charges) as avg_spend_per_stay,
        SUM(sh.room_charges) as room_revenue,
        CASE WHEN COUNT(DISTINCT sh.stay_id) >= 2 THEN 1 ELSE 0 END as is_repeat_guest
    FROM BRONZE.guest_profiles gp
    LEFT JOIN BRONZE.stay_history sh ON gp.guest_id = sh.guest_id
    WHERE gp.guest_id NOT IN (SELECT guest_id FROM BRONZE.loyalty_program)
    GROUP BY gp.guest_id
),
non_member_metrics AS (
    SELECT 
        'Non-Member - ' || guest_type as segment,
        'Non-Member' as loyalty_tier,
        guest_type,
        COUNT(DISTINCT guest_id) as active_members,
        SUM(is_repeat_guest) as repeat_guests,
        ROUND(SUM(is_repeat_guest) * 100.0 / COUNT(DISTINCT guest_id), 2) as repeat_rate_pct,
        ROUND(AVG(CASE WHEN stay_count > 0 THEN avg_spend_per_stay ELSE 0 END), 0) as avg_spend_per_stay,
        ROUND(SUM(total_spend), 2) as total_revenue,
        ROUND(SUM(room_revenue) * 100.0 / NULLIF(SUM(total_spend), 0), 1) as room_revenue_pct
    FROM non_member_stats
    GROUP BY guest_type
)
SELECT 
    nm.segment,
    nm.loyalty_tier,
    nm.guest_type,
    nm.active_members,
    nm.repeat_guests,
    nm.repeat_rate_pct,
    nm.avg_spend_per_stay,
    nm.total_revenue,
    nm.room_revenue_pct,
    ROUND((100 - nm.room_revenue_pct) * 0.50, 1) as amenity_revenue_pct,
    ROUND((100 - nm.room_revenue_pct) * 0.30, 1) as fb_revenue_pct,
    ROUND((100 - nm.room_revenue_pct) * 0.15, 1) as spa_revenue_pct,
    ROUND((100 - nm.room_revenue_pct) * 0.05, 1) as other_revenue_pct,
    '' as top_friction_driver,
    0.00 as issue_rate_pct,
    'bar' as experience_affinity,
    'Engagement & Retention' as recommended_focus,
    'Dining Experiences' as underutilized_opportunity,
    CURRENT_TIMESTAMP() as refreshed_at
FROM non_member_metrics nm;

-- ============================================================================
-- Summary
-- ============================================================================
SELECT 'Silver and Gold layers refreshed successfully!' AS STATUS;
SELECT 
    '10 Silver tables rebuilt (7 core + 3 Intelligence Hub)' AS SILVER_RESULT,
    '6 Gold tables rebuilt (3 core + 3 Intelligence Hub)' AS GOLD_RESULT;

