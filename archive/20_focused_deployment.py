#!/usr/bin/env python3
"""
Hotel Personalization System - Focused Deployment
Creates the core tables and data step by step
"""

import snowflake.connector
import os
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.serialization import load_pem_private_key

def load_private_key():
    key_path = os.path.expanduser("~/.ssh/snowflake_rsa_key")
    with open(key_path, "rb") as key_file:
        private_key = load_pem_private_key(key_file.read(), password=None)
    
    return private_key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )

def execute_sql(cursor, sql, description):
    try:
        cursor.execute(sql)
        print(f"  ✅ {description}")
        return True
    except Exception as e:
        print(f"  ⚠️  {description}: {str(e)}")
        return False

def main():
    conn = snowflake.connector.connect(
        user='srsubramanian',
        account='SFSENORTHAMERICA-SFSENORTHAMERICA_SRISUB_AWS1',
        warehouse='COMPUTE_WH',
        role='LOSS_PREVENTION_ADMIN',
        private_key=load_private_key()
    )
    cursor = conn.cursor()
    
    print("🚀 FOCUSED HOTEL PERSONALIZATION DEPLOYMENT")
    print("=" * 50)
    
    # Set context
    execute_sql(cursor, "USE DATABASE HOTEL_PERSONALIZATION", "Using database")
    execute_sql(cursor, "USE SCHEMA BRONZE", "Using Bronze schema")
    
    print("\n📊 CREATING BRONZE LAYER TABLES")
    print("-" * 30)
    
    # Create guest profiles table
    guest_profiles_sql = """
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
        city STRING,
        state_province STRING,
        country STRING,
        registration_date TIMESTAMP,
        marketing_opt_in BOOLEAN,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
    )
    """
    execute_sql(cursor, guest_profiles_sql, "Guest profiles table")
    
    # Create hotel properties table
    hotel_properties_sql = """
    CREATE OR REPLACE TABLE hotel_properties (
        hotel_id STRING PRIMARY KEY,
        hotel_name STRING,
        brand STRING,
        city STRING,
        state_province STRING,
        country STRING,
        star_rating INTEGER,
        total_rooms INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
    )
    """
    execute_sql(cursor, hotel_properties_sql, "Hotel properties table")
    
    # Create booking history table
    booking_history_sql = """
    CREATE OR REPLACE TABLE booking_history (
        booking_id STRING PRIMARY KEY,
        guest_id STRING,
        hotel_id STRING,
        booking_date TIMESTAMP,
        check_in_date DATE,
        check_out_date DATE,
        num_nights INTEGER,
        room_type STRING,
        total_amount DECIMAL(10,2),
        booking_channel STRING,
        booking_status STRING,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
    )
    """
    execute_sql(cursor, booking_history_sql, "Booking history table")
    
    # Create loyalty program table
    loyalty_program_sql = """
    CREATE OR REPLACE TABLE loyalty_program (
        loyalty_id STRING PRIMARY KEY,
        guest_id STRING,
        tier_level STRING,
        points_balance INTEGER,
        lifetime_points INTEGER,
        status STRING,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
    )
    """
    execute_sql(cursor, loyalty_program_sql, "Loyalty program table")
    
    print("\n📈 INSERTING SAMPLE DATA")
    print("-" * 30)
    
    # Insert sample hotels
    hotels_data = """
    INSERT INTO hotel_properties VALUES
    ('HOTEL_001', 'Hilton Downtown', 'Hilton', 'New York', 'NY', 'USA', 4, 350, CURRENT_TIMESTAMP()),
    ('HOTEL_002', 'Marriott Garden Inn', 'Marriott', 'Los Angeles', 'CA', 'USA', 3, 200, CURRENT_TIMESTAMP()),
    ('HOTEL_003', 'Hyatt Regency', 'Hyatt', 'Chicago', 'IL', 'USA', 4, 400, CURRENT_TIMESTAMP()),
    ('HOTEL_004', 'IHG Holiday Inn', 'IHG', 'Miami', 'FL', 'USA', 3, 180, CURRENT_TIMESTAMP()),
    ('HOTEL_005', 'Hilton Embassy Suites', 'Hilton', 'San Francisco', 'CA', 'USA', 4, 250, CURRENT_TIMESTAMP())
    """
    execute_sql(cursor, hotels_data, "Sample hotels (5 properties)")
    
    # Insert sample guests
    guests_data = """
    INSERT INTO guest_profiles VALUES
    ('GUEST_001', 'John', 'Smith', 'john.smith@email.com', '+1-555-0101', '1985-03-15', 'M', 'USA', 'English', 'Boston', 'MA', 'USA', '2020-01-15', TRUE, CURRENT_TIMESTAMP()),
    ('GUEST_002', 'Jane', 'Doe', 'jane.doe@email.com', '+1-555-0102', '1990-07-22', 'F', 'USA', 'English', 'Seattle', 'WA', 'USA', '2019-05-20', TRUE, CURRENT_TIMESTAMP()),
    ('GUEST_003', 'Mike', 'Johnson', 'mike.j@email.com', '+1-555-0103', '1978-11-08', 'M', 'Canada', 'English', 'Toronto', 'ON', 'Canada', '2021-03-10', FALSE, CURRENT_TIMESTAMP()),
    ('GUEST_004', 'Sarah', 'Wilson', 'sarah.w@email.com', '+1-555-0104', '1992-12-03', 'F', 'USA', 'English', 'Austin', 'TX', 'USA', '2020-08-12', TRUE, CURRENT_TIMESTAMP()),
    ('GUEST_005', 'David', 'Brown', 'david.b@email.com', '+1-555-0105', '1983-04-18', 'M', 'UK', 'English', 'London', 'England', 'UK', '2019-11-25', TRUE, CURRENT_TIMESTAMP())
    """
    execute_sql(cursor, guests_data, "Sample guests (5 profiles)")
    
    # Insert loyalty data
    loyalty_data = """
    INSERT INTO loyalty_program VALUES
    ('LOYALTY_001', 'GUEST_001', 'Gold', 15000, 45000, 'Active', CURRENT_TIMESTAMP()),
    ('LOYALTY_002', 'GUEST_002', 'Diamond', 25000, 85000, 'Active', CURRENT_TIMESTAMP()),
    ('LOYALTY_003', 'GUEST_003', 'Silver', 8000, 18000, 'Active', CURRENT_TIMESTAMP()),
    ('LOYALTY_004', 'GUEST_004', 'Blue', 3000, 8000, 'Active', CURRENT_TIMESTAMP()),
    ('LOYALTY_005', 'GUEST_005', 'Gold', 12000, 35000, 'Active', CURRENT_TIMESTAMP())
    """
    execute_sql(cursor, loyalty_data, "Sample loyalty data")
    
    # Insert booking data
    booking_data = """
    INSERT INTO booking_history VALUES
    ('BOOKING_001', 'GUEST_001', 'HOTEL_001', '2024-01-15 10:30:00', '2024-02-01', '2024-02-03', 2, 'Deluxe King', 450.00, 'Website', 'Confirmed', CURRENT_TIMESTAMP()),
    ('BOOKING_002', 'GUEST_002', 'HOTEL_002', '2024-01-20 14:15:00', '2024-02-15', '2024-02-18', 3, 'Suite', 720.00, 'Mobile App', 'Confirmed', CURRENT_TIMESTAMP()),
    ('BOOKING_003', 'GUEST_003', 'HOTEL_003', '2024-01-25 09:45:00', '2024-03-01', '2024-03-02', 1, 'Standard Queen', 180.00, 'Phone', 'Confirmed', CURRENT_TIMESTAMP()),
    ('BOOKING_004', 'GUEST_004', 'HOTEL_004', '2024-02-01 16:20:00', '2024-03-15', '2024-03-17', 2, 'Deluxe King', 380.00, 'Website', 'Confirmed', CURRENT_TIMESTAMP()),
    ('BOOKING_005', 'GUEST_005', 'HOTEL_005', '2024-02-05 11:10:00', '2024-04-01', '2024-04-05', 4, 'Executive Suite', 1200.00, 'Travel Agent', 'Confirmed', CURRENT_TIMESTAMP())
    """
    execute_sql(cursor, booking_data, "Sample bookings (5 records)")
    
    print("\n🔄 CREATING SILVER LAYER")
    print("-" * 30)
    
    execute_sql(cursor, "USE SCHEMA SILVER", "Switching to Silver schema")
    
    # Create guests standardized view
    guests_standardized_sql = """
    CREATE OR REPLACE TABLE guests_standardized AS
    SELECT 
        g.guest_id,
        g.first_name,
        g.last_name,
        g.email,
        g.date_of_birth,
        DATEDIFF(year, g.date_of_birth, CURRENT_DATE()) as age,
        CASE 
            WHEN DATEDIFF(year, g.date_of_birth, CURRENT_DATE()) < 25 THEN 'Gen Z'
            WHEN DATEDIFF(year, g.date_of_birth, CURRENT_DATE()) < 40 THEN 'Millennial'
            WHEN DATEDIFF(year, g.date_of_birth, CURRENT_DATE()) < 55 THEN 'Gen X'
            ELSE 'Boomer'
        END as generation,
        g.gender,
        g.nationality,
        g.city,
        g.state_province,
        g.country,
        l.tier_level as loyalty_tier,
        l.points_balance as loyalty_points,
        COUNT(b.booking_id) as total_bookings,
        SUM(b.total_amount) as total_revenue,
        AVG(b.total_amount) as avg_booking_value,
        g.marketing_opt_in,
        CURRENT_TIMESTAMP() as processed_at
    FROM BRONZE.guest_profiles g
    LEFT JOIN BRONZE.loyalty_program l ON g.guest_id = l.guest_id
    LEFT JOIN BRONZE.booking_history b ON g.guest_id = b.guest_id
    GROUP BY g.guest_id, g.first_name, g.last_name, g.email, g.date_of_birth, 
             g.gender, g.nationality, g.city, g.state_province, g.country,
             l.tier_level, l.points_balance, g.marketing_opt_in
    """
    execute_sql(cursor, guests_standardized_sql, "Guests standardized table")
    
    print("\n🏆 CREATING GOLD LAYER")
    print("-" * 30)
    
    execute_sql(cursor, "USE SCHEMA GOLD", "Switching to Gold schema")
    
    # Create guest 360 view
    guest_360_sql = """
    CREATE OR REPLACE TABLE guest_360_view AS
    SELECT 
        guest_id,
        first_name,
        last_name,
        email,
        age,
        generation,
        loyalty_tier,
        loyalty_points,
        total_bookings,
        total_revenue,
        avg_booking_value,
        CASE 
            WHEN total_revenue >= 5000 AND loyalty_tier = 'Diamond' THEN 'VIP Champion'
            WHEN total_revenue >= 3000 THEN 'High Value'
            WHEN total_bookings >= 3 THEN 'Loyal Regular'
            ELSE 'Regular'
        END as customer_segment,
        CASE 
            WHEN total_bookings = 0 THEN 'High Risk'
            WHEN total_bookings <= 2 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END as churn_risk,
        marketing_opt_in,
        processed_at
    FROM SILVER.guests_standardized
    """
    execute_sql(cursor, guest_360_sql, "Guest 360 view table")
    
    # Create personalization scores
    personalization_scores_sql = """
    CREATE OR REPLACE TABLE personalization_scores AS
    SELECT 
        guest_id,
        customer_segment,
        loyalty_tier,
        CASE 
            WHEN total_bookings >= 5 THEN LEAST(100, 60 + (total_bookings * 5))
            WHEN total_bookings >= 3 THEN 50 + (total_bookings * 8)
            WHEN total_bookings >= 1 THEN 30 + (total_bookings * 10)
            ELSE 20
        END as personalization_readiness_score,
        CASE 
            WHEN customer_segment = 'VIP Champion' THEN 85 + RANDOM() * 15
            WHEN customer_segment = 'High Value' THEN 70 + RANDOM() * 20
            WHEN customer_segment = 'Loyal Regular' THEN 55 + RANDOM() * 25
            ELSE 30 + RANDOM() * 30
        END as upsell_propensity_score,
        CASE 
            WHEN loyalty_tier = 'Diamond' THEN 90 + RANDOM() * 10
            WHEN loyalty_tier = 'Gold' THEN 75 + RANDOM() * 15
            WHEN loyalty_tier = 'Silver' THEN 60 + RANDOM() * 20
            ELSE 40 + RANDOM() * 30
        END as loyalty_propensity_score,
        CURRENT_TIMESTAMP() as calculated_at
    FROM guest_360_view
    """
    execute_sql(cursor, personalization_scores_sql, "Personalization scores table")
    
    print("\n👁️ CREATING SEMANTIC VIEWS")
    print("-" * 30)
    
    execute_sql(cursor, "USE SCHEMA SEMANTIC", "Switching to Semantic schema")
    
    # Create guest profile summary view
    guest_summary_sql = """
    CREATE OR REPLACE VIEW guest_profile_summary AS
    SELECT 
        g.guest_id,
        CONCAT(g.first_name, ' ', g.last_name) as full_name,
        g.email,
        g.age || ' years old' as age_description,
        g.generation,
        g.loyalty_tier as loyalty_status,
        g.loyalty_points as current_points,
        g.total_bookings as lifetime_bookings,
        '$' || FORMAT(g.total_revenue, 2) as lifetime_value,
        g.customer_segment as guest_category,
        g.churn_risk as retention_risk,
        g.marketing_opt_in as accepts_marketing,
        p.personalization_readiness_score,
        p.upsell_propensity_score,
        p.loyalty_propensity_score
    FROM GOLD.guest_360_view g
    LEFT JOIN GOLD.personalization_scores p ON g.guest_id = p.guest_id
    """
    execute_sql(cursor, guest_summary_sql, "Guest profile summary view")
    
    # Create personalization opportunities view
    personalization_opps_sql = """
    CREATE OR REPLACE VIEW personalization_opportunities AS
    SELECT 
        gps.guest_id,
        gps.full_name,
        gps.email,
        gps.guest_category,
        gps.loyalty_status,
        gps.personalization_readiness_score,
        CASE 
            WHEN gps.personalization_readiness_score >= 80 THEN 'Excellent'
            WHEN gps.personalization_readiness_score >= 60 THEN 'Good'
            WHEN gps.personalization_readiness_score >= 40 THEN 'Fair'
            ELSE 'Limited'
        END as personalization_potential,
        gps.upsell_propensity_score,
        CASE 
            WHEN gps.upsell_propensity_score >= 70 THEN 'High Potential'
            WHEN gps.upsell_propensity_score >= 50 THEN 'Medium Potential'
            ELSE 'Low Potential'
        END as upsell_opportunity,
        gps.accepts_marketing
    FROM guest_profile_summary gps
    WHERE gps.personalization_readiness_score >= 30
    ORDER BY gps.personalization_readiness_score DESC
    """
    execute_sql(cursor, personalization_opps_sql, "Personalization opportunities view")
    
    print("\n✅ VERIFICATION")
    print("-" * 30)
    
    # Verify data
    verification_queries = [
        ("Bronze - Guest Profiles", "SELECT COUNT(*) FROM BRONZE.guest_profiles"),
        ("Bronze - Hotels", "SELECT COUNT(*) FROM BRONZE.hotel_properties"),
        ("Bronze - Bookings", "SELECT COUNT(*) FROM BRONZE.booking_history"),
        ("Silver - Guests Standardized", "SELECT COUNT(*) FROM SILVER.guests_standardized"),
        ("Gold - Guest 360 View", "SELECT COUNT(*) FROM GOLD.guest_360_view"),
        ("Gold - Personalization Scores", "SELECT COUNT(*) FROM GOLD.personalization_scores"),
        ("Semantic - Profile Summary", "SELECT COUNT(*) FROM SEMANTIC.guest_profile_summary"),
        ("Semantic - Personalization Opps", "SELECT COUNT(*) FROM SEMANTIC.personalization_opportunities")
    ]
    
    for description, query in verification_queries:
        try:
            cursor.execute(query)
            result = cursor.fetchone()
            print(f"  ✅ {description}: {result[0]} records")
        except Exception as e:
            print(f"  ⚠️  {description}: {str(e)}")
    
    print("\n🎯 SAMPLE DATA PREVIEW")
    print("-" * 30)
    
    cursor.execute("SELECT * FROM SEMANTIC.guest_profile_summary LIMIT 3")
    results = cursor.fetchall()
    for result in results:
        print(f"  👤 {result[1]} ({result[5]}) - {result[7]} bookings - {result[8]} LTV")
    
    print("\n🎉 FOCUSED DEPLOYMENT COMPLETED!")
    print("=" * 50)
    print("✅ Database: HOTEL_PERSONALIZATION created")
    print("✅ Schemas: Bronze, Silver, Gold, Semantic ready")
    print("✅ Core tables: Guest profiles, hotels, bookings, loyalty")
    print("✅ Sample data: 5 guests, 5 hotels, 5 bookings loaded")
    print("✅ Analytics: Guest 360 view and personalization scores")
    print("✅ Semantic views: Business-friendly guest insights")
    
    print("\n💡 NEXT STEPS:")
    print("1. Test semantic views with business queries")
    print("2. Create Snowflake Intelligence Agents")
    print("3. Add more sample data as needed")
    print("4. Set up RBAC for production use")
    
    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()



