-- Hotel Personalization System - Consolidated Deployment
-- Execute this complete script using Snowflake MCP or your preferred Snowflake client

-- =====================================================
-- STEP 1: DATABASE AND SCHEMA SETUP
-- =====================================================

-- Create main database
CREATE DATABASE IF NOT EXISTS HOTEL_PERSONALIZATION;
USE DATABASE HOTEL_PERSONALIZATION;

-- Create schemas for medallion architecture
CREATE SCHEMA IF NOT EXISTS BRONZE COMMENT = 'Raw data layer - untransformed source data';
CREATE SCHEMA IF NOT EXISTS SILVER COMMENT = 'Cleaned and standardized data layer';
CREATE SCHEMA IF NOT EXISTS GOLD COMMENT = 'Analytics-ready aggregated data layer';
CREATE SCHEMA IF NOT EXISTS SEMANTIC COMMENT = 'Semantic views for business users';

-- Set context for subsequent operations
USE SCHEMA BRONZE;

-- =====================================================
-- STEP 2: BRONZE LAYER TABLES (First 5 core tables)
-- =====================================================

-- Guest Profiles (Core guest information)
CREATE OR REPLACE TABLE guest_profiles (
    guest_id STRING PRIMARY KEY,
    first_name STRING,
    last_name STRING,
    email STRING,
    phone STRING,
    date_of_birth DATE,
    gender STRING,
    nationality STRING,
    language_preference STRING,
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    state_province STRING,
    postal_code STRING,
    country STRING,
    registration_date TIMESTAMP,
    last_updated TIMESTAMP,
    marketing_opt_in BOOLEAN,
    communication_preferences VARIANT,
    emergency_contact VARIANT
);

-- Hotel Properties (Hotel information for reference)
CREATE OR REPLACE TABLE hotel_properties (
    hotel_id STRING PRIMARY KEY,
    hotel_name STRING,
    brand STRING,
    address_line1 STRING,
    address_line2 STRING,
    city STRING,
    state_province STRING,
    postal_code STRING,
    country STRING,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    phone STRING,
    email STRING,
    star_rating INTEGER,
    total_rooms INTEGER,
    amenities VARIANT,
    room_types VARIANT,
    check_in_time TIME,
    check_out_time TIME,
    timezone STRING,
    opened_date DATE,
    last_renovation_date DATE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Booking History (All booking transactions)
CREATE OR REPLACE TABLE booking_history (
    booking_id STRING PRIMARY KEY,
    guest_id STRING,
    hotel_id STRING,
    booking_date TIMESTAMP,
    check_in_date DATE,
    check_out_date DATE,
    num_nights INTEGER,
    num_adults INTEGER,
    num_children INTEGER,
    room_type STRING,
    rate_code STRING,
    total_amount DECIMAL(10,2),
    currency STRING,
    booking_channel STRING,
    booking_status STRING,
    cancellation_date TIMESTAMP,
    advance_booking_days INTEGER,
    special_requests VARIANT,
    promo_code STRING,
    payment_method STRING,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Loyalty Program (Loyalty tier and points data)
CREATE OR REPLACE TABLE loyalty_program (
    loyalty_id STRING PRIMARY KEY,
    guest_id STRING,
    program_name STRING,
    member_number STRING,
    tier_level STRING, -- bronze, silver, gold, diamond
    points_balance INTEGER,
    lifetime_points INTEGER,
    tier_qualification_date DATE,
    next_tier_threshold INTEGER,
    expiration_date DATE,
    benefits VARIANT, -- array of current benefits
    referral_count INTEGER,
    status STRING, -- active, inactive, suspended
    last_activity_date DATE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Room Preferences (Guest room preferences)
CREATE OR REPLACE TABLE room_preferences (
    preference_id STRING PRIMARY KEY,
    guest_id STRING,
    room_type_preference STRING,
    floor_preference STRING, -- low, middle, high
    view_preference STRING, -- city, ocean, garden, etc.
    bed_type_preference STRING,
    smoking_preference BOOLEAN,
    accessibility_needs BOOLEAN,
    temperature_preference INTEGER, -- in Fahrenheit
    lighting_preference STRING, -- bright, dim, natural
    pillow_type_preference STRING,
    room_amenities VARIANT, -- array of preferred amenities
    noise_level_preference STRING, -- quiet, moderate, doesn't_matter
    last_updated TIMESTAMP,
    created_at TIMESTAMP
);

-- =====================================================
-- STEP 3: SAMPLE DATA GENERATION (Core Data)
-- =====================================================

-- Generate Hotel Properties (20 hotels for demo)
INSERT INTO hotel_properties
WITH hotel_data AS (
    SELECT 
        'HOTEL_' || LPAD(seq, 3, '0') as hotel_id,
        CASE 
            WHEN seq <= 5 THEN 'Hilton ' || ['Downtown', 'Garden Inn', 'Embassy Suites', 'DoubleTree', 'Hampton Inn'][seq % 5]
            WHEN seq <= 10 THEN 'Marriott ' || ['Courtyard', 'Residence Inn', 'SpringHill Suites', 'Fairfield Inn', 'TownePlace Suites'][seq % 5]
            WHEN seq <= 15 THEN 'Hyatt ' || ['Place', 'House', 'Centric', 'Regency', 'Grand'][seq % 5]
            ELSE 'IHG ' || ['Holiday Inn', 'Crowne Plaza', 'InterContinental', 'Staybridge Suites', 'Candlewood Suites'][seq % 5]
        END as hotel_name,
        CASE 
            WHEN seq <= 5 THEN 'Hilton'
            WHEN seq <= 10 THEN 'Marriott'
            WHEN seq <= 15 THEN 'Hyatt'
            ELSE 'IHG'
        END as brand,
        (seq * 123) || ' ' || ['Main St', 'Broadway', 'Park Ave', 'First St', 'Oak Blvd'][seq % 5] as address_line1,
        NULL as address_line2,
        ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose'][seq % 10] as city,
        ['NY', 'CA', 'IL', 'TX', 'AZ', 'PA', 'TX', 'CA', 'TX', 'CA'][seq % 10] as state_province,
        LPAD((10000 + seq * 17) % 90000 + 10000, 5, '0') as postal_code,
        'USA' as country,
        ROUND(25.0 + (seq * 7) % 25 + RANDOM() * 0.001, 6) as latitude,
        ROUND(-125.0 + (seq * 11) % 50 + RANDOM() * 0.001, 6) as longitude,
        '+1' || LPAD((seq * 31) % 900 + 100, 3, '0') || LPAD((seq * 47) % 9000 + 1000, 4, '0') as phone,
        LOWER(REPLACE(hotel_name, ' ', '.')) || '@hiltonchain.com' as email,
        3 + (seq % 3) as star_rating,
        100 + (seq * 23) % 400 as total_rooms,
        PARSE_JSON('["WiFi", "Parking", "Pool", "Fitness Center", "Restaurant", "Room Service", "Concierge", "Business Center"]') as amenities,
        PARSE_JSON('["Standard King", "Standard Queen", "Deluxe King", "Suite", "Executive", "Family Room"]') as room_types,
        TIME('15:00:00') as check_in_time,
        TIME('11:00:00') as check_out_time,
        ['America/New_York', 'America/Los_Angeles', 'America/Chicago', 'America/Denver'][seq % 4] as timezone,
        DATEADD(day, -1 * (seq * 100 + 365), CURRENT_DATE()) as opened_date,
        DATEADD(day, -1 * (seq * 30 + 100), CURRENT_DATE()) as last_renovation_date,
        CURRENT_TIMESTAMP() as created_at,
        CURRENT_TIMESTAMP() as updated_at
    FROM TABLE(GENERATOR(ROWCOUNT => 20)) t(seq)
)
SELECT * FROM hotel_data;

-- Generate Guest Profiles (1,000 guests for demo)
INSERT INTO guest_profiles
WITH guest_data AS (
    SELECT 
        'GUEST_' || LPAD(seq, 6, '0') as guest_id,
        ['James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 'Linda', 'David', 'Elizabeth', 
         'William', 'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica', 'Thomas', 'Sarah', 'Christopher', 'Karen'][seq % 20] as first_name,
        ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
         'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin'][seq % 20] as last_name,
        LOWER(first_name || '.' || last_name || seq) || '@' || ['gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com', 'company.com'][seq % 5] as email,
        '+1' || LPAD((seq * 23) % 900 + 100, 3, '0') || LPAD((seq * 41) % 9000 + 1000, 4, '0') as phone,
        DATEADD(year, -1 * (20 + (seq * 13) % 60), CURRENT_DATE()) as date_of_birth,
        ['M', 'F', 'Other'][seq % 3] as gender,
        ['USA', 'Canada', 'UK', 'Germany', 'France', 'Japan', 'Australia', 'Brazil', 'India', 'Mexico'][seq % 10] as nationality,
        ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese', 'Portuguese', 'Hindi'][seq % 8] as language_preference,
        (seq * 47) || ' ' || ['Oak St', 'Pine Ave', 'Maple Dr', 'Cedar Ln', 'Elm Way'][seq % 5] as address_line1,
        CASE WHEN seq % 4 = 0 THEN 'Apt ' || (seq % 100 + 1) ELSE NULL END as address_line2,
        ['Boston', 'Miami', 'Seattle', 'Denver', 'Atlanta', 'Las Vegas', 'Portland', 'Nashville', 'Austin', 'Orlando'][seq % 10] as city,
        ['MA', 'FL', 'WA', 'CO', 'GA', 'NV', 'OR', 'TN', 'TX', 'FL'][seq % 10] as state_province,
        LPAD((20000 + seq * 19) % 80000 + 10000, 5, '0') as postal_code,
        'USA' as country,
        DATEADD(day, -1 * (seq * 7), CURRENT_DATE()) as registration_date,
        CURRENT_TIMESTAMP() as last_updated,
        seq % 3 != 0 as marketing_opt_in,
        PARSE_JSON('{"email": true, "sms": ' || (seq % 2 = 0)::STRING || ', "phone": ' || (seq % 3 = 0)::STRING || '}') as communication_preferences,
        PARSE_JSON('{"name": "Emergency Contact", "phone": "+1' || LPAD((seq * 67) % 9000 + 1000, 4, '0') || '", "relationship": "' || ['spouse', 'parent', 'sibling', 'friend'][seq % 4] || '"}') as emergency_contact
    FROM TABLE(GENERATOR(ROWCOUNT => 1000)) t(seq)
)
SELECT * FROM guest_data;

-- Generate Loyalty Program Data (800 guests enrolled)
INSERT INTO loyalty_program
WITH loyalty_data AS (
    SELECT 
        'LOYALTY_' || LPAD(seq, 6, '0') as loyalty_id,
        'GUEST_' || LPAD(seq, 6, '0') as guest_id,
        'Hilton Honors' as program_name,
        'HH' || LPAD(seq * 73, 10, '0') as member_number,
        CASE 
            WHEN seq % 100 < 5 THEN 'Diamond'
            WHEN seq % 100 < 20 THEN 'Gold'
            WHEN seq % 100 < 50 THEN 'Silver'
            ELSE 'Blue'
        END as tier_level,
        (seq * 127) % 50000 + 1000 as points_balance,
        (seq * 191) % 200000 + 5000 as lifetime_points,
        DATEADD(day, -1 * (seq * 3), CURRENT_DATE()) as tier_qualification_date,
        CASE tier_level
            WHEN 'Blue' THEN 10000
            WHEN 'Silver' THEN 25000
            WHEN 'Gold' THEN 75000
            ELSE 0
        END as next_tier_threshold,
        DATEADD(year, 1, CURRENT_DATE()) as expiration_date,
        CASE tier_level
            WHEN 'Diamond' THEN PARSE_JSON('["Executive Lounge", "Room Upgrades", "Late Checkout", "Free Breakfast", "WiFi", "Welcome Gift"]')
            WHEN 'Gold' THEN PARSE_JSON('["Room Upgrades", "Late Checkout", "Free Breakfast", "WiFi"]')
            WHEN 'Silver' THEN PARSE_JSON('["Late Checkout", "WiFi"]')
            ELSE PARSE_JSON('["WiFi"]')
        END as benefits,
        seq % 10 as referral_count,
        'Active' as status,
        DATEADD(day, -1 * (seq % 30), CURRENT_DATE()) as last_activity_date,
        CURRENT_TIMESTAMP() as created_at,
        CURRENT_TIMESTAMP() as updated_at
    FROM TABLE(GENERATOR(ROWCOUNT => 800)) t(seq)
    WHERE seq <= 800
)
SELECT * FROM loyalty_data;

-- Generate Room Preferences (750 guests with preferences)
INSERT INTO room_preferences
WITH pref_data AS (
    SELECT 
        'PREF_' || LPAD(seq, 6, '0') as preference_id,
        'GUEST_' || LPAD(seq, 6, '0') as guest_id,
        ['Standard King', 'Standard Queen', 'Deluxe King', 'Suite', 'Executive'][seq % 5] as room_type_preference,
        ['low', 'middle', 'high', 'no_preference'][seq % 4] as floor_preference,
        ['city', 'ocean', 'garden', 'mountain', 'pool', 'no_preference'][seq % 6] as view_preference,
        ['king', 'queen', 'twin', 'no_preference'][seq % 4] as bed_type_preference,
        seq % 20 = 0 as smoking_preference,
        seq % 50 = 0 as accessibility_needs,
        68 + (seq % 12) as temperature_preference, -- 68-79°F
        ['bright', 'dim', 'natural', 'no_preference'][seq % 4] as lighting_preference,
        ['firm', 'soft', 'memory_foam', 'feather', 'no_preference'][seq % 5] as pillow_type_preference,
        PARSE_JSON('["' || ['mini_fridge', 'coffee_maker', 'iron', 'safe', 'robe', 'slippers', 'newspaper'][seq % 7] || '", "' || ['mini_fridge', 'coffee_maker', 'iron', 'safe', 'robe', 'slippers', 'newspaper'][(seq + 1) % 7] || '"]') as room_amenities,
        ['quiet', 'moderate', 'doesnt_matter'][seq % 3] as noise_level_preference,
        CURRENT_TIMESTAMP() as last_updated,
        CURRENT_TIMESTAMP() as created_at
    FROM TABLE(GENERATOR(ROWCOUNT => 750)) t(seq)
    WHERE seq <= 750
)
SELECT * FROM pref_data;

-- Generate Booking History (2,500 bookings)
INSERT INTO booking_history
WITH booking_data AS (
    SELECT 
        'BOOKING_' || LPAD(seq, 7, '0') as booking_id,
        'GUEST_' || LPAD((seq % 800) + 1, 6, '0') as guest_id, -- Some guests have multiple bookings
        'HOTEL_' || LPAD((seq % 20) + 1, 3, '0') as hotel_id,
        DATEADD(day, -1 * ((seq * 7) % 365), CURRENT_TIMESTAMP()) as booking_date, -- Past year
        DATE(DATEADD(day, (seq * 13) % 30 + 1, booking_date)) as check_in_date, -- 1-30 days advance
        DATE(DATEADD(day, ((seq % 7) + 1), check_in_date)) as check_out_date, -- 1-7 night stays
        DATEDIFF(day, check_in_date, check_out_date) as num_nights,
        CASE WHEN seq % 10 = 0 THEN 2 ELSE 1 END + (seq % 3) as num_adults, -- 1-4 adults
        CASE WHEN seq % 5 = 0 THEN (seq % 3) ELSE 0 END as num_children, -- 0-2 children
        ['Standard King', 'Standard Queen', 'Deluxe King', 'Suite', 'Executive', 'Family Room'][seq % 6] as room_type,
        ['BAR', 'CORP', 'AAA', 'GOVT', 'PROMO', 'MEMBER'][seq % 6] as rate_code,
        ROUND(80 + (seq * 17) % 400 + (num_nights * 150) + RANDOM() * 50, 2) as total_amount,
        'USD' as currency,
        ['Website', 'Mobile App', 'Phone', 'Travel Agent', 'OTA', 'Walk-in'][seq % 6] as booking_channel,
        CASE 
            WHEN seq % 20 = 0 THEN 'Cancelled'
            WHEN seq % 100 = 0 THEN 'No-show'
            ELSE 'Confirmed'
        END as booking_status,
        CASE WHEN booking_status = 'Cancelled' THEN DATEADD(day, -1 * (seq % 7), check_in_date) ELSE NULL END as cancellation_date,
        DATEDIFF(day, booking_date, check_in_date) as advance_booking_days,
        CASE WHEN seq % 7 = 0 THEN 
            PARSE_JSON('["' || ['late_arrival', 'early_check_in', 'quiet_room', 'high_floor', 'away_from_elevator', 'connecting_rooms'][seq % 6] || '"]')
            ELSE NULL 
        END as special_requests,
        CASE WHEN seq % 15 = 0 THEN 'SAVE20' || (seq % 10) ELSE NULL END as promo_code,
        ['Credit Card', 'Debit Card', 'Digital Wallet', 'Bank Transfer', 'Points'][seq % 5] as payment_method,
        booking_date as created_at,
        booking_date as updated_at
    FROM TABLE(GENERATOR(ROWCOUNT => 2500)) t(seq)
)
SELECT * FROM booking_data;

-- =====================================================
-- STEP 4: VERIFICATION QUERIES
-- =====================================================

-- Check data was loaded successfully
SELECT 'Hotel Properties' as table_name, COUNT(*) as row_count FROM hotel_properties
UNION ALL
SELECT 'Guest Profiles' as table_name, COUNT(*) as row_count FROM guest_profiles
UNION ALL
SELECT 'Loyalty Program' as table_name, COUNT(*) as row_count FROM loyalty_program
UNION ALL
SELECT 'Room Preferences' as table_name, COUNT(*) as row_count FROM room_preferences
UNION ALL
SELECT 'Booking History' as table_name, COUNT(*) as row_count FROM booking_history
ORDER BY table_name;

-- Show sample data
SELECT 'Sample Guest Data' as info;
SELECT guest_id, first_name, last_name, email, nationality, marketing_opt_in 
FROM guest_profiles 
LIMIT 5;

SELECT 'Sample Hotel Data' as info;
SELECT hotel_id, hotel_name, brand, city, star_rating, total_rooms 
FROM hotel_properties 
LIMIT 5;

SELECT 'Sample Booking Data' as info;
SELECT booking_id, guest_id, hotel_id, check_in_date, num_nights, total_amount, booking_status 
FROM booking_history 
LIMIT 5;

-- Show deployment completion
SELECT 
    'Bronze Layer Deployment Complete' as status,
    CURRENT_TIMESTAMP() as completion_time,
    'Ready for Silver and Gold layer creation' as next_steps;




