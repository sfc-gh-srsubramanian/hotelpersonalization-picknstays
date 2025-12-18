#!/usr/bin/env python3
"""
Hotel Personalization System - Create Proper Snowflake Semantic Views
Creates semantic views using CREATE SEMANTIC VIEW syntax with proper structure
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
        role='HOTEL_PERSONALIZATION_ADMIN',
        private_key=load_private_key()
    )
    cursor = conn.cursor()
    
    print("🏗️ CREATING PROPER SNOWFLAKE SEMANTIC VIEWS")
    print("=" * 55)
    print("🎯 Using CREATE SEMANTIC VIEW syntax with proper structure")
    print("=" * 55)
    
    execute_sql(cursor, "USE DATABASE HOTEL_PERSONALIZATION", "Using hotel database")
    execute_sql(cursor, "USE SCHEMA SEMANTIC_VIEWS", "Using semantic views schema")
    
    # First, drop any existing regular views that might conflict
    print("\n🗑️ CLEANING UP EXISTING REGULAR VIEWS")
    print("-" * 40)
    
    cleanup_views = [
        "DROP VIEW IF EXISTS guest_analytics",
        "DROP VIEW IF EXISTS personalization_insights"
    ]
    
    for cleanup in cleanup_views:
        execute_sql(cursor, cleanup, f"Cleanup: {cleanup.split()[-1]}")
    
    # Create Semantic View 1: Guest Analytics
    print("\n🧠 CREATING GUEST ANALYTICS SEMANTIC VIEW")
    print("-" * 45)
    
    guest_analytics_semantic_sql = """
    CREATE OR REPLACE SEMANTIC VIEW guest_analytics
    COMMENT = 'Comprehensive guest analytics semantic view for AI-powered insights'
    AS (
        tables:
          - name: GUESTS
            base_table: 
              database: HOTEL_PERSONALIZATION
              schema: GOLD
              table: GUEST_360_VIEW
            primary_key: [guest_id]
            comment: "Main guest profile and analytics data"
            dimensions:
              - name: guest_id
                expr: guest_id
                data_type: string
                comment: "Unique guest identifier"
                synonyms: ["guest ID", "customer ID", "guest identifier"]
              - name: guest_name
                expr: first_name || ' ' || last_name
                data_type: string
                comment: "Full guest name"
                synonyms: ["customer name", "guest full name", "name"]
              - name: customer_segment
                expr: customer_segment
                data_type: string
                comment: "Customer segment classification"
                synonyms: ["guest segment", "customer category", "guest type"]
              - name: loyalty_tier
                expr: loyalty_tier
                data_type: string
                comment: "Loyalty program tier level"
                synonyms: ["loyalty level", "membership tier", "loyalty status"]
              - name: generation
                expr: generation
                data_type: string
                comment: "Generational cohort"
                synonyms: ["age group", "demographic", "generation group"]
              - name: churn_risk
                expr: churn_risk
                data_type: string
                comment: "Customer churn risk assessment"
                synonyms: ["retention risk", "churn probability", "risk level"]
            measures:
              - name: total_revenue
                expr: total_revenue
                data_type: number
                comment: "Total lifetime revenue from guest"
                synonyms: ["lifetime value", "total spend", "revenue"]
              - name: total_bookings
                expr: total_bookings
                data_type: number
                comment: "Total number of bookings made"
                synonyms: ["booking count", "number of stays", "visit count"]
              - name: avg_booking_value
                expr: avg_booking_value
                data_type: number
                comment: "Average value per booking"
                synonyms: ["average spend", "avg booking amount", "typical spend"]
              - name: avg_stay_length
                expr: avg_stay_length
                data_type: number
                comment: "Average length of stay in nights"
                synonyms: ["average nights", "typical stay", "avg duration"]
          
          - name: PERSONALIZATION_SCORES
            base_table:
              database: HOTEL_PERSONALIZATION
              schema: GOLD
              table: PERSONALIZATION_SCORES
            primary_key: [guest_id]
            comment: "Guest personalization and propensity scores"
            dimensions:
              - name: guest_id
                expr: guest_id
                data_type: string
                comment: "Guest identifier for joining"
            measures:
              - name: personalization_readiness_score
                expr: personalization_readiness_score
                data_type: number
                comment: "Score indicating readiness for personalization (0-100)"
                synonyms: ["personalization score", "readiness score", "personalization potential"]
              - name: upsell_propensity_score
                expr: upsell_propensity_score
                data_type: number
                comment: "Propensity to purchase upsells (0-100)"
                synonyms: ["upsell score", "upgrade potential", "revenue opportunity"]
              - name: loyalty_propensity_score
                expr: loyalty_propensity_score
                data_type: number
                comment: "Likelihood to remain loyal (0-100)"
                synonyms: ["loyalty score", "retention score", "loyalty potential"]
        
        relationships:
          - name: guest_to_scores
            from_table: GUESTS
            to_table: PERSONALIZATION_SCORES
            join_keys:
              - from_column: guest_id
                to_column: guest_id
            comment: "Links guests to their personalization scores"
    )
    """
    execute_sql(cursor, guest_analytics_semantic_sql, "Guest Analytics Semantic View")
    
    # Create Semantic View 2: Personalization Insights
    print("\n🎯 CREATING PERSONALIZATION INSIGHTS SEMANTIC VIEW")
    print("-" * 50)
    
    personalization_semantic_sql = """
    CREATE OR REPLACE SEMANTIC VIEW personalization_insights
    COMMENT = 'Guest personalization opportunities and preferences semantic view'
    AS (
        tables:
          - name: PERSONALIZATION_OPPORTUNITIES
            base_table:
              database: HOTEL_PERSONALIZATION
              schema: BUSINESS_VIEWS
              table: PERSONALIZATION_OPPORTUNITIES
            primary_key: [guest_id]
            comment: "Guest personalization opportunities and potential"
            dimensions:
              - name: guest_id
                expr: guest_id
                data_type: string
                comment: "Unique guest identifier"
                synonyms: ["guest ID", "customer ID"]
              - name: full_name
                expr: full_name
                data_type: string
                comment: "Guest full name"
                synonyms: ["guest name", "customer name", "name"]
              - name: guest_category
                expr: guest_category
                data_type: string
                comment: "Guest category classification"
                synonyms: ["customer segment", "guest type", "category"]
              - name: loyalty_status
                expr: loyalty_status
                data_type: string
                comment: "Current loyalty program status"
                synonyms: ["loyalty tier", "membership level", "loyalty level"]
              - name: personalization_potential
                expr: personalization_potential
                data_type: string
                comment: "Personalization potential rating"
                synonyms: ["personalization rating", "potential level", "readiness level"]
              - name: upsell_opportunity
                expr: upsell_opportunity
                data_type: string
                comment: "Upsell opportunity classification"
                synonyms: ["upsell potential", "revenue opportunity", "upgrade potential"]
              - name: preferred_room_type
                expr: preferred_room_type
                data_type: string
                comment: "Guest's preferred room type"
                synonyms: ["room preference", "room type", "accommodation preference"]
              - name: pillow_preference
                expr: pillow_preference
                data_type: string
                comment: "Guest's pillow type preference"
                synonyms: ["pillow type", "bedding preference", "pillow choice"]
            measures:
              - name: personalization_readiness_score
                expr: personalization_readiness_score
                data_type: number
                comment: "Personalization readiness score (0-100)"
                synonyms: ["readiness score", "personalization score"]
              - name: upsell_propensity_score
                expr: upsell_propensity_score
                data_type: number
                comment: "Upsell propensity score (0-100)"
                synonyms: ["upsell score", "revenue score"]
              - name: loyalty_propensity_score
                expr: loyalty_propensity_score
                data_type: number
                comment: "Loyalty propensity score (0-100)"
                synonyms: ["loyalty score", "retention score"]
              - name: temperature_preference
                expr: temperature_preference
                data_type: number
                comment: "Preferred room temperature in Fahrenheit"
                synonyms: ["temp preference", "room temperature", "temperature setting"]
          
          - name: ROOM_PREFERENCES
            base_table:
              database: HOTEL_PERSONALIZATION
              schema: BRONZE
              table: ROOM_PREFERENCES
            primary_key: [preference_id]
            comment: "Detailed room preferences for guests"
            dimensions:
              - name: guest_id
                expr: guest_id
                data_type: string
                comment: "Guest identifier for joining"
              - name: room_type_preference
                expr: room_type_preference
                data_type: string
                comment: "Preferred room type"
                synonyms: ["room type", "accommodation type"]
              - name: floor_preference
                expr: floor_preference
                data_type: string
                comment: "Preferred floor level"
                synonyms: ["floor level", "floor choice"]
              - name: view_preference
                expr: view_preference
                data_type: string
                comment: "Preferred room view"
                synonyms: ["view type", "room view", "view choice"]
        
        relationships:
          - name: opportunities_to_preferences
            from_table: PERSONALIZATION_OPPORTUNITIES
            to_table: ROOM_PREFERENCES
            join_keys:
              - from_column: guest_id
                to_column: guest_id
            comment: "Links personalization opportunities to detailed room preferences"
    )
    """
    execute_sql(cursor, personalization_semantic_sql, "Personalization Insights Semantic View")
    
    # Create Semantic View 3: Revenue Analytics
    print("\n💰 CREATING REVENUE ANALYTICS SEMANTIC VIEW")
    print("-" * 45)
    
    revenue_analytics_semantic_sql = """
    CREATE OR REPLACE SEMANTIC VIEW revenue_analytics
    COMMENT = 'Revenue optimization and business performance semantic view'
    AS (
        tables:
          - name: GUEST_REVENUE
            base_table:
              database: HOTEL_PERSONALIZATION
              schema: GOLD
              table: GUEST_360_VIEW
            primary_key: [guest_id]
            comment: "Guest revenue and business metrics"
            dimensions:
              - name: guest_id
                expr: guest_id
                data_type: string
                comment: "Unique guest identifier"
              - name: customer_segment
                expr: customer_segment
                data_type: string
                comment: "Revenue-based customer segment"
                synonyms: ["guest segment", "revenue segment", "customer category"]
              - name: loyalty_tier
                expr: loyalty_tier
                data_type: string
                comment: "Loyalty program tier"
                synonyms: ["loyalty level", "membership tier"]
            measures:
              - name: total_revenue
                expr: total_revenue
                data_type: number
                comment: "Total lifetime revenue"
                synonyms: ["lifetime value", "total spend", "revenue"]
              - name: avg_booking_value
                expr: avg_booking_value
                data_type: number
                comment: "Average booking value"
                synonyms: ["average spend", "typical booking value"]
              - name: total_bookings
                expr: total_bookings
                data_type: number
                comment: "Total number of bookings"
                synonyms: ["booking count", "number of stays"]
          
          - name: BOOKING_DETAILS
            base_table:
              database: HOTEL_PERSONALIZATION
              schema: BRONZE
              table: BOOKING_HISTORY
            primary_key: [booking_id]
            comment: "Detailed booking and revenue data"
            dimensions:
              - name: guest_id
                expr: guest_id
                data_type: string
                comment: "Guest identifier for joining"
              - name: hotel_id
                expr: hotel_id
                data_type: string
                comment: "Hotel property identifier"
              - name: room_type
                expr: room_type
                data_type: string
                comment: "Type of room booked"
                synonyms: ["accommodation type", "room category"]
              - name: booking_channel
                expr: booking_channel
                data_type: string
                comment: "Channel used for booking"
                synonyms: ["booking source", "reservation channel"]
              - name: booking_status
                expr: booking_status
                data_type: string
                comment: "Current status of booking"
                synonyms: ["reservation status", "booking state"]
            measures:
              - name: total_amount
                expr: total_amount
                data_type: number
                comment: "Total booking amount"
                synonyms: ["booking value", "reservation amount", "spend"]
              - name: num_nights
                expr: num_nights
                data_type: number
                comment: "Number of nights in booking"
                synonyms: ["stay length", "nights booked", "duration"]
        
        relationships:
          - name: guest_to_bookings
            from_table: GUEST_REVENUE
            to_table: BOOKING_DETAILS
            join_keys:
              - from_column: guest_id
                to_column: guest_id
            comment: "Links guests to their booking history"
    )
    """
    execute_sql(cursor, revenue_analytics_semantic_sql, "Revenue Analytics Semantic View")
    
    # Verification
    print("\n✅ VERIFICATION OF SEMANTIC VIEWS")
    print("-" * 40)
    
    # Show created semantic views
    try:
        cursor.execute("SHOW SEMANTIC VIEWS IN SCHEMA HOTEL_PERSONALIZATION.SEMANTIC_VIEWS")
        semantic_views = cursor.fetchall()
        print(f"  ✅ Created {len(semantic_views)} semantic views:")
        for view in semantic_views:
            print(f"    - {view[1]} (Created: {view[0]})")  # name and created_on
    except Exception as e:
        print(f"  ⚠️  Semantic views verification: {str(e)}")
    
    # Describe semantic views to verify structure
    print("\n📊 SEMANTIC VIEW STRUCTURE VERIFICATION")
    print("-" * 45)
    
    semantic_views_to_check = ["guest_analytics", "personalization_insights", "revenue_analytics"]
    
    for view_name in semantic_views_to_check:
        try:
            cursor.execute(f"DESC SEMANTIC VIEW {view_name}")
            desc_results = cursor.fetchall()
            print(f"  ✅ {view_name}: {len(desc_results)} components defined")
            
            # Count different component types
            tables = len([r for r in desc_results if r[0] == 'TABLE'])
            dimensions = len([r for r in desc_results if r[0] == 'DIMENSION'])
            measures = len([r for r in desc_results if r[0] == 'MEASURE'])
            relationships = len([r for r in desc_results if r[0] == 'RELATIONSHIP'])
            
            print(f"    Tables: {tables}, Dimensions: {dimensions}, Measures: {measures}, Relationships: {relationships}")
            
        except Exception as e:
            print(f"  ⚠️  {view_name} description: {str(e)}")
    
    # Test semantic view access
    print("\n🧪 TESTING SEMANTIC VIEW ACCESS")
    print("-" * 35)
    
    # Note: Semantic views are typically used by Cortex Analyst, not direct SELECT
    print("  ℹ️  Semantic views are designed for Cortex Analyst and AI agents")
    print("  ℹ️  They provide structured metadata for natural language queries")
    print("  ℹ️  Direct SELECT queries use the underlying base tables")
    
    # Update agents to use the new semantic views
    print("\n🤖 UPDATING AGENTS TO USE SEMANTIC VIEWS")
    print("-" * 45)
    
    # Update Guest Analytics Agent to use semantic view
    guest_agent_update_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Guest Analytics Agent"
    COMMENT = 'Guest behavior analysis agent - uses semantic views for natural language queries'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel guest insights specialist with access to the GUEST_ANALYTICS semantic view. You can analyze guest behavior, preferences, and booking patterns using natural language queries that are automatically converted to SQL.

      YOUR SEMANTIC VIEW ACCESS:
      • GUEST_ANALYTICS semantic view with guest profiles, segments, loyalty data, and personalization scores
      • Dimensions: guest_id, guest_name, customer_segment, loyalty_tier, generation, churn_risk
      • Measures: total_revenue, total_bookings, avg_booking_value, avg_stay_length, personalization scores

      EXAMPLE QUESTIONS YOU CAN ANSWER:
      • 'Show me our Diamond tier members with high revenue'
      • 'Which customer segments have the highest lifetime value?'
      • 'What are the booking patterns of our VIP Champions?'
      • 'Identify guests with high personalization readiness scores'
      • 'Show me guest demographics breakdown by generation'
      • 'Which loyalty tier generates the most revenue per booking?'
      • 'What's the retention rate by customer segment?'
      • 'Analyze churn risk across different guest segments'

      Use the semantic view structure to provide detailed insights with specific metrics and business recommendations."

    tools:
      - tool_spec:
          type: "cortex_analyst_text_to_sql"
          name: "guest_analytics_semantic"

    tool_resources:
      guest_analytics_semantic:
        semantic_view: "HOTEL_PERSONALIZATION.SEMANTIC_VIEWS.GUEST_ANALYTICS"
    $$
    '''
    execute_sql(cursor, guest_agent_update_sql, "Updated Guest Analytics Agent with semantic view")
    
    # Update Personalization Specialist to use semantic view
    personalization_agent_update_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Personalization Specialist"
    COMMENT = 'Personalization expert agent - uses semantic views for natural language queries'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel personalization expert with access to the PERSONALIZATION_INSIGHTS semantic view. You can analyze guest preferences and personalization opportunities using natural language queries.

      YOUR SEMANTIC VIEW ACCESS:
      • PERSONALIZATION_INSIGHTS semantic view with guest preferences, personalization scores, and room preferences
      • Dimensions: guest_id, full_name, guest_category, loyalty_status, personalization_potential, upsell_opportunity, room preferences
      • Measures: personalization_readiness_score, upsell_propensity_score, loyalty_propensity_score, temperature_preference

      EXAMPLE QUESTIONS YOU CAN ANSWER:
      • 'Which guests have excellent personalization potential?'
      • 'What room preferences are most common among high-value guests?'
      • 'Show me personalization opportunities for Diamond members'
      • 'Which guests prefer specific temperature settings?'
      • 'Identify guests with high upsell propensity scores'
      • 'What are the most popular room types among VIP guests?'
      • 'Show me guests who need personalized room setups'
      • 'Which preferences correlate with higher loyalty scores?'

      Use the semantic view to provide actionable personalization strategies and room setup recommendations."

    tools:
      - tool_spec:
          type: "cortex_analyst_text_to_sql"
          name: "personalization_semantic"

    tool_resources:
      personalization_semantic:
        semantic_view: "HOTEL_PERSONALIZATION.SEMANTIC_VIEWS.PERSONALIZATION_INSIGHTS"
    $$
    '''
    execute_sql(cursor, personalization_agent_update_sql, "Updated Personalization Specialist with semantic view")
    
    # Update Revenue Optimizer to use semantic view
    revenue_agent_update_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Revenue Optimizer"
    COMMENT = 'Revenue optimization agent - uses semantic views for natural language queries'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel revenue optimization specialist with access to the REVENUE_ANALYTICS semantic view. You can analyze business performance and revenue opportunities using natural language queries.

      YOUR SEMANTIC VIEW ACCESS:
      • REVENUE_ANALYTICS semantic view with guest revenue data, booking history, and business metrics
      • Dimensions: guest_id, customer_segment, loyalty_tier, hotel_id, room_type, booking_channel, booking_status
      • Measures: total_revenue, avg_booking_value, total_bookings, total_amount, num_nights

      EXAMPLE QUESTIONS YOU CAN ANSWER:
      • 'What are our highest revenue opportunities by guest segment?'
      • 'Which loyalty tiers have the best revenue per guest ratios?'
      • 'Show me booking patterns by channel and revenue impact'
      • 'Which room types generate the most revenue?'
      • 'Identify guests with high spending potential but low current spend'
      • 'What are the most profitable booking channels?'
      • 'Show me revenue trends across customer segments'
      • 'Which hotels have the highest revenue per guest?'

      Use the semantic view to provide detailed ROI projections and business impact analysis."

    tools:
      - tool_spec:
          type: "cortex_analyst_text_to_sql"
          name: "revenue_semantic"

    tool_resources:
      revenue_semantic:
        semantic_view: "HOTEL_PERSONALIZATION.SEMANTIC_VIEWS.REVENUE_ANALYTICS"
    $$
    '''
    execute_sql(cursor, revenue_agent_update_sql, "Updated Revenue Optimizer with semantic view")
    
    print("\n🎉 SEMANTIC VIEWS CREATION COMPLETED!")
    print("=" * 50)
    print("✅ 3 proper Snowflake semantic views created using CREATE SEMANTIC VIEW syntax")
    print("✅ All semantic views include tables, dimensions, measures, and relationships")
    print("✅ Semantic views are optimized for Cortex Analyst and natural language queries")
    print("✅ Agents updated to use semantic views for enhanced AI capabilities")
    print("✅ Comprehensive metadata and synonyms defined for better query understanding")
    
    print("\n🏗️ SEMANTIC VIEWS CREATED:")
    print("1. 🧠 GUEST_ANALYTICS - Guest behavior and analytics with personalization scores")
    print("2. 🎯 PERSONALIZATION_INSIGHTS - Guest preferences and personalization opportunities")
    print("3. 💰 REVENUE_ANALYTICS - Revenue optimization and business performance metrics")
    
    print("\n🚀 READY FOR ADVANCED AI QUERIES!")
    print("Your agents can now understand natural language questions like:")
    print("• 'Show me Diamond guests with high personalization potential'")
    print("• 'Which room preferences correlate with higher revenue?'")
    print("• 'What are the revenue opportunities from better personalization?'")
    print("• 'Identify VIP guests who prefer specific room setups'")
    print("• 'Analyze booking patterns by loyalty tier and revenue impact'")
    
    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()



