-- =====================================================================
-- Script: 01b_expand_to_100_properties.sql
-- Purpose: Expand portfolio from 50 to 100 properties globally
--          Add regional fields (region, sub_region)
--          Generate 30 EMEA + 20 APAC properties
-- =====================================================================

-- Database and schema context set by deploy script

-- =====================================================================
-- Step 1: Add Region Columns to hotel_properties
-- =====================================================================

ALTER TABLE BRONZE.hotel_properties ADD COLUMN IF NOT EXISTS region VARCHAR(10);
ALTER TABLE BRONZE.hotel_properties ADD COLUMN IF NOT EXISTS sub_region VARCHAR(50);

-- =====================================================================
-- Step 2: Update Existing 50 AMER Properties with Regional Assignments
-- =====================================================================

UPDATE BRONZE.hotel_properties
SET 
    region = 'AMER',
    sub_region = CASE
        -- Northeast (10 properties)
        WHEN state_province IN ('NY', 'MA', 'PA', 'DC', 'NJ', 'CT', 'MD', 'VA') THEN 'Northeast'
        -- Southeast (10 properties)
        WHEN state_province IN ('FL', 'GA', 'TN', 'NC', 'SC', 'AL', 'LA', 'MS') THEN 'Southeast'
        -- Central (10 properties)
        WHEN state_province IN ('IL', 'TX', 'MN', 'OH', 'MO', 'IN', 'MI', 'WI') THEN 'Central'
        -- West (10 properties)
        WHEN state_province IN ('CA', 'WA', 'NV', 'CO', 'AZ', 'OR', 'UT', 'ID') THEN 'West'
        -- Canada (6 properties)
        WHEN country = 'Canada' THEN 'Canada'
        -- Mexico (4 properties)
        WHEN country = 'Mexico' THEN 'Mexico'
        ELSE 'Other'
    END
WHERE hotel_id LIKE 'HOTEL_0%';

-- =====================================================================
-- Step 3: Generate 50 New Global Properties (30 EMEA + 20 APAC)
-- =====================================================================

-- Delete any existing global properties (HOTEL_050 onwards) to make this idempotent
-- Also remove any duplicate HOTEL_050 entries that may have been created
DELETE FROM BRONZE.hotel_properties WHERE hotel_id >= 'HOTEL_050' AND hotel_id <= 'HOTEL_099';

INSERT INTO BRONZE.hotel_properties
WITH new_properties AS (
    SELECT 
        (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq,
        'HOTEL_' || LPAD((50 + seq)::VARCHAR, 3, '0') as hotel_id,
        
        -- Determine region and sub_region
        CASE 
            WHEN seq < 30 THEN 'EMEA'
            ELSE 'APAC'
        END as region,
        
        CASE 
            -- EMEA Sub-regions (0-29)
            WHEN seq < 8 THEN 'United Kingdom'
            WHEN seq >= 8 AND seq < 20 THEN 'Western Europe'
            WHEN seq >= 20 AND seq < 30 THEN 'Middle East'
            -- APAC Sub-regions (30-49)
            WHEN seq >= 30 AND seq < 40 THEN 'East Asia'
            WHEN seq >= 40 AND seq < 46 THEN 'Southeast Asia'
            WHEN seq >= 46 THEN 'Oceania'
        END as sub_region,
        
        -- Brand assignment (maintain 20/40/20/20 distribution)
        CASE 
            WHEN seq % 5 = 0 THEN 'Summit Peak Reserve'
            WHEN seq % 5 IN (1, 2) THEN 'Summit Ice'
            WHEN seq % 5 = 3 THEN 'Summit Permafrost'
            ELSE 'The Snowline by Summit'
        END as brand,
        
        -- Category
        CASE 
            WHEN seq % 5 = 0 THEN 'Luxury'
            WHEN seq % 5 IN (1, 2) THEN 'Select Service'
            WHEN seq % 5 = 3 THEN 'Extended Stay'
            ELSE 'Urban/Modern'
        END as category,
        
        -- Country
        CASE 
            -- EMEA countries
            WHEN seq < 8 THEN 'United Kingdom'
            WHEN seq IN (8, 9, 10, 11) THEN 'France'
            WHEN seq IN (12, 13, 14) THEN 'Germany'
            WHEN seq IN (15, 16) THEN 'Netherlands'
            WHEN seq IN (17, 18) THEN 'Italy'
            WHEN seq = 19 THEN 'Spain'
            WHEN seq IN (20, 21, 22) THEN 'United Arab Emirates'
            WHEN seq IN (23, 24) THEN 'Saudi Arabia'
            WHEN seq IN (25, 26) THEN 'Qatar'
            WHEN seq = 27 THEN 'Oman'
            WHEN seq = 28 THEN 'Bahrain'
            WHEN seq = 29 THEN 'Qatar'
            -- APAC countries
            WHEN seq IN (30, 31, 32, 33, 34) THEN 'Japan'
            WHEN seq IN (35, 36, 37) THEN 'China'
            WHEN seq IN (38, 39) THEN 'South Korea'
            WHEN seq IN (40, 41) THEN 'Singapore'
            WHEN seq IN (42, 43) THEN 'Thailand'
            WHEN seq = 44 THEN 'Malaysia'
            WHEN seq = 45 THEN 'Philippines'
            WHEN seq IN (46, 47) THEN 'Australia'
            WHEN seq = 48 THEN 'Australia'
            WHEN seq = 49 THEN 'New Zealand'
        END as country,
        
        -- City
        CASE 
            WHEN seq = 0 THEN 'London'
            WHEN seq = 1 THEN 'London'
            WHEN seq = 2 THEN 'London'
            WHEN seq = 3 THEN 'Manchester'
            WHEN seq = 4 THEN 'Edinburgh'
            WHEN seq = 5 THEN 'Birmingham'
            WHEN seq = 6 THEN 'Liverpool'
            WHEN seq = 7 THEN 'Bristol'
            WHEN seq = 8 THEN 'Paris'
            WHEN seq = 9 THEN 'Paris'
            WHEN seq = 10 THEN 'Lyon'
            WHEN seq = 11 THEN 'Nice'
            WHEN seq = 12 THEN 'Berlin'
            WHEN seq = 13 THEN 'Munich'
            WHEN seq = 14 THEN 'Frankfurt'
            WHEN seq = 15 THEN 'Amsterdam'
            WHEN seq = 16 THEN 'Amsterdam'
            WHEN seq = 17 THEN 'Rome'
            WHEN seq = 18 THEN 'Milan'
            WHEN seq = 19 THEN 'Barcelona'
            WHEN seq = 20 THEN 'Dubai'
            WHEN seq = 21 THEN 'Dubai'
            WHEN seq = 22 THEN 'Dubai'
            WHEN seq = 23 THEN 'Abu Dhabi'
            WHEN seq = 24 THEN 'Abu Dhabi'
            WHEN seq = 25 THEN 'Doha'
            WHEN seq = 26 THEN 'Doha'
            WHEN seq = 27 THEN 'Riyadh'
            WHEN seq = 28 THEN 'Jeddah'
            WHEN seq = 29 THEN 'Muscat'
            WHEN seq = 30 THEN 'Tokyo'
            WHEN seq = 31 THEN 'Tokyo'
            WHEN seq = 32 THEN 'Tokyo'
            WHEN seq = 33 THEN 'Osaka'
            WHEN seq = 34 THEN 'Kyoto'
            WHEN seq = 35 THEN 'Beijing'
            WHEN seq = 36 THEN 'Shanghai'
            WHEN seq = 37 THEN 'Shanghai'
            WHEN seq = 38 THEN 'Seoul'
            WHEN seq = 39 THEN 'Seoul'
            WHEN seq = 40 THEN 'Singapore'
            WHEN seq = 41 THEN 'Singapore'
            WHEN seq = 42 THEN 'Bangkok'
            WHEN seq = 43 THEN 'Bangkok'
            WHEN seq = 44 THEN 'Kuala Lumpur'
            WHEN seq = 45 THEN 'Manila'
            WHEN seq = 46 THEN 'Sydney'
            WHEN seq = 47 THEN 'Sydney'
            WHEN seq = 48 THEN 'Melbourne'
            WHEN seq = 49 THEN 'Auckland'
        END as city,
        
        -- State/Province (mostly NULL for international, except Australia)
        CASE 
            WHEN seq = 46 THEN 'NSW'
            WHEN seq = 47 THEN 'NSW'
            WHEN seq = 48 THEN 'VIC'
            ELSE NULL
        END as state_province
        
    FROM TABLE(GENERATOR(ROWCOUNT => 50))
),
properties_with_details AS (
    SELECT 
        hotel_id,
        region,
        sub_region,
        brand,
        category,
        
        -- Hotel Name (brand + city + descriptor)
        CASE 
            WHEN brand = 'Summit Peak Reserve' THEN brand || ' ' || city
            WHEN brand = 'Summit Ice' THEN brand || ' ' || city || CASE 
                WHEN city IN ('London', 'Paris', 'Dubai', 'Tokyo', 'Singapore', 'Sydney') THEN ' City Centre'
                ELSE ''
            END
            WHEN brand = 'Summit Permafrost' THEN brand || ' ' || city
            ELSE 'The Snowline ' || city
        END as hotel_name,
        
        -- Address Line 1
        CASE 
            WHEN seq < 8 THEN (100 + seq * 10)::VARCHAR || ' ' || 
                CASE 
                    WHEN seq IN (0, 1, 2) THEN 'Piccadilly Street'
                    WHEN seq = 3 THEN 'Oxford Road'
                    WHEN seq = 4 THEN 'Princes Street'
                    WHEN seq = 5 THEN 'Broad Street'
                    WHEN seq = 6 THEN 'Bold Street'
                    ELSE 'Queen Square'
                END
            WHEN seq >= 8 AND seq < 20 THEN (10 + seq * 5)::VARCHAR || ' ' ||
                CASE 
                    WHEN city = 'Paris' THEN 'Avenue des Champs-Élysées'
                    WHEN city = 'Lyon' THEN 'Rue de la République'
                    WHEN city = 'Nice' THEN 'Promenade des Anglais'
                    WHEN city = 'Berlin' THEN 'Unter den Linden'
                    WHEN city = 'Munich' THEN 'Maximilianstraße'
                    WHEN city = 'Frankfurt' THEN 'Zeil'
                    WHEN city = 'Amsterdam' THEN 'Damrak'
                    WHEN city = 'Rome' THEN 'Via del Corso'
                    WHEN city = 'Milan' THEN 'Corso Buenos Aires'
                    ELSE 'Passeig de Gràcia'
                END
            WHEN seq >= 20 AND seq < 30 THEN 
                CASE 
                    WHEN city = 'Dubai' THEN 'Sheikh Zayed Road'
                    WHEN city = 'Abu Dhabi' THEN 'Corniche Road'
                    WHEN city = 'Doha' THEN 'Corniche Street'
                    WHEN city = 'Riyadh' THEN 'King Fahd Road'
                    WHEN city = 'Jeddah' THEN 'Tahlia Street'
                    ELSE 'Al Qurm Street'
                END
            WHEN seq >= 30 AND seq < 40 THEN (1 + seq)::VARCHAR || '-' || (1 + seq % 10)::VARCHAR || '-' || (1 + seq % 5)::VARCHAR || ' ' ||
                CASE 
                    WHEN city IN ('Tokyo', 'Osaka', 'Kyoto') THEN 'Chuo-ku'
                    WHEN city IN ('Beijing', 'Shanghai') THEN 'Dongcheng District'
                    ELSE 'Gangnam-gu'
                END
            WHEN seq >= 40 AND seq < 46 THEN (10 + seq)::VARCHAR || ' ' ||
                CASE 
                    WHEN city = 'Singapore' THEN 'Orchard Road'
                    WHEN city = 'Bangkok' THEN 'Sukhumvit Road'
                    WHEN city = 'Kuala Lumpur' THEN 'Jalan Bukit Bintang'
                    ELSE 'Ayala Avenue'
                END
            ELSE (100 + seq * 5)::VARCHAR || ' ' ||
                CASE 
                    WHEN city = 'Sydney' THEN 'George Street'
                    WHEN city = 'Melbourne' THEN 'Collins Street'
                    ELSE 'Queen Street'
                END
        END as address_line1,
        
        NULL as address_line2,
        city,
        state_province,
        
        -- Postal Code
        CASE 
            WHEN seq < 8 THEN 'SW1A ' || (seq + 1)::VARCHAR || 'AA'
            WHEN seq >= 8 AND seq < 20 THEN (75001 + seq)::VARCHAR
            WHEN seq >= 20 AND seq < 30 THEN NULL  -- Middle East
            WHEN seq >= 30 AND seq < 40 THEN (100 + seq)::VARCHAR || '-' || LPAD((1000 + seq * 10)::VARCHAR, 4, '0')
            WHEN seq >= 40 AND seq < 46 THEN (seq * 1000)::VARCHAR
            ELSE (2000 + seq * 10)::VARCHAR
        END as postal_code,
        
        country,
        
        -- Latitude
        CASE 
            WHEN city = 'London' THEN 51.5074 + (seq % 3) * 0.01
            WHEN city = 'Manchester' THEN 53.4808
            WHEN city = 'Edinburgh' THEN 55.9533
            WHEN city = 'Birmingham' THEN 52.4862
            WHEN city = 'Liverpool' THEN 53.4084
            WHEN city = 'Bristol' THEN 51.4545
            WHEN city = 'Paris' THEN 48.8566 + (seq % 2) * 0.01
            WHEN city = 'Lyon' THEN 45.7640
            WHEN city = 'Nice' THEN 43.7102
            WHEN city = 'Berlin' THEN 52.5200
            WHEN city = 'Munich' THEN 48.1351
            WHEN city = 'Frankfurt' THEN 50.1109
            WHEN city = 'Amsterdam' THEN 52.3676 + (seq % 2) * 0.01
            WHEN city = 'Rome' THEN 41.9028
            WHEN city = 'Milan' THEN 45.4642
            WHEN city = 'Barcelona' THEN 41.3851
            WHEN city = 'Dubai' THEN 25.2048 + (seq % 3) * 0.01
            WHEN city = 'Abu Dhabi' THEN 24.4539 + (seq % 2) * 0.01
            WHEN city = 'Doha' THEN 25.2854 + (seq % 2) * 0.01
            WHEN city = 'Riyadh' THEN 24.7136
            WHEN city = 'Jeddah' THEN 21.5433
            WHEN city = 'Muscat' THEN 23.5880
            WHEN city = 'Tokyo' THEN 35.6762 + (seq % 3) * 0.01
            WHEN city = 'Osaka' THEN 34.6937
            WHEN city = 'Kyoto' THEN 35.0116
            WHEN city = 'Beijing' THEN 39.9042
            WHEN city = 'Shanghai' THEN 31.2304 + (seq % 2) * 0.01
            WHEN city = 'Seoul' THEN 37.5665 + (seq % 2) * 0.01
            WHEN city = 'Singapore' THEN 1.3521 + (seq % 2) * 0.01
            WHEN city = 'Bangkok' THEN 13.7563 + (seq % 2) * 0.01
            WHEN city = 'Kuala Lumpur' THEN 3.1390
            WHEN city = 'Manila' THEN 14.5995
            WHEN city = 'Sydney' THEN -33.8688 + (seq % 2) * 0.01
            WHEN city = 'Melbourne' THEN -37.8136
            WHEN city = 'Auckland' THEN -36.8485
        END as latitude,
        
        -- Longitude
        CASE 
            WHEN city = 'London' THEN -0.1278 + (seq % 3) * 0.01
            WHEN city = 'Manchester' THEN -2.2426
            WHEN city = 'Edinburgh' THEN -3.1883
            WHEN city = 'Birmingham' THEN -1.8904
            WHEN city = 'Liverpool' THEN -2.9916
            WHEN city = 'Bristol' THEN -2.5879
            WHEN city = 'Paris' THEN 2.3522 + (seq % 2) * 0.01
            WHEN city = 'Lyon' THEN 4.8357
            WHEN city = 'Nice' THEN 7.2620
            WHEN city = 'Berlin' THEN 13.4050
            WHEN city = 'Munich' THEN 11.5820
            WHEN city = 'Frankfurt' THEN 8.6821
            WHEN city = 'Amsterdam' THEN 4.9041 + (seq % 2) * 0.01
            WHEN city = 'Rome' THEN 12.4964
            WHEN city = 'Milan' THEN 9.1900
            WHEN city = 'Barcelona' THEN 2.1734
            WHEN city = 'Dubai' THEN 55.2708 + (seq % 3) * 0.01
            WHEN city = 'Abu Dhabi' THEN 54.3773 + (seq % 2) * 0.01
            WHEN city = 'Doha' THEN 51.5310 + (seq % 2) * 0.01
            WHEN city = 'Riyadh' THEN 46.6753
            WHEN city = 'Jeddah' THEN 39.1728
            WHEN city = 'Muscat' THEN 58.3829
            WHEN city = 'Tokyo' THEN 139.6503 + (seq % 3) * 0.01
            WHEN city = 'Osaka' THEN 135.5022
            WHEN city = 'Kyoto' THEN 135.7681
            WHEN city = 'Beijing' THEN 116.4074
            WHEN city = 'Shanghai' THEN 121.4737 + (seq % 2) * 0.01
            WHEN city = 'Seoul' THEN 126.9780 + (seq % 2) * 0.01
            WHEN city = 'Singapore' THEN 103.8198 + (seq % 2) * 0.01
            WHEN city = 'Bangkok' THEN 100.5018 + (seq % 2) * 0.01
            WHEN city = 'Kuala Lumpur' THEN 101.6869
            WHEN city = 'Manila' THEN 120.9842
            WHEN city = 'Sydney' THEN 151.2093 + (seq % 2) * 0.01
            WHEN city = 'Melbourne' THEN 144.9631
            WHEN city = 'Auckland' THEN 174.7633
        END as longitude,
        
        -- Star Rating
        CASE 
            WHEN category = 'Luxury' THEN 5
            WHEN category = 'Select Service' THEN 4
            WHEN category = 'Extended Stay' THEN 3
            ELSE 4
        END as star_rating,
        
        -- Total Rooms
        CASE 
            WHEN category = 'Luxury' THEN 150 + (seq % 20) * 10
            WHEN category = 'Select Service' THEN 200 + (seq % 30) * 10
            WHEN category = 'Extended Stay' THEN 180 + (seq % 25) * 10
            ELSE 120 + (seq % 20) * 10
        END as total_rooms,
        
        seq
        
    FROM new_properties
)
SELECT 
    hotel_id,
    hotel_name,
    brand,
    category,
    region,
    sub_region,
    address_line1,
    address_line2,
    city,
    state_province,
    postal_code,
    country,
    latitude,
    longitude,
    '+1-800-SUMMIT' as phone,
    LOWER(REPLACE(REPLACE(hotel_name, ' ', '.'), '''', '')) || '@summithospitality.com' as email,
    star_rating,
    total_rooms,
    CASE 
        WHEN category = 'Luxury' THEN PARSE_JSON('["WiFi", "Valet Parking", "Infinity Pool", "Spa", "Fine Dining Restaurant", "Rooftop Bar", "24/7 Room Service", "Concierge", "Business Center", "Fitness Center", "Sauna"]')
        WHEN category = 'Select Service' THEN PARSE_JSON('["WiFi", "Parking", "Pool", "Fitness Center", "Breakfast", "Business Center"]')
        WHEN category = 'Extended Stay' THEN PARSE_JSON('["WiFi", "Parking", "Full Kitchen", "Laundry Facilities", "Fitness Center", "Pet Friendly", "Weekly Housekeeping"]')
        ELSE PARSE_JSON('["WiFi", "Rooftop Bar", "Co-Working Space", "Boutique Fitness", "Smart Room Tech", "Bike Rentals", "Local Art Gallery"]')
    END as amenities,
    CASE 
        WHEN category = 'Luxury' THEN PARSE_JSON('["Deluxe King", "Deluxe Queen", "Executive Suite", "Presidential Suite", "Penthouse Suite"]')
        WHEN category = 'Select Service' THEN PARSE_JSON('["Standard King", "Standard Queen", "Deluxe King", "Junior Suite"]')
        WHEN category = 'Extended Stay' THEN PARSE_JSON('["Studio Suite", "One Bedroom Suite", "Two Bedroom Suite"]')
        ELSE PARSE_JSON('["Modern King", "Modern Queen", "Urban Loft", "Skyline Suite"]')
    END as room_types,
    CASE WHEN category = 'Luxury' THEN TIME('16:00:00') ELSE TIME('15:00:00') END as check_in_time,
    CASE WHEN category = 'Luxury' THEN TIME('12:00:00') ELSE TIME('11:00:00') END as check_out_time,
    CASE 
        WHEN region = 'AMER' THEN 'America/New_York'
        WHEN region = 'EMEA' AND country IN ('United Kingdom', 'France', 'Germany', 'Netherlands', 'Italy', 'Spain') THEN 'Europe/London'
        WHEN region = 'EMEA' THEN 'Asia/Dubai'
        WHEN region = 'APAC' AND country IN ('Japan', 'China', 'South Korea') THEN 'Asia/Tokyo'
        WHEN region = 'APAC' AND country IN ('Singapore', 'Thailand', 'Malaysia', 'Philippines') THEN 'Asia/Singapore'
        ELSE 'Pacific/Auckland'
    END as timezone,
    DATEADD(day, -1 * (UNIFORM(365, 3650, RANDOM())), CURRENT_DATE()) as opened_date,
    DATEADD(day, -1 * (UNIFORM(30, 1095, RANDOM())), CURRENT_DATE()) as last_renovation_date,
    CURRENT_TIMESTAMP() as created_at,
    CURRENT_TIMESTAMP() as updated_at
FROM properties_with_details
ORDER BY seq;

-- =====================================================================
-- Step 4: Validation Queries
-- =====================================================================

-- Verify regional distribution
SELECT 
    region, 
    sub_region, 
    COUNT(*) as property_count,
    COUNT(DISTINCT brand) as brands,
    ROUND(AVG(total_rooms), 0) as avg_rooms
FROM BRONZE.hotel_properties
GROUP BY region, sub_region
ORDER BY region, sub_region;

-- Verify brand distribution across regions
SELECT 
    region,
    brand,
    COUNT(*) as count
FROM BRONZE.hotel_properties
GROUP BY region, brand
ORDER BY region, brand;

-- Total count check
SELECT COUNT(*) as total_properties FROM BRONZE.hotel_properties;

-- Sample of new properties
SELECT * FROM BRONZE.hotel_properties WHERE hotel_id >= 'HOTEL_050' ORDER BY hotel_id LIMIT 10;

SELECT '✅ Portfolio expanded to 100 properties globally' as status;
