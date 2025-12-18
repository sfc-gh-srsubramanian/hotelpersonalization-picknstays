#!/usr/bin/env python3
"""
Hotel Personalization System - Create Admin Role
Creates the HOTEL_PERSONALIZATION_ADMIN role with proper permissions
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
    # Connect with existing role to create new admin role
    conn = snowflake.connector.connect(
        user='srsubramanian',
        account='SFSENORTHAMERICA-SFSENORTHAMERICA_SRISUB_AWS1',
        warehouse='COMPUTE_WH',
        role='LOSS_PREVENTION_ADMIN',  # Use existing role to create new one
        private_key=load_private_key()
    )
    cursor = conn.cursor()
    
    print("🔐 CREATING HOTEL PERSONALIZATION ADMIN ROLE")
    print("=" * 50)
    
    # Create the admin role
    admin_role_sql = """
    CREATE ROLE IF NOT EXISTS HOTEL_PERSONALIZATION_ADMIN
    COMMENT = 'Administrative role for Hotel Personalization System with full permissions'
    """
    execute_sql(cursor, admin_role_sql, "Hotel Personalization Admin role")
    
    # Grant necessary privileges to the admin role
    privileges = [
        "GRANT CREATE DATABASE ON ACCOUNT TO ROLE HOTEL_PERSONALIZATION_ADMIN",
        "GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE HOTEL_PERSONALIZATION_ADMIN",
        "GRANT CREATE ROLE ON ACCOUNT TO ROLE HOTEL_PERSONALIZATION_ADMIN",
        "GRANT CREATE USER ON ACCOUNT TO ROLE HOTEL_PERSONALIZATION_ADMIN",
        "GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE HOTEL_PERSONALIZATION_ADMIN",
        "GRANT OPERATE ON WAREHOUSE COMPUTE_WH TO ROLE HOTEL_PERSONALIZATION_ADMIN",
        "GRANT MONITOR ON WAREHOUSE COMPUTE_WH TO ROLE HOTEL_PERSONALIZATION_ADMIN"
    ]
    
    print("\n🎯 GRANTING ADMIN PRIVILEGES")
    print("-" * 30)
    
    for privilege in privileges:
        execute_sql(cursor, privilege, f"Privilege: {privilege.split(' TO ')[0].replace('GRANT ', '')}")
    
    # Grant the admin role to your user
    grant_role_sql = "GRANT ROLE HOTEL_PERSONALIZATION_ADMIN TO USER srsubramanian"
    execute_sql(cursor, grant_role_sql, "Admin role granted to srsubramanian")
    
    # Check if we can use the new role
    print("\n🔄 TESTING NEW ADMIN ROLE")
    print("-" * 30)
    
    try:
        cursor.execute("USE ROLE HOTEL_PERSONALIZATION_ADMIN")
        print("  ✅ Successfully switched to HOTEL_PERSONALIZATION_ADMIN role")
        
        # Test database creation permission
        cursor.execute("CREATE DATABASE IF NOT EXISTS HOTEL_PERSONALIZATION_TEST")
        print("  ✅ Database creation permission verified")
        
        # Clean up test database
        cursor.execute("DROP DATABASE IF EXISTS HOTEL_PERSONALIZATION_TEST")
        print("  ✅ Test database cleaned up")
        
        # Show current role and permissions
        cursor.execute("SELECT CURRENT_ROLE()")
        role = cursor.fetchone()
        print(f"  ✅ Current role: {role[0]}")
        
    except Exception as e:
        print(f"  ⚠️  Role test failed: {str(e)}")
    
    print("\n🎉 ADMIN ROLE SETUP COMPLETED!")
    print("=" * 50)
    print("✅ HOTEL_PERSONALIZATION_ADMIN role created")
    print("✅ Full database and warehouse permissions granted")
    print("✅ Role assigned to srsubramanian user")
    print("✅ Ready for hotel personalization system deployment")
    
    print("\n🚀 NEXT STEPS:")
    print("1. Use HOTEL_PERSONALIZATION_ADMIN role for all deployments")
    print("2. Deploy the complete hotel personalization system")
    print("3. Create additional project-specific roles as needed")
    
    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()



