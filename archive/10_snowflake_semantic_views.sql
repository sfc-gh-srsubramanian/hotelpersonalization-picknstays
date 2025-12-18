-- Hotel Personalization System - Snowflake Semantic Views
-- Creates semantic views following Snowflake's semantic model structure
-- Based on Snowflake semantic view documentation

USE DATABASE HOTEL_PERSONALIZATION;
USE SCHEMA SEMANTIC;

-- =====================================================
-- SEMANTIC VIEW 1: GUEST ANALYTICS
-- =====================================================

CREATE OR REPLACE SEMANTIC VIEW guest_analytics
COMMENT = 'Comprehensive guest analytics semantic view for personalization insights'
AS (
  -- Base tables
  TABLE guests (
    BASE_TABLE_DATABASE_NAME = 'HOTEL_PERSONALIZATION',
    BASE_TABLE_SCHEMA_NAME = 'GOLD',
    BASE_TABLE_NAME = 'guest_360_view',
    PRIMARY_KEY = ['guest_id'],
    COMMENT = 'Main table for guest data and analytics'
  ),
  
  TABLE bookings (
    BASE_TABLE_DATABASE_NAME = 'HOTEL_PERSONALIZATION',
    BASE_TABLE_SCHEMA_NAME = 'SILVER',
    BASE_TABLE_NAME = 'bookings_enriched',
    PRIMARY_KEY = ['booking_id'],
    COMMENT = 'Enriched booking transactions'
  ),
  
  TABLE stays (
    BASE_TABLE_DATABASE_NAME = 'HOTEL_PERSONALIZATION',
    BASE_TABLE_SCHEMA_NAME = 'SILVER',
    BASE_TABLE_NAME = 'stays_processed',
    PRIMARY_KEY = ['stay_id'],
    COMMENT = 'Processed stay records with satisfaction metrics'
  ),
  
  TABLE hotels (
    BASE_TABLE_DATABASE_NAME = 'HOTEL_PERSONALIZATION',
    BASE_TABLE_SCHEMA_NAME = 'BRONZE',
    BASE_TABLE_NAME = 'hotel_properties',
    PRIMARY_KEY = ['hotel_id'],
    COMMENT = 'Hotel property information'
  ),
  
  -- Relationships
  RELATIONSHIP guest_to_bookings (
    TABLE = bookings,
    REF_TABLE = guests,
    FOREIGN_KEY = ['guest_id'],
    REF_KEY = ['guest_id']
  ),
  
  RELATIONSHIP booking_to_stays (
    TABLE = stays,
    REF_TABLE = bookings,
    FOREIGN_KEY = ['booking_id'],
    REF_KEY = ['booking_id']
  ),
  
  RELATIONSHIP booking_to_hotels (
    TABLE = bookings,
    REF_TABLE = hotels,
    FOREIGN_KEY = ['hotel_id'],
    REF_KEY = ['hotel_id']
  ),
  
  -- Dimensions
  DIMENSION guest_name (
    TABLE = guests,
    EXPRESSION = CONCAT(guests.first_name, ' ', guests.last_name),
    DATA_TYPE = VARCHAR(100),
    SYNONYMS = ['customer name', 'full name', 'guest full name'],
    COMMENT = 'Full name of the guest'
  ),
  
  DIMENSION guest_segment (
    TABLE = guests,
    EXPRESSION = guests.customer_segment,
    DATA_TYPE = VARCHAR(50),
    SYNONYMS = ['customer category', 'guest category', 'segment'],
    COMMENT = 'Customer segmentation category'
  ),
  
  DIMENSION loyalty_tier (
    TABLE = guests,
    EXPRESSION = guests.loyalty_tier,
    DATA_TYPE = VARCHAR(20),
    SYNONYMS = ['loyalty level', 'tier level', 'membership tier'],
    COMMENT = 'Guest loyalty program tier'
  ),
  
  DIMENSION guest_generation (
    TABLE = guests,
    EXPRESSION = guests.generation,
    DATA_TYPE = VARCHAR(20),
    SYNONYMS = ['age group', 'demographic group'],
    COMMENT = 'Generational demographic of guest'
  ),
  
  DIMENSION hotel_brand (
    TABLE = hotels,
    EXPRESSION = hotels.brand,
    DATA_TYPE = VARCHAR(50),
    SYNONYMS = ['brand name', 'hotel chain'],
    COMMENT = 'Hotel brand or chain name'
  ),
  
  DIMENSION hotel_city (
    TABLE = hotels,
    EXPRESSION = hotels.city,
    DATA_TYPE = VARCHAR(100),
    SYNONYMS = ['location', 'city name', 'destination'],
    COMMENT = 'City where hotel is located'
  ),
  
  DIMENSION booking_channel (
    TABLE = bookings,
    EXPRESSION = bookings.booking_channel,
    DATA_TYPE = VARCHAR(50),
    SYNONYMS = ['channel', 'booking source', 'reservation channel'],
    COMMENT = 'Channel through which booking was made'
  ),
  
  DIMENSION room_type (
    TABLE = bookings,
    EXPRESSION = bookings.room_type,
    DATA_TYPE = VARCHAR(50),
    SYNONYMS = ['accommodation type', 'room category'],
    COMMENT = 'Type of room booked'
  ),
  
  -- Facts
  FACT total_revenue (
    TABLE = guests,
    EXPRESSION = guests.total_revenue,
    DATA_TYPE = NUMBER(12,2),
    COMMENT = 'Total lifetime revenue from guest'
  ),
  
  FACT booking_value (
    TABLE = bookings,
    EXPRESSION = bookings.total_amount,
    DATA_TYPE = NUMBER(10,2),
    COMMENT = 'Total value of individual booking'
  ),
  
  FACT stay_satisfaction (
    TABLE = stays,
    EXPRESSION = stays.guest_satisfaction_score,
    DATA_TYPE = NUMBER(2,1),
    COMMENT = 'Guest satisfaction score for stay (1-5 scale)'
  ),
  
  FACT nights_stayed (
    TABLE = bookings,
    EXPRESSION = bookings.num_nights,
    DATA_TYPE = NUMBER(3,0),
    COMMENT = 'Number of nights in booking'
  ),
  
  FACT advance_booking_days (
    TABLE = bookings,
    EXPRESSION = bookings.advance_booking_days,
    DATA_TYPE = NUMBER(4,0),
    COMMENT = 'Days between booking and check-in'
  ),
  
  FACT incidental_charges (
    TABLE = stays,
    EXPRESSION = stays.incidental_charges,
    DATA_TYPE = NUMBER(10,2),
    COMMENT = 'Additional charges during stay'
  ),
  
  -- Metrics
  METRIC average_booking_value (
    TABLE = guests,
    EXPRESSION = AVG(bookings.total_amount),
    DATA_TYPE = NUMBER(10,2),
    COMMENT = 'Average booking value per guest'
  ),
  
  METRIC average_satisfaction_score (
    TABLE = guests,
    EXPRESSION = AVG(stays.guest_satisfaction_score),
    DATA_TYPE = NUMBER(3,2),
    COMMENT = 'Average satisfaction score across all stays'
  ),
  
  METRIC total_bookings (
    TABLE = guests,
    EXPRESSION = COUNT(bookings.booking_id),
    DATA_TYPE = NUMBER(10,0),
    COMMENT = 'Total number of bookings per guest'
  ),
  
  METRIC completed_stays (
    TABLE = guests,
    EXPRESSION = COUNT(stays.stay_id),
    DATA_TYPE = NUMBER(10,0),
    COMMENT = 'Total number of completed stays per guest'
  ),
  
  METRIC revenue_per_night (
    TABLE = bookings,
    EXPRESSION = bookings.total_amount / bookings.num_nights,
    DATA_TYPE = NUMBER(10,2),
    COMMENT = 'Revenue per night for booking'
  ),
  
  METRIC guest_lifetime_value (
    TABLE = guests,
    EXPRESSION = SUM(bookings.total_amount),
    DATA_TYPE = NUMBER(12,2),
    COMMENT = 'Total lifetime value of guest'
  ),
  
  METRIC satisfaction_trend (
    TABLE = guests,
    EXPRESSION = (MAX(stays.guest_satisfaction_score) - MIN(stays.guest_satisfaction_score)),
    DATA_TYPE = NUMBER(2,1),
    COMMENT = 'Trend in satisfaction scores over time'
  )
);

-- =====================================================
-- SEMANTIC VIEW 2: PERSONALIZATION INSIGHTS
-- =====================================================

CREATE OR REPLACE SEMANTIC VIEW personalization_insights
COMMENT = 'Personalization readiness and recommendation insights'
AS (
  -- Base tables
  TABLE personalization (
    BASE_TABLE_DATABASE_NAME = 'HOTEL_PERSONALIZATION',
    BASE_TABLE_SCHEMA_NAME = 'GOLD',
    BASE_TABLE_NAME = 'personalization_scores',
    PRIMARY_KEY = ['guest_id'],
    COMMENT = 'Guest personalization scores and propensities'
  ),
  
  TABLE preferences (
    BASE_TABLE_DATABASE_NAME = 'HOTEL_PERSONALIZATION',
    BASE_TABLE_SCHEMA_NAME = 'SILVER',
    BASE_TABLE_NAME = 'preferences_consolidated',
    PRIMARY_KEY = ['guest_id'],
    COMMENT = 'Consolidated guest preferences'
  ),
  
  TABLE engagement (
    BASE_TABLE_DATABASE_NAME = 'HOTEL_PERSONALIZATION',
    BASE_TABLE_SCHEMA_NAME = 'SILVER',
    BASE_TABLE_NAME = 'engagement_metrics',
    PRIMARY_KEY = ['guest_id'],
    COMMENT = 'Social media engagement metrics'
  ),
  
  -- Relationships
  RELATIONSHIP personalization_to_preferences (
    TABLE = preferences,
    REF_TABLE = personalization,
    FOREIGN_KEY = ['guest_id'],
    REF_KEY = ['guest_id']
  ),
  
  RELATIONSHIP personalization_to_engagement (
    TABLE = engagement,
    REF_TABLE = personalization,
    FOREIGN_KEY = ['guest_id'],
    REF_KEY = ['guest_id']
  ),
  
  -- Dimensions
  DIMENSION customer_segment (
    TABLE = personalization,
    EXPRESSION = personalization.customer_segment,
    DATA_TYPE = VARCHAR(50),
    SYNONYMS = ['guest segment', 'customer category'],
    COMMENT = 'Customer segmentation category'
  ),
  
  DIMENSION room_preference (
    TABLE = preferences,
    EXPRESSION = preferences.room_type_preference,
    DATA_TYPE = VARCHAR(50),
    SYNONYMS = ['preferred room type', 'room category preference'],
    COMMENT = 'Guest preferred room type'
  ),
  
  DIMENSION temperature_category (
    TABLE = preferences,
    EXPRESSION = preferences.temperature_category,
    DATA_TYPE = VARCHAR(20),
    SYNONYMS = ['temperature preference', 'climate preference'],
    COMMENT = 'Guest temperature preference category'
  ),
  
  DIMENSION engagement_level (
    TABLE = engagement,
    EXPRESSION = engagement.engagement_level,
    DATA_TYPE = VARCHAR(20),
    SYNONYMS = ['social activity level', 'digital engagement'],
    COMMENT = 'Level of social media engagement'
  ),
  
  DIMENSION sentiment_category (
    TABLE = engagement,
    EXPRESSION = engagement.overall_sentiment,
    DATA_TYPE = VARCHAR(20),
    SYNONYMS = ['sentiment', 'social sentiment', 'brand sentiment'],
    COMMENT = 'Overall social media sentiment'
  ),
  
  -- Facts
  FACT personalization_readiness_score (
    TABLE = personalization,
    EXPRESSION = personalization.personalization_readiness_score,
    DATA_TYPE = NUMBER(5,2),
    COMMENT = 'Score indicating readiness for personalization (0-100)'
  ),
  
  FACT upsell_propensity_score (
    TABLE = personalization,
    EXPRESSION = personalization.upsell_propensity_score,
    DATA_TYPE = NUMBER(5,2),
    COMMENT = 'Propensity to purchase upsells (0-100)'
  ),
  
  FACT loyalty_propensity_score (
    TABLE = personalization,
    EXPRESSION = personalization.loyalty_propensity_score,
    DATA_TYPE = NUMBER(5,2),
    COMMENT = 'Propensity to remain loyal (0-100)'
  ),
  
  FACT preference_completeness (
    TABLE = preferences,
    EXPRESSION = preferences.preference_completeness_score,
    DATA_TYPE = NUMBER(3,0),
    COMMENT = 'Completeness of guest preferences (0-7)'
  ),
  
  FACT social_activities (
    TABLE = engagement,
    EXPRESSION = engagement.total_activities,
    DATA_TYPE = NUMBER(8,0),
    COMMENT = 'Total social media activities'
  ),
  
  FACT hotel_mentions (
    TABLE = engagement,
    EXPRESSION = engagement.hotel_mentions,
    DATA_TYPE = NUMBER(6,0),
    COMMENT = 'Number of hotel mentions in social media'
  ),
  
  -- Metrics
  METRIC average_personalization_readiness (
    TABLE = personalization,
    EXPRESSION = AVG(personalization.personalization_readiness_score),
    DATA_TYPE = NUMBER(5,2),
    COMMENT = 'Average personalization readiness across guests'
  ),
  
  METRIC high_upsell_potential_guests (
    TABLE = personalization,
    EXPRESSION = COUNT(CASE WHEN personalization.upsell_propensity_score >= 70 THEN 1 END),
    DATA_TYPE = NUMBER(10,0),
    COMMENT = 'Number of guests with high upsell potential'
  ),
  
  METRIC preference_completion_rate (
    TABLE = preferences,
    EXPRESSION = AVG(preferences.preference_completeness_score / 7.0 * 100),
    DATA_TYPE = NUMBER(5,2),
    COMMENT = 'Average preference completion rate as percentage'
  ),
  
  METRIC social_engagement_rate (
    TABLE = engagement,
    EXPRESSION = COUNT(CASE WHEN engagement.engagement_level IN ('High', 'Medium') THEN 1 END) / COUNT(*) * 100,
    DATA_TYPE = NUMBER(5,2),
    COMMENT = 'Percentage of guests with medium to high social engagement'
  ),
  
  METRIC positive_sentiment_rate (
    TABLE = engagement,
    EXPRESSION = COUNT(CASE WHEN engagement.overall_sentiment = 'Positive' THEN 1 END) / COUNT(*) * 100,
    DATA_TYPE = NUMBER(5,2),
    COMMENT = 'Percentage of guests with positive social sentiment'
  )
);

-- =====================================================
-- SEMANTIC VIEW 3: REVENUE OPTIMIZATION
-- =====================================================

CREATE OR REPLACE SEMANTIC VIEW revenue_optimization
COMMENT = 'Revenue optimization and business performance metrics'
AS (
  -- Base tables
  TABLE business_metrics (
    BASE_TABLE_DATABASE_NAME = 'HOTEL_PERSONALIZATION',
    BASE_TABLE_SCHEMA_NAME = 'GOLD',
    BASE_TABLE_NAME = 'business_metrics',
    PRIMARY_KEY = ['metric_month', 'hotel_id'],
    COMMENT = 'Monthly business performance metrics by hotel'
  ),
  
  TABLE recommendation_features (
    BASE_TABLE_DATABASE_NAME = 'HOTEL_PERSONALIZATION',
    BASE_TABLE_SCHEMA_NAME = 'GOLD',
    BASE_TABLE_NAME = 'recommendation_features',
    PRIMARY_KEY = ['guest_id'],
    COMMENT = 'Features for recommendation engine'
  ),
  
  -- Dimensions
  DIMENSION metric_month (
    TABLE = business_metrics,
    EXPRESSION = business_metrics.metric_month,
    DATA_TYPE = DATE,
    SYNONYMS = ['month', 'reporting month', 'period'],
    COMMENT = 'Month for which metrics are calculated'
  ),
  
  DIMENSION hotel_name (
    TABLE = business_metrics,
    EXPRESSION = business_metrics.hotel_name,
    DATA_TYPE = VARCHAR(100),
    SYNONYMS = ['property name', 'hotel property'],
    COMMENT = 'Name of the hotel property'
  ),
  
  DIMENSION brand_name (
    TABLE = business_metrics,
    EXPRESSION = business_metrics.brand,
    DATA_TYPE = VARCHAR(50),
    SYNONYMS = ['hotel brand', 'chain'],
    COMMENT = 'Hotel brand or chain'
  ),
  
  DIMENSION preferred_cuisine (
    TABLE = recommendation_features,
    EXPRESSION = recommendation_features.preferred_cuisine_1,
    DATA_TYPE = VARCHAR(50),
    SYNONYMS = ['cuisine preference', 'food preference'],
    COMMENT = 'Guest preferred cuisine type'
  ),
  
  -- Facts
  FACT monthly_revenue (
    TABLE = business_metrics,
    EXPRESSION = business_metrics.total_revenue,
    DATA_TYPE = NUMBER(12,2),
    COMMENT = 'Total revenue for the month'
  ),
  
  FACT monthly_bookings (
    TABLE = business_metrics,
    EXPRESSION = business_metrics.total_bookings,
    DATA_TYPE = NUMBER(8,0),
    COMMENT = 'Total bookings for the month'
  ),
  
  FACT unique_guests (
    TABLE = business_metrics,
    EXPRESSION = business_metrics.unique_guests,
    DATA_TYPE = NUMBER(8,0),
    COMMENT = 'Number of unique guests for the month'
  ),
  
  FACT vip_guests (
    TABLE = business_metrics,
    EXPRESSION = business_metrics.vip_guests,
    DATA_TYPE = NUMBER(6,0),
    COMMENT = 'Number of VIP guests for the month'
  ),
  
  FACT average_daily_rate (
    TABLE = business_metrics,
    EXPRESSION = business_metrics.avg_daily_rate,
    DATA_TYPE = NUMBER(8,2),
    COMMENT = 'Average daily rate for the month'
  ),
  
  FACT satisfaction_rate (
    TABLE = business_metrics,
    EXPRESSION = business_metrics.satisfaction_rate,
    DATA_TYPE = NUMBER(5,2),
    COMMENT = 'Guest satisfaction rate percentage'
  ),
  
  -- Metrics
  METRIC revenue_per_guest (
    TABLE = business_metrics,
    EXPRESSION = business_metrics.total_revenue / business_metrics.unique_guests,
    DATA_TYPE = NUMBER(10,2),
    COMMENT = 'Revenue per unique guest'
  ),
  
  METRIC vip_guest_percentage (
    TABLE = business_metrics,
    EXPRESSION = business_metrics.vip_guests / business_metrics.unique_guests * 100,
    DATA_TYPE = NUMBER(5,2),
    COMMENT = 'Percentage of guests who are VIP'
  ),
  
  METRIC loyalty_penetration (
    TABLE = business_metrics,
    EXPRESSION = business_metrics.loyalty_penetration_rate,
    DATA_TYPE = NUMBER(5,2),
    COMMENT = 'Loyalty program penetration rate'
  ),
  
  METRIC personalization_readiness_rate (
    TABLE = business_metrics,
    EXPRESSION = business_metrics.high_personalization_ready_rate,
    DATA_TYPE = NUMBER(5,2),
    COMMENT = 'Percentage of guests ready for personalization'
  ),
  
  METRIC incidental_revenue (
    TABLE = business_metrics,
    EXPRESSION = business_metrics.total_incidental_revenue,
    DATA_TYPE = NUMBER(10,2),
    COMMENT = 'Total incidental revenue for the month'
  )
);

-- =====================================================
-- VERIFICATION AND SAMPLE QUERIES
-- =====================================================

-- Verify semantic views were created
SHOW SEMANTIC VIEWS IN SCHEMA SEMANTIC;

-- Sample queries using semantic views
SELECT 'Semantic Views Created Successfully' as status;

-- Test query 1: Guest analytics
SELECT 
    guest_name,
    guest_segment,
    loyalty_tier,
    total_revenue,
    average_satisfaction_score
FROM guest_analytics
WHERE loyalty_tier IN ('Diamond', 'Gold')
LIMIT 10;

-- Test query 2: Personalization insights
SELECT 
    customer_segment,
    COUNT(*) as guest_count,
    AVG(personalization_readiness_score) as avg_readiness,
    AVG(upsell_propensity_score) as avg_upsell_propensity
FROM personalization_insights
GROUP BY customer_segment
ORDER BY avg_readiness DESC;

-- Test query 3: Revenue optimization
SELECT 
    brand_name,
    SUM(monthly_revenue) as total_revenue,
    AVG(satisfaction_rate) as avg_satisfaction,
    AVG(vip_guest_percentage) as avg_vip_percentage
FROM revenue_optimization
WHERE metric_month >= DATEADD(month, -6, CURRENT_DATE())
GROUP BY brand_name
ORDER BY total_revenue DESC;




