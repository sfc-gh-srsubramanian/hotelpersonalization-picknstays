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
        ((seq % 1000) * 123)::VARCHAR || ' ' || ['Main St', 'Broadway', 'Park Ave', 'First St', 'Oak Blvd'][seq % 5] as address_line1,
        NULL as address_line2,
        ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose'][seq % 10] as city,
        ['NY', 'CA', 'IL', 'TX', 'AZ', 'PA', 'TX', 'CA', 'TX', 'CA'][seq % 10] as state_province,
        LPAD((10000 + (seq % 5000) * 17 % 90000)::VARCHAR, 5, '0') as postal_code,
        'USA' as country,
        CAST(25.0 + ((seq % 25) * 7 % 25) + UNIFORM(0.0, 0.001, RANDOM()) AS DECIMAL(10,8)) as latitude,
        CAST(-125.0 + ((seq % 50) * 11 % 50) + UNIFORM(0.0, 0.001, RANDOM()) AS DECIMAL(11,8)) as longitude,
        '+1' || LPAD(((seq % 900) * 31 % 900 + 100)::VARCHAR, 3, '0') || LPAD(((seq % 9000) * 47 % 9000 + 1000)::VARCHAR, 4, '0') as phone,
        LOWER(REPLACE(hotel_name, ' ', '.')) || '@hotel.com' as email,
        3 + (seq % 3) as star_rating,
        100 + ((seq % 400) * 23 % 400) as total_rooms,
        PARSE_JSON('["WiFi", "Parking", "Pool", "Fitness Center", "Restaurant", "Room Service", "Concierge", "Business Center"]') as amenities,
        PARSE_JSON('["Standard King", "Standard Queen", "Deluxe King", "Suite", "Executive", "Family Room"]') as room_types,
        TIME('15:00:00') as check_in_time,
        TIME('11:00:00') as check_out_time,
        ['America/New_York', 'America/Los_Angeles', 'America/Chicago', 'America/Denver'][seq % 4] as timezone,
        DATEADD(day, -1 * ((seq % 100) * 100 + 365), CURRENT_DATE()) as opened_date,
        DATEADD(day, -1 * ((seq % 365) * 30 + 100), CURRENT_DATE()) as last_renovation_date,
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
        'GUEST_' || LPAD(seq::VARCHAR, 6, '0') as guest_id,
        ['James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 'Linda', 'David', 'Elizabeth', 
         'William', 'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica', 'Thomas', 'Sarah', 'Christopher', 'Karen',
         'Daniel', 'Nancy', 'Matthew', 'Lisa', 'Anthony', 'Betty', 'Mark', 'Helen', 'Donald', 'Sandra'][seq % 30] as first_name,
        ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
         'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
         'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson'][seq % 30] as last_name,
        LOWER(first_name || '.' || last_name || seq::VARCHAR) || '@' || ['gmail.com', 'yahoo.com', 'outlook.com', 'hotmail.com', 'company.com'][seq % 5] as email,
        '+1' || LPAD(((seq % 900) * 23 % 900 + 100)::VARCHAR, 3, '0') || LPAD(((seq % 9000) * 41 % 9000 + 1000)::VARCHAR, 4, '0') as phone,
        DATEADD(year, -1 * (20 + (seq % 60) * 13 % 60), CURRENT_DATE()) as date_of_birth,
        ['M', 'F', 'Other'][seq % 3] as gender,
        ['USA', 'Canada', 'UK', 'Germany', 'France', 'Japan', 'Australia', 'Brazil', 'India', 'Mexico'][seq % 10] as nationality,
        ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese', 'Portuguese', 'Hindi'][seq % 8] as language_preference,
        ((seq % 1000) * 47)::VARCHAR || ' ' || ['Oak St', 'Pine Ave', 'Maple Dr', 'Cedar Ln', 'Elm Way'][seq % 5] as address_line1,
        CASE WHEN seq % 4 = 0 THEN 'Apt ' || (seq % 100 + 1)::VARCHAR ELSE NULL END as address_line2,
        ['Boston', 'Miami', 'Seattle', 'Denver', 'Atlanta', 'Las Vegas', 'Portland', 'Nashville', 'Austin', 'Orlando'][seq % 10] as city,
        ['MA', 'FL', 'WA', 'CO', 'GA', 'NV', 'OR', 'TN', 'TX', 'FL'][seq % 10] as state_province,
        LPAD((20000 + (seq % 4000) * 19 % 80000)::VARCHAR, 5, '0') as postal_code,
        'USA' as country,
        DATEADD(day, -1 * ((seq % 1095) * 7), CURRENT_DATE()) as registration_date,
        CURRENT_TIMESTAMP() as last_updated,
        seq % 3 != 0 as marketing_opt_in,
        PARSE_JSON('{"email": true, "sms": ' || (seq % 2 = 0)::STRING || ', "phone": ' || (seq % 3 = 0)::STRING || '}') as communication_preferences,
        PARSE_JSON('{"name": "Emergency Contact", "phone": "+1' || LPAD(((seq % 9000) * 67 % 9000 + 1000)::VARCHAR, 4, '0') || '", "relationship": "' || ['spouse', 'parent', 'sibling', 'friend'][seq % 4] || '"}') as emergency_contact
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
        'LOYALTY_' || LPAD(seq::VARCHAR, 6, '0') as loyalty_id,
        'GUEST_' || LPAD(seq::VARCHAR, 6, '0') as guest_id,
        'Hotel Rewards Program' as program_name,
        'HRP' || LPAD(((seq % 10000) * 73)::VARCHAR, 10, '0') as member_number,
        CASE 
            WHEN seq % 100 < 5 THEN 'Diamond'
            WHEN seq % 100 < 20 THEN 'Gold'
            WHEN seq % 100 < 50 THEN 'Silver'
            ELSE 'Blue'
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
-- 4. ROOM PREFERENCES (7,500 guests)
-- ============================================================================
INSERT INTO room_preferences
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 7500))
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
-- 5. SERVICE PREFERENCES (7,000 guests)
-- ============================================================================
INSERT INTO service_preferences
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 7000))
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
-- 6. BOOKING HISTORY (25,000 bookings)
-- ============================================================================
INSERT INTO booking_history
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 25000))
),
booking_dates AS (
    SELECT 
        seq,
        'BOOKING_' || LPAD(seq::VARCHAR, 7, '0') as booking_id,
        'GUEST_' || LPAD(((seq % 8000) + 1)::VARCHAR, 6, '0') as guest_id,
        'HOTEL_' || LPAD(((seq % 50) + 1)::VARCHAR, 3, '0') as hotel_id,
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
stay_base AS (
    SELECT 
        'STAY_' || LPAD((ROW_NUMBER() OVER (ORDER BY bh.booking_date))::INTEGER::VARCHAR, 7, '0') as stay_id,
        bh.booking_id,
        bh.guest_id,
        bh.hotel_id,
        (100 + ((ROW_NUMBER() OVER (ORDER BY bh.booking_date))::INTEGER % 900) * 23 % 900)::VARCHAR as room_number,
        DATEADD(hour, UNIFORM(-2, 6, RANDOM())::INTEGER, bh.check_in_date::TIMESTAMP) as actual_check_in,
        DATEADD(hour, UNIFORM(-1, 5, RANDOM())::INTEGER, bh.check_out_date::TIMESTAMP) as actual_check_out,
        bh.room_type,
        ['City View', 'Ocean View', 'Garden View', 'Pool View', 'Mountain View', 'Courtyard View'][UNIFORM(0, 5, RANDOM())::INTEGER] as view_type,
        ['King', 'Queen', 'Twin', 'Double'][UNIFORM(0, 3, RANDOM())::INTEGER] as bed_type,
        CAST(bh.total_amount * (0.95 + UNIFORM(0, 0.1, RANDOM())) AS DECIMAL(10,2)) as total_charges,
        FALSE as no_show,
        UNIFORM(0, 49, RANDOM())::INTEGER = 0 as early_departure,
        UNIFORM(0, 29, RANDOM())::INTEGER = 0 as late_checkout,
        CASE 
            WHEN UNIFORM(0, 99, RANDOM())::INTEGER < 5 THEN 1
            WHEN UNIFORM(0, 99, RANDOM())::INTEGER < 15 THEN 2
            WHEN UNIFORM(0, 99, RANDOM())::INTEGER < 35 THEN 3
            WHEN UNIFORM(0, 99, RANDOM())::INTEGER < 70 THEN 4
            ELSE 5
        END as guest_satisfaction_score,
        NULL as staff_notes,
        CURRENT_TIMESTAMP() as created_at
    FROM confirmed_bookings bh
),
stay_data AS (
    SELECT
        stay_id,
        booking_id,
        guest_id,
        hotel_id,
        room_number,
        actual_check_in,
        actual_check_out,
        room_type,
        CASE 
            WHEN SUBSTRING(room_number, 1, 1) IN ('1', '2') THEN 1
            WHEN SUBSTRING(room_number, 1, 1) IN ('3', '4', '5') THEN 2
            WHEN SUBSTRING(room_number, 1, 1) IN ('6', '7', '8') THEN 3
            ELSE 4
        END as floor_number,
        view_type,
        bed_type,
        total_charges,
        CAST(total_charges * 0.75 AS DECIMAL(10,2)) as room_charges,
        CAST(total_charges * 0.15 AS DECIMAL(10,2)) as tax_amount,
        CAST(total_charges * 0.10 AS DECIMAL(10,2)) as incidental_charges,
        no_show,
        early_departure,
        late_checkout,
        guest_satisfaction_score,
        staff_notes,
        created_at
    FROM stay_base
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
        'TRANS_' || LPAD((ROW_NUMBER() OVER (ORDER BY RANDOM()))::INTEGER::VARCHAR, 8, '0') as transaction_id,
        sh.stay_id,
        sh.guest_id,
        a.category as amenity_category,
        a.service as service_name,
        DATEADD(HOUR, FLOOR(RANDOM() * DATEDIFF(HOUR, sh.actual_check_in, sh.actual_check_out))::INTEGER, sh.actual_check_in) as transaction_date,
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
usage_base AS (
    SELECT 
        'USAGE_' || LPAD((ROW_NUMBER() OVER (ORDER BY RANDOM()))::INTEGER::VARCHAR, 8, '0') as usage_id,
        sh.stay_id,
        sh.guest_id,
        a.category as amenity_category,
        a.amenity as amenity_name,
        DATEADD(HOUR, FLOOR(RANDOM() * DATEDIFF(HOUR, sh.actual_check_in, sh.actual_check_out))::INTEGER, sh.actual_check_in) as usage_start_time,
        UNIFORM(15, 240, RANDOM())::INTEGER as duration_minutes,
        CASE 
            WHEN a.category = 'wifi' THEN 'Room ' || (100 + UNIFORM(1, 500, RANDOM())::INTEGER)::VARCHAR
            WHEN a.category = 'smart_tv' THEN 'Room ' || (100 + UNIFORM(1, 500, RANDOM())::INTEGER)::VARCHAR
            WHEN a.category = 'pool' THEN 'Pool Deck'
        END as location,
        CASE 
            WHEN a.category = 'wifi' THEN 'Device_' || UNIFORM(1000, 9999, RANDOM())::INTEGER::VARCHAR
            WHEN a.category = 'smart_tv' THEN 'TV_' || UNIFORM(100, 999, RANDOM())::INTEGER::VARCHAR
            ELSE NULL
        END as device_info,
        a.usage_type,
        CASE 
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
    WHERE UNIFORM(0, 99, RANDOM())::INTEGER < 15
    LIMIT 15000
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
INSERT INTO social_media_activity
WITH seq_generator AS (
    SELECT (ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1)::INTEGER as seq
    FROM TABLE(GENERATOR(ROWCOUNT => 5000))
),
social_data AS (
    SELECT 
        'SOCIAL_' || LPAD(seq::VARCHAR, 7, '0') as activity_id,
        'GUEST_' || LPAD(((seq % 2000) + 1)::VARCHAR, 6, '0') as guest_id,
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

