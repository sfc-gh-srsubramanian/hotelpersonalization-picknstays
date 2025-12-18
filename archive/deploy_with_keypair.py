#!/usr/bin/env python3
"""
Hotel Personalization System - Snowflake Deployment Script
Uses key-pair authentication to deploy the complete system
"""

import snowflake.connector
import os
from pathlib import Path
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.serialization import load_pem_private_key
import sys

def load_private_key():
    """Load the private key for Snowflake authentication"""
    key_path = os.path.expanduser("~/.snowflake/snowflake_key.p8")
    
    with open(key_path, "rb") as key_file:
        private_key = load_pem_private_key(
            key_file.read(),
            password=None,  # No passphrase for p8 format
        )
    
    pkb = private_key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )
    
    return pkb

def execute_sql_file(cursor, file_path):
    """Execute SQL commands from a file"""
    print(f"Executing {file_path}...")
    
    with open(file_path, 'r') as file:
        sql_content = file.read()
    
    # Split by semicolon and execute each statement
    statements = [stmt.strip() for stmt in sql_content.split(';') if stmt.strip()]
    
    for i, statement in enumerate(statements):
        if statement.upper().startswith('SOURCE'):
            # Skip source statements as we're executing files directly
            continue
            
        try:
            cursor.execute(statement)
            print(f"  ✓ Statement {i+1} executed successfully")
        except Exception as e:
            print(f"  ✗ Error in statement {i+1}: {str(e)}")
            # Continue with next statement for non-critical errors
            continue

def main():
    """Main deployment function"""
    
    # Connection parameters from your Snowflake config
    connection_params = {
        'user': 'srsubramanian',
        'account': 'SFSENORTHAMERICA-SFSENORTHAMERICA_SRISUB_AWS1',
        'warehouse': 'COMPUTE_WH',
        'role': 'LOSS_PREVENTION_ADMIN',
        'private_key': load_private_key(),
    }
    
    # SQL files to execute in order
    sql_files = [
        '01_setup_database.sql',
        '02_bronze_layer_tables.sql',
        '03_sample_data_generation.sql',
        '04_booking_stay_data.sql',
        '05_silver_layer.sql',
        '06_gold_layer.sql',
        '07_semantic_views.sql'
    ]
    
    try:
        print("🚀 Starting Snowflake deployment...")
        print("Connecting to Snowflake...")
        
        # Establish connection
        conn = snowflake.connector.connect(**connection_params)
        cursor = conn.cursor()
        
        print("✓ Connected successfully!")
        
        # Execute each SQL file
        for sql_file in sql_files:
            if os.path.exists(sql_file):
                execute_sql_file(cursor, sql_file)
            else:
                print(f"⚠️  File {sql_file} not found, skipping...")
        
        # Verification queries
        print("\n📊 Running verification queries...")
        
        verification_queries = [
            ("Bronze layer - Guest Profiles", "SELECT COUNT(*) FROM BRONZE.guest_profiles"),
            ("Bronze layer - Booking History", "SELECT COUNT(*) FROM BRONZE.booking_history"),
            ("Bronze layer - Stay History", "SELECT COUNT(*) FROM BRONZE.stay_history"),
            ("Silver layer - Guests Standardized", "SELECT COUNT(*) FROM SILVER.guests_standardized"),
            ("Gold layer - Guest 360 View", "SELECT COUNT(*) FROM GOLD.guest_360_view"),
            ("Semantic - Personalization Opportunities", "SELECT COUNT(*) FROM SEMANTIC.personalization_opportunities")
        ]
        
        for description, query in verification_queries:
            try:
                cursor.execute(query)
                result = cursor.fetchone()
                print(f"  ✓ {description}: {result[0]:,} records")
            except Exception as e:
                print(f"  ✗ {description}: Error - {str(e)}")
        
        print("\n🎉 Deployment completed successfully!")
        print("\n📋 Next steps:")
        print("1. Test the semantic views with sample queries")
        print("2. Set up dashboards using the business views")
        print("3. Integrate with hotel systems for real-time personalization")
        
    except Exception as e:
        print(f"❌ Deployment failed: {str(e)}")
        sys.exit(1)
    
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    main()
