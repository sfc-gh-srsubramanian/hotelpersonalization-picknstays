-- ============================================================================
-- Hotel Personalization - Data Generation
-- ============================================================================
-- Generates synthetic data across all Bronze layer tables
-- Creates realistic volume and variety for demo purposes
-- 
-- Data volumes:
--   - 100 hotel properties (50 AMER + 30 EMEA + 20 APAC) [after 01b expansion]
--   - 100,000 guest profiles (target 50% repeat rate)
--   - 50,000 loyalty members (50% of guests)
--   - 75,000 room preferences
--   - 70,000 service preferences
--   - 250,000 bookings (includes historical + cancelled)
--   - ~1.9M stays (realistic 60-70% occupancy over 12 months)
--   - 60,000+ amenity transactions
--   - 30,000+ amenity usage records
--   - Target repeat rate: ~50% (50K one-time guests + 50K repeat guests)
-- 
-- Session variables (set by deploy.sh):
--   $FULL_PREFIX, $PROJECT_ROLE
-- ============================================================================

USE ROLE IDENTIFIER($PROJECT_ROLE);
USE DATABASE IDENTIFIER($FULL_PREFIX);
USE SCHEMA BRONZE;

-- ============================================================================
-- 1. HOTEL PROPERTIES (50 hotels - base AMER properties)
-- ============================================================================
-- NOTE: These are the initial 50 AMER properties
-- 01b_expand_to_100_properties.sql will later add 50 more (EMEA/APAC) and region fields

-- Delete existing base properties to make this script idempotent
DELETE FROM hotel_properties WHERE hotel_id >= 'HOTEL_000' AND hotel_id <= 'HOTEL_049';

INSERT INTO hotel_properties
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 50))
),
hotel_data AS (
    SELECT 
        'HOTEL_' || LPAD(seq::VARCHAR, 3, '0') as hotel_id,
        -- Hotel name
        CASE 
            WHEN seq = 0 THEN 'Summit Peak Reserve New York'
            WHEN seq = 1 THEN 'Summit Peak Reserve Los Angeles'
            WHEN seq = 2 THEN 'Summit Peak Reserve Chicago'
            WHEN seq = 3 THEN 'Summit Peak Reserve San Francisco'
            WHEN seq = 4 THEN 'Summit Peak Reserve Miami'
            WHEN seq = 5 THEN 'Summit Peak Reserve Boston'
            WHEN seq = 6 THEN 'Summit Peak Reserve Seattle'
            WHEN seq = 7 THEN 'Summit Peak Reserve Las Vegas'
            WHEN seq = 8 THEN 'Summit Peak Reserve Honolulu'
            WHEN seq = 9 THEN 'Summit Peak Reserve Aspen'
            WHEN seq = 10 THEN 'Summit Ice Times Square'
            WHEN seq = 11 THEN 'Summit Ice Midtown Manhattan'
            WHEN seq = 12 THEN 'Summit Ice Santa Monica'
            WHEN seq = 13 THEN 'Summit Ice Beverly Hills'
            WHEN seq = 14 THEN 'Summit Ice Downtown Chicago'
            WHEN seq = 15 THEN 'Summit Ice O''Hare'
            WHEN seq = 16 THEN 'Summit Ice Dallas'
            WHEN seq = 17 THEN 'Summit Ice Houston'
            WHEN seq = 18 THEN 'Summit Ice Phoenix'
            WHEN seq = 19 THEN 'Summit Ice Atlanta'
            WHEN seq = 20 THEN 'Summit Ice Denver'
            WHEN seq = 21 THEN 'Summit Ice Orlando'
            WHEN seq = 22 THEN 'Summit Ice Nashville'
            WHEN seq = 23 THEN 'Summit Ice Austin'
            WHEN seq = 24 THEN 'Summit Ice Portland'
            WHEN seq = 25 THEN 'Summit Ice Charlotte'
            WHEN seq = 26 THEN 'Summit Ice San Diego'
            WHEN seq = 27 THEN 'Summit Ice Minneapolis'
            WHEN seq = 28 THEN 'Summit Ice Tampa'
            WHEN seq = 29 THEN 'Summit Ice Philadelphia'
            WHEN seq = 30 THEN 'Summit Permafrost Manhattan'
            WHEN seq = 31 THEN 'Summit Permafrost Silicon Valley'
            WHEN seq = 32 THEN 'Summit Permafrost Boston'
            WHEN seq = 33 THEN 'Summit Permafrost San Diego'
            WHEN seq = 34 THEN 'Summit Permafrost Washington DC'
            WHEN seq = 35 THEN 'Summit Permafrost Atlanta'
            WHEN seq = 36 THEN 'Summit Permafrost Dallas'
            WHEN seq = 37 THEN 'Summit Permafrost Seattle'
            WHEN seq = 38 THEN 'Summit Permafrost Denver'
            WHEN seq = 39 THEN 'Summit Permafrost Austin'
            WHEN seq = 40 THEN 'The Snowline Brooklyn'
            WHEN seq = 41 THEN 'The Snowline Williamsburg'
            WHEN seq = 42 THEN 'The Snowline West Hollywood'
            WHEN seq = 43 THEN 'The Snowline Wicker Park'
            WHEN seq = 44 THEN 'The Snowline Wynwood'
            WHEN seq = 45 THEN 'The Snowline Mission District'
            WHEN seq = 46 THEN 'The Snowline Capitol Hill Seattle'
            WHEN seq = 47 THEN 'The Snowline Pearl District'
            WHEN seq = 48 THEN 'The Snowline Arts District Nashville'
            WHEN seq = 49 THEN 'The Snowline South Congress Austin'
        END as hotel_name,
        -- Brand assignment by category
        CASE 
            WHEN seq BETWEEN 0 AND 9 THEN 'Summit Peak Reserve'
            WHEN seq BETWEEN 10 AND 29 THEN 'Summit Ice'
            WHEN seq BETWEEN 30 AND 39 THEN 'Summit Permafrost'
            ELSE 'The Snowline by Summit'
        END as brand,
        -- Category assignment
        CASE 
            WHEN seq BETWEEN 0 AND 9 THEN 'Luxury'
            WHEN seq BETWEEN 10 AND 29 THEN 'Select Service'
            WHEN seq BETWEEN 30 AND 39 THEN 'Extended Stay'
            ELSE 'Urban/Modern'
        END as category,
        -- Region (all initial 50 hotels are in AMER)
        'AMER' as region,
        -- Sub-region based on location
        CASE 
            WHEN seq IN (0, 10, 11, 30, 40, 41, 5, 32, 29, 34) THEN 'East Coast'
            WHEN seq IN (1, 12, 13, 42, 3, 31, 45, 26, 33, 7, 18) THEN 'West Coast'
            WHEN seq IN (2, 14, 15, 43, 27) THEN 'Midwest'
            WHEN seq IN (6, 37, 46, 24, 47, 9, 20, 38) THEN 'Mountain West'
            WHEN seq IN (4, 21, 44, 28, 16, 17, 25, 19, 35, 36, 22, 23, 39, 48, 49) THEN 'South'
            ELSE 'West Coast'
        END as sub_region,
        -- Address (realistic streets)
        CASE 
            WHEN seq = 0 THEN '350 Fifth Avenue'
            WHEN seq = 1 THEN '9920 Wilshire Boulevard'
            WHEN seq = 2 THEN '151 West Adams Street'
            WHEN seq = 3 THEN '50 Third Street'
            WHEN seq = 4 THEN '1395 Brickell Avenue'
            WHEN seq = 5 THEN '138 St James Avenue'
            WHEN seq = 6 THEN '1301 Sixth Avenue'
            WHEN seq = 7 THEN '3570 Las Vegas Boulevard'
            WHEN seq = 8 THEN '2259 Kalakaua Avenue'
            WHEN seq = 9 THEN '315 East Dean Street'
            WHEN seq = 10 THEN '226 West 52nd Street'
            WHEN seq = 11 THEN '700 Eighth Avenue'
            WHEN seq = 12 THEN '1700 Ocean Avenue'
            WHEN seq = 13 THEN '465 South Beverly Drive'
            WHEN seq = 14 THEN '172 West Adams Street'
            WHEN seq = 15 THEN '6810 North Mannheim Road'
            WHEN seq = 16 THEN '2914 Swiss Avenue'
            WHEN seq = 17 THEN '1919 Smith Street'
            WHEN seq = 18 THEN '50 East Adams Street'
            WHEN seq = 19 THEN '265 Peachtree Center Avenue'
            WHEN seq = 20 THEN '1450 Larimer Street'
            WHEN seq = 21 THEN '5905 International Drive'
            WHEN seq = 22 THEN '623 Union Street'
            WHEN seq = 23 THEN '500 East 4th Street'
            WHEN seq = 24 THEN '1510 SW Harbor Way'
            WHEN seq = 25 THEN '237 South Tryon Street'
            WHEN seq = 26 THEN '1047 Fifth Avenue'
            WHEN seq = 27 THEN '1330 Industrial Boulevard'
            WHEN seq = 28 THEN '4860 West Kennedy Boulevard'
            WHEN seq = 29 THEN '1234 Market Street'
            WHEN seq = 30 THEN '138 Lafayette Street'
            WHEN seq = 31 THEN '5155 Old Ironsides Drive'
            WHEN seq = 32 THEN '40 Berkeley Street'
            WHEN seq = 33 THEN '1433 Camino Del Rio South'
            WHEN seq = 34 THEN '1199 Vermont Avenue NW'
            WHEN seq = 35 THEN '3399 Peachtree Road NE'
            WHEN seq = 36 THEN '4440 North Central Expressway'
            WHEN seq = 37 THEN '1011 Pike Street'
            WHEN seq = 38 THEN '4950 South Syracuse Street'
            WHEN seq = 39 THEN '1603 South Congress Avenue'
            WHEN seq = 40 THEN '123 Kent Avenue'
            WHEN seq = 41 THEN '85 North 3rd Street'
            WHEN seq = 42 THEN '8490 Sunset Boulevard'
            WHEN seq = 43 THEN '1622 North Milwaukee Avenue'
            WHEN seq = 44 THEN '2913 North Miami Avenue'
            WHEN seq = 45 THEN '2655 Mission Street'
            WHEN seq = 46 THEN '1620 Belmont Avenue'
            WHEN seq = 47 THEN '411 NW Flanders Street'
            WHEN seq = 48 THEN '2115 Division Street'
            WHEN seq = 49 THEN '1603 South Congress Avenue'
        END as address_line1,
        NULL as address_line2,
        -- City
        CASE 
            WHEN seq IN (0, 10, 11, 30, 40, 41) THEN 'New York'
            WHEN seq IN (1, 12, 13, 42) THEN 'Los Angeles'
            WHEN seq IN (2, 14, 15, 43) THEN 'Chicago'
            WHEN seq IN (3, 31, 45) THEN 'San Francisco'
            WHEN seq IN (4, 44) THEN 'Miami'
            WHEN seq IN (5, 32) THEN 'Boston'
            WHEN seq IN (6, 37, 46) THEN 'Seattle'
            WHEN seq = 7 THEN 'Las Vegas'
            WHEN seq = 8 THEN 'Honolulu'
            WHEN seq = 9 THEN 'Aspen'
            WHEN seq IN (16, 36) THEN 'Dallas'
            WHEN seq = 17 THEN 'Houston'
            WHEN seq = 18 THEN 'Phoenix'
            WHEN seq IN (19, 35) THEN 'Atlanta'
            WHEN seq IN (20, 38) THEN 'Denver'
            WHEN seq = 21 THEN 'Orlando'
            WHEN seq IN (22, 48) THEN 'Nashville'
            WHEN seq IN (23, 39, 49) THEN 'Austin'
            WHEN seq IN (24, 47) THEN 'Portland'
            WHEN seq = 25 THEN 'Charlotte'
            WHEN seq IN (26, 33) THEN 'San Diego'
            WHEN seq = 27 THEN 'Minneapolis'
            WHEN seq = 28 THEN 'Tampa'
            WHEN seq = 29 THEN 'Philadelphia'
            WHEN seq = 34 THEN 'Washington'
        END as city,
        -- State
        CASE 
            WHEN seq IN (0, 10, 11, 30, 40, 41) THEN 'NY'
            WHEN seq IN (1, 12, 13, 42) THEN 'CA'
            WHEN seq IN (2, 14, 15, 43) THEN 'IL'
            WHEN seq IN (3, 31, 45) THEN 'CA'
            WHEN seq IN (4, 44) THEN 'FL'
            WHEN seq IN (5, 32) THEN 'MA'
            WHEN seq IN (6, 37, 46) THEN 'WA'
            WHEN seq = 7 THEN 'NV'
            WHEN seq = 8 THEN 'HI'
            WHEN seq = 9 THEN 'CO'
            WHEN seq IN (16, 36) THEN 'TX'
            WHEN seq = 17 THEN 'TX'
            WHEN seq = 18 THEN 'AZ'
            WHEN seq IN (19, 35) THEN 'GA'
            WHEN seq IN (20, 38) THEN 'CO'
            WHEN seq = 21 THEN 'FL'
            WHEN seq IN (22, 48) THEN 'TN'
            WHEN seq IN (23, 39, 49) THEN 'TX'
            WHEN seq IN (24, 47) THEN 'OR'
            WHEN seq = 25 THEN 'NC'
            WHEN seq IN (26, 33) THEN 'CA'
            WHEN seq = 27 THEN 'MN'
            WHEN seq = 28 THEN 'FL'
            WHEN seq = 29 THEN 'PA'
            WHEN seq = 34 THEN 'DC'
        END as state_province,
        -- Postal codes
        CASE 
            WHEN seq = 0 THEN '10118'
            WHEN seq = 1 THEN '90212'
            WHEN seq = 2 THEN '60603'
            WHEN seq = 3 THEN '94103'
            WHEN seq = 4 THEN '33131'
            WHEN seq = 5 THEN '02116'
            WHEN seq = 6 THEN '98101'
            WHEN seq = 7 THEN '89109'
            WHEN seq = 8 THEN '96815'
            WHEN seq = 9 THEN '81611'
            WHEN seq = 10 THEN '10019'
            WHEN seq = 11 THEN '10019'
            WHEN seq = 12 THEN '90401'
            WHEN seq = 13 THEN '90212'
            WHEN seq = 14 THEN '60603'
            WHEN seq = 15 THEN '60666'
            WHEN seq = 16 THEN '75204'
            WHEN seq = 17 THEN '77002'
            WHEN seq = 18 THEN '85003'
            WHEN seq = 19 THEN '30303'
            WHEN seq = 20 THEN '80202'
            WHEN seq = 21 THEN '32819'
            WHEN seq = 22 THEN '37219'
            WHEN seq = 23 THEN '78701'
            WHEN seq = 24 THEN '97201'
            WHEN seq = 25 THEN '28202'
            WHEN seq = 26 THEN '92101'
            WHEN seq = 27 THEN '55413'
            WHEN seq = 28 THEN '33609'
            WHEN seq = 29 THEN '19107'
            WHEN seq = 30 THEN '10013'
            WHEN seq = 31 THEN '95054'
            WHEN seq = 32 THEN '02116'
            WHEN seq = 33 THEN '92108'
            WHEN seq = 34 THEN '20005'
            WHEN seq = 35 THEN '30326'
            WHEN seq = 36 THEN '75206'
            WHEN seq = 37 THEN '98101'
            WHEN seq = 38 THEN '80237'
            WHEN seq = 39 THEN '78704'
            WHEN seq = 40 THEN '11249'
            WHEN seq = 41 THEN '11249'
            WHEN seq = 42 THEN '90069'
            WHEN seq = 43 THEN '60622'
            WHEN seq = 44 THEN '33127'
            WHEN seq = 45 THEN '94110'
            WHEN seq = 46 THEN '98102'
            WHEN seq = 47 THEN '97209'
            WHEN seq = 48 THEN '37203'
            WHEN seq = 49 THEN '78704'
        END as postal_code,
        'USA' as country,
        -- Latitude (realistic for each city)
        CASE 
            WHEN seq IN (0, 10, 11, 30, 40, 41) THEN CAST(40.748817 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq IN (1, 12, 13, 42) THEN CAST(34.052235 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq IN (2, 14, 15, 43) THEN CAST(41.878113 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq IN (3, 31, 45) THEN CAST(37.774929 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq IN (4, 44) THEN CAST(25.761681 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq IN (5, 32) THEN CAST(42.360081 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq IN (6, 37, 46) THEN CAST(47.606209 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq = 7 THEN CAST(36.169941 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq = 8 THEN CAST(21.306944 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq = 9 THEN CAST(39.191097 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq IN (16, 36) THEN CAST(32.776665 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq = 17 THEN CAST(29.760427 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq = 18 THEN CAST(33.448376 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq IN (19, 35) THEN CAST(33.748997 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq IN (20, 38) THEN CAST(39.739236 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq = 21 THEN CAST(28.538336 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq IN (22, 48) THEN CAST(36.162664 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq IN (23, 39, 49) THEN CAST(30.267153 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq IN (24, 47) THEN CAST(45.523064 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq = 25 THEN CAST(35.227085 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq IN (26, 33) THEN CAST(32.715736 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq = 27 THEN CAST(44.977753 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq = 28 THEN CAST(27.950575 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq = 29 THEN CAST(39.952583 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
            WHEN seq = 34 THEN CAST(38.907192 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(10,8))
        END as latitude,
        -- Longitude (realistic for each city)
        CASE 
            WHEN seq IN (0, 10, 11, 30, 40, 41) THEN CAST(-73.985428 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq IN (1, 12, 13, 42) THEN CAST(-118.243683 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq IN (2, 14, 15, 43) THEN CAST(-87.629799 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq IN (3, 31, 45) THEN CAST(-122.419418 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq IN (4, 44) THEN CAST(-80.191788 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq IN (5, 32) THEN CAST(-71.058884 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq IN (6, 37, 46) THEN CAST(-122.332069 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq = 7 THEN CAST(-115.139832 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq = 8 THEN CAST(-157.858337 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq = 9 THEN CAST(-106.817535 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq IN (16, 36) THEN CAST(-96.796989 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq = 17 THEN CAST(-95.369804 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq = 18 THEN CAST(-112.074036 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq IN (19, 35) THEN CAST(-84.387985 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq IN (20, 38) THEN CAST(-104.990251 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq = 21 THEN CAST(-81.379234 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq IN (22, 48) THEN CAST(-86.781602 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq IN (23, 39, 49) THEN CAST(-97.743057 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq IN (24, 47) THEN CAST(-122.676483 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq = 25 THEN CAST(-80.843124 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq IN (26, 33) THEN CAST(-117.161087 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq = 27 THEN CAST(-93.265015 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq = 28 THEN CAST(-82.457176 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq = 29 THEN CAST(-75.165222 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
            WHEN seq = 34 THEN CAST(-77.036873 + UNIFORM(-0.02, 0.02, RANDOM()) AS DECIMAL(11,8))
        END as longitude,
        '+1' || LPAD(((seq % 900) * 31 % 900 + 100)::VARCHAR, 3, '0') || LPAD(((seq % 9000) * 47 % 9000 + 1000)::VARCHAR, 4, '0') as phone,
        LOWER(REPLACE(REPLACE(hotel_name, ' ', '.'), '''', '')) || '@summithospitality.com' as email,
        -- Star rating by category
        CASE 
            WHEN seq BETWEEN 0 AND 9 THEN 5
            WHEN seq BETWEEN 10 AND 29 THEN 3 + (seq % 2)
            WHEN seq BETWEEN 30 AND 39 THEN 3
            ELSE 4
        END as star_rating,
        -- Total rooms by category
        CASE 
            WHEN seq BETWEEN 0 AND 9 THEN 250 + (seq * 25)
            WHEN seq BETWEEN 10 AND 29 THEN 120 + (seq % 6) * 10
            WHEN seq BETWEEN 30 AND 39 THEN 100 + (seq % 5) * 10
            ELSE 80 + (seq % 4) * 10
        END as total_rooms,
        -- Amenities by category
        CASE 
            WHEN seq BETWEEN 0 AND 9 THEN PARSE_JSON('["WiFi", "Valet Parking", "Infinity Pool", "Spa", "Fine Dining Restaurant", "Rooftop Bar", "24/7 Room Service", "Concierge", "Business Center", "Fitness Center", "Sauna"]')
            WHEN seq BETWEEN 10 AND 29 THEN PARSE_JSON('["WiFi", "Parking", "Pool", "Fitness Center", "Breakfast", "Business Center"]')
            WHEN seq BETWEEN 30 AND 39 THEN PARSE_JSON('["WiFi", "Parking", "Full Kitchen", "Laundry Facilities", "Fitness Center", "Pet Friendly", "Weekly Housekeeping"]')
            ELSE PARSE_JSON('["WiFi", "Rooftop Bar", "Co-Working Space", "Boutique Fitness", "Smart Room Tech", "Bike Rentals", "Local Art Gallery"]')
        END as amenities,
        -- Room types by category
        CASE 
            WHEN seq BETWEEN 0 AND 9 THEN PARSE_JSON('["Deluxe King", "Deluxe Queen", "Executive Suite", "Presidential Suite", "Penthouse Suite"]')
            WHEN seq BETWEEN 10 AND 29 THEN PARSE_JSON('["Standard King", "Standard Queen", "Deluxe King", "Junior Suite"]')
            WHEN seq BETWEEN 30 AND 39 THEN PARSE_JSON('["Studio Suite", "One Bedroom Suite", "Two Bedroom Suite"]')
            ELSE PARSE_JSON('["Modern King", "Modern Queen", "Urban Loft", "Skyline Suite"]')
        END as room_types,
        -- Check-in time by category
        CASE 
            WHEN seq BETWEEN 0 AND 9 THEN TIME('16:00:00')
            ELSE TIME('15:00:00')
        END as check_in_time,
        -- Check-out time by category
        CASE 
            WHEN seq BETWEEN 0 AND 9 THEN TIME('12:00:00')
            ELSE TIME('11:00:00')
        END as check_out_time,
        -- Timezone by city
        CASE 
            WHEN seq IN (0, 10, 11, 30, 40, 41, 5, 32, 29, 34) THEN 'America/New_York'
            WHEN seq IN (1, 12, 13, 42, 3, 31, 45, 26, 33, 7, 18) THEN 'America/Los_Angeles'
            WHEN seq IN (2, 14, 15, 43, 27) THEN 'America/Chicago'
            WHEN seq IN (6, 37, 46, 24, 47, 9, 20, 38) THEN 'America/Denver'
            WHEN seq = 8 THEN 'Pacific/Honolulu'
            ELSE 'America/Chicago'
        END as timezone,
        DATEADD(day, -1 * ((seq % 100) * 100 + 365), CURRENT_DATE()) as opened_date,
        DATEADD(day, -1 * ((seq % 365) * 30 + 100), CURRENT_DATE()) as last_renovation_date,
        CURRENT_TIMESTAMP() as created_at,
        CURRENT_TIMESTAMP() as updated_at
    FROM seq_generator
)
SELECT * FROM hotel_data;

-- ============================================================================
-- 2. GUEST PROFILES (100,000 guests - GUEST_000000 to GUEST_099999)
-- ============================================================================
-- Note: 100K guests to achieve ~50% repeat rate with 1.877M stays
-- 50% of guests (50K) will have only 1 stay, 50% (50K) will be repeat guests
DELETE FROM BRONZE.guest_profiles WHERE guest_id LIKE 'GUEST_%';

INSERT INTO guest_profiles
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 100000))
),
guest_data AS (
    SELECT 
        'GUEST_' || LPAD(seq::VARCHAR, 6, '0') as guest_id,
        -- First name (1,000 variants)
        (ARRAY_CONSTRUCT('James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 'Linda', 'William', 'Elizabeth',
                        'David', 'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica', 'Thomas', 'Sarah', 'Charles', 'Karen',
                        'Christopher', 'Nancy', 'Daniel', 'Lisa', 'Matthew', 'Betty', 'Anthony', 'Margaret', 'Mark', 'Sandra',
                        'Donald', 'Ashley', 'Steven', 'Kimberly', 'Paul', 'Emily', 'Andrew', 'Donna', 'Joshua', 'Michelle'))[seq % 40] as first_name,
        -- Last name (1,000 variants)
        (ARRAY_CONSTRUCT('Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
                        'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
                        'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson',
                        'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores',
                        'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts'))[seq % 50] as last_name,
        LOWER((ARRAY_CONSTRUCT('James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 'Linda', 'William', 'Elizabeth',
                        'David', 'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica', 'Thomas', 'Sarah', 'Charles', 'Karen',
                        'Christopher', 'Nancy', 'Daniel', 'Lisa', 'Matthew', 'Betty', 'Anthony', 'Margaret', 'Mark', 'Sandra',
                        'Donald', 'Ashley', 'Steven', 'Kimberly', 'Paul', 'Emily', 'Andrew', 'Donna', 'Joshua', 'Michelle'))[seq % 40]) || '.' ||
            LOWER((ARRAY_CONSTRUCT('Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
                        'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
                        'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson',
                        'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores',
                        'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts'))[seq % 50]) || 
            '@example.com' as email,
        '+1' || LPAD(((seq % 900) * 17 % 900 + 100)::VARCHAR, 3, '0') || LPAD(((seq % 9000) * 23 % 9000 + 1000)::VARCHAR, 4, '0') as phone,
        DATEADD(year, -1 * (25 + seq % 50), CURRENT_DATE()) as date_of_birth,
        CASE WHEN seq % 2 = 0 THEN 'Male' ELSE 'Female' END as gender,
        (ARRAY_CONSTRUCT('USA', 'Canada', 'UK', 'Germany', 'France', 'Japan', 'Australia', 'Mexico', 'Brazil', 'India'))[seq % 10] as nationality,
        (ARRAY_CONSTRUCT('English', 'Spanish', 'French', 'German', 'Mandarin', 'Japanese', 'Portuguese', 'Hindi', 'Arabic', 'Russian'))[seq % 10] as language_preference,
        (ARRAY_CONSTRUCT('123 Main St', '456 Oak Ave', '789 Pine Rd', '321 Elm St', '654 Maple Dr',
                        '987 Cedar Ln', '147 Birch Way', '258 Willow Ct', '369 Ash Pl', '741 Spruce Blvd'))[seq % 10] as address_line1,
        NULL as address_line2,
        (ARRAY_CONSTRUCT('New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix',
                        'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose'))[seq % 10] as city,
        (ARRAY_CONSTRUCT('NY', 'CA', 'IL', 'TX', 'AZ', 'PA', 'TX', 'CA', 'TX', 'CA'))[seq % 10] as state_province,
        LPAD((10000 + seq % 90000)::VARCHAR, 5, '0') as postal_code,
        'USA' as country,
        DATEADD(day, -1 * ((seq % 2000) * 3 + 30), CURRENT_DATE()) as registration_date,
        CURRENT_TIMESTAMP() as last_updated,
        CASE WHEN seq % 3 != 0 THEN TRUE ELSE FALSE END as marketing_opt_in,
        PARSE_JSON('{"email": true, "sms": ' || CASE WHEN seq % 2 = 0 THEN 'true' ELSE 'false' END || ', "phone": false}') as communication_preferences,
        PARSE_JSON('{"name": "Emergency Contact", "phone": "+1-555-0100", "relationship": "Family"}') as emergency_contact
    FROM seq_generator
)
SELECT * FROM guest_data;

-- ============================================================================
-- 3. LOYALTY PROGRAM (10,000 members - 50% of guests)
-- ============================================================================
-- Note: Loyalty members are the first 50K guests (GUEST_000000 to GUEST_049999) - 50% of total
DELETE FROM BRONZE.loyalty_program WHERE loyalty_id LIKE 'LOYALTY_%';

INSERT INTO loyalty_program
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 50000))
),
loyalty_data AS (
    SELECT 
        'LOYALTY_' || LPAD(seq::VARCHAR, 6, '0') as loyalty_id,
        'GUEST_' || LPAD(seq::VARCHAR, 6, '0') as guest_id,
        'Hotel Rewards Program' as program_name,
        'HRP' || LPAD(((seq % 20000) * 73)::VARCHAR, 10, '0') as member_number,
        CASE 
            WHEN seq % 100 < 10 THEN 'Diamond'   -- 10% = 5,000 members
            WHEN seq % 100 < 30 THEN 'Gold'      -- 20% = 10,000 members
            WHEN seq % 100 < 60 THEN 'Silver'    -- 30% = 15,000 members
            ELSE 'Blue'                           -- 40% = 20,000 members
        END as tier_level,
        (seq % 50000) * 127 % 50000 + 1000 as points_balance,
        (seq % 200000) * 191 % 200000 + 5000 as lifetime_points,
        DATEADD(day, -1 * ((seq % 1095) * 3), CURRENT_DATE()) as tier_qualification_date,
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
    FROM seq_generator
)
SELECT * FROM loyalty_data;

-- ============================================================================
-- 4. ROOM PREFERENCES (15,000 guests - 75% of guests, scaled 2x)
-- ============================================================================
TRUNCATE TABLE room_preferences;

INSERT INTO room_preferences
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 75000))  -- 75% of 100K guests
),
pref_data AS (
    SELECT 
        'PREF_' || LPAD(seq::VARCHAR, 6, '0') as preference_id,
        'GUEST_' || LPAD(seq::VARCHAR, 6, '0') as guest_id,
        ['Standard King', 'Standard Queen', 'Deluxe King', 'Suite', 'Executive'][seq % 5] as room_type_preference,
        ['low', 'middle', 'high', 'no_preference'][seq % 4] as floor_preference,
        ['city', 'ocean', 'garden', 'mountain', 'pool', 'no_preference'][seq % 6] as view_preference,
        ['king', 'queen', 'twin', 'no_preference'][seq % 4] as bed_type_preference,
        seq % 20 = 0 as smoking_preference,
        seq % 50 = 0 as accessibility_needs,
        68 + (seq % 12) as temperature_preference,
        ['bright', 'dim', 'natural', 'no_preference'][seq % 4] as lighting_preference,
        ['firm', 'soft', 'memory_foam', 'feather', 'no_preference'][seq % 5] as pillow_type_preference,
        PARSE_JSON('["mini_fridge", "coffee_maker"]') as room_amenities,
        ['quiet', 'moderate', 'doesnt_matter'][seq % 3] as noise_level_preference,
        CURRENT_TIMESTAMP() as last_updated,
        CURRENT_TIMESTAMP() as created_at
    FROM seq_generator
)
SELECT * FROM pref_data;

-- ============================================================================
-- 5. SERVICE PREFERENCES (14,000 guests - 70% of guests, scaled 2x)
-- ============================================================================
TRUNCATE TABLE service_preferences;

INSERT INTO service_preferences
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 70000))  -- 70% of 100K guests
),
service_data AS (
    SELECT 
        'SERV_PREF_' || LPAD(seq::VARCHAR, 6, '0') as preference_id,
        'GUEST_' || LPAD(seq::VARCHAR, 6, '0') as guest_id,
        PARSE_JSON('{"cuisines": ["italian", "asian"], "dietary_restrictions": ["none"]}') as dining_preferences,
        PARSE_JSON('["massage", "facial"]') as spa_services,
        PARSE_JSON('["gym", "pool"]') as fitness_preferences,
        PARSE_JSON('["meeting_rooms", "business_center"]') as business_services,
        PARSE_JSON('["airport_shuttle", "rental_car"]') as transportation_preferences,
        PARSE_JSON('["live_music", "bar"]') as entertainment_preferences,
        PARSE_JSON('{"frequency": "daily", "time": "morning"}') as housekeeping_preferences,
        PARSE_JSON('["restaurant_reservations", "tour_booking"]') as concierge_services,
        ['email', 'sms', 'phone', 'app'][seq % 4] as preferred_communication_method,
        TIME('15:00:00') as preferred_check_in_time,
        TIME('11:00:00') as preferred_check_out_time,
        CURRENT_TIMESTAMP() as last_updated,
        CURRENT_TIMESTAMP() as created_at
    FROM seq_generator
)
SELECT * FROM service_data;

-- ============================================================================
-- 6. BOOKING HISTORY (50,000 bookings - scaled 2x)
-- ============================================================================
TRUNCATE TABLE booking_history;

INSERT INTO booking_history
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 250000))  -- 250K bookings for 100K guests (includes historical + cancelled)
),
booking_dates AS (
    SELECT 
        seq,
        'BOOKING_' || LPAD(seq::VARCHAR, 7, '0') as booking_id,
        'GUEST_' || LPAD((seq % 100000)::VARCHAR, 6, '0') as guest_id,  -- Reference all 100K guests
        'HOTEL_' || LPAD(((seq % 100) + 1)::VARCHAR, 3, '0') as hotel_id,
        DATEADD(day, -1 * ((seq % 1095) * 7), CURRENT_TIMESTAMP()) as booking_date,
        DATE(DATEADD(day, (seq % 30) + 1, DATEADD(day, -1 * ((seq % 1095) * 7), CURRENT_TIMESTAMP()))) as check_in_date,
        (CASE WHEN seq % 10 = 0 THEN 2 ELSE 1 END + (seq % 3))::INTEGER as num_adults,
        (CASE WHEN seq % 5 = 0 THEN (seq % 3) ELSE 0 END)::INTEGER as num_children,
        ['Standard King', 'Standard Queen', 'Deluxe King', 'Suite', 'Executive', 'Family Room'][seq % 6] as room_type,
        ['BAR', 'CORP', 'AAA', 'GOVT', 'PROMO', 'MEMBER'][seq % 6] as rate_code,
        'USD' as currency,
        ['Website', 'Mobile App', 'Phone', 'Travel Agent', 'OTA', 'Walk-in'][seq % 6] as booking_channel
    FROM seq_generator
),
booking_data AS (
    SELECT 
        booking_id,
        guest_id,
        hotel_id,
        booking_date,
        check_in_date,
        DATE(DATEADD(day, ((seq % 7) + 1), check_in_date)) as check_out_date,
        ((seq % 7) + 1)::INTEGER as num_nights,
        num_adults,
        num_children,
        room_type,
        rate_code,
        CAST(80 + ((seq % 400) * 17 % 400) + ((((seq % 7) + 1) % 30) * 150) + UNIFORM(0, 50, RANDOM()) AS DECIMAL(10,2)) as total_amount,
        currency,
        booking_channel,
        CASE 
            WHEN seq % 20 = 0 THEN 'Cancelled'
            WHEN seq % 100 = 0 THEN 'No-show'
            ELSE 'Confirmed'
        END as booking_status,
        seq,
        check_in_date as temp_check_in
    FROM booking_dates
),
booking_final AS (
    SELECT
        booking_id,
        guest_id,
        hotel_id,
        booking_date,
        check_in_date,
        check_out_date,
        num_nights,
        num_adults,
        num_children,
        room_type,
        rate_code,
        total_amount,
        currency,
        booking_channel,
        booking_status,
        CASE WHEN booking_status = 'Cancelled' THEN DATEADD(day, -1 * (seq % 7), temp_check_in) ELSE NULL END as cancellation_date,
        DATEDIFF(day, booking_date, check_in_date)::INTEGER as advance_booking_days,
        CASE WHEN seq % 7 = 0 THEN 
            PARSE_JSON('["quiet_room", "high_floor"]')
            ELSE NULL 
        END as special_requests,
        CASE WHEN seq % 15 = 0 THEN 'SAVE20' ELSE NULL END as promo_code,
        ['Credit Card', 'Debit Card', 'Digital Wallet', 'Bank Transfer', 'Points'][seq % 5] as payment_method,
        booking_date as created_at,
        booking_date as updated_at
    FROM booking_data
)
SELECT 
    booking_id, guest_id, hotel_id, booking_date, check_in_date, check_out_date,
    num_nights, num_adults, num_children, room_type, rate_code, total_amount,
    currency, booking_channel, booking_status, cancellation_date, advance_booking_days,
    special_requests, promo_code, payment_method, created_at, updated_at
FROM booking_final;

-- ============================================================================
-- 7. STAY HISTORY (~1.9M stays with realistic 60-70% occupancy)
-- ============================================================================
-- Generates stays based on daily check-ins with realistic occupancy patterns
-- For 100 properties × ~250 rooms × 365 days × 22% daily check-in rate = ~1.9M stays
-- This results in ~60-70% occupancy with avg 3-night stays
--
-- DETERMINISTIC REPEAT RATE LOGIC:
-- - Diamond: 75% repeat rate (25% one-timers get exactly 1 stay, 75% repeaters cycle)
-- - Gold: 60% repeat rate (40% one-timers, 60% repeaters)
-- - Silver: 50% repeat rate (50% one-timers, 50% repeaters)
-- - Blue: 40% repeat rate (60% one-timers, 40% repeaters)
-- - Non-Member: 20% repeat rate (80% one-timers, 20% repeaters)
--
-- Regional Pricing Multipliers (applied to room charges):
-- - AMER: 1.25x (higher cost markets)
-- - EMEA: 1.00x (baseline)
-- - APAC: 0.80x (lower cost markets)
--
-- Loyalty Tier Revenue Multipliers (applied after regional):
-- - Diamond: 1.30x (suite upgrades, premium amenities)
-- - Gold: 1.20x
-- - Silver: 1.10x
-- - Blue: 1.05x
-- - Non-Member: 1.00x

TRUNCATE TABLE stay_history;

INSERT INTO stay_history
WITH date_range AS (
    -- Last 12 months of check-in dates
    SELECT DATEADD(day, -SEQ4(), CURRENT_DATE()) as check_in_date
    FROM TABLE(GENERATOR(ROWCOUNT => 365))
    WHERE DATEADD(day, -SEQ4(), CURRENT_DATE()) >= DATEADD(month, -12, CURRENT_DATE())
),
hotel_capacity AS (
    SELECT 
        hotel_id,
        total_rooms,
        brand,
        region,
        -- Target daily check-in rate (20-24% of rooms check in each day)
        -- Results in 60-72% occupancy with 3-night average stays
        CASE 
            WHEN brand IN ('Summit Peak Reserve', 'The Snowline by Summit') THEN 0.24
            WHEN brand = 'Summit Ice' THEN 0.23
            ELSE 0.21
        END as checkin_rate,
        -- Regional pricing multiplier (creates realistic RevPAR variance)
        CASE 
            WHEN region = 'AMER' THEN 1.25  -- Americas: highest rates (US market premium)
            WHEN region = 'EMEA' THEN 1.0   -- EMEA: baseline rates
            WHEN region = 'APAC' THEN 0.80  -- APAC: lower rates (different market dynamics)
            ELSE 1.0
        END as regional_multiplier
    FROM hotel_properties
),
daily_checkins AS (
    SELECT 
        dr.check_in_date,
        hc.hotel_id,
        hc.brand,
        hc.region,
        hc.regional_multiplier,
        hc.total_rooms,
        -- Calculate check-ins for this day with seasonality
        ROUND(hc.total_rooms * hc.checkin_rate * 
            (1 + 0.15 * SIN(DATEDIFF(day, '2025-01-01', dr.check_in_date) * 2 * 3.14159 / 365))
        ) as checkins_today
    FROM date_range dr
    CROSS JOIN hotel_capacity hc
),
stay_generator AS (
    SELECT 
        dc.check_in_date,
        dc.hotel_id,
        dc.brand,
        dc.region,
        dc.regional_multiplier,
        ROW_NUMBER() OVER (PARTITION BY dc.check_in_date, dc.hotel_id ORDER BY SEQ4()) as checkin_seq,
        dc.checkins_today,
        -- Stay length distribution (weighted toward 2-3 nights)
        CASE 
            WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN 1
            WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 2
            WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 3
            WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 4
            ELSE 5 + UNIFORM(0, 2, RANDOM())
        END as num_nights,
        -- Calculate global stay index for guest assignment
        ROW_NUMBER() OVER (ORDER BY dc.check_in_date, dc.hotel_id) as global_stay_num
    FROM daily_checkins dc
    CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 100))
    QUALIFY checkin_seq <= checkins_today
),
tier_assignment_with_rand AS (
SELECT 
        sg.*,
        -- Generate single random number for tier assignment (0-99)
        UNIFORM(0, 100, RANDOM()) as tier_rand
    FROM stay_generator sg
),
tier_assignment AS (
    SELECT 
        *,
        -- Assign tier based on stay distribution using SINGLE random number
        -- Higher tiers stay more frequently, so stay % > guest %
        CASE 
            WHEN tier_rand < 13 THEN 'Diamond'    -- 13% of stays (from 10% of guests who stay frequently)
            WHEN tier_rand < 35 THEN 'Gold'       -- 22% more stays (cumulative 35%)
            WHEN tier_rand < 62 THEN 'Silver'     -- 27% more stays (cumulative 62%)
            WHEN tier_rand < 90 THEN 'Blue'       -- 28% more stays (cumulative 90%)
            ELSE 'Non-Member'                      -- 10% of stays (from 50% of guests who rarely stay)
        END as tier
    FROM tier_assignment_with_rand
),
tier_stay_sequence AS (
    SELECT 
        ta.*,
        -- For each tier, number stays sequentially for deterministic one-timer/repeater split
        ROW_NUMBER() OVER (PARTITION BY tier ORDER BY global_stay_num) as tier_stay_num,
        COUNT(*) OVER (PARTITION BY tier) as tier_total_stays
    FROM tier_assignment ta
),
stay_with_guest AS (
    SELECT 
        tss.*,
        -- SCATTERED PATTERN GUEST ASSIGNMENT
        -- Match loyalty_program's seq%100 logic for tier assignment
        -- Target repeat rates: Diamond 75%, Gold 60%, Silver 50%, Blue 40%, Non-Member 20%
        CASE 
            WHEN tier = 'Diamond' THEN
                -- Diamond: seq%100 < 10 (guests at 0-9, 100-109, 200-209, etc.)
                -- 3,750 repeaters out of 5,000 members (75% repeat rate)
                -- Formula: block*100 + offset where offset in [0,9]
                'GUEST_' || LPAD(
                    (FLOOR(((tier_stay_num - 1) % 3750) / 10) * 100 + 
                     ((tier_stay_num - 1) % 3750) % 10)::VARCHAR, 
                    6, '0')
            
            WHEN tier = 'Gold' THEN
                -- Gold: seq%100 in [10,29] (guests at 10-29, 110-129, 210-229, etc.)
                -- 6,000 repeaters out of 10,000 members (60% repeat rate)
                -- Formula: block*100 + 10 + offset where offset in [0,19]
                'GUEST_' || LPAD(
                    (FLOOR(((tier_stay_num - 1) % 6000) / 20) * 100 + 10 + 
                     ((tier_stay_num - 1) % 6000) % 20)::VARCHAR, 
                    6, '0')
            
            WHEN tier = 'Silver' THEN
                -- Silver: seq%100 in [30,59] (guests at 30-59, 130-159, 230-259, etc.)
                -- 7,500 repeaters out of 15,000 members (50% repeat rate)
                -- Formula: block*100 + 30 + offset where offset in [0,29]
                'GUEST_' || LPAD(
                    (FLOOR(((tier_stay_num - 1) % 7500) / 30) * 100 + 30 + 
                     ((tier_stay_num - 1) % 7500) % 30)::VARCHAR, 
                    6, '0')
            
            WHEN tier = 'Blue' THEN
                -- Blue: seq%100 in [60,99] (guests at 60-99, 160-199, 260-299, etc.)
                -- 8,000 repeaters out of 20,000 members (40% repeat rate)
                -- Formula: block*100 + 60 + offset where offset in [0,39]
                'GUEST_' || LPAD(
                    (FLOOR(((tier_stay_num - 1) % 8000) / 40) * 100 + 60 + 
                     ((tier_stay_num - 1) % 8000) % 40)::VARCHAR, 
                    6, '0')
            
            ELSE
                -- Non-members: GUEST_050000-099999
                -- 10,000 repeaters out of 50,000 (20% repeat rate)
                'GUEST_' || LPAD((50000 + ((tier_stay_num - 1) % 10000))::VARCHAR, 6, '0')
        END as guest_id
    FROM tier_stay_sequence tss
)
SELECT 
    'STAY_' || LPAD(swg.global_stay_num::VARCHAR, 8, '0') as stay_id,
    'BOOKING_' || LPAD(swg.global_stay_num::VARCHAR, 8, '0') as booking_id,
    swg.guest_id,
    swg.hotel_id,
    LPAD((UNIFORM(100, 999, RANDOM()))::VARCHAR, 3, '0') as room_number,
    swg.check_in_date::TIMESTAMP as actual_check_in,
    DATEADD(day, swg.num_nights, swg.check_in_date)::TIMESTAMP as actual_check_out,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 'Standard King'
        WHEN UNIFORM(0, 100, RANDOM()) < 75 THEN 'Standard Queen'
        WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'Deluxe King'
        WHEN UNIFORM(0, 100, RANDOM()) < 97 THEN 'Suite'
        ELSE 'Executive'
    END as room_type,
    UNIFORM(1, 20, RANDOM()) as floor_number,
    CASE UNIFORM(0, 3, RANDOM())
        WHEN 0 THEN 'City View'
        WHEN 1 THEN 'Ocean View'
        WHEN 2 THEN 'Mountain View'
        ELSE 'Garden View'
    END as view_type,
    CASE UNIFORM(0, 2, RANDOM())
        WHEN 0 THEN 'King'
        WHEN 1 THEN 'Queen'
        ELSE 'Twin'
    END as bed_type,
    -- Realistic pricing with REGIONAL + LOYALTY TIER multipliers
    -- Base price by brand, then multiply by region and loyalty tier
    ROUND(
        swg.num_nights * (
            CASE 
                WHEN swg.brand = 'Summit Peak Reserve' THEN 350 + UNIFORM(0, 150, RANDOM())
                WHEN swg.brand = 'The Snowline by Summit' THEN 320 + UNIFORM(0, 120, RANDOM())
                WHEN swg.brand = 'Summit Ice' THEN 180 + UNIFORM(0, 80, RANDOM())
                ELSE 140 + UNIFORM(0, 60, RANDOM())
            END
        ) * swg.regional_multiplier  -- Regional pricing (AMER 1.25x, EMEA 1.0x, APAC 0.80x)
        * (
            -- Loyalty tier pricing (Diamond pays more for premium service)
            -- Use scattered pattern matching: extract numeric part and check seq%100
            CASE 
                WHEN swg.guest_id >= 'GUEST_050000' THEN 1.00  -- Non-members: base rate
                WHEN (SUBSTRING(swg.guest_id, 7, 6)::INTEGER % 100) < 10 THEN 1.30  -- Diamond: 30% premium
                WHEN (SUBSTRING(swg.guest_id, 7, 6)::INTEGER % 100) BETWEEN 10 AND 29 THEN 1.20  -- Gold: 20% premium
                WHEN (SUBSTRING(swg.guest_id, 7, 6)::INTEGER % 100) BETWEEN 30 AND 59 THEN 1.10  -- Silver: 10% premium
                ELSE 1.05  -- Blue (60-99): 5% premium
            END
        ) * 1.30, 2) as total_charges,  -- Total includes room + tax + incidentals
    ROUND(total_charges / 1.30, 2) as room_charges,
    ROUND(room_charges * 0.08, 2) as tax_amount,
    ROUND(room_charges * 0.22, 2) as incidental_charges,
    FALSE as no_show,
    UNIFORM(0, 100, RANDOM()) < 5 as early_departure,
    UNIFORM(0, 100, RANDOM()) < 10 as late_checkout,
    -- Guest satisfaction varies by loyalty tier (higher tiers have higher expectations but better service)
    70 + UNIFORM(0, 30, RANDOM()) + (
        CASE 
            WHEN swg.guest_id >= 'GUEST_050000' THEN 0  -- Non-members: baseline
            WHEN (SUBSTRING(swg.guest_id, 7, 6)::INTEGER % 100) < 10 THEN 5  -- Diamond: +5 (better service)
            WHEN (SUBSTRING(swg.guest_id, 7, 6)::INTEGER % 100) BETWEEN 10 AND 29 THEN 3  -- Gold: +3
            WHEN (SUBSTRING(swg.guest_id, 7, 6)::INTEGER % 100) BETWEEN 30 AND 59 THEN 2  -- Silver: +2
            ELSE 1  -- Blue: +1
        END
    ) as guest_satisfaction_score,  -- Scale: 70-105 (capped at 100 by table constraints)
    NULL as staff_notes,
    swg.check_in_date::TIMESTAMP as created_at
FROM stay_with_guest swg;

-- ============================================================================
-- 8. AMENITY TRANSACTIONS (60,000+ transactions - scaled 2x)
-- ============================================================================
TRUNCATE TABLE amenity_transactions;

INSERT INTO amenity_transactions
WITH amenity_services AS (
    SELECT * FROM VALUES
    -- Spa Services
    ('spa', 'Swedish Massage', 120.00, 'Serenity Spa'),
    ('spa', 'Deep Tissue Massage', 140.00, 'Serenity Spa'),
    ('spa', 'Facial Treatment', 95.00, 'Serenity Spa'),
    
    -- Restaurant Services
    ('restaurant', 'Prix Fixe Dinner', 85.00, 'Azure Restaurant'),
    ('restaurant', 'Breakfast Buffet', 35.00, 'Garden Cafe'),
    ('restaurant', 'Lunch Special', 28.00, 'Garden Cafe'),
    
    -- Bar Services
    ('bar', 'Craft Cocktails', 18.00, 'Skyline Lounge'),
    ('bar', 'Premium Wine Glass', 22.00, 'Skyline Lounge'),
    ('bar', 'Wine Bottle Service', 85.00, 'Skyline Lounge'),
    
    -- Room Service
    ('room_service', 'Gourmet Breakfast', 42.00, 'In-Room Dining'),
    ('room_service', 'Late Night Menu', 35.00, 'In-Room Dining'),
    ('room_service', 'Romantic Dinner', 95.00, 'In-Room Dining'),
    
    -- WiFi Upgrades
    ('wifi', 'Premium WiFi Upgrade', 15.00, 'Guest Room'),
    ('wifi', 'Business WiFi Package', 25.00, 'Guest Room'),
    
    -- Smart TV Premium
    ('smart_tv', 'Premium Channel Package', 12.00, 'Guest Room'),
    ('smart_tv', 'Movie Rental Premium', 8.00, 'Guest Room'),
    
    -- Pool Services
    ('pool_services', 'Poolside Cabana Rental', 85.00, 'Pool Deck'),
    ('pool_services', 'Pool Bar Service', 45.00, 'Pool Bar')
    
    AS t(category, service, base_price, location)
),
transactions AS (
    SELECT 
        'TRANS_' || LPAD((ROW_NUMBER() OVER (ORDER BY RANDOM()))::INTEGER::VARCHAR, 8, '0') as transaction_id,
        sh.stay_id,
        sh.guest_id,
        a.category as amenity_category,
        a.service as service_name,
        DATEADD(HOUR, UNIFORM(0, 168, RANDOM())::INTEGER, sh.actual_check_in) as transaction_date,
        CAST(a.base_price * (0.8 + UNIFORM(0, 0.4, RANDOM())) AS DECIMAL(10,2)) as amount,
        CASE 
            WHEN a.category IN ('spa', 'room_service', 'wifi') THEN 1
            WHEN a.category IN ('restaurant', 'smart_tv') THEN UNIFORM(1, 2, RANDOM())::INTEGER
            ELSE UNIFORM(1, 4, RANDOM())::INTEGER
        END as quantity,
        a.location,
        CASE 
            WHEN UNIFORM(0, 99, RANDOM())::INTEGER < 5 THEN 1
            WHEN UNIFORM(0, 99, RANDOM())::INTEGER < 15 THEN 2
            WHEN UNIFORM(0, 99, RANDOM())::INTEGER < 35 THEN 3
            WHEN UNIFORM(0, 99, RANDOM())::INTEGER < 65 THEN 4
            ELSE 5
        END as guest_satisfaction,
        CASE WHEN a.category IN ('wifi', 'smart_tv') THEN 'upgrade' ELSE 'paid' END as service_type,
        a.service as service_subcategory,
        a.base_price > 100 as is_premium_service,
        FALSE as is_repeat_service,
        CASE 
            WHEN a.category = 'spa' THEN UNIFORM(30, 120, RANDOM())::INTEGER
            WHEN a.category = 'restaurant' THEN UNIFORM(45, 180, RANDOM())::INTEGER
            ELSE NULL
        END as duration_minutes,
        'STAFF_' || LPAD(UNIFORM(1, 50, RANDOM())::INTEGER::VARCHAR, 3, '0') as staff_id,
        sh.hotel_id,
        sh.booking_id
    FROM stay_history sh
    CROSS JOIN amenity_services a
    WHERE UNIFORM(0, 99, RANDOM())::INTEGER < 20
    LIMIT 60000
)
SELECT * FROM transactions;

-- ============================================================================
-- 9. AMENITY USAGE (30,000+ usage records - scaled 2x)
-- ============================================================================
TRUNCATE TABLE amenity_usage;

INSERT INTO amenity_usage
WITH usage_amenities AS (
    SELECT * FROM VALUES
    -- WiFi Usage (high coverage - 80% of stays)
    ('wifi', 'Regular WiFi', 'free'),
    ('wifi', 'Premium WiFi', 'paid'),
    
    -- Smart TV Usage (high coverage - 70% of stays)
    ('smart_tv', 'Basic Smart TV', 'free'),
    ('smart_tv', 'Premium Channels', 'paid'),
    
    -- Pool Usage (moderate coverage - 40% of stays)
    ('pool', 'Main Pool', 'free'),
    ('pool', 'VIP Pool Area', 'paid'),
    ('pool', 'Pool Cabana', 'paid'),
    
    -- Spa Usage (lower coverage - 25% of stays, premium amenity)
    ('spa', 'Spa Facilities', 'paid'),
    ('spa', 'Fitness Center', 'free'),
    
    -- Restaurant/Bar (moderate-high coverage - 60% of stays)
    ('restaurant', 'Hotel Restaurant', 'paid'),
    ('bar', 'Hotel Bar', 'paid')
    
    AS t(category, amenity, usage_type)
),
usage_base AS (
    SELECT 
        'USAGE_' || LPAD((ROW_NUMBER() OVER (ORDER BY RANDOM()))::INTEGER::VARCHAR, 8, '0') as usage_id,
        sh.stay_id,
        sh.guest_id,
        a.category as amenity_category,
        a.amenity as amenity_name,
        DATEADD(HOUR, UNIFORM(0, 168, RANDOM())::INTEGER, sh.actual_check_in) as usage_start_time,
        UNIFORM(15, 240, RANDOM())::INTEGER as duration_minutes,
        CASE 
            WHEN a.category = 'wifi' THEN 'Room ' || (100 + UNIFORM(1, 500, RANDOM())::INTEGER)::VARCHAR
            WHEN a.category = 'smart_tv' THEN 'Room ' || (100 + UNIFORM(1, 500, RANDOM())::INTEGER)::VARCHAR
            WHEN a.category = 'pool' THEN 'Pool Deck'
            WHEN a.category = 'spa' THEN 'Spa Level'
            WHEN a.category IN ('restaurant', 'bar') THEN 'Restaurant Level'
        END as location,
        CASE 
            WHEN a.category = 'wifi' THEN 'Device_' || UNIFORM(1000, 9999, RANDOM())::INTEGER::VARCHAR
            WHEN a.category = 'smart_tv' THEN 'TV_' || UNIFORM(100, 999, RANDOM())::INTEGER::VARCHAR
            ELSE NULL
        END as device_info,
        a.usage_type,
        -- Loyalty guests have higher satisfaction with amenities
        CASE 
            WHEN sh.guest_id < 'GUEST_030000' AND UNIFORM(0, 99, RANDOM())::INTEGER < 20 THEN 5  -- High-tier loyalty: mostly 5s
            WHEN UNIFORM(0, 99, RANDOM())::INTEGER < 5 THEN 1
            WHEN UNIFORM(0, 99, RANDOM())::INTEGER < 15 THEN 2
            WHEN UNIFORM(0, 99, RANDOM())::INTEGER < 40 THEN 3
            WHEN UNIFORM(0, 99, RANDOM())::INTEGER < 70 THEN 4
            ELSE 5
        END as guest_satisfaction,
        UNIFORM(1, 5, RANDOM())::INTEGER as usage_frequency,
        CASE WHEN a.category = 'wifi' THEN UNIFORM(50, 2000, RANDOM())::INTEGER ELSE NULL END as data_consumed_mb,
        CASE WHEN a.category = 'smart_tv' THEN PARSE_JSON('["Netflix", "HBO", "ESPN"]') ELSE NULL END as channels_accessed,
        CURRENT_TIMESTAMP() as created_at
    FROM stay_history sh
    CROSS JOIN usage_amenities a
    -- Higher coverage: 50% chance each amenity is used (was 15%)
    -- Varies by category: wifi/TV high usage, spa lower
    WHERE (
        (a.category = 'wifi' AND UNIFORM(0, 99, RANDOM())::INTEGER < 80) OR
        (a.category = 'smart_tv' AND UNIFORM(0, 99, RANDOM())::INTEGER < 70) OR
        (a.category IN ('restaurant', 'bar') AND UNIFORM(0, 99, RANDOM())::INTEGER < 60) OR
        (a.category = 'pool' AND UNIFORM(0, 99, RANDOM())::INTEGER < 40) OR
        (a.category = 'spa' AND UNIFORM(0, 99, RANDOM())::INTEGER < 25)
    )
    -- Generate ~4-5M usage records (was 15K) - realistic for ~1.9M stays
    LIMIT 5000000
),
usage_records AS (
    SELECT
        usage_id,
        stay_id,
        guest_id,
        amenity_category,
        amenity_name,
        usage_start_time,
        DATEADD(MINUTE, duration_minutes, usage_start_time) as usage_end_time,
        duration_minutes as usage_duration_minutes,
        location,
        device_info,
        usage_type,
        guest_satisfaction,
        usage_frequency,
        data_consumed_mb,
        channels_accessed,
        created_at
    FROM usage_base
)
SELECT * FROM usage_records;

-- ============================================================================
-- 10. SOCIAL MEDIA ACTIVITY (5,000 activities)
-- ============================================================================
TRUNCATE TABLE social_media_activity;

INSERT INTO social_media_activity
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 5000))
),
social_data AS (
    SELECT 
        'SOCIAL_' || LPAD(seq::VARCHAR, 7, '0') as activity_id,
        'GUEST_' || LPAD(((seq % 4000) + 1)::VARCHAR, 6, '0') as guest_id,
        ['Instagram', 'Twitter', 'Facebook', 'TikTok', 'LinkedIn'][seq % 5] as platform,
        ['Post', 'Share', 'Review', 'Check-in'][seq % 4] as activity_type,
        PARSE_JSON('{"text": "Great stay!", "hashtags": ["hotel", "travel", "vacation"]}') as content,
        CAST(-1.0 + UNIFORM(0, 2.0, RANDOM()) AS DECIMAL(3,2)) as sentiment_score,
        PARSE_JSON('{"likes": ' || UNIFORM(0, 500, RANDOM())::INTEGER || ', "shares": ' || UNIFORM(0, 50, RANDOM())::INTEGER || ', "comments": ' || UNIFORM(0, 100, RANDOM())::INTEGER || '}') as engagement_metrics,
        ['New York', 'Los Angeles', 'Chicago'][seq % 3] as location_tag,
        seq % 2 = 0 as hotel_mention,
        seq % 3 = 0 as brand_mention,
        DATEADD(day, -1 * (seq % 365), CURRENT_TIMESTAMP()) as activity_date,
        CURRENT_TIMESTAMP() as processed_at,
        CURRENT_TIMESTAMP() as created_at
    FROM seq_generator
)
SELECT * FROM social_data;

-- ============================================================================
-- 11. FEEDBACK REVIEWS (10,000 reviews)
-- ============================================================================
TRUNCATE TABLE feedback_reviews;

INSERT INTO feedback_reviews
WITH review_base AS (
    SELECT 
        'REVIEW_' || LPAD((ROW_NUMBER() OVER (ORDER BY sh.actual_check_out))::INTEGER::VARCHAR, 7, '0') as review_id,
        sh.guest_id,
        sh.stay_id,
        sh.hotel_id,
        sh.guest_satisfaction_score as overall_rating,
        GREATEST(1, sh.guest_satisfaction_score + UNIFORM(-1, 1, RANDOM())::INTEGER) as room_rating,
        GREATEST(1, sh.guest_satisfaction_score + UNIFORM(-1, 1, RANDOM())::INTEGER) as service_rating,
        GREATEST(1, sh.guest_satisfaction_score + UNIFORM(-1, 1, RANDOM())::INTEGER) as cleanliness_rating,
        GREATEST(1, sh.guest_satisfaction_score + UNIFORM(-1, 1, RANDOM())::INTEGER) as amenities_rating,
        GREATEST(1, sh.guest_satisfaction_score + UNIFORM(-1, 1, RANDOM())::INTEGER) as location_rating,
        GREATEST(1, sh.guest_satisfaction_score + UNIFORM(-1, 1, RANDOM())::INTEGER) as value_rating,
        CASE 
            WHEN sh.guest_satisfaction_score >= 4 THEN 'Excellent hotel experience!'
            WHEN sh.guest_satisfaction_score >= 3 THEN 'Good stay overall.'
            ELSE 'Room for improvement.'
        END as review_text,
        DATEADD(day, UNIFORM(1, 7, RANDOM())::INTEGER, sh.actual_check_out) as review_date,
        ['Internal', 'TripAdvisor', 'Google', 'Booking.com'][UNIFORM(0, 3, RANDOM())::INTEGER] as platform,
        TRUE as verified_stay,
        UNIFORM(0, 50, RANDOM())::INTEGER as helpful_votes,
        CASE WHEN UNIFORM(0, 2, RANDOM())::INTEGER = 0 THEN 'Thank you for your feedback!' ELSE NULL END as management_response,
        PARSE_JSON('{"sentiment": ' || (sh.guest_satisfaction_score / 5.0)::STRING || '}') as sentiment_analysis,
        CURRENT_TIMESTAMP() as created_at,
        sh.actual_check_out
    FROM stay_history sh
    WHERE UNIFORM(0, 1, RANDOM()) < 0.5
    LIMIT 10000
),
review_data AS (
    SELECT
        review_id,
        guest_id,
        stay_id,
        hotel_id,
        overall_rating,
        room_rating,
        service_rating,
        cleanliness_rating,
        amenities_rating,
        location_rating,
        value_rating,
        review_text,
        review_date,
        platform,
        verified_stay,
        helpful_votes,
        management_response,
        CASE WHEN management_response IS NOT NULL THEN DATEADD(day, 1, review_date) ELSE NULL END as response_date,
        sentiment_analysis,
        created_at
    FROM review_base
)
SELECT * FROM review_data;

-- ============================================================================
-- Summary
-- ============================================================================
SELECT 'Data generation completed successfully!' AS STATUS;
SELECT 
    'Hotels: 50, Guests: 10,000, Bookings: 25,000, Stays: 20,000' AS CORE_DATA,
    'Amenity Transactions: 30,000+, Usage Records: 15,000+' AS AMENITY_DATA,
    'Ready for Silver layer transformation' AS NEXT_STEP;

