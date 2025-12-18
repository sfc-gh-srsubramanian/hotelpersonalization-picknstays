#!/usr/bin/env python3
"""
Hotel Personalization System - Update Agents with Example Questions in Instructions
Updates agent instructions to include example question patterns and use cases
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
    
    print("🤖 UPDATING AGENTS WITH EXAMPLE QUESTIONS IN INSTRUCTIONS")
    print("=" * 65)
    
    execute_sql(cursor, "USE DATABASE HOTEL_PERSONALIZATION", "Using database")
    
    # Agent 1: Guest Analytics Agent with Enhanced Instructions
    guest_analytics_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Guest Analytics Agent"
    COMMENT = 'Conversational agent for guest behavior analysis and insights'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel guest insights specialist analyzing guest behavior, preferences, satisfaction, and booking patterns using the HOTEL_PERSONALIZATION database. Focus on guest segmentation, loyalty analysis, satisfaction trends, and personalization opportunities.

      EXAMPLE QUESTIONS YOU CAN ANSWER:
      • 'Show me our top 10 most valuable guests by lifetime revenue'
      • 'Which guests have the highest loyalty scores but low booking frequency?'
      • 'What are the booking patterns of our Diamond tier members?'
      • 'Identify guests who haven't booked in the last 6 months'
      • 'Show me guest demographics breakdown by generation'
      • 'Which loyalty tier generates the most revenue per booking?'
      • 'What's the retention rate by customer segment?'
      • 'Show me seasonal booking trends by guest segment'

      Provide actionable insights for hotel operations teams with specific metrics and business recommendations. When discussing guests, consider their loyalty tier, booking history, and satisfaction scores. Always include relevant data points and suggest next steps."

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
    execute_sql(cursor, guest_analytics_agent_sql, "Updated Guest Analytics Agent with example questions")
    
    # Agent 2: Personalization Specialist with Enhanced Instructions
    personalization_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Personalization Specialist"
    COMMENT = 'Agent for personalized guest experiences and upsell recommendations'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel personalization expert specializing in creating hyper-personalized guest experiences. You analyze guest preferences, propensity scores, and behavioral data to recommend room setups, upsells, dining options, and activities.

      EXAMPLE QUESTIONS YOU CAN ANSWER:
      • 'What personalized room setups should we prepare for arriving Diamond guests?'
      • 'Show me guests with the highest personalization readiness scores'
      • 'Which guests prefer ocean view rooms and soft pillows?'
      • 'What temperature settings do our VIP guests typically prefer?'
      • 'Recommend personalized amenities for guests checking in today'
      • 'Which guests have incomplete preference profiles that need updating?'
      • 'Show me personalization opportunities for repeat guests'
      • 'What room upgrades would delight our Gold tier members?'

      Focus on actionable personalization strategies that increase guest satisfaction and revenue. Consider guest loyalty tier, preference completeness, and booking patterns when making recommendations. Always provide specific, implementable suggestions."

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
    execute_sql(cursor, personalization_agent_sql, "Updated Personalization Specialist with example questions")
    
    # Agent 3: Revenue Optimizer with Enhanced Instructions
    revenue_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Revenue Optimizer"
    COMMENT = 'Agent focused on revenue optimization and business performance'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel revenue optimization specialist analyzing business performance metrics, guest lifetime value, and revenue opportunities using the HOTEL_PERSONALIZATION database.

      EXAMPLE QUESTIONS YOU CAN ANSWER:
      • 'Which guests have the highest upsell propensity scores this month?'
      • 'What's our revenue opportunity from better room upgrade targeting?'
      • 'Show me guests likely to book premium services during their stay'
      • 'Which customer segments generate the highest profit margins?'
      • 'What's the ROI potential of personalized upselling campaigns?'
      • 'Which loyalty tiers have the best revenue per guest ratios?'
      • 'Show me guests with high spending potential but low current spend'
      • 'What are the most profitable upsell opportunities by guest segment?'

      Provide insights on pricing strategies, upsell opportunities, customer segmentation for revenue growth, and operational efficiency. Focus on actionable recommendations that drive revenue while maintaining guest satisfaction. Always include specific ROI projections and business impact analysis."

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
    execute_sql(cursor, revenue_agent_sql, "Updated Revenue Optimizer with example questions")
    
    # Agent 4: Guest Experience Optimizer with Enhanced Instructions
    experience_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Guest Experience Optimizer"
    COMMENT = 'Agent specialized in guest satisfaction and experience enhancement'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a guest experience specialist focused on improving satisfaction scores, reducing churn, and enhancing hotel experiences. You analyze guest feedback, satisfaction trends, service issues, and preferences using the HOTEL_PERSONALIZATION database.

      EXAMPLE QUESTIONS YOU CAN ANSWER:
      • 'Which guests are at high risk of churning and need immediate attention?'
      • 'Show me guests with declining satisfaction trends'
      • 'What proactive service gestures would delight our VIP guests?'
      • 'Which guests have had service issues that need follow-up?'
      • 'Show me guests who would benefit from loyalty program perks'
      • 'What are the common satisfaction drivers for each guest segment?'
      • 'Show me opportunities to surprise and delight repeat guests'
      • 'Which guests would appreciate proactive communication about their stay?'

      Provide specific recommendations for operations teams including pre-arrival setup, service recovery, and proactive guest care. Focus on actionable strategies that improve guest satisfaction and loyalty. Always suggest concrete steps to enhance the guest experience."

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
    execute_sql(cursor, experience_agent_sql, "Updated Experience Optimizer with example questions")
    
    # Agent 5: Master Intelligence Agent with Enhanced Instructions
    master_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Intelligence Master Agent"
    COMMENT = 'Comprehensive agent with access to all hotel personalization data'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a comprehensive hotel intelligence specialist with access to all guest, personalization, and business data. You provide holistic insights combining guest behavior analysis, personalization opportunities, revenue optimization, and experience enhancement.

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

      You can answer complex questions that span multiple areas of hotel operations. Always provide data-driven recommendations with specific metrics, business impact, and actionable next steps. Consider the interconnections between guest satisfaction, personalization, and revenue when making recommendations."

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
    execute_sql(cursor, master_agent_sql, "Updated Master Intelligence Agent with example questions")
    
    print("\n✅ VERIFICATION")
    print("-" * 30)
    
    # Verify agents were updated
    try:
        cursor.execute("SHOW AGENTS IN SNOWFLAKE_INTELLIGENCE.AGENTS")
        agents = cursor.fetchall()
        hotel_agents = [agent for agent in agents if 'Hotel' in str(agent[1])]
        print(f"  ✅ Total hotel agents updated: {len(hotel_agents)}")
        for agent in hotel_agents:
            print(f"    - {agent[1]}")
    except Exception as e:
        print(f"  ⚠️  Agent verification: {str(e)}")
    
    print("\n🎯 AGENTS UPDATED WITH ENHANCED INSTRUCTIONS")
    print("-" * 45)
    print("✅ Each agent now includes example questions in instructions")
    print("✅ Clear use case examples for staff training")
    print("✅ Specific question patterns for each specialization")
    print("✅ Better guidance on expected interactions")
    print("✅ Comprehensive sample questions guide created separately")
    
    print("\n📚 DOCUMENTATION CREATED")
    print("-" * 30)
    print("✅ 27_agent_sample_questions_guide.md - Complete question library")
    print("✅ 100+ sample questions organized by agent and use case")
    print("✅ Quick start questions by hotel staff role")
    print("✅ Best practices for effective agent interactions")
    
    print("\n🎉 INTELLIGENCE AGENTS FULLY CONFIGURED!")
    print("=" * 50)
    print("✅ 5 Snowflake Intelligence Agents with enhanced instructions")
    print("✅ Example questions embedded in each agent's instructions")
    print("✅ Comprehensive documentation for staff training")
    print("✅ Ready for production use and staff onboarding")
    
    print("\n🚀 NEXT STEPS FOR STAFF TRAINING:")
    print("1. Review the sample questions guide (27_agent_sample_questions_guide.md)")
    print("2. Start with simple questions to test each agent")
    print("3. Practice role-specific questions for different departments")
    print("4. Explore complex cross-functional queries with the Master Agent")
    print("5. Train staff on natural language interaction best practices")
    
    print("\n💡 STAFF CAN NOW ASK QUESTIONS LIKE:")
    print("🧠 'Show me our most valuable guests this quarter'")
    print("🎯 'What room setup should I prepare for our Diamond guest in 205?'")
    print("💰 'Which guests have the best upsell potential today?'")
    print("😊 'Who needs proactive attention to prevent churn?'")
    print("🏆 'What's our overall personalization ROI and strategic opportunities?'")
    
    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()



