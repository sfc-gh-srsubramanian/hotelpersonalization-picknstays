-- ============================================================================
-- Hotel Personalization System - Sample Queries
-- ============================================================================
-- Demonstrates key personalization use cases and business scenarios
-- All queries use actual tables from Bronze, Silver, and Gold layers
-- 
-- Note: Queries rewritten to match actual schema (Jan 2026)
-- ============================================================================

USE DATABASE IDENTIFIER($FULL_PREFIX);

-- ============================================================================
-- 1. GUEST PROFILING & SEGMENTATION
-- ============================================================================

-- Query: High-value guests with detailed profiles
SELECT 
    guest_id,
    first_name,
    last_name,
    email,
    age,
    generation,
    loyalty_tier,
    customer_segment,
    total_bookings,
    total_revenue,
    avg_booking_value,
    loyalty_points,
    churn_risk,
    tech_adoption_profile,
    amenity_spending_category
FROM GOLD.guest_360_view_enhanced
WHERE customer_segment IN ('High Value', 'Premium')
    AND marketing_opt_in = TRUE
ORDER BY total_revenue DESC
LIMIT 20;

-- Query: VIP guests requiring special attention
SELECT 
    g.guest_id,
    g.first_name,
    g.last_name,
    g.email,
    g.customer_segment,
    g.loyalty_tier,
    g.total_revenue,
    g.churn_risk,
    g.total_amenity_spend,
    pc.room_type_preference,
    pc.temperature_preference,
    pc.accessibility_needs,
    pc.preferred_check_in_time
FROM GOLD.guest_360_view_enhanced g
LEFT JOIN SILVER.preferences_consolidated pc ON g.guest_id = pc.guest_id
WHERE g.customer_segment IN ('High Value', 'Premium')
    AND g.total_bookings >= 3
ORDER BY g.total_revenue DESC
LIMIT 10;

-- ============================================================================
-- 2. PERSONALIZED UPSELL OPPORTUNITIES
-- ============================================================================

-- Query: Guests with high upsell potential for spa services
SELECT 
    g.guest_id,
    g.first_name,
    g.last_name,
    g.email,
    g.customer_segment,
    ps.spa_upsell_propensity,
    ps.upsell_propensity_score,
    g.total_spa_spend,
    g.spa_visits,
    CASE 
        WHEN ps.spa_upsell_propensity >= 70 THEN 'High Priority'
        WHEN ps.spa_upsell_propensity >= 50 THEN 'Medium Priority'
        ELSE 'Low Priority'
    END as upsell_priority,
    ROUND(g.avg_booking_value * 0.25, 2) as estimated_spa_revenue_potential
FROM GOLD.guest_360_view_enhanced g
JOIN GOLD.personalization_scores_enhanced ps ON g.guest_id = ps.guest_id
WHERE ps.spa_upsell_propensity >= 50
    AND g.marketing_opt_in = TRUE
ORDER BY ps.spa_upsell_propensity DESC, g.total_revenue DESC
LIMIT 25;

-- Query: Technology upsell opportunities (WiFi, Smart TV)
SELECT 
    g.guest_id,
    g.first_name,
    g.last_name,
    g.email,
    ps.tech_upsell_propensity,
    g.tech_adoption_profile,
    g.total_wifi_sessions,
    g.total_smart_tv_sessions,
    g.avg_wifi_duration,
    g.infrastructure_engagement_score,
    ROUND(ps.tech_upsell_propensity * g.avg_booking_value * 0.10, 2) as estimated_tech_revenue
FROM GOLD.guest_360_view_enhanced g
JOIN GOLD.personalization_scores_enhanced ps ON g.guest_id = ps.guest_id
WHERE ps.tech_upsell_propensity >= 60
    AND g.tech_adoption_profile IN ('High Tech User', 'Basic Tech User')
ORDER BY ps.tech_upsell_propensity DESC
LIMIT 20;

-- Query: Dining & food service upsell opportunities
SELECT 
    g.guest_id,
    g.first_name,
    g.last_name,
    ps.dining_upsell_propensity,
    g.total_restaurant_spend,
    g.restaurant_visits,
    g.total_bar_spend,
    g.bar_visits,
    g.total_room_service_spend,
    g.room_service_orders,
    ROUND(ps.dining_upsell_propensity * g.avg_booking_value * 0.20, 2) as estimated_dining_revenue,
    pc.dining_preferences
FROM GOLD.guest_360_view_enhanced g
JOIN GOLD.personalization_scores_enhanced ps ON g.guest_id = ps.guest_id
LEFT JOIN SILVER.preferences_consolidated pc ON g.guest_id = pc.guest_id
WHERE ps.dining_upsell_propensity >= 55
ORDER BY ps.dining_upsell_propensity DESC, g.total_revenue DESC
LIMIT 30;

-- ============================================================================
-- 3. CHURN PREVENTION & RETENTION
-- ============================================================================

-- Query: High-value guests at risk of churning
SELECT 
    g.guest_id,
    g.first_name,
    g.last_name,
    g.email,
    g.customer_segment,
    g.loyalty_tier,
    g.churn_risk,
    g.total_revenue,
    g.total_bookings,
    g.avg_amenity_satisfaction,
    g.avg_infrastructure_satisfaction,
    ps.loyalty_propensity_score,
    CASE 
        WHEN g.churn_risk = 'High Risk' THEN 'Immediate intervention required'
        WHEN g.churn_risk = 'Medium Risk' THEN 'Proactive outreach recommended'
        ELSE 'Monitor closely'
    END as intervention_level,
    pc.preferred_communication_method
FROM GOLD.guest_360_view_enhanced g
JOIN GOLD.personalization_scores_enhanced ps ON g.guest_id = ps.guest_id
LEFT JOIN SILVER.preferences_consolidated pc ON g.guest_id = pc.guest_id
WHERE g.churn_risk IN ('High Risk', 'Medium Risk')
    AND g.customer_segment IN ('High Value', 'Premium', 'Regular')
ORDER BY 
    CASE g.churn_risk 
        WHEN 'High Risk' THEN 1 
        WHEN 'Medium Risk' THEN 2 
        ELSE 3 
    END,
    g.total_revenue DESC
LIMIT 25;

-- Query: Loyalty program engagement opportunities
SELECT 
    g.guest_id,
    g.first_name,
    g.last_name,
    g.loyalty_tier,
    lp.points_balance,
    lp.lifetime_points,
    lp.tier_level,
    lp.tier_start_date,
    lp.points_to_next_tier,
    ps.loyalty_propensity_score,
    g.total_bookings,
    g.total_revenue,
    CASE 
        WHEN lp.points_to_next_tier <= 500 THEN 'Close to tier upgrade'
        WHEN ps.loyalty_propensity_score >= 70 THEN 'High engagement potential'
        ELSE 'Standard loyalty member'
    END as loyalty_opportunity
FROM GOLD.guest_360_view_enhanced g
JOIN BRONZE.loyalty_program lp ON g.guest_id = lp.guest_id
JOIN GOLD.personalization_scores_enhanced ps ON g.guest_id = ps.guest_id
WHERE g.marketing_opt_in = TRUE
ORDER BY ps.loyalty_propensity_score DESC, lp.points_to_next_tier ASC
LIMIT 30;

-- ============================================================================
-- 4. AMENITY PERFORMANCE ANALYTICS
-- ============================================================================

-- Query: Top performing amenities by revenue and satisfaction
SELECT 
    amenity_category,
    service_group,
    location,
    total_transactions,
    unique_guests,
    total_revenue,
    avg_transaction_value,
    avg_satisfaction,
    satisfaction_rate,
    premium_transactions,
    premium_service_rate,
    total_usage_sessions,
    avg_session_duration,
    CASE 
        WHEN total_revenue > 50000 AND satisfaction_rate >= 80 THEN 'Star Performer'
        WHEN total_revenue > 50000 THEN 'High Revenue'
        WHEN satisfaction_rate >= 80 THEN 'High Satisfaction'
        ELSE 'Standard'
    END as performance_tier
FROM GOLD.amenity_analytics
WHERE metric_month >= DATEADD(month, -3, CURRENT_DATE())
ORDER BY total_revenue DESC, satisfaction_rate DESC
LIMIT 20;

-- Query: Monthly amenity revenue trends
SELECT 
    metric_month,
    amenity_category,
    service_group,
    SUM(total_revenue) as monthly_revenue,
    SUM(total_transactions) as monthly_transactions,
    SUM(unique_guests) as monthly_unique_guests,
    AVG(avg_satisfaction) as avg_satisfaction,
    AVG(satisfaction_rate) as avg_satisfaction_rate
FROM GOLD.amenity_analytics
WHERE metric_month >= DATEADD(month, -6, CURRENT_DATE())
GROUP BY metric_month, amenity_category, service_group
ORDER BY metric_month DESC, monthly_revenue DESC
LIMIT 50;

-- Query: Amenity usage patterns by guest segment
SELECT 
    g.customer_segment,
    g.amenity_spending_category,
    COUNT(DISTINCT g.guest_id) as guest_count,
    AVG(g.total_amenity_spend) as avg_amenity_spend,
    AVG(g.amenity_diversity_score) as avg_diversity_score,
    AVG(g.spa_visits) as avg_spa_visits,
    AVG(g.restaurant_visits) as avg_restaurant_visits,
    AVG(g.bar_visits) as avg_bar_visits,
    AVG(g.total_wifi_sessions) as avg_wifi_sessions,
    AVG(g.avg_amenity_satisfaction) as avg_satisfaction
FROM GOLD.guest_360_view_enhanced g
WHERE g.total_amenity_spend > 0
GROUP BY g.customer_segment, g.amenity_spending_category
ORDER BY avg_amenity_spend DESC, guest_count DESC;

-- ============================================================================
-- 5. GUEST PREFERENCES & PERSONALIZATION
-- ============================================================================

-- Query: Room preference patterns for inventory management
SELECT 
    pc.room_type_preference,
    pc.floor_preference,
    pc.view_preference,
    pc.bed_type_preference,
    COUNT(DISTINCT pc.guest_id) as guest_count,
    AVG(g.avg_booking_value) as avg_booking_value,
    AVG(g.total_revenue) as avg_lifetime_value,
    COUNT(CASE WHEN g.customer_segment IN ('High Value', 'Premium') THEN 1 END) as high_value_count,
    AVG(pc.temperature_preference) as avg_temp_preference,
    AVG(pc.preference_completeness_score) as avg_profile_completeness
FROM SILVER.preferences_consolidated pc
JOIN GOLD.guest_360_view_enhanced g ON pc.guest_id = g.guest_id
WHERE pc.room_type_preference IS NOT NULL
    AND g.total_bookings >= 2
GROUP BY 
    pc.room_type_preference, 
    pc.floor_preference, 
    pc.view_preference, 
    pc.bed_type_preference
HAVING guest_count >= 3
ORDER BY high_value_count DESC, avg_lifetime_value DESC
LIMIT 25;

-- Query: Service preferences for operational planning
SELECT 
    'Spa Services' as service_category,
    COUNT(DISTINCT CASE WHEN ARRAY_SIZE(pc.spa_services) > 0 THEN pc.guest_id END) as interested_guests,
    AVG(ps.spa_upsell_propensity) as avg_upsell_propensity,
    SUM(g.spa_visits) as total_historical_visits,
    SUM(g.total_spa_spend) as total_historical_revenue,
    AVG(g.total_spa_spend) as avg_spend_per_guest
FROM SILVER.preferences_consolidated pc
JOIN GOLD.guest_360_view_enhanced g ON pc.guest_id = g.guest_id
JOIN GOLD.personalization_scores_enhanced ps ON pc.guest_id = ps.guest_id
WHERE pc.spa_services IS NOT NULL

UNION ALL

SELECT 
    'Fitness Services' as service_category,
    COUNT(DISTINCT CASE WHEN ARRAY_SIZE(pc.fitness_preferences) > 0 THEN pc.guest_id END) as interested_guests,
    AVG(ps.upsell_propensity_score) as avg_upsell_propensity,
    0 as total_historical_visits,
    0 as total_historical_revenue,
    AVG(g.total_amenity_spend) * 0.15 as avg_spend_per_guest
FROM SILVER.preferences_consolidated pc
JOIN GOLD.guest_360_view_enhanced g ON pc.guest_id = g.guest_id
JOIN GOLD.personalization_scores_enhanced ps ON pc.guest_id = ps.guest_id
WHERE pc.fitness_preferences IS NOT NULL

UNION ALL

SELECT 
    'Business Services' as service_category,
    COUNT(DISTINCT CASE WHEN ARRAY_SIZE(pc.business_services) > 0 THEN pc.guest_id END) as interested_guests,
    AVG(ps.tech_upsell_propensity) as avg_upsell_propensity,
    SUM(g.wifi_upgrades) as total_historical_visits,
    SUM(g.total_wifi_spend) as total_historical_revenue,
    AVG(g.total_wifi_spend) as avg_spend_per_guest
FROM SILVER.preferences_consolidated pc
JOIN GOLD.guest_360_view_enhanced g ON pc.guest_id = g.guest_id
JOIN GOLD.personalization_scores_enhanced ps ON pc.guest_id = ps.guest_id
WHERE pc.business_services IS NOT NULL

ORDER BY interested_guests DESC;

-- ============================================================================
-- 6. SOCIAL MEDIA SENTIMENT & ENGAGEMENT
-- ============================================================================

-- Query: Recent social media activity requiring attention
SELECT 
    g.guest_id,
    g.first_name,
    g.last_name,
    g.email,
    g.customer_segment,
    em.overall_sentiment,
    em.avg_sentiment,
    em.hotel_mentions,
    em.brand_mentions,
    em.total_engagement,
    em.platforms_used,
    em.last_activity_date,
    CASE 
        WHEN em.avg_sentiment < -0.3 THEN 'Immediate response required'
        WHEN em.avg_sentiment < 0 THEN 'Monitor and consider response'
        WHEN em.avg_sentiment > 0.5 AND em.hotel_mentions > 0 THEN 'Thank and amplify positive feedback'
        ELSE 'No immediate action needed'
    END as response_recommendation
FROM SILVER.engagement_metrics em
JOIN GOLD.guest_360_view_enhanced g ON em.guest_id = g.guest_id
WHERE em.last_activity_date >= DATEADD(day, -14, CURRENT_DATE())
    AND (em.hotel_mentions > 0 OR em.brand_mentions > 0)
ORDER BY 
    CASE 
        WHEN em.avg_sentiment < -0.3 THEN 1 
        WHEN em.avg_sentiment > 0.5 AND em.hotel_mentions > 0 THEN 2 
        ELSE 3 
    END,
    em.total_engagement DESC
LIMIT 30;

-- Query: Social media influencers (high engagement guests)
SELECT 
    g.guest_id,
    g.first_name,
    g.last_name,
    g.generation,
    g.customer_segment,
    em.total_activities,
    em.platforms_used,
    em.total_engagement,
    em.hotel_mentions,
    em.brand_mentions,
    em.overall_sentiment,
    em.posts_count,
    em.reviews_count,
    em.checkins_count
FROM SILVER.engagement_metrics em
JOIN GOLD.guest_360_view_enhanced g ON em.guest_id = g.guest_id
WHERE em.total_engagement >= 100
    AND em.overall_sentiment IN ('Positive', 'Neutral')
ORDER BY em.total_engagement DESC, g.total_revenue DESC
LIMIT 20;

-- ============================================================================
-- 7. OPERATIONAL INSIGHTS
-- ============================================================================

-- Query: Guest satisfaction trends by amenity category
SELECT 
    g.amenity_spending_category,
    g.customer_segment,
    COUNT(DISTINCT g.guest_id) as guest_count,
    AVG(g.avg_amenity_satisfaction) as avg_amenity_satisfaction,
    AVG(g.avg_infrastructure_satisfaction) as avg_infrastructure_satisfaction,
    AVG(g.total_amenity_spend) as avg_amenity_spend,
    AVG(g.amenity_diversity_score) as avg_diversity_score,
    SUM(CASE WHEN g.churn_risk IN ('High Risk', 'Medium Risk') THEN 1 ELSE 0 END) as at_risk_count
FROM GOLD.guest_360_view_enhanced g
GROUP BY g.amenity_spending_category, g.customer_segment
ORDER BY guest_count DESC, avg_amenity_satisfaction DESC;

-- Query: Technology adoption and engagement patterns
SELECT 
    g.tech_adoption_profile,
    g.generation,
    COUNT(DISTINCT g.guest_id) as guest_count,
    AVG(g.total_wifi_sessions) as avg_wifi_sessions,
    AVG(g.total_smart_tv_sessions) as avg_smart_tv_sessions,
    AVG(g.avg_wifi_duration) as avg_wifi_duration,
    AVG(g.infrastructure_engagement_score) as avg_engagement_score,
    AVG(g.total_wifi_spend) as avg_wifi_revenue,
    AVG(ps.tech_upsell_propensity) as avg_tech_upsell_score
FROM GOLD.guest_360_view_enhanced g
JOIN GOLD.personalization_scores_enhanced ps ON g.guest_id = ps.guest_id
GROUP BY g.tech_adoption_profile, g.generation
ORDER BY guest_count DESC, avg_engagement_score DESC;

-- Query: Booking patterns and revenue by customer segment
SELECT 
    g.customer_segment,
    g.churn_risk,
    COUNT(DISTINCT g.guest_id) as guest_count,
    AVG(g.total_bookings) as avg_bookings_per_guest,
    AVG(g.avg_booking_value) as avg_booking_value,
    AVG(g.avg_stay_length) as avg_stay_length,
    SUM(g.total_revenue) as total_revenue,
    AVG(g.total_revenue) as avg_lifetime_value,
    AVG(g.loyalty_points) as avg_loyalty_points,
    AVG(ps.personalization_readiness_score) as avg_personalization_readiness,
    AVG(ps.upsell_propensity_score) as avg_upsell_propensity
FROM GOLD.guest_360_view_enhanced g
JOIN GOLD.personalization_scores_enhanced ps ON g.guest_id = ps.guest_id
GROUP BY g.customer_segment, g.churn_risk
ORDER BY total_revenue DESC, guest_count DESC;

-- ============================================================================
-- 8. PERSONALIZATION READINESS DASHBOARD
-- ============================================================================

-- Query: Overall personalization metrics summary
SELECT 
    COUNT(DISTINCT g.guest_id) as total_guests,
    COUNT(DISTINCT CASE WHEN g.marketing_opt_in = TRUE THEN g.guest_id END) as marketing_opt_in_count,
    COUNT(DISTINCT CASE WHEN ps.personalization_readiness_score >= 70 THEN g.guest_id END) as high_readiness_guests,
    COUNT(DISTINCT CASE WHEN g.customer_segment IN ('High Value', 'Premium') THEN g.guest_id END) as high_value_guests,
    AVG(ps.personalization_readiness_score) as avg_personalization_readiness,
    AVG(ps.upsell_propensity_score) as avg_upsell_propensity,
    AVG(ps.loyalty_propensity_score) as avg_loyalty_propensity,
    AVG(g.total_revenue) as avg_lifetime_value,
    SUM(g.total_revenue) as total_revenue,
    AVG(g.avg_amenity_satisfaction) as avg_satisfaction
FROM GOLD.guest_360_view_enhanced g
JOIN GOLD.personalization_scores_enhanced ps ON g.guest_id = ps.guest_id;

-- Query: Personalization opportunity breakdown by segment
SELECT 
    g.customer_segment,
    COUNT(DISTINCT g.guest_id) as guest_count,
    AVG(ps.personalization_readiness_score) as avg_readiness,
    AVG(ps.spa_upsell_propensity) as spa_opportunity,
    AVG(ps.dining_upsell_propensity) as dining_opportunity,
    AVG(ps.tech_upsell_propensity) as tech_opportunity,
    AVG(ps.pool_services_upsell_propensity) as pool_opportunity,
    SUM(g.total_revenue) as segment_revenue,
    AVG(g.total_amenity_spend) as avg_amenity_spend,
    ROUND(SUM(g.total_revenue) * 0.15, 2) as estimated_upsell_potential
FROM GOLD.guest_360_view_enhanced g
JOIN GOLD.personalization_scores_enhanced ps ON g.guest_id = ps.guest_id
GROUP BY g.customer_segment
ORDER BY segment_revenue DESC, avg_readiness DESC;

-- ============================================================================
-- Summary
-- ============================================================================
SELECT 'Sample queries completed successfully!' AS STATUS;
SELECT 
    'All queries use actual Bronze/Silver/Gold tables' AS NOTE,
    'No SEMANTIC business views required' AS ARCHITECTURE,
    'Ready for business intelligence and analytics' AS NEXT_STEP;
