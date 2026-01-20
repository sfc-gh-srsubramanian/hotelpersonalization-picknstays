-- ============================================================================
-- Hotel Personalization - Semantic Views
-- ============================================================================
-- Creates Snowflake Semantic Views for natural language querying
-- Powers Snowflake Intelligence Agents with business-friendly interfaces
-- 
-- Semantic Views (6 total):
--   Core Guest & Personalization Views:
--   1. GUEST_ANALYTICS_VIEW - Comprehensive guest behavior and amenity usage
--   2. PERSONALIZATION_INSIGHTS_VIEW - AI scoring and upsell opportunities
--   3. AMENITY_ANALYTICS_VIEW - Unified amenity performance metrics
--   
--   Intelligence Hub Views (100 global properties):
--   4. PORTFOLIO_INTELLIGENCE_VIEW - Executive portfolio performance metrics
--   5. LOYALTY_INTELLIGENCE_VIEW - Loyalty segment intelligence & retention
--   6. CX_SERVICE_INTELLIGENCE_VIEW - Customer experience & service quality
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
    PUBLIC GUESTS.AMENITY_SPENDING_CATEGORY AS amenity_spending_category
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
-- 4. PORTFOLIO INTELLIGENCE SEMANTIC VIEW
-- ============================================================================
-- Executive portfolio performance metrics for natural language querying
-- Includes Intelligence Hub KPIs across 100 global properties
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW PORTFOLIO_INTELLIGENCE_VIEW
TABLES (
    PORTFOLIO_KPI AS GOLD.PORTFOLIO_PERFORMANCE_KPIS PRIMARY KEY (hotel_id, performance_date)
)
DIMENSIONS (
    PUBLIC PORTFOLIO_KPI.performance_date AS performance_date,
    PUBLIC PORTFOLIO_KPI.hotel_id AS hotel_id,
    PUBLIC PORTFOLIO_KPI.brand AS brand,
    PUBLIC PORTFOLIO_KPI.category AS category,
    PUBLIC PORTFOLIO_KPI.region AS region,
    PUBLIC PORTFOLIO_KPI.sub_region AS sub_region,
    PUBLIC PORTFOLIO_KPI.city AS city,
    PUBLIC PORTFOLIO_KPI.country AS country,
    PUBLIC PORTFOLIO_KPI.total_rooms AS total_rooms
)
METRICS (
    PUBLIC PORTFOLIO_KPI.occupancy_pct AS AVG(portfolio_kpi.occupancy_pct),
    PUBLIC PORTFOLIO_KPI.adr AS AVG(portfolio_kpi.adr),
    PUBLIC PORTFOLIO_KPI.revpar AS AVG(portfolio_kpi.revpar),
    PUBLIC PORTFOLIO_KPI.rooms_occupied AS SUM(portfolio_kpi.rooms_occupied),
    PUBLIC PORTFOLIO_KPI.total_revenue AS SUM(portfolio_kpi.total_revenue),
    PUBLIC PORTFOLIO_KPI.repeat_stay_rate_pct AS AVG(portfolio_kpi.repeat_stay_rate_pct),
    PUBLIC PORTFOLIO_KPI.satisfaction_index AS AVG(portfolio_kpi.satisfaction_index),
    PUBLIC PORTFOLIO_KPI.personalization_coverage_pct AS AVG(portfolio_kpi.personalization_coverage_pct),
    PUBLIC PORTFOLIO_KPI.service_case_rate_per_1000_stays AS AVG(portfolio_kpi.service_case_rate_per_1000_stays),
    PUBLIC PORTFOLIO_KPI.net_sentiment_score AS AVG(portfolio_kpi.net_sentiment_score)
)
COMMENT='Portfolio performance metrics for natural language querying. Includes occupancy, revenue, satisfaction, and operational KPIs across all properties and regions.';

-- ============================================================================
-- 5. LOYALTY INTELLIGENCE SEMANTIC VIEW
-- ============================================================================
-- Loyalty segment behavior, spend patterns, and retention intelligence
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW LOYALTY_INTELLIGENCE_VIEW
TABLES (
    LOYALTY_SEG AS GOLD.LOYALTY_SEGMENT_INTELLIGENCE PRIMARY KEY (segment)
)
DIMENSIONS (
    PUBLIC LOYALTY_SEG.segment AS segment,
    PUBLIC LOYALTY_SEG.loyalty_tier AS loyalty_tier,
    PUBLIC LOYALTY_SEG.guest_type AS guest_type,
    PUBLIC LOYALTY_SEG.top_friction_driver AS top_friction_driver,
    PUBLIC LOYALTY_SEG.recommended_focus AS recommended_focus,
    PUBLIC LOYALTY_SEG.experience_affinity AS experience_affinity,
    PUBLIC LOYALTY_SEG.underutilized_opportunity AS underutilized_opportunity
)
METRICS (
    PUBLIC LOYALTY_SEG.active_members AS SUM(loyalty_seg.active_members),
    PUBLIC LOYALTY_SEG.repeat_rate_pct AS AVG(loyalty_seg.repeat_rate_pct),
    PUBLIC LOYALTY_SEG.avg_spend_per_stay AS AVG(loyalty_seg.avg_spend_per_stay),
    PUBLIC LOYALTY_SEG.total_revenue AS SUM(loyalty_seg.total_revenue),
    PUBLIC LOYALTY_SEG.room_revenue_pct AS AVG(loyalty_seg.room_revenue_pct),
    PUBLIC LOYALTY_SEG.fb_revenue_pct AS AVG(loyalty_seg.fb_revenue_pct),
    PUBLIC LOYALTY_SEG.spa_revenue_pct AS AVG(loyalty_seg.spa_revenue_pct),
    PUBLIC LOYALTY_SEG.other_revenue_pct AS AVG(loyalty_seg.other_revenue_pct)
)
COMMENT='Loyalty segment intelligence for understanding guest behavior, spend patterns, and retention strategies. Enables natural language queries about segment performance and opportunities.';

-- ============================================================================
-- 6. CX & SERVICE INTELLIGENCE SEMANTIC VIEW
-- ============================================================================
-- Customer experience, service quality, and at-risk guest intelligence
-- Includes city-level geographic analysis
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW CX_SERVICE_INTELLIGENCE_VIEW
TABLES (
    CX_SIGNALS AS GOLD.EXPERIENCE_SERVICE_SIGNALS PRIMARY KEY (hotel_id)
)
DIMENSIONS (
    PUBLIC CX_SIGNALS.hotel_id AS hotel_id,
    PUBLIC CX_SIGNALS.city AS city,
    PUBLIC CX_SIGNALS.country AS country,
    PUBLIC CX_SIGNALS.brand AS brand,
    PUBLIC CX_SIGNALS.region AS region,
    PUBLIC CX_SIGNALS.sub_region AS sub_region,
    PUBLIC CX_SIGNALS.top_issue_driver_1 AS top_issue_driver_1,
    PUBLIC CX_SIGNALS.top_issue_driver_2 AS top_issue_driver_2,
    PUBLIC CX_SIGNALS.top_issue_driver_3 AS top_issue_driver_3
)
METRICS (
    PUBLIC CX_SIGNALS.service_case_rate AS AVG(cx_signals.service_case_rate),
    PUBLIC CX_SIGNALS.avg_resolution_time_hours AS AVG(cx_signals.avg_resolution_time_hours),
    PUBLIC CX_SIGNALS.negative_sentiment_rate_pct AS AVG(cx_signals.negative_sentiment_rate_pct),
    PUBLIC CX_SIGNALS.avg_sentiment_score AS AVG(cx_signals.avg_sentiment_score),
    PUBLIC CX_SIGNALS.service_recovery_success_pct AS AVG(cx_signals.service_recovery_success_pct),
    PUBLIC CX_SIGNALS.at_risk_high_value_guests_count AS SUM(cx_signals.at_risk_high_value_guests_count),
    PUBLIC CX_SIGNALS.vip_watchlist_count AS SUM(cx_signals.vip_watchlist_count)
)
COMMENT='Customer experience and service operational intelligence. Tracks service quality, sentiment, recovery effectiveness, and at-risk guest identification by city, country, brand, and region for last 30 days.';

-- =====================================================================
-- 7. GUEST_SENTIMENT_INTELLIGENCE_VIEW (Guest-level sentiment trends)
-- Purpose: Individual guest sentiment tracking for churn risk and VIP monitoring
-- Enables queries like "high-value guests with declining sentiment"
-- =====================================================================

CREATE OR REPLACE SEMANTIC VIEW GUEST_SENTIMENT_INTELLIGENCE_VIEW
TABLES (
    SENTIMENT AS BRONZE.SENTIMENT_DATA PRIMARY KEY (sentiment_id),
    STAYS AS BRONZE.STAY_HISTORY PRIMARY KEY (stay_id),
    GUESTS AS BRONZE.GUEST_PROFILES PRIMARY KEY (guest_id)
)
RELATIONSHIPS (
    SENTIMENT_TO_GUEST AS SENTIMENT(guest_id) REFERENCES GUESTS(guest_id),
    SENTIMENT_TO_STAY AS SENTIMENT(stay_id) REFERENCES STAYS(stay_id)
)
DIMENSIONS (
    PUBLIC SENTIMENT.guest_id AS guest_id,
    PUBLIC SENTIMENT.hotel_id AS hotel_id,
    PUBLIC SENTIMENT.source AS source,
    PUBLIC SENTIMENT.sentiment_label AS sentiment_label,
    PUBLIC SENTIMENT.platform AS platform,
    PUBLIC SENTIMENT.posted_at AS posted_at,
    PUBLIC GUESTS.nationality AS nationality,
    PUBLIC GUESTS.language_preference AS language_preference,
    PUBLIC STAYS.actual_check_in AS actual_check_in
)
METRICS (
    PUBLIC SENTIMENT.sentiment_score AS AVG(SENTIMENT.sentiment_score),
    PUBLIC SENTIMENT.sentiment_id AS COUNT(SENTIMENT.sentiment_id),
    PUBLIC STAYS.total_charges AS SUM(STAYS.total_charges),
    PUBLIC STAYS.stay_id AS COUNT(DISTINCT STAYS.stay_id)
)
COMMENT='Guest-level sentiment tracking over time. Enables trend analysis, churn risk identification, and VIP sentiment monitoring. Query by guest, loyalty tier, hotel, or time period to identify declining sentiment patterns.';

-- =====================================================================
-- 8. GUEST_ARRIVALS_VIEW (Future bookings with service history)
-- Purpose: Natural language access to upcoming arrivals with VIP/service context
-- =====================================================================

CREATE OR REPLACE SEMANTIC VIEW GUEST_ARRIVALS_VIEW
TABLES (
    BOOKINGS AS BRONZE.BOOKING_HISTORY PRIMARY KEY (booking_id),
    GUESTS AS BRONZE.GUEST_PROFILES PRIMARY KEY (guest_id),
    PROPERTIES AS BRONZE.HOTEL_PROPERTIES PRIMARY KEY (hotel_id),
    SERVICE_CASES AS BRONZE.SERVICE_CASES PRIMARY KEY (case_id)
)
RELATIONSHIPS (
    BOOKINGS_TO_GUESTS AS BOOKINGS(guest_id) REFERENCES GUESTS(guest_id),
    BOOKINGS_TO_HOTELS AS BOOKINGS(hotel_id) REFERENCES PROPERTIES(hotel_id),
    SERVICE_TO_GUESTS AS SERVICE_CASES(guest_id) REFERENCES GUESTS(guest_id)
)
DIMENSIONS (
    PUBLIC BOOKINGS.booking_id AS booking_id,
    PUBLIC BOOKINGS.guest_id AS guest_id,
    PUBLIC BOOKINGS.hotel_id AS hotel_id,
    PUBLIC BOOKINGS.check_in_date AS check_in_date,
    PUBLIC BOOKINGS.check_out_date AS check_out_date,
    PUBLIC BOOKINGS.booking_date AS booking_date,
    PUBLIC BOOKINGS.booking_status AS booking_status,
    PUBLIC BOOKINGS.booking_channel AS booking_channel,
    PUBLIC BOOKINGS.room_type AS room_type,
    PUBLIC GUESTS.first_name AS first_name,
    PUBLIC GUESTS.last_name AS last_name,
    PUBLIC GUESTS.email AS email,
    PUBLIC GUESTS.nationality AS nationality,
    PUBLIC PROPERTIES.hotel_name AS hotel_name,
    PUBLIC PROPERTIES.brand AS brand,
    PUBLIC PROPERTIES.city AS city,
    PUBLIC PROPERTIES.country AS country,
    PUBLIC PROPERTIES.region AS region,
    PUBLIC PROPERTIES.sub_region AS sub_region
)
METRICS (
    PUBLIC BOOKINGS.num_nights AS SUM(BOOKINGS.num_nights),
    PUBLIC BOOKINGS.num_adults AS SUM(BOOKINGS.num_adults),
    PUBLIC BOOKINGS.num_children AS SUM(BOOKINGS.num_children),
    PUBLIC BOOKINGS.total_amount AS SUM(BOOKINGS.total_amount),
    PUBLIC BOOKINGS.advance_booking_days AS AVG(BOOKINGS.advance_booking_days)
)
COMMENT='Future guest arrivals (confirmed bookings) with loyalty status, service history, and property context. Enables VIP watchlist queries, service recovery planning, and proactive personalized service preparation for upcoming arrivals.';

-- =====================================================================
-- 9. GUEST_PREFERENCES_VIEW (Room & Service Preferences)
-- Purpose: Natural language access to guest preferences for personalization
-- Enables queries like "What are the most common pillow preferences for Diamond guests?"
-- =====================================================================

CREATE OR REPLACE SEMANTIC VIEW GUEST_PREFERENCES_VIEW
TABLES (
    PREFS AS GOLD.PREFERENCES_CONSOLIDATED PRIMARY KEY (guest_id),
    GUESTS AS BRONZE.GUEST_PROFILES PRIMARY KEY (guest_id)
)
RELATIONSHIPS (
    PREFS_TO_GUESTS AS PREFS(guest_id) REFERENCES GUESTS(guest_id)
)
DIMENSIONS (
    PUBLIC PREFS.guest_id AS guest_id,
    PUBLIC GUESTS.first_name AS first_name,
    PUBLIC GUESTS.last_name AS last_name,
    PUBLIC GUESTS.nationality AS nationality,
    PUBLIC GUESTS.language_preference AS language_preference,
    PUBLIC PREFS.room_type_preference AS room_type_preference,
    PUBLIC PREFS.floor_preference AS floor_preference,
    PUBLIC PREFS.view_preference AS view_preference,
    PUBLIC PREFS.bed_type_preference AS bed_type_preference,
    PUBLIC PREFS.smoking_preference AS smoking_preference,
    PUBLIC PREFS.accessibility_needs AS accessibility_needs,
    PUBLIC PREFS.temperature_category AS temperature_category,
    PUBLIC PREFS.lighting_preference AS lighting_preference,
    PUBLIC PREFS.pillow_type_preference AS pillow_type_preference,
    PUBLIC PREFS.noise_level_preference AS noise_level_preference,
    PUBLIC PREFS.preferred_communication_method AS communication_method,
    PUBLIC PREFS.last_updated AS preference_last_updated
)
METRICS (
    PUBLIC PREFS.temperature_preference AS AVG(PREFS.temperature_preference),
    PUBLIC PREFS.preference_completeness_score AS AVG(PREFS.preference_completeness_score),
    PUBLIC PREFS.guest_id AS COUNT(DISTINCT PREFS.guest_id)
)
COMMENT='Guest room and service preferences for personalized experiences. Track preferences by loyalty tier, nationality, and demographics. Query pillow types, room preferences, temperature settings, and communication methods for targeted service delivery.';

-- ============================================================================
-- Summary
-- ============================================================================
SELECT 'All semantic views created successfully!' AS STATUS;
SELECT 
    '9 semantic views: Guest Analytics, Personalization, Amenity Analytics, Portfolio Intelligence, Loyalty Intelligence, CX & Service Intelligence, Guest Sentiment Intelligence, Guest Arrivals, Guest Preferences' AS VIEWS_CREATED,
    'Ready for Intelligence Agents setup' AS NEXT_STEP;

