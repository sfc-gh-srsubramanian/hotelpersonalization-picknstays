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

USE ROLE IDENTIFIER($PROJECT_ROLE);
USE DATABASE IDENTIFIER($FULL_PREFIX);

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
    CURRENT_TIMESTAMP() as processed_at
FROM SILVER.guests_standardized g
LEFT JOIN BRONZE.loyalty_program lp ON g.guest_id = lp.guest_id
LEFT JOIN temp_booking_agg ba ON g.guest_id = ba.guest_id
LEFT JOIN temp_amenity_spend_agg ase ON g.guest_id = ase.guest_id
LEFT JOIN temp_amenity_usage_agg aue ON g.guest_id = aue.guest_id;

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
        (CASE WHEN g360.loyalty_tier IN ('Gold', 'Platinum', 'Diamond') THEN 20 ELSE 0 END) -
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
              WHEN g360.loyalty_tier = 'Platinum' THEN 15
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
SELECT 'Silver and Gold layers refreshed successfully!' AS STATUS;
SELECT 
    '7 Silver tables rebuilt with fresh Bronze data' AS SILVER_RESULT,
    '3 Gold tables rebuilt with aggregated metrics' AS GOLD_RESULT;

