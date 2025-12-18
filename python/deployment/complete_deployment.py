#!/usr/bin/env python3
"""
Complete Hotel Personalization System Deployment
===============================================
This script deploys the entire hotel personalization system to Snowflake
including database setup, data layers, semantic views, and AI agents.
"""

import snowflake.connector
import os
from pathlib import Path

# Connection configuration
SNOWFLAKE_CONFIG = {
    'user': 'SRSUBRAMANIAN',
    'account': 'snowflake_partner_se_training-srsubramanian',
    'private_key_file': os.path.expanduser('~/.ssh/snowflake_rsa_key'),
    'role': 'ACCOUNTADMIN',
    'warehouse': 'COMPUTE_WH',
    'database': 'HOTEL_PERSONALIZATION'
}

def load_private_key():
    """Load the private key for authentication"""
    from cryptography.hazmat.primitives import serialization
    
    with open(SNOWFLAKE_CONFIG['private_key_file'], 'rb') as key_file:
        private_key = serialization.load_pem_private_key(
            key_file.read(),
            password=None
        )
    
    return private_key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )

def execute_sql_file(cursor, file_path, description=""):
    """Execute SQL commands from a file"""
    print(f"\n🔄 Executing {description}: {file_path}")
    
    try:
        with open(file_path, 'r') as file:
            sql_content = file.read()
        
        # Split by semicolon and execute each statement
        statements = [stmt.strip() for stmt in sql_content.split(';') if stmt.strip()]
        
        for i, statement in enumerate(statements, 1):
            if statement:
                print(f"   Executing statement {i}/{len(statements)}")
                cursor.execute(statement)
        
        print(f"✅ Successfully executed {description}")
        return True
        
    except Exception as e:
        print(f"❌ Error executing {description}: {str(e)}")
        return False

def main():
    """Main deployment function"""
    print("🏨 Starting Hotel Personalization System Deployment")
    print("=" * 60)
    
    # Load private key
    try:
        private_key = load_private_key()
        print("✅ Private key loaded successfully")
    except Exception as e:
        print(f"❌ Failed to load private key: {e}")
        return False
    
    # Connect to Snowflake
    try:
        conn = snowflake.connector.connect(
            user=SNOWFLAKE_CONFIG['user'],
            account=SNOWFLAKE_CONFIG['account'],
            private_key=private_key,
            role=SNOWFLAKE_CONFIG['role'],
            warehouse=SNOWFLAKE_CONFIG['warehouse']
        )
        cursor = conn.cursor()
        print("✅ Connected to Snowflake successfully")
    except Exception as e:
        print(f"❌ Failed to connect to Snowflake: {e}")
        return False
    
    # Get project root directory
    project_root = Path(__file__).parent.parent.parent
    sql_dir = project_root / 'sql'
    
    # Deployment steps
    deployment_steps = [
        (sql_dir / 'setup' / '01_setup_database.sql', "Database Setup"),
        (sql_dir / 'security' / '32_create_hotel_project_roles.sql', "Security Roles"),
        (sql_dir / 'bronze' / '02_bronze_layer_tables.sql', "Bronze Layer Tables"),
        (sql_dir / 'bronze' / '03_sample_data_generation.sql', "Sample Data Generation"),
        (sql_dir / 'bronze' / '04_booking_stay_data.sql', "Booking Data Generation"),
        (sql_dir / 'silver' / '05_silver_layer.sql', "Silver Layer"),
        (sql_dir / 'gold' / '06_gold_layer.sql', "Gold Layer"),
        (sql_dir / 'semantic_views' / 'create_semantic_views.sql', "Semantic Views"),
        (sql_dir / 'agents' / 'create_intelligence_agents.sql', "AI Agents")
    ]
    
    # Execute deployment steps
    success_count = 0
    for file_path, description in deployment_steps:
        if file_path.exists():
            if execute_sql_file(cursor, file_path, description):
                success_count += 1
        else:
            print(f"⚠️  File not found: {file_path}")
    
    # Close connection
    cursor.close()
    conn.close()
    
    # Summary
    print("\n" + "=" * 60)
    print(f"🎯 Deployment Summary: {success_count}/{len(deployment_steps)} steps completed")
    
    if success_count == len(deployment_steps):
        print("🎉 Hotel Personalization System deployed successfully!")
        print("\n📋 What's been created:")
        print("   • Database: HOTEL_PERSONALIZATION")
        print("   • 5 Data schemas (Bronze, Silver, Gold, Business_Views, Semantic_Views)")
        print("   • 6 Security roles with proper permissions")
        print("   • 1000+ guest records with realistic data")
        print("   • 3 Semantic views for natural language queries")
        print("   • 5 AI agents for hotel operations")
        print("\n🚀 Ready for production use!")
    else:
        print("⚠️  Some deployment steps failed. Check the logs above.")
    
    return success_count == len(deployment_steps)

if __name__ == "__main__":
    main()


























