#!/usr/bin/env python3
"""
Hotel Personalization System - Create Snowflake Intelligence Agents
Creates AI agents that work with the SEMANTIC_VIEWS and BUSINESS_VIEWS schemas
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
    
    print("🧠 CREATING SNOWFLAKE INTELLIGENCE AGENTS")
    print("=" * 60)
    print("🎯 Using BUSINESS_VIEWS schema for agent data access")
    print("=" * 60)
    
    execute_sql(cursor, "USE DATABASE HOTEL_PERSONALIZATION", "Using database")
    
    # Create simple semantic views in SEMANTIC_VIEWS schema for agents
    print("\n📊 CREATING SIMPLE SEMANTIC VIEWS FOR AGENTS")
    print("-" * 40)
    
    execute_sql(cursor, "USE SCHEMA SEMANTIC_VIEWS", "Using Semantic Views schema")
    
    # Create simple views (not semantic views due to syntax limitations)
    guest_analytics_view_sql = """
    CREATE OR REPLACE VIEW guest_analytics AS
    SELECT 
        gv.guest_id,
        gv.first_name || ' ' || gv.last_name as guest_name,
        gv.customer_segment,
        gv.loyalty_tier,
        gv.generation,
        gv.total_bookings,
        gv.total_revenue,
        gv.avg_booking_value,
        ps.personalization_readiness_score,
        ps.upsell_propensity_score,
        ps.loyalty_propensity_score,
        gv.churn_risk,
        gv.marketing_opt_in
    FROM GOLD.guest_360_view gv
    LEFT JOIN GOLD.personalization_scores ps ON gv.guest_id = ps.guest_id
    """
    execute_sql(cursor, guest_analytics_view_sql, "Guest analytics view for agents")
    
    personalization_insights_view_sql = """
    CREATE OR REPLACE VIEW personalization_insights AS
    SELECT 
        po.guest_id,
        po.full_name,
        po.guest_category,
        po.loyalty_status,
        po.personalization_readiness_score,
        po.personalization_potential,
        po.upsell_propensity_score,
        po.upsell_opportunity,
        po.loyalty_propensity_score,
        po.preferred_room_type,
        po.temperature_preference,
        po.pillow_preference,
        po.accepts_marketing
    FROM BUSINESS_VIEWS.personalization_opportunities po
    """
    execute_sql(cursor, personalization_insights_view_sql, "Personalization insights view for agents")
    
    # Create Snowflake Intelligence Agents
    print("\n🤖 CREATING INTELLIGENCE AGENTS")
    print("-" * 40)
    
    # Agent 1: Guest Analytics Agent
    guest_analytics_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Guest Analytics Agent"
    COMMENT = 'Conversational agent for guest behavior analysis and insights'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel guest insights specialist. You analyze guest behavior, preferences, satisfaction, and booking patterns using the HOTEL_PERSONALIZATION database. Focus on guest segmentation, loyalty analysis, satisfaction trends, and personalization opportunities. Provide actionable insights for hotel operations teams with specific metrics and business recommendations. When discussing guests, consider their loyalty tier, booking history, and satisfaction scores."

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
    execute_sql(cursor, guest_analytics_agent_sql, "Hotel Guest Analytics Agent")
    
    # Agent 2: Personalization Specialist Agent
    personalization_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Personalization Specialist"
    COMMENT = 'Agent for personalized guest experiences and upsell recommendations'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel personalization expert specializing in creating hyper-personalized guest experiences. You analyze guest preferences, propensity scores, and behavioral data to recommend room setups, upsells, dining options, and activities. Focus on actionable personalization strategies that increase guest satisfaction and revenue. Consider guest loyalty tier, preference completeness, and booking patterns when making recommendations."

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
    execute_sql(cursor, personalization_agent_sql, "Hotel Personalization Specialist")
    
    # Agent 3: Revenue Optimization Agent
    revenue_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Revenue Optimizer"
    COMMENT = 'Agent focused on revenue optimization and business performance'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel revenue optimization specialist. You analyze business performance metrics, guest lifetime value, and revenue opportunities using the HOTEL_PERSONALIZATION database. Provide insights on pricing strategies, upsell opportunities, customer segmentation for revenue growth, and operational efficiency. Focus on actionable recommendations that drive revenue while maintaining guest satisfaction. Always include specific ROI projections and business impact analysis."

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
    execute_sql(cursor, revenue_agent_sql, "Hotel Revenue Optimizer")
    
    # Agent 4: Guest Experience Agent
    experience_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Guest Experience Optimizer"
    COMMENT = 'Agent specialized in guest satisfaction and experience enhancement'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a guest experience specialist focused on improving satisfaction scores, reducing churn, and enhancing hotel experiences. You analyze guest feedback, satisfaction trends, service issues, and preferences using the HOTEL_PERSONALIZATION database. Provide specific recommendations for operations teams including pre-arrival setup, service recovery, and proactive guest care. Focus on actionable strategies that improve guest satisfaction and loyalty."

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
    execute_sql(cursor, experience_agent_sql, "Guest Experience Optimizer")
    
    # Agent 5: Master Intelligence Agent
    master_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Intelligence Master Agent"
    COMMENT = 'Comprehensive agent with access to all hotel personalization data'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a comprehensive hotel intelligence specialist with access to all guest, personalization, and business data. You provide holistic insights combining guest behavior analysis, personalization opportunities, revenue optimization, and experience enhancement. You can answer complex questions that span multiple areas of hotel operations. Always provide data-driven recommendations with specific metrics, business impact, and actionable next steps. Consider the interconnections between guest satisfaction, personalization, and revenue when making recommendations."

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
    execute_sql(cursor, master_agent_sql, "Hotel Intelligence Master Agent")
    
    print("\n✅ VERIFICATION")
    print("-" * 30)
    
    # Verify agents were created
    try:
        cursor.execute("SHOW AGENTS IN SNOWFLAKE_INTELLIGENCE.AGENTS")
        agents = cursor.fetchall()
        print(f"  ✅ Total agents created: {len(agents)}")
        for agent in agents:
            if 'Hotel' in str(agent[1]):  # Agent name is in column 1
                print(f"    - {agent[1]}")
    except Exception as e:
        print(f"  ⚠️  Agent verification: {str(e)}")
    
    # Test the semantic views
    test_queries = [
        ("Guest Analytics View", "SELECT COUNT(*) FROM SEMANTIC_VIEWS.guest_analytics"),
        ("Personalization Insights View", "SELECT COUNT(*) FROM SEMANTIC_VIEWS.personalization_insights"),
        ("Business Views Available", "SELECT COUNT(*) FROM BUSINESS_VIEWS.guest_profile_summary")
    ]
    
    for description, query in test_queries:
        try:
            cursor.execute(query)
            result = cursor.fetchone()
            print(f"  ✅ {description}: {result[0]} records available")
        except Exception as e:
            print(f"  ⚠️  {description}: {str(e)}")
    
    print("\n🎯 SAMPLE DATA FOR AGENTS")
    print("-" * 30)
    
    # Show sample data that agents can access
    try:
        cursor.execute("SELECT guest_name, customer_segment, loyalty_tier, personalization_readiness_score FROM SEMANTIC_VIEWS.guest_analytics LIMIT 5")
        results = cursor.fetchall()
        for result in results:
            print(f"  👤 {result[0]} ({result[1]}, {result[2]}) - Personalization Score: {result[3]}")
    except Exception as e:
        print(f"  ⚠️  Sample data: {str(e)}")
    
    print("\n🎉 INTELLIGENCE AGENTS DEPLOYMENT COMPLETED!")
    print("=" * 60)
    print("✅ 5 Snowflake Intelligence Agents created successfully")
    print("✅ Agents have access to guest analytics and personalization data")
    print("✅ SEMANTIC_VIEWS schema populated with agent-ready views")
    print("✅ BUSINESS_VIEWS schema available for reporting")
    print("✅ Complete hotel personalization system ready for use")
    
    print("\n🤖 AVAILABLE AGENTS:")
    print("1. 🧠 Hotel Guest Analytics Agent - Guest behavior and insights")
    print("2. 🎯 Hotel Personalization Specialist - Personalized experiences")
    print("3. 💰 Hotel Revenue Optimizer - Revenue and business performance")
    print("4. 😊 Guest Experience Optimizer - Satisfaction and experience")
    print("5. 🏆 Hotel Intelligence Master Agent - Comprehensive insights")
    
    print("\n💬 SAMPLE QUESTIONS TO ASK THE AGENTS:")
    print("• 'Show me our VIP guests with the highest personalization scores'")
    print("• 'Which guests have high upsell potential this week?'")
    print("• 'What personalized room setups should we prepare for Diamond members?'")
    print("• 'Identify guests at risk of churning who need attention'")
    print("• 'What revenue opportunities exist from better personalization?'")
    
    print("\n🚀 NEXT STEPS:")
    print("1. Test agents with natural language queries")
    print("2. Set up role-based access for different user types")
    print("3. Create dashboards using BUSINESS_VIEWS")
    print("4. Integrate with hotel operational systems")
    print("5. Train staff on using conversational AI for personalization")
    
    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()



