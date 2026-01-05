-- ============================================================================
-- Hotel Personalization - Refresh Silver and Gold Layers (Step 4b)
-- ============================================================================
-- Rebuilds Silver and Gold tables after Bronze data is loaded
-- Run this AFTER 03_data_generation.sql (Step 4) to populate Silver and Gold layers
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
    sh.room_type,
    sh.floor_number,
    sh.view_type,
    sh.bed_type,
    sh.total_charges,
    sh.room_charges,
    sh.tax_amount,
    sh.incidental_charges,
    sh.no_show,
    sh.early_departure,
    sh.late_checkout,
    sh.housekeeping_notes,
    sh.maintenance_requests,
    sh.created_at,
    sh.updated_at,
    DATEDIFF(hour, sh.actual_check_in, sh.actual_check_out) / 24.0 as actual_nights,
    CASE 
        WHEN sh.no_show THEN 'No Show'
        WHEN sh.early_departure THEN 'Early Departure'
        WHEN sh.late_checkout THEN 'Late Checkout'
        ELSE 'Normal'
    END as stay_category,
    ROUND(sh.total_charges / NULLIF(DATEDIFF(day, sh.actual_check_in, sh.actual_check_out), 0), 2) as avg_daily_charges,
    CASE 
        WHEN sh.incidental_charges > (sh.room_charges * 0.5) THEN 'High Spender'
        WHEN sh.incidental_charges > (sh.room_charges * 0.2) THEN 'Moderate Spender'
        WHEN sh.incidental_charges > 0 THEN 'Light Spender'
        ELSE 'No Extras'
    END as spending_category,
    CURRENT_TIMESTAMP() as processed_at
FROM BRONZE.stay_history sh;

-- ----------------------------------------------------------------------------
-- Preferences Consolidated (Guest preferences aggregated)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE preferences_consolidated AS
SELECT 
    gp.guest_id,
    gp.preference_category,
    LISTAGG(gp.preference_value, ', ') WITHIN GROUP (ORDER BY gp.preference_value) as preferences,
    COUNT(DISTINCT gp.preference_value) as preference_count,
    MAX(gp.last_updated) as last_preference_update,
    CURRENT_TIMESTAMP() as processed_at
FROM BRONZE.guest_preferences gp
GROUP BY gp.guest_id, gp.preference_category;

-- ----------------------------------------------------------------------------
-- Engagement Metrics (Guest engagement scores)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE engagement_metrics AS
SELECT 
    ga.guest_id,
    ga.activity_type,
    COUNT(*) as activity_count,
    MAX(ga.activity_date) as last_activity_date,
    MIN(ga.activity_date) as first_activity_date,
    DATEDIFF(day, MIN(ga.activity_date), MAX(ga.activity_date)) as engagement_span_days,
    CASE 
        WHEN MAX(ga.activity_date) > DATEADD(month, -1, CURRENT_DATE()) THEN 'Active'
        WHEN MAX(ga.activity_date) > DATEADD(month, -3, CURRENT_DATE()) THEN 'Moderate'
        WHEN MAX(ga.activity_date) > DATEADD(month, -6, CURRENT_DATE()) THEN 'Low'
        ELSE 'Dormant'
    END as engagement_level,
    CURRENT_TIMESTAMP() as processed_at
FROM BRONZE.guest_activity ga
GROUP BY ga.guest_id, ga.activity_type;

-- ----------------------------------------------------------------------------
-- Amenity Spending Enriched (Amenity transactions with categorization)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE amenity_spending_enriched AS
SELECT
    at.transaction_id,
    at.guest_id,
    at.hotel_id,
    at.stay_id,
    at.amenity_category,
    at.amenity_type,
    at.amenity_name,
    at.amenity_location,
    at.transaction_date,
    at.quantity,
    at.unit_price,
    at.amount,
    at.currency,
    at.payment_method,
    at.staff_member,
    at.guest_satisfaction,
    at.notes,
    at.created_at,
    CASE 
        WHEN at.amenity_category = 'spa' THEN 'Wellness'
        WHEN at.amenity_category IN ('restaurant', 'bar', 'room_service') THEN 'Food & Beverage'
        WHEN at.amenity_category IN ('wifi', 'smart_tv') THEN 'Technology'
        WHEN at.amenity_category = 'pool_services' THEN 'Recreation'
        ELSE 'Other'
    END as service_group,
    CASE 
        WHEN HOUR(at.transaction_date) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(at.transaction_date) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(at.transaction_date) BETWEEN 18 AND 22 THEN 'Evening'
        ELSE 'Late Night'
    END as time_of_day,
    DAYOFWEEK(at.transaction_date) as day_of_week,
    CASE 
        WHEN DAYOFWEEK(at.transaction_date) IN (6, 7) THEN TRUE 
        ELSE FALSE 
    END as is_weekend,
    CURRENT_TIMESTAMP() as processed_at
FROM BRONZE.amenity_transactions at;

-- ----------------------------------------------------------------------------
-- Amenity Usage Enriched (Infrastructure amenity usage with metrics)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TABLE amenity_usage_enriched AS
SELECT
    au.usage_id,
    au.guest_id,
    au.hotel_id,
    au.stay_id,
    au.amenity_category,
    au.amenity_type,
    au.usage_start_time,
    au.usage_end_time,
    au.usage_duration_minutes,
    au.usage_type,
    au.device_id,
    au.data_consumed_mb,
    au.content_category,
    au.guest_satisfaction,
    au.technical_issues,
    au.created_at,
    CASE 
        WHEN au.amenity_category = 'wifi' THEN 'Connectivity'
        WHEN au.amenity_category = 'smart_tv' THEN 'Entertainment'
        WHEN au.amenity_category = 'pool' THEN 'Recreation'
        ELSE 'Other'
    END as usage_group,
    CASE 
        WHEN HOUR(au.usage_start_time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(au.usage_start_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(au.usage_start_time) BETWEEN 18 AND 22 THEN 'Evening'
        ELSE 'Late Night'
    END as time_of_day,
    ROUND(au.usage_duration_minutes / 60.0, 2) as usage_hours,
    CASE 
        WHEN au.usage_duration_minutes < 30 THEN 'Short Session'
        WHEN au.usage_duration_minutes < 120 THEN 'Medium Session'
        ELSE 'Long Session'
    END as session_length_category,
    CURRENT_TIMESTAMP() as processed_at
FROM BRONZE.amenity_usage au;

-- ============================================================================
-- GOLD LAYER: Rebuild Analytics Tables
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
    COALESCE(COUNT(DISTINCT be.booking_id), 0) as total_bookings,
    COALESCE(SUM(be.total_amount), 0) as total_revenue,
    COALESCE(AVG(be.total_amount), 0) as avg_booking_value,
    COALESCE(AVG(be.num_nights), 0) as avg_stay_length,
    CASE 
        WHEN COALESCE(SUM(be.total_amount), 0) >= 10000 THEN 'High Value'
        WHEN COALESCE(SUM(be.total_amount), 0) >= 5000 THEN 'Premium'
        WHEN COALESCE(COUNT(DISTINCT be.booking_id), 0) >= 5 THEN 'Regular'
        WHEN COALESCE(SUM(be.total_amount), 0) >= 1000 THEN 'Developing'
        ELSE 'New Guest'
    END as customer_segment,
    CASE 
        WHEN MAX(be.check_in_date) IS NULL THEN 'Unknown'
        WHEN DATEDIFF(day, MAX(be.check_in_date), CURRENT_DATE()) > 365 THEN 'High Risk'
        WHEN DATEDIFF(day, MAX(be.check_in_date), CURRENT_DATE()) > 180 THEN 'Medium Risk'
        WHEN DATEDIFF(day, MAX(be.check_in_date), CURRENT_DATE()) > 90 THEN 'Low Risk'
        ELSE 'Active'
    END as churn_risk,
    g.marketing_opt_in,
    COALESCE(SUM(ase.amount), 0) as total_amenity_spend,
    COALESCE(AVG(ase.amount), 0) as avg_amenity_per_transaction,
    COALESCE(SUM(CASE WHEN ase.amenity_category = 'spa' THEN ase.amount ELSE 0 END), 0) as total_spa_spend,
    COALESCE(SUM(CASE WHEN ase.amenity_category = 'restaurant' THEN ase.amount ELSE 0 END), 0) as total_restaurant_spend,
    COALESCE(SUM(CASE WHEN ase.amenity_category = 'bar' THEN ase.amount ELSE 0 END), 0) as total_bar_spend,
    COALESCE(SUM(CASE WHEN ase.amenity_category = 'room_service' THEN ase.amount ELSE 0 END), 0) as total_room_service_spend,
    COALESCE(SUM(CASE WHEN ase.amenity_category = 'wifi' THEN ase.amount ELSE 0 END), 0) as total_wifi_spend,
    COALESCE(SUM(CASE WHEN ase.amenity_category = 'smart_tv' THEN ase.amount ELSE 0 END), 0) as total_smart_tv_spend,
    COALESCE(SUM(CASE WHEN ase.amenity_category = 'pool_services' THEN ase.amount ELSE 0 END), 0) as total_pool_services_spend,
    COUNT(DISTINCT CASE WHEN ase.amenity_category = 'spa' THEN ase.transaction_id END) as spa_visits,
    COUNT(DISTINCT CASE WHEN ase.amenity_category = 'bar' THEN ase.transaction_id END) as bar_visits,
    COUNT(DISTINCT CASE WHEN ase.amenity_category = 'restaurant' THEN ase.transaction_id END) as restaurant_visits,
    COUNT(DISTINCT CASE WHEN ase.amenity_category = 'room_service' THEN ase.transaction_id END) as room_service_orders,
    COUNT(DISTINCT CASE WHEN ase.amenity_category = 'wifi' THEN ase.transaction_id END) as wifi_upgrades,
    COUNT(DISTINCT CASE WHEN ase.amenity_category = 'smart_tv' THEN ase.transaction_id END) as smart_tv_upgrades,
    COUNT(DISTINCT CASE WHEN ase.amenity_category = 'pool_services' THEN ase.transaction_id END) as pool_service_purchases,
    COUNT(DISTINCT ase.amenity_category) as amenity_diversity_score,
    COALESCE(AVG(ase.guest_satisfaction), 0) as avg_amenity_satisfaction,
    COALESCE(COUNT(DISTINCT CASE WHEN aue.amenity_category = 'wifi' THEN aue.usage_id END), 0) as total_wifi_sessions,
    COALESCE(COUNT(DISTINCT CASE WHEN aue.amenity_category = 'smart_tv' THEN aue.usage_id END), 0) as total_smart_tv_sessions,
    COALESCE(COUNT(DISTINCT CASE WHEN aue.amenity_category = 'pool' THEN aue.usage_id END), 0) as total_pool_sessions,
    COALESCE(AVG(CASE WHEN aue.amenity_category = 'wifi' THEN aue.usage_duration_minutes END), 0) as avg_wifi_duration,
    COALESCE(AVG(CASE WHEN aue.amenity_category = 'smart_tv' THEN aue.usage_duration_minutes END), 0) as avg_smart_tv_duration,
    COALESCE(AVG(CASE WHEN aue.amenity_category = 'pool' THEN aue.usage_duration_minutes END), 0) as avg_pool_duration,
    COALESCE(SUM(CASE WHEN aue.amenity_category = 'wifi' THEN aue.data_consumed_mb END), 0) as total_wifi_data_mb,
    COALESCE(AVG(CASE WHEN aue.amenity_category IN ('wifi', 'smart_tv', 'pool') THEN aue.guest_satisfaction END), 0) as avg_infrastructure_satisfaction,
    CASE 
        WHEN COUNT(DISTINCT CASE WHEN aue.amenity_category = 'wifi' AND aue.usage_type = 'paid' THEN aue.usage_id END) > 0 THEN 'Premium Tech User'
        WHEN COUNT(DISTINCT CASE WHEN aue.amenity_category IN ('wifi', 'smart_tv') THEN aue.usage_id END) > 5 THEN 'High Tech User'
        WHEN COUNT(DISTINCT CASE WHEN aue.amenity_category IN ('wifi', 'smart_tv') THEN aue.usage_id END) > 0 THEN 'Basic Tech User'
        ELSE 'Non-Tech User'
    END as tech_adoption_profile,
    LEAST(100, GREATEST(0, 
        (COUNT(DISTINCT CASE WHEN aue.amenity_category IN ('wifi', 'smart_tv', 'pool') THEN aue.usage_id END) * 5) + 
        (COALESCE(AVG(CASE WHEN aue.amenity_category IN ('wifi', 'smart_tv', 'pool') THEN aue.usage_duration_minutes END), 0) / 10) + 
        (COUNT(DISTINCT CASE WHEN aue.usage_type = 'paid' THEN aue.usage_id END) * 15)
    )) as infrastructure_engagement_score,
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
        ase.amenity_category,
        ase.amenity_type,
        ase.amenity_location,
        ase.service_group,
        COUNT(DISTINCT ase.transaction_id) as total_transactions,
        COUNT(DISTINCT ase.guest_id) as unique_guests,
        SUM(ase.amount) as total_revenue,
        AVG(ase.amount) as avg_transaction_value,
        AVG(ase.guest_satisfaction) as avg_satisfaction,
        COUNT(CASE WHEN ase.guest_satisfaction >= 4 THEN 1 END)::FLOAT / NULLIF(COUNT(*), 0) as satisfaction_rate,
        SUM(ase.quantity) as total_quantity_sold
    FROM SILVER.amenity_spending_enriched ase
    GROUP BY 1,2,3,4
),
usage_metrics AS (
    SELECT
        aue.amenity_category,
        aue.amenity_type,
        aue.usage_group,
        COUNT(DISTINCT aue.usage_id) as total_sessions,
        COUNT(DISTINCT aue.guest_id) as unique_users,
        AVG(aue.usage_duration_minutes) as avg_session_duration,
        SUM(aue.usage_duration_minutes) as total_usage_minutes,
        AVG(aue.guest_satisfaction) as avg_satisfaction,
        SUM(aue.data_consumed_mb) as total_data_consumed_mb,
        COUNT(CASE WHEN aue.technical_issues THEN 1 END)::FLOAT / NULLIF(COUNT(*), 0) as technical_issue_rate
    FROM SILVER.amenity_usage_enriched aue
    GROUP BY 1,2,3
)
SELECT
    COALESCE(tm.amenity_category, um.amenity_category) as amenity_category,
    COALESCE(tm.amenity_type, um.amenity_type) as amenity_type,
    tm.amenity_location,
    COALESCE(tm.service_group, um.usage_group) as service_group,
    tm.total_transactions,
    tm.unique_guests as transaction_unique_guests,
    tm.total_revenue,
    tm.avg_transaction_value,
    tm.total_quantity_sold,
    um.total_sessions as usage_sessions,
    um.unique_users as usage_unique_guests,
    um.avg_session_duration,
    um.total_usage_minutes,
    um.total_data_consumed_mb,
    um.technical_issue_rate,
    COALESCE(tm.avg_satisfaction, um.avg_satisfaction) as overall_satisfaction,
    tm.satisfaction_rate as transaction_satisfaction_rate,
    CASE 
        WHEN COALESCE(tm.total_revenue, 0) > 10000 AND COALESCE(tm.avg_satisfaction, 0) >= 4 THEN 'Star Performer'
        WHEN COALESCE(tm.total_revenue, 0) > 10000 THEN 'High Revenue'
        WHEN COALESCE(tm.avg_satisfaction, 0) >= 4 THEN 'High Satisfaction'
        WHEN COALESCE(tm.total_transactions, um.total_sessions, 0) > 100 THEN 'High Volume'
        ELSE 'Standard'
    END as performance_category,
    CURRENT_TIMESTAMP() as processed_at
FROM transaction_metrics tm
FULL OUTER JOIN usage_metrics um 
    ON tm.amenity_category = um.amenity_category 
    AND tm.amenity_type = um.amenity_type;

-- ============================================================================
-- Summary
-- ============================================================================
SELECT 'Silver and Gold layers refreshed successfully!' AS STATUS;
SELECT 
    '7 Silver tables rebuilt with fresh Bronze data' AS SILVER_RESULT,
    '3 Gold tables rebuilt with aggregated metrics' AS GOLD_RESULT;

