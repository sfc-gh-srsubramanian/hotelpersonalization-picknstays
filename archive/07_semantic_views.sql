-- Hotel Personalization System - Semantic Views
-- Business-friendly views for easy querying and reporting

USE DATABASE HOTEL_PERSONALIZATION;
USE SCHEMA SEMANTIC;

-- Guest Profile Summary (Business-friendly guest overview)
CREATE OR REPLACE VIEW guest_profile_summary AS
SELECT 
    guest_id,
    CONCAT(first_name, ' ', last_name) as full_name,
    email,
    CONCAT(age, ' years old') as age_description,
    generation,
    CASE 
        WHEN gender = 'M' THEN 'Male'
        WHEN gender = 'F' THEN 'Female'
        ELSE 'Other'
    END as gender_description,
    nationality,
    language_preference,
    CONCAT(city, ', ', state_province, ', ', country) as full_address,
    
    -- Loyalty information
    COALESCE(loyalty_tier, 'Not Enrolled') as loyalty_status,
    COALESCE(loyalty_points, 0) as current_points,
    
    -- Key metrics
    total_bookings as lifetime_bookings,
    completed_stays,
    CONCAT('$', FORMAT(total_revenue, 2)) as lifetime_value,
    CONCAT(avg_stay_length, ' nights') as typical_stay_length,
    ROUND(avg_satisfaction_score, 1) as satisfaction_rating,
    
    -- Customer classification
    customer_segment as guest_category,
    churn_risk as retention_risk,
    
    -- Last activity
    last_stay_date,
    CASE 
        WHEN days_since_last_stay <= 30 THEN 'Very Recent'
        WHEN days_since_last_stay <= 90 THEN 'Recent'
        WHEN days_since_last_stay <= 180 THEN 'Moderate'
        WHEN days_since_last_stay <= 365 THEN 'Distant'
        ELSE 'Very Distant'
    END as recency_description,
    
    marketing_opt_in as accepts_marketing
    
FROM GOLD.guest_360_view;

-- Personalization Opportunities (Guests ready for personalized experiences)
CREATE OR REPLACE VIEW personalization_opportunities AS
SELECT 
    gps.guest_id,
    gps.full_name,
    gps.email,
    gps.guest_category,
    gps.loyalty_status,
    
    -- Personalization readiness
    ps.personalization_readiness_score,
    CASE 
        WHEN ps.personalization_readiness_score >= 80 THEN 'Excellent'
        WHEN ps.personalization_readiness_score >= 60 THEN 'Good'
        WHEN ps.personalization_readiness_score >= 40 THEN 'Fair'
        ELSE 'Limited'
    END as personalization_potential,
    
    -- Key preferences for personalization
    pc.room_type_preference as preferred_room_type,
    pc.floor_preference as floor_preference,
    pc.view_preference as view_preference,
    pc.temperature_preference as preferred_temperature,
    pc.pillow_type_preference as pillow_preference,
    pc.preferred_communication_method,
    
    -- Service preferences
    pc.dining_preferences:cuisines[0]::STRING as favorite_cuisine,
    pc.dining_preferences:dietary_restrictions[0]::STRING as dietary_needs,
    CASE WHEN ARRAY_SIZE(pc.spa_services) > 0 THEN 'Yes' ELSE 'No' END as interested_in_spa,
    CASE WHEN ARRAY_SIZE(pc.fitness_preferences) > 0 THEN 'Yes' ELSE 'No' END as uses_fitness,
    
    -- Upsell opportunities
    ps.upsell_propensity_score,
    CASE 
        WHEN ps.upsell_propensity_score >= 70 THEN 'High Potential'
        WHEN ps.upsell_propensity_score >= 50 THEN 'Medium Potential'
        ELSE 'Low Potential'
    END as upsell_opportunity,
    
    -- Recent activity
    gps.last_stay_date,
    gps.recency_description,
    
    -- Contact preferences
    CASE 
        WHEN gps.accepts_marketing AND pc.preferred_communication_method IS NOT NULL 
        THEN pc.preferred_communication_method
        ELSE 'No Marketing'
    END as contact_method
    
FROM guest_profile_summary gps
JOIN GOLD.personalization_scores ps ON gps.guest_id = ps.guest_id
LEFT JOIN SILVER.preferences_consolidated pc ON gps.guest_id = pc.guest_id
WHERE ps.personalization_readiness_score >= 30 -- Only include guests with some personalization potential
ORDER BY ps.personalization_readiness_score DESC;

-- Upsell Recommendations (Targeted upsell opportunities)
CREATE OR REPLACE VIEW upsell_recommendations AS
SELECT 
    gps.guest_id,
    gps.full_name,
    gps.email,
    gps.guest_category,
    gps.loyalty_status,
    
    -- Upsell scoring
    ps.upsell_propensity_score,
    
    -- Recommended upsells based on preferences and behavior
    CASE 
        WHEN pc.spa_services IS NOT NULL AND ARRAY_SIZE(pc.spa_services) > 0 
        THEN 'Spa Package - ' || pc.spa_services[0]::STRING
        WHEN rf.avg_incidental_per_stay > 50 
        THEN 'Premium Amenities Package'
        WHEN pc.room_type_preference = 'Suite' 
        THEN 'Suite Upgrade'
        WHEN rf.preferred_room_type != 'Standard King' AND rf.preferred_room_type != 'Standard Queen'
        THEN 'Room Upgrade to ' || rf.preferred_room_type
        ELSE 'Premium WiFi & Services'
    END as primary_upsell_recommendation,
    
    CASE 
        WHEN pc.dining_preferences:cuisines[0]::STRING IS NOT NULL 
        THEN 'Restaurant Package - ' || pc.dining_preferences:cuisines[0]::STRING || ' cuisine'
        WHEN pc.fitness_preferences IS NOT NULL AND ARRAY_SIZE(pc.fitness_preferences) > 0
        THEN 'Fitness & Wellness Package'
        WHEN gps.guest_category IN ('VIP Champion', 'High Value')
        THEN 'Executive Lounge Access'
        ELSE 'Late Checkout & Welcome Gift'
    END as secondary_upsell_recommendation,
    
    -- Estimated additional revenue potential
    CASE 
        WHEN ps.upsell_propensity_score >= 80 THEN ROUND(rf.avg_booking_value * 0.3, 0)
        WHEN ps.upsell_propensity_score >= 60 THEN ROUND(rf.avg_booking_value * 0.2, 0)
        WHEN ps.upsell_propensity_score >= 40 THEN ROUND(rf.avg_booking_value * 0.15, 0)
        ELSE ROUND(rf.avg_booking_value * 0.1, 0)
    END as estimated_additional_revenue,
    
    -- Best contact timing
    CASE 
        WHEN gps.recency_description IN ('Very Recent', 'Recent') THEN 'Now'
        WHEN rf.avg_booking_lead_time <= 7 THEN 'Close to booking'
        WHEN rf.avg_booking_lead_time <= 30 THEN '2-3 weeks before typical booking'
        ELSE '1 month before seasonal booking period'
    END as optimal_contact_timing,
    
    pc.preferred_communication_method as contact_method,
    gps.accepts_marketing
    
FROM guest_profile_summary gps
JOIN GOLD.personalization_scores ps ON gps.guest_id = ps.guest_id
JOIN GOLD.recommendation_features rf ON gps.guest_id = rf.guest_id
LEFT JOIN SILVER.preferences_consolidated pc ON gps.guest_id = pc.guest_id
WHERE ps.upsell_propensity_score >= 40
    AND gps.accepts_marketing = TRUE
ORDER BY ps.upsell_propensity_score DESC, estimated_additional_revenue DESC;

-- Room Setup Recommendations (Pre-arrival room configuration)
CREATE OR REPLACE VIEW room_setup_recommendations AS
SELECT 
    gps.guest_id,
    gps.full_name,
    
    -- Next booking prediction (this would typically come from a booking system)
    'FUTURE_BOOKING' as booking_reference, -- Placeholder
    
    -- Room preferences
    COALESCE(pc.room_type_preference, rf.preferred_room_type, 'Standard King') as recommended_room_type,
    COALESCE(pc.floor_preference, 'middle') as floor_recommendation,
    COALESCE(pc.view_preference, 'city') as view_recommendation,
    COALESCE(pc.bed_type_preference, 'king') as bed_configuration,
    
    -- Room setup instructions
    CASE 
        WHEN pc.temperature_preference IS NOT NULL 
        THEN 'Set thermostat to ' || pc.temperature_preference || '°F'
        ELSE 'Set thermostat to 72°F (default)'
    END as temperature_setting,
    
    CASE 
        WHEN pc.lighting_preference = 'bright' THEN 'Open all curtains, turn on all lights'
        WHEN pc.lighting_preference = 'dim' THEN 'Close curtains partially, use ambient lighting'
        WHEN pc.lighting_preference = 'natural' THEN 'Open curtains, minimal artificial lighting'
        ELSE 'Standard lighting setup'
    END as lighting_setup,
    
    CASE 
        WHEN pc.pillow_type_preference IS NOT NULL 
        THEN 'Provide ' || pc.pillow_type_preference || ' pillows'
        ELSE 'Standard pillows'
    END as pillow_setup,
    
    -- Amenity recommendations
    CASE 
        WHEN pc.room_amenities IS NOT NULL 
        THEN 'Stock room with: ' || ARRAY_TO_STRING(pc.room_amenities, ', ')
        ELSE 'Standard amenities'
    END as amenity_setup,
    
    -- Special considerations
    CASE 
        WHEN pc.accessibility_needs = TRUE THEN 'Accessibility features required'
        WHEN pc.noise_level_preference = 'quiet' THEN 'Assign quiet room away from elevators/ice machines'
        WHEN pc.smoking_preference = TRUE THEN 'Smoking room required'
        ELSE 'No special requirements'
    END as special_requirements,
    
    -- Service setup
    CASE 
        WHEN pc.housekeeping_preferences:frequency::STRING = 'daily' THEN 'Schedule daily housekeeping'
        WHEN pc.housekeeping_preferences:frequency::STRING = 'every_other_day' THEN 'Schedule every other day housekeeping'
        ELSE 'Standard housekeeping schedule'
    END as housekeeping_schedule,
    
    -- Welcome amenities based on preferences and status
    CASE 
        WHEN gps.guest_category = 'VIP Champion' THEN 'Premium welcome amenities + personalized note'
        WHEN gps.guest_category IN ('High Value', 'Loyal Premium') THEN 'Enhanced welcome amenities'
        WHEN gps.loyalty_status IN ('Diamond', 'Gold') THEN 'Loyalty tier welcome gift'
        WHEN pc.dining_preferences:dietary_restrictions[0]::STRING IS NOT NULL 
        THEN 'Dietary-appropriate welcome snacks'
        ELSE 'Standard welcome amenities'
    END as welcome_amenities,
    
    ps.personalization_readiness_score
    
FROM guest_profile_summary gps
LEFT JOIN SILVER.preferences_consolidated pc ON gps.guest_id = pc.guest_id
LEFT JOIN GOLD.recommendation_features rf ON gps.guest_id = rf.guest_id
LEFT JOIN GOLD.personalization_scores ps ON gps.guest_id = ps.guest_id
WHERE ps.personalization_readiness_score >= 50
ORDER BY ps.personalization_readiness_score DESC;

-- Activity Recommendations (Personalized activity and dining suggestions)
CREATE OR REPLACE VIEW activity_recommendations AS
SELECT 
    gps.guest_id,
    gps.full_name,
    gps.email,
    
    -- Dining recommendations
    CASE 
        WHEN pc.dining_preferences:cuisines[0]::STRING = 'italian' 
        THEN 'Recommend: Mario''s Italian Bistro (hotel restaurant) or Luigi''s (nearby)'
        WHEN pc.dining_preferences:cuisines[0]::STRING = 'asian' 
        THEN 'Recommend: Sakura Sushi Bar (hotel) or Golden Dragon (nearby)'
        WHEN pc.dining_preferences:cuisines[0]::STRING = 'american' 
        THEN 'Recommend: The Grill (hotel steakhouse) or Local Tavern (nearby)'
        WHEN pc.dining_preferences:cuisines[0]::STRING = 'mexican' 
        THEN 'Recommend: Cantina (hotel) or El Mariachi (nearby)'
        ELSE 'Recommend: The Bistro (hotel) for variety'
    END as dining_recommendation,
    
    -- Dietary accommodation
    CASE 
        WHEN pc.dining_preferences:dietary_restrictions[0]::STRING = 'vegetarian' 
        THEN 'Highlight vegetarian menu options'
        WHEN pc.dining_preferences:dietary_restrictions[0]::STRING = 'vegan' 
        THEN 'Recommend vegan-friendly restaurants and menu items'
        WHEN pc.dining_preferences:dietary_restrictions[0]::STRING = 'gluten_free' 
        THEN 'Suggest gluten-free menu and nearby specialized restaurants'
        WHEN pc.dining_preferences:dietary_restrictions[0]::STRING = 'nut_allergy' 
        THEN 'Alert kitchen of nut allergy, suggest safe dining options'
        ELSE 'No special dietary requirements'
    END as dietary_accommodation,
    
    -- Activity recommendations
    CASE 
        WHEN pc.fitness_preferences IS NOT NULL AND ARRAY_SIZE(pc.fitness_preferences) > 0
        THEN 'Fitness: ' || pc.fitness_preferences[0]::STRING || ' (check hotel gym or nearby facilities)'
        ELSE 'Consider: Hotel fitness center tour'
    END as fitness_recommendation,
    
    CASE 
        WHEN pc.spa_services IS NOT NULL AND ARRAY_SIZE(pc.spa_services) > 0
        THEN 'Spa: Book ' || pc.spa_services[0]::STRING || ' treatment'
        ELSE 'Consider: Spa relaxation package'
    END as wellness_recommendation,
    
    CASE 
        WHEN pc.entertainment_preferences IS NOT NULL AND ARRAY_SIZE(pc.entertainment_preferences) > 0
        THEN 'Entertainment: ' || pc.entertainment_preferences[0]::STRING || ' (check local venues)'
        ELSE 'Consider: Local entertainment guide'
    END as entertainment_recommendation,
    
    -- Transportation assistance
    CASE 
        WHEN pc.transportation_preferences IS NOT NULL AND ARRAY_SIZE(pc.transportation_preferences) > 0
        THEN 'Transport: Arrange ' || pc.transportation_preferences[0]::STRING
        ELSE 'Offer: Airport shuttle information'
    END as transportation_recommendation,
    
    -- Business services
    CASE 
        WHEN pc.business_services IS NOT NULL AND ARRAY_SIZE(pc.business_services) > 0
        THEN 'Business: Set up ' || pc.business_services[0]::STRING
        WHEN rf.generation = 'Millennial' OR rf.generation = 'Gen Z'
        THEN 'Offer: Co-working space access'
        ELSE 'Available: Business center services'
    END as business_recommendation,
    
    -- Concierge services
    CASE 
        WHEN pc.concierge_services IS NOT NULL AND ARRAY_SIZE(pc.concierge_services) > 0
        THEN 'Concierge: Proactively offer ' || pc.concierge_services[0]::STRING
        WHEN gps.guest_category IN ('VIP Champion', 'High Value')
        THEN 'VIP Concierge: Full-service assistance available'
        ELSE 'Standard concierge services available upon request'
    END as concierge_recommendation,
    
    -- Local attractions based on social activity
    CASE 
        WHEN em.social_engagement_level = 'High' 
        THEN 'Instagram-worthy spots: Recommend photo opportunities and trendy locations'
        WHEN rf.age <= 35 
        THEN 'Nightlife: Suggest popular bars and entertainment districts'
        WHEN rf.age >= 55 
        THEN 'Culture: Recommend museums, galleries, and historical sites'
        ELSE 'General: Provide comprehensive local attractions guide'
    END as local_recommendations,
    
    gps.guest_category,
    gps.loyalty_status
    
FROM guest_profile_summary gps
LEFT JOIN SILVER.preferences_consolidated pc ON gps.guest_id = pc.guest_id
LEFT JOIN GOLD.recommendation_features rf ON gps.guest_id = rf.guest_id
LEFT JOIN SILVER.engagement_metrics em ON gps.guest_id = em.guest_id
WHERE pc.guest_id IS NOT NULL -- Only guests with some preferences
ORDER BY gps.guest_category DESC, gps.loyalty_status DESC;

-- Guest Communication Preferences (How and when to contact guests)
CREATE OR REPLACE VIEW guest_communication_preferences AS
SELECT 
    gps.guest_id,
    gps.full_name,
    gps.email,
    
    -- Communication method preference
    COALESCE(pc.preferred_communication_method, 'email') as preferred_contact_method,
    
    -- Marketing preferences
    gps.accepts_marketing,
    CASE 
        WHEN gps.accepts_marketing = TRUE AND rf.social_engagement_level = 'High' 
        THEN 'Digital marketing preferred (email, social media, app notifications)'
        WHEN gps.accepts_marketing = TRUE AND rf.generation IN ('Millennial', 'Gen Z')
        THEN 'Mobile-first communication (SMS, app notifications, email)'
        WHEN gps.accepts_marketing = TRUE AND rf.generation IN ('Gen X', 'Boomer')
        THEN 'Traditional channels (email, phone calls)'
        ELSE 'No marketing communications'
    END as marketing_approach,
    
    -- Optimal timing for communication
    CASE 
        WHEN rf.avg_booking_lead_time <= 7 THEN 'Contact 3-5 days before typical booking window'
        WHEN rf.avg_booking_lead_time <= 30 THEN 'Contact 1-2 weeks before typical booking'
        ELSE 'Contact 3-4 weeks before seasonal patterns'
    END as optimal_contact_timing,
    
    -- Message personalization level
    CASE 
        WHEN ps.personalization_readiness_score >= 80 
        THEN 'Highly personalized messages with specific preferences and recommendations'
        WHEN ps.personalization_readiness_score >= 60 
        THEN 'Moderately personalized with basic preferences'
        WHEN ps.personalization_readiness_score >= 40 
        THEN 'Lightly personalized with loyalty status'
        ELSE 'Generic communications'
    END as personalization_level,
    
    -- Content recommendations
    CASE 
        WHEN gps.guest_category = 'VIP Champion' 
        THEN 'Exclusive offers, early access, premium content'
        WHEN gps.guest_category IN ('High Value', 'Loyal Premium')
        THEN 'Special promotions, loyalty benefits, upgrade offers'
        WHEN gps.guest_category IN ('Premium', 'Loyal Regular')
        THEN 'Targeted offers, seasonal promotions'
        ELSE 'General promotions, new guest offers'
    END as content_strategy,
    
    -- Language preference
    rf.language_preference,
    
    -- Response likelihood
    CASE 
        WHEN ps.loyalty_propensity_score >= 70 AND gps.accepts_marketing = TRUE 
        THEN 'High response likelihood'
        WHEN ps.loyalty_propensity_score >= 50 AND gps.accepts_marketing = TRUE 
        THEN 'Moderate response likelihood'
        WHEN gps.accepts_marketing = TRUE 
        THEN 'Low response likelihood'
        ELSE 'Service communications only'
    END as response_prediction,
    
    -- Communication frequency recommendation
    CASE 
        WHEN gps.guest_category IN ('VIP Champion', 'High Value') 
        THEN 'Monthly personalized communications'
        WHEN gps.guest_category IN ('Loyal Premium', 'Premium') 
        THEN 'Bi-monthly targeted offers'
        WHEN gps.guest_category = 'Loyal Regular' 
        THEN 'Quarterly loyalty communications'
        ELSE 'Seasonal promotions only'
    END as communication_frequency,
    
    gps.last_stay_date,
    gps.recency_description
    
FROM guest_profile_summary gps
LEFT JOIN SILVER.preferences_consolidated pc ON gps.guest_id = pc.guest_id
LEFT JOIN GOLD.recommendation_features rf ON gps.guest_id = rf.guest_id
LEFT JOIN GOLD.personalization_scores ps ON gps.guest_id = ps.guest_id
ORDER BY ps.personalization_readiness_score DESC, gps.guest_category DESC;

