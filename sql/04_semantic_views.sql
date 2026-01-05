-- ============================================================================
-- Hotel Personalization - Semantic Views
-- ============================================================================
-- Creates Snowflake Semantic Views for natural language querying
-- Powers Snowflake Intelligence Agents with business-friendly interfaces
-- 
-- Semantic Views:
--   1. GUEST_ANALYTICS_VIEW - Comprehensive guest behavior and amenity usage
--   2. PERSONALIZATION_INSIGHTS_VIEW - AI scoring and upsell opportunities
--   3. AMENITY_ANALYTICS - Unified amenity performance metrics
-- 
-- Session variables (set by deploy.sh):
--   $FULL_PREFIX, $PROJECT_ROLE
-- ============================================================================

USE ROLE IDENTIFIER($PROJECT_ROLE);
USE DATABASE IDENTIFIER($FULL_PREFIX);
USE SCHEMA SEMANTIC_VIEWS;

-- ============================================================================
-- 1. GUEST ANALYTICS SEMANTIC VIEW
-- ============================================================================
-- Comprehensive guest profiles with amenity spending and infrastructure usage
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW GUEST_ANALYTICS_VIEW
TABLES (
    GUESTS AS GOLD.GUEST_360_VIEW_ENHANCED PRIMARY KEY (GUEST_ID)
)
DIMENSIONS (
    PUBLIC GUESTS.FIRST_NAME AS first_name,
    PUBLIC GUESTS.LAST_NAME AS last_name,
    PUBLIC GUESTS.GENERATION AS generation,
    PUBLIC GUESTS.GENDER AS gender,
    PUBLIC GUESTS.NATIONALITY AS nationality,
    PUBLIC GUESTS.LANGUAGE_PREFERENCE AS language_preference,
    PUBLIC GUESTS.LOYALTY_TIER AS loyalty_tier,
    PUBLIC GUESTS.CUSTOMER_SEGMENT AS customer_segment,
    PUBLIC GUESTS.CHURN_RISK AS churn_risk,
    PUBLIC GUESTS.TECH_ADOPTION_PROFILE AS tech_adoption_profile,
    PUBLIC GUESTS.AMENITY_SPENDING_CATEGORY AS amenity_spending_category
)
METRICS (
    PUBLIC GUESTS.TOTAL_BOOKINGS AS COUNT(guests.guest_id),
    PUBLIC GUESTS.TOTAL_REVENUE AS SUM(guests.total_revenue),
    PUBLIC GUESTS.AVG_BOOKING_VALUE AS AVG(guests.avg_booking_value),
    PUBLIC GUESTS.AVG_STAY_LENGTH AS AVG(guests.avg_stay_length),
    PUBLIC GUESTS.LOYALTY_POINTS AS SUM(guests.loyalty_points),
    PUBLIC GUESTS.TOTAL_AMENITY_SPEND AS SUM(guests.total_amenity_spend),
    PUBLIC GUESTS.TOTAL_SPA_SPEND AS SUM(guests.total_spa_spend),
    PUBLIC GUESTS.TOTAL_RESTAURANT_SPEND AS SUM(guests.total_restaurant_spend),
    PUBLIC GUESTS.TOTAL_BAR_SPEND AS SUM(guests.total_bar_spend),
    PUBLIC GUESTS.TOTAL_ROOM_SERVICE_SPEND AS SUM(guests.total_room_service_spend),
    PUBLIC GUESTS.TOTAL_WIFI_SPEND AS SUM(guests.total_wifi_spend),
    PUBLIC GUESTS.TOTAL_SMART_TV_SPEND AS SUM(guests.total_smart_tv_spend),
    PUBLIC GUESTS.TOTAL_POOL_SERVICES_SPEND AS SUM(guests.total_pool_services_spend),
    PUBLIC GUESTS.SPA_VISITS AS SUM(guests.spa_visits),
    PUBLIC GUESTS.BAR_VISITS AS SUM(guests.bar_visits),
    PUBLIC GUESTS.RESTAURANT_VISITS AS SUM(guests.restaurant_visits),
    PUBLIC GUESTS.ROOM_SERVICE_ORDERS AS SUM(guests.room_service_orders),
    PUBLIC GUESTS.WIFI_UPGRADES AS SUM(guests.wifi_upgrades),
    PUBLIC GUESTS.SMART_TV_UPGRADES AS SUM(guests.smart_tv_upgrades),
    PUBLIC GUESTS.POOL_SERVICE_PURCHASES AS SUM(guests.pool_service_purchases),
    PUBLIC GUESTS.TOTAL_WIFI_SESSIONS AS SUM(guests.total_wifi_sessions),
    PUBLIC GUESTS.TOTAL_SMART_TV_SESSIONS AS SUM(guests.total_smart_tv_sessions),
    PUBLIC GUESTS.TOTAL_POOL_SESSIONS AS SUM(guests.total_pool_sessions),
    PUBLIC GUESTS.AVG_WIFI_DURATION AS AVG(guests.avg_wifi_duration),
    PUBLIC GUESTS.AVG_SMART_TV_DURATION AS AVG(guests.avg_smart_tv_duration),
    PUBLIC GUESTS.AVG_POOL_DURATION AS AVG(guests.avg_pool_duration),
    PUBLIC GUESTS.TOTAL_WIFI_DATA_MB AS SUM(guests.total_wifi_data_mb),
    PUBLIC GUESTS.INFRASTRUCTURE_ENGAGEMENT_SCORE AS AVG(guests.infrastructure_engagement_score),
    PUBLIC GUESTS.AMENITY_DIVERSITY_SCORE AS AVG(guests.amenity_diversity_score),
    PUBLIC GUESTS.AVG_AMENITY_SATISFACTION AS AVG(guests.avg_amenity_satisfaction),
    PUBLIC GUESTS.AVG_INFRASTRUCTURE_SATISFACTION AS AVG(guests.avg_infrastructure_satisfaction)
);

-- ============================================================================
-- 2. PERSONALIZATION INSIGHTS SEMANTIC VIEW
-- ============================================================================
-- AI-powered personalization scores for upselling and loyalty management
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW PERSONALIZATION_INSIGHTS_VIEW
TABLES (
    SCORES AS GOLD.PERSONALIZATION_SCORES_ENHANCED PRIMARY KEY (GUEST_ID),
    GUESTS AS GOLD.GUEST_360_VIEW_ENHANCED PRIMARY KEY (GUEST_ID)
)
RELATIONSHIPS (
    SCORES_TO_GUESTS AS SCORES(GUEST_ID) REFERENCES GUESTS(GUEST_ID)
)
DIMENSIONS (
    PUBLIC GUESTS.FIRST_NAME AS first_name,
    PUBLIC GUESTS.LAST_NAME AS last_name,
    PUBLIC GUESTS.LOYALTY_TIER AS loyalty_tier,
    PUBLIC GUESTS.CUSTOMER_SEGMENT AS customer_segment,
    PUBLIC GUESTS.TECH_ADOPTION_PROFILE AS tech_adoption_profile,
    PUBLIC GUESTS.AMENITY_SPENDING_CATEGORY AS amenity_spending_category,
    PUBLIC SCORES.CUSTOMER_SEGMENT AS score_segment
)
METRICS (
    PUBLIC SCORES.PERSONALIZATION_READINESS_SCORE AS AVG(scores.personalization_readiness_score),
    PUBLIC SCORES.UPSELL_PROPENSITY_SCORE AS AVG(scores.upsell_propensity_score),
    PUBLIC SCORES.SPA_UPSELL_PROPENSITY AS AVG(scores.spa_upsell_propensity),
    PUBLIC SCORES.DINING_UPSELL_PROPENSITY AS AVG(scores.dining_upsell_propensity),
    PUBLIC SCORES.TECH_UPSELL_PROPENSITY AS AVG(scores.tech_upsell_propensity),
    PUBLIC SCORES.POOL_SERVICES_UPSELL_PROPENSITY AS AVG(scores.pool_services_upsell_propensity),
    PUBLIC SCORES.LOYALTY_PROPENSITY_SCORE AS AVG(scores.loyalty_propensity_score),
    PUBLIC SCORES.AMENITY_ENGAGEMENT_SCORE AS AVG(scores.amenity_engagement_score),
    PUBLIC SCORES.INFRASTRUCTURE_ENGAGEMENT_SCORE AS AVG(scores.infrastructure_engagement_score),
    PUBLIC GUESTS.TOTAL_AMENITY_SPEND AS SUM(guests.total_amenity_spend),
    PUBLIC GUESTS.TOTAL_WIFI_SESSIONS AS SUM(guests.total_wifi_sessions),
    PUBLIC GUESTS.TOTAL_SMART_TV_SESSIONS AS SUM(guests.total_smart_tv_sessions),
    PUBLIC GUESTS.TOTAL_POOL_SESSIONS AS SUM(guests.total_pool_sessions),
    PUBLIC GUESTS.AVG_AMENITY_SATISFACTION AS AVG(guests.avg_amenity_satisfaction),
    PUBLIC GUESTS.AVG_INFRASTRUCTURE_SATISFACTION AS AVG(guests.avg_infrastructure_satisfaction)
);

-- ============================================================================
-- 3. UNIFIED AMENITY ANALYTICS SEMANTIC VIEW
-- ============================================================================
-- Consolidated amenity performance metrics (transactions + usage)
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW AMENITY_ANALYTICS_VIEW
TABLES (
    AMENITIES AS GOLD.AMENITY_ANALYTICS PRIMARY KEY (METRIC_MONTH, AMENITY_CATEGORY, LOCATION)
)
DIMENSIONS (
    PUBLIC AMENITIES.AMENITY_CATEGORY AS amenity_category,
    PUBLIC AMENITIES.SERVICE_GROUP AS service_group,
    PUBLIC AMENITIES.LOCATION AS location,
    PUBLIC AMENITIES.METRIC_MONTH AS metric_month
)
METRICS (
    PUBLIC AMENITIES.TOTAL_REVENUE AS SUM(amenities.total_revenue),
    PUBLIC AMENITIES.TOTAL_TRANSACTIONS AS SUM(amenities.total_transactions),
    PUBLIC AMENITIES.UNIQUE_GUESTS AS SUM(amenities.unique_guests),
    PUBLIC AMENITIES.AVG_TRANSACTION_VALUE AS AVG(amenities.avg_transaction_value),
    PUBLIC AMENITIES.AVG_SATISFACTION AS AVG(amenities.avg_satisfaction),
    PUBLIC AMENITIES.SATISFACTION_RATE AS AVG(amenities.satisfaction_rate),
    PUBLIC AMENITIES.PREMIUM_SERVICE_RATE AS AVG(amenities.premium_service_rate),
    PUBLIC AMENITIES.TOTAL_USAGE_SESSIONS AS SUM(amenities.total_usage_sessions),
    PUBLIC AMENITIES.TOTAL_USAGE_MINUTES AS SUM(amenities.total_usage_minutes),
    PUBLIC AMENITIES.AVG_SESSION_DURATION AS AVG(amenities.avg_session_duration),
    PUBLIC AMENITIES.TOTAL_DATA_CONSUMED_MB AS SUM(amenities.total_data_consumed_mb)
);

-- ============================================================================
-- Summary
-- ============================================================================
SELECT 'Semantic views created successfully!' AS STATUS;
SELECT 
    'GUEST_ANALYTICS_VIEW, PERSONALIZATION_INSIGHTS_VIEW, AMENITY_ANALYTICS_VIEW' AS VIEWS_CREATED,
    'Ready for Intelligence Agents setup' AS NEXT_STEP;

