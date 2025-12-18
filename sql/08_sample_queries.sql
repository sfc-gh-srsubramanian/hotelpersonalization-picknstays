-- Hotel Personalization System - Sample Queries
-- Demonstrates key personalization use cases and business scenarios

USE DATABASE HOTEL_PERSONALIZATION;

-- =====================================================
-- 1. PRE-ARRIVAL ROOM SETUP AUTOMATION
-- =====================================================

-- Query: Get room setup instructions for arriving guests today
SELECT 
    guest_id,
    full_name,
    recommended_room_type,
    temperature_setting,
    lighting_setup,
    pillow_setup,
    amenity_setup,
    special_requirements,
    welcome_amenities
FROM SEMANTIC.room_setup_recommendations
WHERE booking_reference = 'FUTURE_BOOKING' -- In real scenario, join with actual bookings
LIMIT 10;

-- Query: Identify VIP guests arriving today who need special attention
SELECT 
    gps.full_name,
    gps.guest_category,
    gps.loyalty_status,
    gps.lifetime_value,
    rsr.temperature_setting,
    rsr.special_requirements,
    rsr.welcome_amenities,
    pc.preferred_communication_method
FROM SEMANTIC.guest_profile_summary gps
JOIN SEMANTIC.room_setup_recommendations rsr ON gps.guest_id = rsr.guest_id
LEFT JOIN SILVER.preferences_consolidated pc ON gps.guest_id = pc.guest_id
WHERE gps.guest_category IN ('VIP Champion', 'High Value')
ORDER BY gps.lifetime_value DESC
LIMIT 5;

-- =====================================================
-- 2. PERSONALIZED UPSELL RECOMMENDATIONS
-- =====================================================

-- Query: High-value upsell opportunities for current week
SELECT 
    full_name,
    email,
    guest_category,
    upsell_propensity_score,
    primary_upsell_recommendation,
    secondary_upsell_recommendation,
    estimated_additional_revenue,
    optimal_contact_timing,
    contact_method
FROM SEMANTIC.upsell_recommendations
WHERE upsell_propensity_score >= 70
    AND accepts_marketing = TRUE
ORDER BY estimated_additional_revenue DESC
LIMIT 15;

-- Query: Spa package upsell opportunities
SELECT 
    ur.full_name,
    ur.guest_category,
    ur.primary_upsell_recommendation,
    ur.estimated_additional_revenue,
    pc.spa_services,
    gv.avg_incidental_per_stay
FROM SEMANTIC.upsell_recommendations ur
JOIN SILVER.preferences_consolidated pc ON ur.guest_id = pc.guest_id
JOIN GOLD.guest_360_view gv ON ur.guest_id = gv.guest_id
WHERE ur.primary_upsell_recommendation LIKE '%Spa%'
    AND ur.upsell_propensity_score >= 60
ORDER BY ur.estimated_additional_revenue DESC;

-- =====================================================
-- 3. PERSONALIZED DINING & ACTIVITY RECOMMENDATIONS
-- =====================================================

-- Query: Guests with specific dietary needs arriving this week
SELECT 
    full_name,
    dining_recommendation,
    dietary_accommodation,
    fitness_recommendation,
    wellness_recommendation,
    guest_category
FROM SEMANTIC.activity_recommendations
WHERE dietary_accommodation != 'No special dietary requirements'
    AND guest_category IN ('VIP Champion', 'High Value', 'Loyal Premium')
LIMIT 10;

-- Query: High social media influence guests for experience recommendations
SELECT 
    ar.full_name,
    ar.dining_recommendation,
    ar.entertainment_recommendation,
    ar.local_recommendations,
    em.social_engagement_level,
    em.total_engagement,
    em.overall_sentiment
FROM SEMANTIC.activity_recommendations ar
JOIN SILVER.engagement_metrics em ON ar.guest_id = em.guest_id
WHERE em.social_engagement_level = 'High'
    AND em.overall_sentiment = 'Positive'
ORDER BY em.total_engagement DESC
LIMIT 10;

-- =====================================================
-- 4. CUSTOMER SEGMENTATION & TARGETING
-- =====================================================

-- Query: Identify guests at risk of churning who need attention
SELECT 
    gps.full_name,
    gps.guest_category,
    gps.retention_risk,
    gps.recency_description,
    gps.satisfaction_rating,
    gps.lifetime_value,
    ps.loyalty_propensity_score,
    gcp.preferred_contact_method,
    gcp.optimal_contact_timing
FROM SEMANTIC.guest_profile_summary gps
JOIN GOLD.personalization_scores ps ON gps.guest_id = ps.guest_id
JOIN SEMANTIC.guest_communication_preferences gcp ON gps.guest_id = gcp.guest_id
WHERE gps.retention_risk IN ('High Risk', 'Medium Risk')
    AND gps.guest_category IN ('VIP Champion', 'High Value', 'Loyal Premium', 'Premium')
ORDER BY gps.lifetime_value DESC
LIMIT 20;

-- Query: Millennial guests with high social engagement for digital campaigns
SELECT 
    gps.full_name,
    gps.age_description,
    gps.generation,
    em.social_engagement_level,
    em.platforms_used,
    em.total_engagement,
    em.hotel_mentions,
    gcp.marketing_approach,
    gcp.response_prediction
FROM SEMANTIC.guest_profile_summary gps
JOIN SILVER.engagement_metrics em ON gps.guest_id = em.guest_id
JOIN SEMANTIC.guest_communication_preferences gcp ON gps.guest_id = gcp.guest_id
WHERE gps.generation = 'Millennial'
    AND em.social_engagement_level IN ('High', 'Medium')
    AND gps.accepts_marketing = TRUE
ORDER BY em.total_engagement DESC
LIMIT 15;

-- =====================================================
-- 5. BUSINESS INTELLIGENCE DASHBOARDS
-- =====================================================

-- Query: Monthly personalization performance metrics
SELECT 
    metric_month,
    brand,
    total_bookings,
    unique_guests,
    vip_guests,
    ROUND(vip_guests / unique_guests * 100, 1) as vip_percentage,
    CONCAT('$', FORMAT(total_revenue, 0)) as revenue,
    ROUND(avg_satisfaction, 1) as satisfaction,
    ROUND(satisfaction_rate, 1) as satisfaction_percentage,
    ROUND(loyalty_penetration_rate, 1) as loyalty_rate,
    ROUND(avg_personalization_readiness, 1) as personalization_score
FROM GOLD.business_metrics
WHERE metric_month >= DATEADD(month, -6, CURRENT_DATE())
ORDER BY metric_month DESC, total_revenue DESC
LIMIT 30;

-- Query: Hotel performance comparison for personalization readiness
SELECT 
    bm.hotel_name,
    bm.hotel_city,
    bm.brand,
    COUNT(DISTINCT gv.guest_id) as total_guests,
    COUNT(DISTINCT CASE WHEN ps.personalization_readiness_score >= 70 THEN gv.guest_id END) as high_readiness_guests,
    ROUND(high_readiness_guests / total_guests * 100, 1) as personalization_ready_percentage,
    AVG(ps.personalization_readiness_score) as avg_personalization_score,
    AVG(ps.upsell_propensity_score) as avg_upsell_score,
    CONCAT('$', FORMAT(SUM(gv.total_revenue), 0)) as total_guest_revenue
FROM GOLD.business_metrics bm
JOIN GOLD.guest_360_view gv ON TRUE -- Cross join for aggregation
JOIN GOLD.personalization_scores ps ON gv.guest_id = ps.guest_id
WHERE bm.metric_month = DATE_TRUNC('month', CURRENT_DATE())
GROUP BY bm.hotel_name, bm.hotel_city, bm.brand
HAVING total_guests >= 10 -- Only hotels with sufficient data
ORDER BY personalization_ready_percentage DESC, avg_personalization_score DESC
LIMIT 20;

-- =====================================================
-- 6. PREDICTIVE ANALYTICS INSIGHTS
-- =====================================================

-- Query: Guests most likely to book again in next 30 days
SELECT 
    gv.guest_id,
    gps.full_name,
    gps.guest_category,
    pf.next_booking_likelihood,
    pf.recency,
    pf.frequency,
    pf.monetary,
    pf.satisfaction_trend,
    pf.spend_trend,
    gcp.optimal_contact_timing,
    gcp.preferred_contact_method
FROM GOLD.predictive_features pf
JOIN GOLD.guest_360_view gv ON pf.guest_id = gv.guest_id
JOIN SEMANTIC.guest_profile_summary gps ON pf.guest_id = gps.guest_id
JOIN SEMANTIC.guest_communication_preferences gcp ON pf.guest_id = gcp.guest_id
WHERE pf.next_booking_likelihood >= 0.6
    AND gps.accepts_marketing = TRUE
ORDER BY pf.next_booking_likelihood DESC, pf.monetary DESC
LIMIT 25;

-- Query: Churn risk analysis with intervention recommendations
SELECT 
    gps.full_name,
    gps.guest_category,
    gps.lifetime_value,
    pf.churn_probability,
    pf.satisfaction_trend,
    pf.spend_trend,
    CASE 
        WHEN pf.churn_probability >= 0.7 THEN 'Immediate intervention required'
        WHEN pf.churn_probability >= 0.5 THEN 'Proactive outreach recommended'
        WHEN pf.churn_probability >= 0.3 THEN 'Monitor closely'
        ELSE 'Low risk'
    END as intervention_level,
    CASE 
        WHEN pf.satisfaction_trend < -0.5 THEN 'Focus on service quality improvement'
        WHEN pf.spend_trend < -50 THEN 'Offer value-based promotions'
        WHEN pf.recency_normalized > 0.8 THEN 'Re-engagement campaign'
        ELSE 'Standard retention program'
    END as recommended_action,
    gcp.preferred_contact_method,
    gcp.marketing_approach
FROM GOLD.predictive_features pf
JOIN SEMANTIC.guest_profile_summary gps ON pf.guest_id = gps.guest_id
JOIN SEMANTIC.guest_communication_preferences gcp ON pf.guest_id = gcp.guest_id
WHERE pf.churn_probability >= 0.3
    AND gps.guest_category IN ('VIP Champion', 'High Value', 'Loyal Premium', 'Premium')
ORDER BY pf.churn_probability DESC, gps.lifetime_value DESC
LIMIT 30;

-- =====================================================
-- 7. SOCIAL MEDIA SENTIMENT TRACKING
-- =====================================================

-- Query: Recent social media mentions requiring response
SELECT 
    gps.full_name,
    gps.email,
    em.overall_sentiment,
    em.avg_sentiment,
    em.hotel_mentions,
    em.brand_mentions,
    em.last_activity_date,
    CASE 
        WHEN em.avg_sentiment < -0.3 THEN 'Immediate response required'
        WHEN em.avg_sentiment < 0 THEN 'Monitor and consider response'
        WHEN em.avg_sentiment > 0.5 AND em.hotel_mentions > 0 THEN 'Thank and amplify'
        ELSE 'No action needed'
    END as response_recommendation,
    gps.guest_category,
    gps.loyalty_status
FROM SILVER.engagement_metrics em
JOIN SEMANTIC.guest_profile_summary gps ON em.guest_id = gps.guest_id
WHERE em.last_activity_date >= DATEADD(day, -7, CURRENT_DATE())
    AND (em.hotel_mentions > 0 OR em.brand_mentions > 0)
ORDER BY 
    CASE WHEN em.avg_sentiment < -0.3 THEN 1 
         WHEN em.avg_sentiment > 0.5 AND em.hotel_mentions > 0 THEN 2 
         ELSE 3 END,
    em.total_engagement DESC
LIMIT 20;

-- =====================================================
-- 8. OPERATIONAL INSIGHTS
-- =====================================================

-- Query: Room preference patterns for inventory management
SELECT 
    pc.room_type_preference,
    pc.floor_preference,
    pc.view_preference,
    pc.bed_type_preference,
    COUNT(*) as guest_count,
    AVG(gv.avg_booking_value) as avg_spend,
    AVG(gv.avg_satisfaction_score) as avg_satisfaction,
    COUNT(CASE WHEN gv.customer_segment IN ('VIP Champion', 'High Value') THEN 1 END) as high_value_guests
FROM SILVER.preferences_consolidated pc
JOIN GOLD.guest_360_view gv ON pc.guest_id = gv.guest_id
WHERE pc.room_type_preference IS NOT NULL
    AND gv.completed_stays >= 2 -- Only repeat guests
GROUP BY pc.room_type_preference, pc.floor_preference, pc.view_preference, pc.bed_type_preference
HAVING guest_count >= 5
ORDER BY high_value_guests DESC, avg_spend DESC
LIMIT 25;

-- Query: Service demand forecasting based on preferences
SELECT 
    'Spa Services' as service_category,
    COUNT(DISTINCT pc.guest_id) as interested_guests,
    AVG(ps.upsell_propensity_score) as avg_upsell_score,
    SUM(CASE WHEN gv.days_since_last_stay <= 90 THEN 1 ELSE 0 END) as recent_guests,
    CONCAT('$', FORMAT(AVG(gv.avg_booking_value) * 0.2, 0)) as estimated_additional_revenue_per_guest
FROM SILVER.preferences_consolidated pc
JOIN GOLD.guest_360_view gv ON pc.guest_id = gv.guest_id
JOIN GOLD.personalization_scores ps ON pc.guest_id = ps.guest_id
WHERE pc.spa_services IS NOT NULL 
    AND ARRAY_SIZE(pc.spa_services) > 0

UNION ALL

SELECT 
    'Fitness Services' as service_category,
    COUNT(DISTINCT pc.guest_id) as interested_guests,
    AVG(ps.upsell_propensity_score) as avg_upsell_score,
    SUM(CASE WHEN gv.days_since_last_stay <= 90 THEN 1 ELSE 0 END) as recent_guests,
    CONCAT('$', FORMAT(AVG(gv.avg_booking_value) * 0.15, 0)) as estimated_additional_revenue_per_guest
FROM SILVER.preferences_consolidated pc
JOIN GOLD.guest_360_view gv ON pc.guest_id = gv.guest_id
JOIN GOLD.personalization_scores ps ON pc.guest_id = ps.guest_id
WHERE pc.fitness_preferences IS NOT NULL 
    AND ARRAY_SIZE(pc.fitness_preferences) > 0

UNION ALL

SELECT 
    'Business Services' as service_category,
    COUNT(DISTINCT pc.guest_id) as interested_guests,
    AVG(ps.upsell_propensity_score) as avg_upsell_score,
    SUM(CASE WHEN gv.days_since_last_stay <= 90 THEN 1 ELSE 0 END) as recent_guests,
    CONCAT('$', FORMAT(AVG(gv.avg_booking_value) * 0.1, 0)) as estimated_additional_revenue_per_guest
FROM SILVER.preferences_consolidated pc
JOIN GOLD.guest_360_view gv ON pc.guest_id = gv.guest_id
JOIN GOLD.personalization_scores ps ON pc.guest_id = ps.guest_id
WHERE pc.business_services IS NOT NULL 
    AND ARRAY_SIZE(pc.business_services) > 0

ORDER BY interested_guests DESC;

