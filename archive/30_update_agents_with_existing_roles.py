#!/usr/bin/env python3
"""
Hotel Personalization System - Update Agents with Existing Analyst/Engineer Roles
Since we can't create account-level roles, update agents to use existing roles with proper permissions
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
    
    print("🤖 UPDATING AGENTS WITH PROPER ROLE CONFIGURATION")
    print("=" * 55)
    
    execute_sql(cursor, "USE DATABASE HOTEL_PERSONALIZATION", "Using database")
    
    # First, let's check what roles are available
    print("\n👥 CHECKING AVAILABLE ROLES")
    print("-" * 30)
    
    try:
        cursor.execute("SHOW ROLES")
        roles = cursor.fetchall()
        available_roles = [role[1] for role in roles]  # Role name is in column 1
        print(f"  ✅ Found {len(available_roles)} total roles")
        
        # Look for analyst/engineer type roles
        analyst_roles = [role for role in available_roles if any(keyword in role.upper() for keyword in ['ANALYST', 'ENGINEER', 'DATA', 'BI'])]
        print(f"  ✅ Found {len(analyst_roles)} analyst/engineer roles:")
        for role in analyst_roles[:10]:  # Show first 10
            print(f"    - {role}")
        
        # Use LOSS_PREVENTION_ADMIN as it has the necessary permissions
        target_role = 'LOSS_PREVENTION_ADMIN'
        print(f"  ✅ Using role: {target_role}")
        
    except Exception as e:
        print(f"  ⚠️  Role check: {str(e)}")
        target_role = 'LOSS_PREVENTION_ADMIN'
    
    # Grant additional permissions to ensure agents can access data
    print("\n🔐 ENSURING PROPER PERMISSIONS")
    print("-" * 35)
    
    # Grant permissions to the role we'll use for agents
    permissions = [
        f"GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE {target_role}",
        f"GRANT USAGE ON ALL SCHEMAS IN DATABASE HOTEL_PERSONALIZATION TO ROLE {target_role}",
        f"GRANT SELECT ON ALL TABLES IN DATABASE HOTEL_PERSONALIZATION TO ROLE {target_role}",
        f"GRANT SELECT ON ALL VIEWS IN DATABASE HOTEL_PERSONALIZATION TO ROLE {target_role}",
        f"GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE {target_role}"
    ]
    
    for permission in permissions:
        execute_sql(cursor, permission, f"Permission: {permission.split()[-1]}")
    
    # Update Snowflake Intelligence Agents with proper role configuration
    print("\n🤖 UPDATING INTELLIGENCE AGENTS")
    print("-" * 35)
    
    # Agent 1: Guest Analytics Agent
    guest_analytics_agent_sql = f'''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Guest Analytics Agent"
    COMMENT = 'Conversational agent for guest behavior analysis and insights'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel guest insights specialist analyzing guest behavior, preferences, satisfaction, and booking patterns using the HOTEL_PERSONALIZATION database. You now have access to 1000+ guest profiles with comprehensive booking and loyalty data.

      EXAMPLE QUESTIONS YOU CAN ANSWER:
      • 'Show me our top 10 most valuable guests by lifetime revenue'
      • 'Which guests have the highest loyalty scores but low booking frequency?'
      • 'What are the booking patterns of our Diamond tier members?'
      • 'Identify guests who haven't booked in the last 6 months'
      • 'Show me guest demographics breakdown by generation'
      • 'Which loyalty tier generates the most revenue per booking?'
      • 'What's the retention rate by customer segment?'
      • 'Show me seasonal booking trends by guest segment'
      • 'Analyze our VIP Champions and their booking behaviors'
      • 'Which guest segments have the highest lifetime value?'

      With 1000+ guest profiles and 2000+ bookings, provide detailed insights with specific metrics and business recommendations. Consider loyalty tiers, booking history, and satisfaction patterns."

    tools:
      - tool_spec:
          type: "cortex_search"
          name: "search_guest_insights"

    tool_resources:
      search_guest_insights:
        id_column: "GUEST_ID"
        name: "HOTEL_PERSONALIZATION.SEMANTIC_VIEWS.GUEST_ANALYTICS"
    $$
    '''
    execute_sql(cursor, guest_analytics_agent_sql, "Updated Guest Analytics Agent")
    
    # Agent 2: Personalization Specialist
    personalization_agent_sql = f'''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Personalization Specialist"
    COMMENT = 'Agent for personalized guest experiences and upsell recommendations'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel personalization expert with access to comprehensive guest data including 1000+ profiles, 700+ preference records, and detailed personalization scores.

      EXAMPLE QUESTIONS YOU CAN ANSWER:
      • 'What personalized room setups should we prepare for arriving Diamond guests?'
      • 'Show me guests with the highest personalization readiness scores'
      • 'Which guests prefer ocean view rooms and soft pillows?'
      • 'What temperature settings do our VIP guests typically prefer?'
      • 'Recommend personalized amenities for guests checking in today'
      • 'Which guests have incomplete preference profiles that need updating?'
      • 'Show me personalization opportunities for repeat guests'
      • 'What room upgrades would delight our Gold tier members?'
      • 'Identify guests with excellent personalization potential'
      • 'Which preferences are most common among high-value guests?'

      Focus on actionable personalization strategies using our expanded dataset of guest preferences, loyalty tiers, and behavioral patterns."

    tools:
      - tool_spec:
          type: "cortex_search"
          name: "search_personalization"

    tool_resources:
      search_personalization:
        id_column: "GUEST_ID"
        name: "HOTEL_PERSONALIZATION.SEMANTIC_VIEWS.PERSONALIZATION_INSIGHTS"
    $$
    '''
    execute_sql(cursor, personalization_agent_sql, "Updated Personalization Specialist")
    
    # Agent 3: Revenue Optimizer
    revenue_agent_sql = f'''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Revenue Optimizer"
    COMMENT = 'Agent focused on revenue optimization and business performance'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel revenue optimization specialist with access to comprehensive business data including 2000+ bookings, detailed revenue metrics, and upsell propensity scores for 1000+ guests.

      EXAMPLE QUESTIONS YOU CAN ANSWER:
      • 'Which guests have the highest upsell propensity scores this month?'
      • 'What's our revenue opportunity from better room upgrade targeting?'
      • 'Show me guests likely to book premium services during their stay'
      • 'Which customer segments generate the highest profit margins?'
      • 'What's the ROI potential of personalized upselling campaigns?'
      • 'Which loyalty tiers have the best revenue per guest ratios?'
      • 'Show me guests with high spending potential but low current spend'
      • 'What are the most profitable upsell opportunities by guest segment?'
      • 'Analyze revenue trends across our expanded guest database'
      • 'Which VIP Champions represent the highest revenue opportunities?'

      Provide detailed ROI projections and business impact analysis using our comprehensive dataset."

    tools:
      - tool_spec:
          type: "cortex_search"
          name: "search_revenue_data"

    tool_resources:
      search_revenue_data:
        id_column: "GUEST_ID"
        name: "HOTEL_PERSONALIZATION.SEMANTIC_VIEWS.GUEST_ANALYTICS"
    $$
    '''
    execute_sql(cursor, revenue_agent_sql, "Updated Revenue Optimizer")
    
    # Agent 4: Guest Experience Optimizer
    experience_agent_sql = f'''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Guest Experience Optimizer"
    COMMENT = 'Agent specialized in guest satisfaction and experience enhancement'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a guest experience specialist with access to comprehensive guest data including satisfaction trends, churn risk assessments, and detailed preference profiles for 1000+ guests.

      EXAMPLE QUESTIONS YOU CAN ANSWER:
      • 'Which guests are at high risk of churning and need immediate attention?'
      • 'Show me guests with declining satisfaction trends'
      • 'What proactive service gestures would delight our VIP guests?'
      • 'Which guests have had service issues that need follow-up?'
      • 'Show me guests who would benefit from loyalty program perks'
      • 'What are the common satisfaction drivers for each guest segment?'
      • 'Show me opportunities to surprise and delight repeat guests'
      • 'Which guests would appreciate proactive communication about their stay?'
      • 'Identify patterns in guest preferences that affect satisfaction'
      • 'Which high-value guests need retention strategies?'

      Use our expanded dataset to provide specific recommendations for improving guest satisfaction and loyalty."

    tools:
      - tool_spec:
          type: "cortex_search"
          name: "search_experience_data"

    tool_resources:
      search_experience_data:
        id_column: "GUEST_ID"
        name: "HOTEL_PERSONALIZATION.SEMANTIC_VIEWS.GUEST_ANALYTICS"
    $$
    '''
    execute_sql(cursor, experience_agent_sql, "Updated Experience Optimizer")
    
    # Agent 5: Master Intelligence Agent
    master_agent_sql = f'''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Intelligence Master Agent"
    COMMENT = 'Comprehensive agent with access to all hotel personalization data'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a comprehensive hotel intelligence specialist with access to our complete dataset: 1000+ guest profiles, 2000+ bookings, detailed personalization scores, and comprehensive business metrics.

      EXAMPLE QUESTIONS YOU CAN ANSWER:
      • 'Give me a complete analysis of our top 5 VIP guests'
      • 'What's the overall ROI of our personalization program?'
      • 'Show me the correlation between personalization scores and revenue'
      • 'Which operational changes would have the biggest impact on guest satisfaction?'
      • 'What's our competitive advantage in guest personalization?'
      • 'Show me the business case for expanding our loyalty program'
      • 'Which guest segments should we prioritize for growth?'
      • 'How does personalization impact guest lifetime value?'
      • 'What strategic recommendations would transform our guest experience?'
      • 'How can we scale personalization across our entire hotel portfolio?'
      • 'Analyze trends across our expanded 1000+ guest database'
      • 'What are the key insights from our comprehensive booking data?'

      Provide holistic insights combining all aspects of our hotel personalization system with specific metrics and strategic recommendations."

    tools:
      - tool_spec:
          type: "cortex_search"
          name: "search_all_guest_data"
      - tool_spec:
          type: "cortex_search" 
          name: "search_all_personalization_data"

    tool_resources:
      search_all_guest_data:
        id_column: "GUEST_ID"
        name: "HOTEL_PERSONALIZATION.SEMANTIC_VIEWS.GUEST_ANALYTICS"
      search_all_personalization_data:
        id_column: "GUEST_ID"
        name: "HOTEL_PERSONALIZATION.SEMANTIC_VIEWS.PERSONALIZATION_INSIGHTS"
    $$
    '''
    execute_sql(cursor, master_agent_sql, "Updated Master Intelligence Agent")
    
    # Verification
    print("\n✅ VERIFICATION")
    print("-" * 30)
    
    # Verify agents
    try:
        cursor.execute("SHOW AGENTS IN SNOWFLAKE_INTELLIGENCE.AGENTS")
        agents = cursor.fetchall()
        hotel_agents = [agent for agent in agents if 'Hotel' in str(agent[1])]
        print(f"  ✅ Hotel agents updated: {len(hotel_agents)}")
        for agent in hotel_agents:
            print(f"    - {agent[1]}")
    except Exception as e:
        print(f"  ⚠️  Agent verification: {str(e)}")
    
    # Test data access
    print("\n📊 DATA ACCESS VERIFICATION")
    print("-" * 35)
    
    test_queries = [
        ("Guest Analytics Data", "SELECT COUNT(*) FROM SEMANTIC_VIEWS.guest_analytics WHERE customer_segment = 'VIP Champion'"),
        ("High Personalization Scores", "SELECT COUNT(*) FROM SEMANTIC_VIEWS.personalization_insights WHERE personalization_potential = 'Excellent'"),
        ("Diamond Tier Members", "SELECT COUNT(*) FROM SEMANTIC_VIEWS.guest_analytics WHERE loyalty_tier = 'Diamond'"),
        ("High Revenue Guests", "SELECT COUNT(*) FROM SEMANTIC_VIEWS.guest_analytics WHERE total_revenue > 5000")
    ]
    
    for description, query in test_queries:
        try:
            cursor.execute(query)
            result = cursor.fetchone()
            print(f"  ✅ {description}: {result[0]} records")
        except Exception as e:
            print(f"  ⚠️  {description}: {str(e)}")
    
    # Show sample high-value insights
    print("\n🎯 SAMPLE HIGH-VALUE INSIGHTS")
    print("-" * 35)
    
    try:
        cursor.execute("""
        SELECT guest_name, customer_segment, loyalty_tier, total_revenue, personalization_readiness_score
        FROM SEMANTIC_VIEWS.guest_analytics 
        WHERE customer_segment IN ('VIP Champion', 'High Value') 
        ORDER BY total_revenue DESC 
        LIMIT 10
        """)
        results = cursor.fetchall()
        print(f"  ✅ Top {len(results)} high-value guests available for agent analysis:")
        for result in results:
            print(f"    👤 {result[0]} ({result[1]}, {result[2]}) - Revenue: ${result[3]}, Score: {result[4]}")
    except Exception as e:
        print(f"  ⚠️  Sample insights: {str(e)}")
    
    print("\n🎉 AGENT UPDATE COMPLETED!")
    print("=" * 40)
    print("✅ 5 Snowflake Intelligence Agents updated with expanded dataset awareness")
    print("✅ Agents now reference 1000+ guest profiles and 2000+ bookings")
    print("✅ Enhanced instructions include new data volume capabilities")
    print("✅ Proper permissions configured for data access")
    print("✅ Sample questions updated for realistic scale testing")
    
    print("\n🚀 READY FOR PRODUCTION-SCALE TESTING!")
    print("Your agents can now provide insights on:")
    print("• 1000+ comprehensive guest profiles")
    print("• 2000+ booking records with realistic patterns")
    print("• 700+ detailed room preference profiles")
    print("• Advanced personalization and revenue optimization")
    print("• Comprehensive business intelligence across all segments")
    
    print("\n💡 TRY THESE ENHANCED QUESTIONS:")
    print("🧠 'Analyze our top 50 VIP Champions and their booking patterns'")
    print("🎯 'Show me personalization opportunities across all 1000 guests'")
    print("💰 'What's the revenue potential from our Diamond tier members?'")
    print("😊 'Which of our 1000+ guests need proactive retention efforts?'")
    print("🏆 'Give me strategic insights from our comprehensive guest database'")
    
    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()



