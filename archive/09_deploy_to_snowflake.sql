-- Hotel Personalization System - Deployment Script
-- Execute this script to deploy the complete system to Snowflake

-- Step 1: Create database and schemas
source 01_setup_database.sql;

-- Step 2: Create Bronze layer tables
source 02_bronze_layer_tables.sql;

-- Step 3: Generate sample data (Part 1)
source 03_sample_data_generation.sql;

-- Step 4: Generate sample data (Part 2)
source 04_booking_stay_data.sql;

-- Step 5: Create Silver layer tables and populate them
source 05_silver_layer.sql;

-- Step 6: Create Gold layer tables and populate them
source 06_gold_layer.sql;

-- Step 7: Create Semantic views
source 07_semantic_views.sql;

-- Verification queries to ensure deployment was successful
USE DATABASE HOTEL_PERSONALIZATION;

-- Check row counts in each layer
SELECT 'BRONZE' as layer, 'guest_profiles' as table_name, COUNT(*) as row_count FROM BRONZE.guest_profiles
UNION ALL
SELECT 'BRONZE' as layer, 'booking_history' as table_name, COUNT(*) as row_count FROM BRONZE.booking_history
UNION ALL
SELECT 'BRONZE' as layer, 'stay_history' as table_name, COUNT(*) as row_count FROM BRONZE.stay_history
UNION ALL
SELECT 'BRONZE' as layer, 'hotel_properties' as table_name, COUNT(*) as row_count FROM BRONZE.hotel_properties
UNION ALL
SELECT 'SILVER' as layer, 'guests_standardized' as table_name, COUNT(*) as row_count FROM SILVER.guests_standardized
UNION ALL
SELECT 'SILVER' as layer, 'bookings_enriched' as table_name, COUNT(*) as row_count FROM SILVER.bookings_enriched
UNION ALL
SELECT 'SILVER' as layer, 'stays_processed' as table_name, COUNT(*) as row_count FROM SILVER.stays_processed
UNION ALL
SELECT 'GOLD' as layer, 'guest_360_view' as table_name, COUNT(*) as row_count FROM GOLD.guest_360_view
UNION ALL
SELECT 'GOLD' as layer, 'personalization_scores' as table_name, COUNT(*) as row_count FROM GOLD.personalization_scores
UNION ALL
SELECT 'GOLD' as layer, 'recommendation_features' as table_name, COUNT(*) as row_count FROM GOLD.recommendation_features
ORDER BY layer, table_name;

-- Test semantic views
SELECT 'Semantic Views Test' as test_type, COUNT(*) as high_personalization_guests 
FROM SEMANTIC.personalization_opportunities 
WHERE personalization_potential = 'Excellent';

SELECT 'Upsell Opportunities' as test_type, COUNT(*) as high_potential_guests 
FROM SEMANTIC.upsell_recommendations 
WHERE upsell_opportunity = 'High Potential';

-- Show deployment summary
SELECT 
    'Deployment Complete' as status,
    CURRENT_TIMESTAMP() as completion_time,
    'Ready for personalization queries' as next_steps;

