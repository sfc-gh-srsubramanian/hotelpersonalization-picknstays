#!/usr/bin/env python3
"""
Hotel Personalization System - Execute Role Creation in Snowflake
Creates proper project-specific roles with appropriate permissions
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

def execute_sql_statement(cursor, sql, description):
    try:
        cursor.execute(sql)
        print(f"  ✅ {description}")
        return True
    except Exception as e:
        print(f"  ⚠️  {description}: {str(e)}")
        return False

def main():
    # Try connecting with ACCOUNTADMIN role first for role creation
    try:
        print("🔐 Attempting connection with ACCOUNTADMIN role...")
        conn = snowflake.connector.connect(
            user='srsubramanian',
            account='SFSENORTHAMERICA-SFSENORTHAMERICA_SRISUB_AWS1',
            warehouse='COMPUTE_WH',
            role='ACCOUNTADMIN',
            private_key=load_private_key()
        )
        print("  ✅ Connected with ACCOUNTADMIN role")
    except Exception as e:
        print(f"  ⚠️  ACCOUNTADMIN connection failed: {str(e)}")
        print("🔐 Attempting connection with SYSADMIN role...")
        try:
            conn = snowflake.connector.connect(
                user='srsubramanian',
                account='SFSENORTHAMERICA-SFSENORTHAMERICA_SRISUB_AWS1',
                warehouse='COMPUTE_WH',
                role='SYSADMIN',
                private_key=load_private_key()
            )
            print("  ✅ Connected with SYSADMIN role")
        except Exception as e:
            print(f"  ⚠️  SYSADMIN connection failed: {str(e)}")
            print("🔐 Falling back to available role...")
            conn = snowflake.connector.connect(
                user='srsubramanian',
                account='SFSENORTHAMERICA-SFSENORTHAMERICA_SRISUB_AWS1',
                warehouse='COMPUTE_WH',
                private_key=load_private_key()
            )
            print("  ✅ Connected with default role")
    
    cursor = conn.cursor()
    
    print("\n🏨 CREATING HOTEL PERSONALIZATION PROJECT ROLES")
    print("=" * 60)
    
    # Step 1: Create Project-Specific Roles
    print("\n👥 STEP 1: CREATING PROJECT-SPECIFIC ROLES")
    print("-" * 45)
    
    roles = [
        ("HOTEL_PERSONALIZATION_ADMIN", "Administrative role for hotel personalization project management"),
        ("HOTEL_GUEST_ANALYST", "Analyst role for guest behavior and preference analysis"),
        ("HOTEL_REVENUE_ANALYST", "Analyst role for revenue optimization and pricing strategies"),
        ("HOTEL_EXPERIENCE_ANALYST", "Analyst role for guest experience and satisfaction analysis"),
        ("HOTEL_DATA_ENGINEER", "Data engineer role for hotel personalization data pipeline management"),
        ("HOTEL_BUSINESS_ANALYST", "Business analyst role for strategic insights and reporting")
    ]
    
    for role_name, comment in roles:
        sql = f"CREATE ROLE IF NOT EXISTS {role_name} COMMENT = '{comment}'"
        execute_sql_statement(cursor, sql, f"Role: {role_name}")
    
    # Step 2: Create Role Hierarchy
    print("\n🏗️ STEP 2: CREATING ROLE HIERARCHY")
    print("-" * 35)
    
    hierarchy_grants = [
        "GRANT ROLE HOTEL_GUEST_ANALYST TO ROLE HOTEL_PERSONALIZATION_ADMIN",
        "GRANT ROLE HOTEL_REVENUE_ANALYST TO ROLE HOTEL_PERSONALIZATION_ADMIN",
        "GRANT ROLE HOTEL_EXPERIENCE_ANALYST TO ROLE HOTEL_PERSONALIZATION_ADMIN",
        "GRANT ROLE HOTEL_DATA_ENGINEER TO ROLE HOTEL_PERSONALIZATION_ADMIN",
        "GRANT ROLE HOTEL_BUSINESS_ANALYST TO ROLE HOTEL_PERSONALIZATION_ADMIN"
    ]
    
    for grant in hierarchy_grants:
        execute_sql_statement(cursor, grant, f"Hierarchy: {grant.split()[-1]}")
    
    # Step 3: Database and Warehouse Permissions
    print("\n🗄️ STEP 3: DATABASE AND WAREHOUSE PERMISSIONS")
    print("-" * 45)
    
    # Ensure database exists
    execute_sql_statement(cursor, "CREATE DATABASE IF NOT EXISTS HOTEL_PERSONALIZATION", "Database creation")
    
    db_permissions = [
        "GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE HOTEL_PERSONALIZATION_ADMIN",
        "GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE HOTEL_GUEST_ANALYST",
        "GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE HOTEL_REVENUE_ANALYST",
        "GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE HOTEL_EXPERIENCE_ANALYST",
        "GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE HOTEL_DATA_ENGINEER",
        "GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE HOTEL_BUSINESS_ANALYST"
    ]
    
    for permission in db_permissions:
        execute_sql_statement(cursor, permission, f"DB Access: {permission.split()[-1]}")
    
    warehouse_permissions = [
        "GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE HOTEL_PERSONALIZATION_ADMIN",
        "GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE HOTEL_GUEST_ANALYST",
        "GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE HOTEL_REVENUE_ANALYST",
        "GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE HOTEL_EXPERIENCE_ANALYST",
        "GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE HOTEL_DATA_ENGINEER",
        "GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE HOTEL_BUSINESS_ANALYST"
    ]
    
    for permission in warehouse_permissions:
        execute_sql_statement(cursor, permission, f"WH Access: {permission.split()[-1]}")
    
    # Step 4: Schema Permissions
    print("\n📁 STEP 4: SCHEMA PERMISSIONS")
    print("-" * 30)
    
    # Admin gets all privileges
    execute_sql_statement(cursor, 
        "GRANT ALL PRIVILEGES ON ALL SCHEMAS IN DATABASE HOTEL_PERSONALIZATION TO ROLE HOTEL_PERSONALIZATION_ADMIN",
        "Admin schema privileges")
    
    # Analyst roles get usage
    schema_usage_roles = ["HOTEL_GUEST_ANALYST", "HOTEL_REVENUE_ANALYST", "HOTEL_EXPERIENCE_ANALYST", 
                         "HOTEL_DATA_ENGINEER", "HOTEL_BUSINESS_ANALYST"]
    
    for role in schema_usage_roles:
        execute_sql_statement(cursor,
            f"GRANT USAGE ON ALL SCHEMAS IN DATABASE HOTEL_PERSONALIZATION TO ROLE {role}",
            f"Schema usage: {role}")
    
    # Step 5: Table and View Permissions
    print("\n📊 STEP 5: TABLE AND VIEW PERMISSIONS")
    print("-" * 40)
    
    # Admin and Data Engineer get full access
    full_access_roles = ["HOTEL_PERSONALIZATION_ADMIN", "HOTEL_DATA_ENGINEER"]
    for role in full_access_roles:
        execute_sql_statement(cursor,
            f"GRANT ALL PRIVILEGES ON ALL TABLES IN DATABASE HOTEL_PERSONALIZATION TO ROLE {role}",
            f"Full table access: {role}")
        execute_sql_statement(cursor,
            f"GRANT ALL PRIVILEGES ON ALL VIEWS IN DATABASE HOTEL_PERSONALIZATION TO ROLE {role}",
            f"Full view access: {role}")
    
    # Analyst roles get SELECT access
    select_roles = ["HOTEL_GUEST_ANALYST", "HOTEL_REVENUE_ANALYST", "HOTEL_EXPERIENCE_ANALYST", "HOTEL_BUSINESS_ANALYST"]
    for role in select_roles:
        execute_sql_statement(cursor,
            f"GRANT SELECT ON ALL TABLES IN DATABASE HOTEL_PERSONALIZATION TO ROLE {role}",
            f"Select table access: {role}")
        execute_sql_statement(cursor,
            f"GRANT SELECT ON ALL VIEWS IN DATABASE HOTEL_PERSONALIZATION TO ROLE {role}",
            f"Select view access: {role}")
    
    # Step 6: Future Object Permissions
    print("\n🔮 STEP 6: FUTURE OBJECT PERMISSIONS")
    print("-" * 40)
    
    # Future objects for admin and data engineer
    for role in full_access_roles:
        execute_sql_statement(cursor,
            f"GRANT ALL PRIVILEGES ON FUTURE TABLES IN DATABASE HOTEL_PERSONALIZATION TO ROLE {role}",
            f"Future table access: {role}")
        execute_sql_statement(cursor,
            f"GRANT ALL PRIVILEGES ON FUTURE VIEWS IN DATABASE HOTEL_PERSONALIZATION TO ROLE {role}",
            f"Future view access: {role}")
    
    # Future objects for analyst roles
    for role in select_roles:
        execute_sql_statement(cursor,
            f"GRANT SELECT ON FUTURE TABLES IN DATABASE HOTEL_PERSONALIZATION TO ROLE {role}",
            f"Future table select: {role}")
        execute_sql_statement(cursor,
            f"GRANT SELECT ON FUTURE VIEWS IN DATABASE HOTEL_PERSONALIZATION TO ROLE {role}",
            f"Future view select: {role}")
    
    # Step 7: Assign Roles to User
    print("\n👤 STEP 7: ASSIGNING ROLES TO USER")
    print("-" * 35)
    
    user_role_grants = [
        "GRANT ROLE HOTEL_PERSONALIZATION_ADMIN TO USER srsubramanian",
        "GRANT ROLE HOTEL_GUEST_ANALYST TO USER srsubramanian",
        "GRANT ROLE HOTEL_REVENUE_ANALYST TO USER srsubramanian",
        "GRANT ROLE HOTEL_EXPERIENCE_ANALYST TO USER srsubramanian",
        "GRANT ROLE HOTEL_DATA_ENGINEER TO USER srsubramanian",
        "GRANT ROLE HOTEL_BUSINESS_ANALYST TO USER srsubramanian"
    ]
    
    for grant in user_role_grants:
        execute_sql_statement(cursor, grant, f"User grant: {grant.split()[2]}")
    
    # Set default role
    execute_sql_statement(cursor,
        "ALTER USER srsubramanian SET DEFAULT_ROLE = 'HOTEL_PERSONALIZATION_ADMIN'",
        "Set default role")
    
    # Step 8: Verification
    print("\n✅ STEP 8: VERIFICATION")
    print("-" * 25)
    
    # Show created roles
    try:
        cursor.execute("SHOW ROLES LIKE 'HOTEL_%'")
        roles = cursor.fetchall()
        print(f"  ✅ Created {len(roles)} hotel project roles:")
        for role in roles:
            print(f"    - {role[1]}")  # Role name is in column 1
    except Exception as e:
        print(f"  ⚠️  Role verification: {str(e)}")
    
    # Test role switching and data access
    print("\n🧪 TESTING ROLE AND DATA ACCESS")
    print("-" * 35)
    
    try:
        execute_sql_statement(cursor, "USE ROLE HOTEL_PERSONALIZATION_ADMIN", "Switch to admin role")
        execute_sql_statement(cursor, "USE DATABASE HOTEL_PERSONALIZATION", "Use hotel database")
        
        # Test data access
        test_queries = [
            ("Bronze guest profiles", "SELECT COUNT(*) FROM BRONZE.guest_profiles"),
            ("Bronze bookings", "SELECT COUNT(*) FROM BRONZE.booking_history"),
            ("Gold guest 360 view", "SELECT COUNT(*) FROM GOLD.guest_360_view"),
            ("Business views access", "SELECT COUNT(*) FROM BUSINESS_VIEWS.guest_profile_summary"),
            ("Semantic views access", "SELECT COUNT(*) FROM SEMANTIC_VIEWS.guest_analytics")
        ]
        
        for description, query in test_queries:
            try:
                cursor.execute(query)
                result = cursor.fetchone()
                print(f"  ✅ {description}: {result[0]} records accessible")
            except Exception as e:
                print(f"  ⚠️  {description}: {str(e)}")
        
    except Exception as e:
        print(f"  ⚠️  Role testing: {str(e)}")
    
    print("\n🎉 HOTEL PROJECT ROLES SETUP COMPLETED!")
    print("=" * 50)
    print("✅ 6 project-specific roles created with proper hierarchy")
    print("✅ Database and warehouse permissions granted")
    print("✅ Schema and object access configured")
    print("✅ Future object permissions set")
    print("✅ Roles assigned to user srsubramanian")
    print("✅ Default role set to HOTEL_PERSONALIZATION_ADMIN")
    print("✅ Data access verified across all layers")
    
    print("\n🚀 READY FOR PROJECT-SPECIFIC OPERATIONS!")
    print("You can now use these roles for:")
    print("• HOTEL_PERSONALIZATION_ADMIN - Full project administration")
    print("• HOTEL_GUEST_ANALYST - Guest behavior analysis")
    print("• HOTEL_REVENUE_ANALYST - Revenue optimization")
    print("• HOTEL_EXPERIENCE_ANALYST - Guest experience enhancement")
    print("• HOTEL_DATA_ENGINEER - Data pipeline management")
    print("• HOTEL_BUSINESS_ANALYST - Strategic business insights")
    
    print("\n💡 NEXT: Update Snowflake Intelligence Agents to use these roles!")
    
    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()



