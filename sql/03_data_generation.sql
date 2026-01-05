-- ============================================================================
-- Hotel Personalization - Data Generation
-- ============================================================================
-- Generates synthetic data across all Bronze layer tables
-- Creates realistic volume and variety for demo purposes
-- 
-- Data volumes:
--   - 50 hotel properties
--   - 10,000 guest profiles
--   - 25,000 bookings
--   - 20,000 stays
--   - 30,000+ amenity transactions
--   - 15,000+ amenity usage records
-- 
-- Session variables (set by deploy.sh):
--   $FULL_PREFIX, $PROJECT_ROLE
-- ============================================================================

USE ROLE IDENTIFIER($PROJECT_ROLE);
USE DATABASE IDENTIFIER($FULL_PREFIX);
USE SCHEMA BRONZE;

-- ============================================================================
-- 1. HOTEL PROPERTIES (50 hotels)
-- ============================================================================
INSERT INTO hotel_properties
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 50))
),
hotel_data AS (
    SELECT 
        'HOTEL_' || LPAD(seq::VARCHAR, 3, '0') as hotel_id,
        CASE 
            WHEN seq <= 10 THEN 'Hilton ' || ['Downtown', 'Garden Inn', 'Embassy Suites', 'DoubleTree', 'Hampton Inn'][seq % 5]
            WHEN seq <= 20 THEN 'Marriott ' || ['Courtyard', 'Residence Inn', 'SpringHill Suites', 'Fairfield Inn', 'TownePlace Suites'][seq % 5]
            WHEN seq <= 30 THEN 'Hyatt ' || ['Place', 'House', 'Centric', 'Regency', 'Grand'][seq % 5]
            WHEN seq <= 40 THEN 'IHG ' || ['Holiday Inn', 'Crowne Plaza', 'InterContinental', 'Staybridge Suites', 'Candlewood Suites'][seq % 5]
            ELSE 'Independent ' || ['Boutique', 'Luxury', 'Business', 'Resort', 'Extended Stay'][seq % 5]
        END as hotel_name,
        CASE 
            WHEN seq <= 10 THEN 'Hilton'
            WHEN seq <= 20 THEN 'Marriott'
            WHEN seq <= 30 THEN 'Hyatt'
            WHEN seq <= 40 THEN 'IHG'
            ELSE 'Independent'
        END as brand,
        (seq * 123)::VARCHAR || ' ' || ['Main St', 'Broadway', 'Park Ave', 'First St', 'Oak Blvd'][seq % 5] as address_line1,
        NULL as address_line2,
        ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose'][seq % 10] as city,
        ['NY', 'CA', 'IL', 'TX', 'AZ', 'PA', 'TX', 'CA', 'TX', 'CA'][seq % 10] as state_province,
        LPAD(((10000 + seq * 17) % 90000 + 10000)::VARCHAR, 5, '0') as postal_code,
        'USA' as country,
        CAST(25.0 + ((seq * 7) % 25) + UNIFORM(0.0, 0.001, RANDOM()) AS DECIMAL(10,8)) as latitude,
        CAST(-125.0 + ((seq * 11) % 50) + UNIFORM(0.0, 0.001, RANDOM()) AS DECIMAL(11,8)) as longitude,
        '+1' || LPAD(((seq * 31) % 900 + 100)::VARCHAR, 3, '0') || LPAD(((seq * 47) % 9000 + 1000)::VARCHAR, 4, '0') as phone,
        LOWER(REPLACE(hotel_name, ' ', '.')) || '@hotel.com' as email,
        3 + (seq % 3) as star_rating,
        100 + ((seq * 23) % 400) as total_rooms,
        PARSE_JSON('["WiFi", "Parking", "Pool", "Fitness Center", "Restaurant", "Room Service", "Concierge", "Business Center"]') as amenities,
        PARSE_JSON('["Standard King", "Standard Queen", "Deluxe King", "Suite", "Executive", "Family Room"]') as room_types,
        TIME('15:00:00') as check_in_time,
        TIME('11:00:00') as check_out_time,
        ['America/New_York', 'America/Los_Angeles', 'America/Chicago', 'America/Denver'][seq % 4] as timezone,
        DATEADD(day, -1 * (seq * 100 + 365), CURRENT_DATE()) as opened_date,
        DATEADD(day, -1 * (seq * 30 + 100), CURRENT_DATE()) as last_renovation_date,
        CURRENT_TIMESTAMP() as created_at,
        CURRENT_TIMESTAMP() as updated_at
    FROM seq_generator
)
SELECT * FROM hotel_data;

-- ============================================================================
-- 2. GUEST PROFILES (10,000 guests)
-- ============================================================================
INSERT INTO guest_profiles
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 10000))
),
guest_data AS (
    SELECT 
        'GUEST_' || LPAD(seq, 6, '0') as guest_id,
        ['James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 'Linda', 'David', 'Elizabeth', 
         'William', 'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica', 'Thomas', 'Sarah', 'Christopher', 'Karen',
         'Daniel', 'Nancy', 'Matthew', 'Lisa', 'Anthony', 'Betty', 'Mark', 'Helen', 'Donald', 'Sandra'][seq % 30] as first_name,
        ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
         'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
         'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson'][seq % 30] as last_name,
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
    FROM seq_generator
)
SELECT * FROM guest_data;

-- ============================================================================
-- 3. LOYALTY PROGRAM (8,000 members)
-- ============================================================================
INSERT INTO loyalty_program
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 8000))
),
loyalty_data AS (
    SELECT 
        'LOYALTY_' || LPAD(seq, 6, '0') as loyalty_id,
        'GUEST_' || LPAD(seq, 6, '0') as guest_id,
        'Hotel Rewards Program' as program_name,
        'HRP' || LPAD(seq * 73, 10, '0') as member_number,
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
    FROM seq_generator
)
SELECT * FROM loyalty_data;

-- ============================================================================
-- 4. ROOM PREFERENCES (7,500 guests)
-- ============================================================================
INSERT INTO room_preferences
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 7500))
),
pref_data AS (
    SELECT 
        'PREF_' || LPAD(seq, 6, '0') as preference_id,
        'GUEST_' || LPAD(seq, 6, '0') as guest_id,
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
-- 5. SERVICE PREFERENCES (7,000 guests)
-- ============================================================================
INSERT INTO service_preferences
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 7000))
),
service_data AS (
    SELECT 
        'SERV_PREF_' || LPAD(seq, 6, '0') as preference_id,
        'GUEST_' || LPAD(seq, 6, '0') as guest_id,
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
-- 6. BOOKING HISTORY (25,000 bookings)
-- ============================================================================
INSERT INTO booking_history
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 25000))
),
booking_data AS (
    SELECT 
        'BOOKING_' || LPAD(seq, 7, '0') as booking_id,
        'GUEST_' || LPAD((seq % 8000) + 1, 6, '0') as guest_id,
        'HOTEL_' || LPAD((seq % 50) + 1, 3, '0') as hotel_id,
        DATEADD(day, -1 * ((seq * 7) % 1095), CURRENT_TIMESTAMP()) as booking_date,
        DATE(DATEADD(day, (seq * 13) % 30 + 1, booking_date)) as check_in_date,
        DATE(DATEADD(day, ((seq % 7) + 1), check_in_date)) as check_out_date,
        DATEDIFF(day, check_in_date, check_out_date) as num_nights,
        CASE WHEN seq % 10 = 0 THEN 2 ELSE 1 END + (seq % 3) as num_adults,
        CASE WHEN seq % 5 = 0 THEN (seq % 3) ELSE 0 END as num_children,
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
            PARSE_JSON('["quiet_room", "high_floor"]')
            ELSE NULL 
        END as special_requests,
        CASE WHEN seq % 15 = 0 THEN 'SAVE20' ELSE NULL END as promo_code,
        ['Credit Card', 'Debit Card', 'Digital Wallet', 'Bank Transfer', 'Points'][seq % 5] as payment_method,
        booking_date as created_at,
        booking_date as updated_at
    FROM seq_generator
)
SELECT * FROM booking_data;

-- ============================================================================
-- 7. STAY HISTORY (20,000 completed stays)
-- ============================================================================
INSERT INTO stay_history
WITH confirmed_bookings AS (
    SELECT *
    FROM booking_history
    WHERE booking_status = 'Confirmed'
    ORDER BY RANDOM()
    LIMIT 20000
),
stay_data AS (
    SELECT 
        'STAY_' || LPAD(ROW_NUMBER() OVER (ORDER BY bh.booking_date), 7, '0') as stay_id,
        bh.booking_id,
        bh.guest_id,
        bh.hotel_id,
        (100 + (ROW_NUMBER() OVER (ORDER BY bh.booking_date) * 23) % 900)::STRING as room_number,
        DATEADD(hour, UNIFORM(-2, 6, RANDOM()), bh.check_in_date::TIMESTAMP) as actual_check_in,
        DATEADD(hour, UNIFORM(-1, 5, RANDOM()), bh.check_out_date::TIMESTAMP) as actual_check_out,
        bh.room_type,
        CASE 
            WHEN SUBSTRING(room_number, 1, 1) IN ('1', '2') THEN 1
            WHEN SUBSTRING(room_number, 1, 1) IN ('3', '4', '5') THEN 2
            WHEN SUBSTRING(room_number, 1, 1) IN ('6', '7', '8') THEN 3
            ELSE 4
        END as floor_number,
        ['City View', 'Ocean View', 'Garden View', 'Pool View', 'Mountain View', 'Courtyard View'][UNIFORM(0, 5, RANDOM())] as view_type,
        ['King', 'Queen', 'Twin', 'Double'][UNIFORM(0, 3, RANDOM())] as bed_type,
        ROUND(bh.total_amount * (0.95 + RANDOM() * 0.1), 2) as total_charges,
        ROUND(total_charges * 0.75, 2) as room_charges,
        ROUND(total_charges * 0.15, 2) as tax_amount,
        ROUND(total_charges * 0.10, 2) as incidental_charges,
        FALSE as no_show,
        UNIFORM(0, 49, RANDOM()) = 0 as early_departure,
        UNIFORM(0, 29, RANDOM()) = 0 as late_checkout,
        CASE 
            WHEN UNIFORM(0, 99, RANDOM()) < 5 THEN 1
            WHEN UNIFORM(0, 99, RANDOM()) < 15 THEN 2
            WHEN UNIFORM(0, 99, RANDOM()) < 35 THEN 3
            WHEN UNIFORM(0, 99, RANDOM()) < 70 THEN 4
            ELSE 5
        END as guest_satisfaction_score,
        NULL as staff_notes,
        CURRENT_TIMESTAMP() as created_at
    FROM confirmed_bookings bh
)
SELECT * FROM stay_data;

-- ============================================================================
-- 8. AMENITY TRANSACTIONS (30,000+ transactions)
-- ============================================================================
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
        'TRANS_' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM()), 8, '0') as transaction_id,
        sh.stay_id,
        sh.guest_id,
        a.category as amenity_category,
        a.service as service_name,
        DATEADD(HOUR, UNIFORM(0, DATEDIFF(HOUR, sh.actual_check_in, sh.actual_check_out), RANDOM()), sh.actual_check_in) as transaction_date,
        ROUND(a.base_price * (0.8 + RANDOM() * 0.4), 2) as amount,
        CASE 
            WHEN a.category IN ('spa', 'room_service', 'wifi') THEN 1
            WHEN a.category IN ('restaurant', 'smart_tv') THEN UNIFORM(1, 2, RANDOM())
            ELSE UNIFORM(1, 4, RANDOM())
        END as quantity,
        a.location,
        CASE 
            WHEN UNIFORM(0, 99, RANDOM()) < 5 THEN 1
            WHEN UNIFORM(0, 99, RANDOM()) < 15 THEN 2
            WHEN UNIFORM(0, 99, RANDOM()) < 35 THEN 3
            WHEN UNIFORM(0, 99, RANDOM()) < 65 THEN 4
            ELSE 5
        END as guest_satisfaction,
        CASE WHEN a.category IN ('wifi', 'smart_tv') THEN 'upgrade' ELSE 'paid' END as service_type,
        a.service as service_subcategory,
        a.base_price > 100 as is_premium_service,
        FALSE as is_repeat_service,
        CASE 
            WHEN a.category = 'spa' THEN UNIFORM(30, 120, RANDOM())
            WHEN a.category = 'restaurant' THEN UNIFORM(45, 180, RANDOM())
            ELSE NULL
        END as duration_minutes,
        'STAFF_' || LPAD(UNIFORM(1, 50, RANDOM()), 3, '0') as staff_id,
        sh.hotel_id,
        sh.booking_id
    FROM stay_history sh
    CROSS JOIN amenity_services a
    WHERE UNIFORM(0, 99, RANDOM()) < 20
    LIMIT 30000
)
SELECT * FROM transactions;

-- ============================================================================
-- 9. AMENITY USAGE (15,000+ usage records)
-- ============================================================================
INSERT INTO amenity_usage
WITH usage_amenities AS (
    SELECT * FROM VALUES
    -- WiFi Usage
    ('wifi', 'Regular WiFi', 'free'),
    ('wifi', 'Premium WiFi', 'paid'),
    
    -- Smart TV Usage
    ('smart_tv', 'Basic Smart TV', 'free'),
    ('smart_tv', 'Premium Channels', 'paid'),
    
    -- Pool Usage
    ('pool', 'Main Pool', 'free'),
    ('pool', 'VIP Pool Area', 'paid')
    
    AS t(category, amenity, usage_type)
),
usage_records AS (
    SELECT 
        'USAGE_' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM()), 8, '0') as usage_id,
        sh.stay_id,
        sh.guest_id,
        a.category as amenity_category,
        a.amenity as amenity_name,
        DATEADD(HOUR, UNIFORM(0, DATEDIFF(HOUR, sh.actual_check_in, sh.actual_check_out), RANDOM()), sh.actual_check_in) as usage_start_time,
        DATEADD(MINUTE, UNIFORM(15, 240, RANDOM()), usage_start_time) as usage_end_time,
        DATEDIFF(MINUTE, usage_start_time, usage_end_time) as usage_duration_minutes,
        CASE 
            WHEN a.category = 'wifi' THEN 'Room ' || (100 + UNIFORM(1, 500, RANDOM()))
            WHEN a.category = 'smart_tv' THEN 'Room ' || (100 + UNIFORM(1, 500, RANDOM()))
            WHEN a.category = 'pool' THEN 'Pool Deck'
        END as location,
        CASE 
            WHEN a.category = 'wifi' THEN 'Device_' || UNIFORM(1000, 9999, RANDOM())
            WHEN a.category = 'smart_tv' THEN 'TV_' || UNIFORM(100, 999, RANDOM())
            ELSE NULL
        END as device_info,
        a.usage_type,
        CASE 
            WHEN UNIFORM(0, 99, RANDOM()) < 5 THEN 1
            WHEN UNIFORM(0, 99, RANDOM()) < 15 THEN 2
            WHEN UNIFORM(0, 99, RANDOM()) < 40 THEN 3
            WHEN UNIFORM(0, 99, RANDOM()) < 70 THEN 4
            ELSE 5
        END as guest_satisfaction,
        UNIFORM(1, 5, RANDOM()) as usage_frequency,
        CASE WHEN a.category = 'wifi' THEN UNIFORM(50, 2000, RANDOM()) ELSE NULL END as data_consumed_mb,
        CASE WHEN a.category = 'smart_tv' THEN PARSE_JSON('["Netflix", "HBO", "ESPN"]') ELSE NULL END as channels_accessed,
        CURRENT_TIMESTAMP() as created_at
    FROM stay_history sh
    CROSS JOIN usage_amenities a
    WHERE UNIFORM(0, 99, RANDOM()) < 15
    LIMIT 15000
)
SELECT * FROM usage_records;

-- ============================================================================
-- 10. SOCIAL MEDIA ACTIVITY (5,000 activities)
-- ============================================================================
INSERT INTO social_media_activity
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 5000))
),
social_data AS (
    SELECT 
        'SOCIAL_' || LPAD(seq, 7, '0') as activity_id,
        'GUEST_' || LPAD((seq % 2000) + 1, 6, '0') as guest_id,
        ['Instagram', 'Twitter', 'Facebook', 'TikTok', 'LinkedIn'][seq % 5] as platform,
        ['Post', 'Share', 'Review', 'Check-in'][seq % 4] as activity_type,
        PARSE_JSON('{"text": "Great stay!", "hashtags": ["hotel", "travel", "vacation"]}') as content,
        ROUND(-1.0 + (RANDOM() * 2), 2) as sentiment_score,
        PARSE_JSON('{"likes": ' || UNIFORM(0, 500, RANDOM()) || ', "shares": ' || UNIFORM(0, 50, RANDOM()) || ', "comments": ' || UNIFORM(0, 100, RANDOM()) || '}') as engagement_metrics,
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
INSERT INTO feedback_reviews
WITH review_data AS (
    SELECT 
        'REVIEW_' || LPAD(ROW_NUMBER() OVER (ORDER BY sh.actual_check_out), 7, '0') as review_id,
        sh.guest_id,
        sh.stay_id,
        sh.hotel_id,
        sh.guest_satisfaction_score as overall_rating,
        GREATEST(1, sh.guest_satisfaction_score + UNIFORM(-1, 1, RANDOM())) as room_rating,
        GREATEST(1, sh.guest_satisfaction_score + UNIFORM(-1, 1, RANDOM())) as service_rating,
        GREATEST(1, sh.guest_satisfaction_score + UNIFORM(-1, 1, RANDOM())) as cleanliness_rating,
        GREATEST(1, sh.guest_satisfaction_score + UNIFORM(-1, 1, RANDOM())) as amenities_rating,
        GREATEST(1, sh.guest_satisfaction_score + UNIFORM(-1, 1, RANDOM())) as location_rating,
        GREATEST(1, sh.guest_satisfaction_score + UNIFORM(-1, 1, RANDOM())) as value_rating,
        CASE 
            WHEN sh.guest_satisfaction_score >= 4 THEN 'Excellent hotel experience!'
            WHEN sh.guest_satisfaction_score >= 3 THEN 'Good stay overall.'
            ELSE 'Room for improvement.'
        END as review_text,
        DATEADD(day, UNIFORM(1, 7, RANDOM()), sh.actual_check_out) as review_date,
        ['Internal', 'TripAdvisor', 'Google', 'Booking.com'][UNIFORM(0, 3, RANDOM())] as platform,
        TRUE as verified_stay,
        UNIFORM(0, 50, RANDOM()) as helpful_votes,
        CASE WHEN UNIFORM(0, 2, RANDOM()) = 0 THEN 'Thank you for your feedback!' ELSE NULL END as management_response,
        CASE WHEN management_response IS NOT NULL THEN DATEADD(day, 1, review_date) ELSE NULL END as response_date,
        PARSE_JSON('{"sentiment": ' || (sh.guest_satisfaction_score / 5.0)::STRING || '}') as sentiment_analysis,
        CURRENT_TIMESTAMP() as created_at
    FROM stay_history sh
    WHERE UNIFORM(0, 1, RANDOM()) < 0.5
    LIMIT 10000
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

