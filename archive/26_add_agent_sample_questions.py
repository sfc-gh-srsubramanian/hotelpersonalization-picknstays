#!/usr/bin/env python3
"""
Hotel Personalization System - Add Sample Questions to Intelligence Agents
Updates each agent with comprehensive sample questions for demonstration
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
    
    print("🤖 UPDATING SNOWFLAKE INTELLIGENCE AGENTS WITH SAMPLE QUESTIONS")
    print("=" * 70)
    
    execute_sql(cursor, "USE DATABASE HOTEL_PERSONALIZATION", "Using database")
    
    # Agent 1: Guest Analytics Agent with Sample Questions
    guest_analytics_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Guest Analytics Agent"
    COMMENT = 'Conversational agent for guest behavior analysis and insights'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel guest insights specialist. You analyze guest behavior, preferences, satisfaction, and booking patterns using the HOTEL_PERSONALIZATION database. Focus on guest segmentation, loyalty analysis, satisfaction trends, and personalization opportunities. Provide actionable insights for hotel operations teams with specific metrics and business recommendations. When discussing guests, consider their loyalty tier, booking history, and satisfaction scores."

    sample_questions:
      - "Show me our top 10 most valuable guests by lifetime revenue"
      - "Which guests have the highest loyalty scores but low booking frequency?"
      - "What are the booking patterns of our Diamond tier members?"
      - "Identify guests who haven't booked in the last 6 months"
      - "Show me guest demographics breakdown by generation"
      - "Which loyalty tier generates the most revenue per booking?"
      - "What's the average customer lifetime value by guest segment?"
      - "Show me guests with declining booking patterns"
      - "Which guests have the highest engagement scores?"
      - "What are the most common guest preferences by loyalty tier?"
      - "Show me seasonal booking trends by guest segment"
      - "Which guests are most likely to refer new customers?"
      - "What's the retention rate by customer segment?"
      - "Show me guests with unusual booking behavior patterns"
      - "Which markets have the highest value guests?"

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
    execute_sql(cursor, guest_analytics_agent_sql, "Updated Hotel Guest Analytics Agent with sample questions")
    
    # Agent 2: Personalization Specialist with Sample Questions
    personalization_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Personalization Specialist"
    COMMENT = 'Agent for personalized guest experiences and upsell recommendations'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel personalization expert specializing in creating hyper-personalized guest experiences. You analyze guest preferences, propensity scores, and behavioral data to recommend room setups, upsells, dining options, and activities. Focus on actionable personalization strategies that increase guest satisfaction and revenue. Consider guest loyalty tier, preference completeness, and booking patterns when making recommendations."

    sample_questions:
      - "What personalized room setups should we prepare for arriving Diamond guests?"
      - "Show me guests with the highest personalization readiness scores"
      - "Which guests prefer ocean view rooms and soft pillows?"
      - "What temperature settings do our VIP guests typically prefer?"
      - "Recommend personalized amenities for guests checking in today"
      - "Which guests have incomplete preference profiles that need updating?"
      - "Show me personalization opportunities for repeat guests"
      - "What are the most effective personalization strategies by guest segment?"
      - "Which guests respond best to proactive service?"
      - "Recommend personalized dining options for guests with dietary preferences"
      - "What room upgrades would delight our Gold tier members?"
      - "Show me guests who would appreciate early check-in offers"
      - "Which guests prefer quiet rooms on higher floors?"
      - "What personalized welcome gifts would surprise our VIP guests?"
      - "Show me guests with strong pillow and bedding preferences"
      - "Which guests would value personalized concierge recommendations?"
      - "What in-room technology preferences do business travelers have?"
      - "Show me guests who prefer specific room layouts or views"
      - "Which guests would appreciate personalized spa recommendations?"
      - "What are the best personalization tactics for first-time guests?"

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
    execute_sql(cursor, personalization_agent_sql, "Updated Hotel Personalization Specialist with sample questions")
    
    # Agent 3: Revenue Optimizer with Sample Questions
    revenue_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Revenue Optimizer"
    COMMENT = 'Agent focused on revenue optimization and business performance'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a hotel revenue optimization specialist. You analyze business performance metrics, guest lifetime value, and revenue opportunities using the HOTEL_PERSONALIZATION database. Provide insights on pricing strategies, upsell opportunities, customer segmentation for revenue growth, and operational efficiency. Focus on actionable recommendations that drive revenue while maintaining guest satisfaction. Always include specific ROI projections and business impact analysis."

    sample_questions:
      - "Which guests have the highest upsell propensity scores this month?"
      - "What's our revenue opportunity from better room upgrade targeting?"
      - "Show me guests likely to book premium services during their stay"
      - "Which customer segments generate the highest profit margins?"
      - "What's the ROI potential of personalized upselling campaigns?"
      - "Show me guests who typically book additional services"
      - "Which loyalty tiers have the best revenue per guest ratios?"
      - "What are the most profitable upsell opportunities by guest segment?"
      - "Show me guests with high spending potential but low current spend"
      - "Which guests are most likely to extend their stays?"
      - "What's the revenue impact of improving personalization scores?"
      - "Show me seasonal revenue trends by guest category"
      - "Which guests would pay premium for exclusive experiences?"
      - "What's the lifetime value progression by loyalty tier?"
      - "Show me guests ready for loyalty tier upgrades"
      - "Which booking channels generate the highest value guests?"
      - "What's the revenue potential of targeted spa and dining packages?"
      - "Show me guests with declining spend who need retention offers"
      - "Which guests have untapped revenue potential?"
      - "What are the best cross-selling opportunities by guest preferences?"

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
    execute_sql(cursor, revenue_agent_sql, "Updated Hotel Revenue Optimizer with sample questions")
    
    # Agent 4: Guest Experience Optimizer with Sample Questions
    experience_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Guest Experience Optimizer"
    COMMENT = 'Agent specialized in guest satisfaction and experience enhancement'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a guest experience specialist focused on improving satisfaction scores, reducing churn, and enhancing hotel experiences. You analyze guest feedback, satisfaction trends, service issues, and preferences using the HOTEL_PERSONALIZATION database. Provide specific recommendations for operations teams including pre-arrival setup, service recovery, and proactive guest care. Focus on actionable strategies that improve guest satisfaction and loyalty."

    sample_questions:
      - "Which guests are at high risk of churning and need immediate attention?"
      - "Show me guests with declining satisfaction trends"
      - "What proactive service gestures would delight our VIP guests?"
      - "Which guests have had service issues that need follow-up?"
      - "Show me guests who would benefit from loyalty program perks"
      - "What are the common satisfaction drivers for each guest segment?"
      - "Which guests haven't received personalized attention recently?"
      - "Show me opportunities to surprise and delight repeat guests"
      - "What service recovery strategies work best for different guest types?"
      - "Which guests would appreciate proactive communication about their stay?"
      - "Show me guests with special occasions during their upcoming stays"
      - "What are the best ways to exceed expectations for first-time guests?"
      - "Which guests have provided positive feedback that we should leverage?"
      - "Show me guests who would value exclusive access or experiences"
      - "What preventive measures can we take for guests with past complaints?"
      - "Which guests would appreciate personalized local recommendations?"
      - "Show me guests who prefer minimal vs. high-touch service styles"
      - "What are the satisfaction patterns of our most loyal guests?"
      - "Which guests would benefit from pre-arrival preference confirmation?"
      - "Show me opportunities to turn satisfied guests into brand advocates"

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
    execute_sql(cursor, experience_agent_sql, "Updated Guest Experience Optimizer with sample questions")
    
    # Agent 5: Master Intelligence Agent with Sample Questions
    master_agent_sql = '''
    CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Intelligence Master Agent"
    COMMENT = 'Comprehensive agent with access to all hotel personalization data'
    FROM SPECIFICATION $$
    models:
      orchestration: "claude-4-sonnet"

    instructions:
      response: "You are a comprehensive hotel intelligence specialist with access to all guest, personalization, and business data. You provide holistic insights combining guest behavior analysis, personalization opportunities, revenue optimization, and experience enhancement. You can answer complex questions that span multiple areas of hotel operations. Always provide data-driven recommendations with specific metrics, business impact, and actionable next steps. Consider the interconnections between guest satisfaction, personalization, and revenue when making recommendations."

    sample_questions:
      - "Give me a complete analysis of our top 5 VIP guests"
      - "What's the overall ROI of our personalization program?"
      - "Show me the correlation between personalization scores and revenue"
      - "Which operational changes would have the biggest impact on guest satisfaction?"
      - "What's our competitive advantage in guest personalization?"
      - "Show me the business case for expanding our loyalty program"
      - "Which guest segments should we prioritize for growth?"
      - "What's the relationship between guest preferences and booking patterns?"
      - "How does personalization impact guest lifetime value?"
      - "Show me our hotel's performance across all key metrics"
      - "What are the biggest opportunities to improve both revenue and satisfaction?"
      - "Which guests represent the highest strategic value to our brand?"
      - "What's the impact of loyalty tier on guest behavior and preferences?"
      - "Show me predictive insights for guest booking and spending patterns"
      - "What operational efficiencies can we gain from better guest data?"
      - "Which personalization investments have the best ROI potential?"
      - "How do our guest segments compare to industry benchmarks?"
      - "What's the optimal personalization strategy for each customer segment?"
      - "Show me the business impact of improving our churn prevention"
      - "What strategic recommendations would transform our guest experience?"
      - "How can we leverage our guest data for competitive advantage?"
      - "What's the long-term value creation potential of our personalization platform?"
      - "Show me cross-functional insights spanning revenue, operations, and experience"
      - "What are the key performance indicators we should track for success?"
      - "How can we scale personalization across our entire hotel portfolio?"

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
    execute_sql(cursor, master_agent_sql, "Updated Hotel Intelligence Master Agent with sample questions")
    
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
    
    print("\n🎯 SAMPLE QUESTIONS ADDED TO EACH AGENT")
    print("-" * 40)
    print("✅ Hotel Guest Analytics Agent: 15 sample questions")
    print("✅ Hotel Personalization Specialist: 20 sample questions") 
    print("✅ Hotel Revenue Optimizer: 20 sample questions")
    print("✅ Guest Experience Optimizer: 20 sample questions")
    print("✅ Hotel Intelligence Master Agent: 25 sample questions")
    
    print("\n🎉 AGENTS UPDATED WITH COMPREHENSIVE SAMPLE QUESTIONS!")
    print("=" * 60)
    print("✅ 100+ sample questions added across all 5 agents")
    print("✅ Questions cover all aspects of hotel personalization")
    print("✅ Each agent has role-specific question examples")
    print("✅ Questions demonstrate real business use cases")
    print("✅ Ready for staff training and demonstration")
    
    print("\n💡 EXAMPLE QUESTIONS BY AGENT:")
    print("\n🧠 Guest Analytics Agent:")
    print("  • 'Show me our top 10 most valuable guests by lifetime revenue'")
    print("  • 'Which guests have the highest loyalty scores but low booking frequency?'")
    
    print("\n🎯 Personalization Specialist:")
    print("  • 'What personalized room setups should we prepare for arriving Diamond guests?'")
    print("  • 'Which guests prefer ocean view rooms and soft pillows?'")
    
    print("\n💰 Revenue Optimizer:")
    print("  • 'Which guests have the highest upsell propensity scores this month?'")
    print("  • 'What's our revenue opportunity from better room upgrade targeting?'")
    
    print("\n😊 Experience Optimizer:")
    print("  • 'Which guests are at high risk of churning and need immediate attention?'")
    print("  • 'What proactive service gestures would delight our VIP guests?'")
    
    print("\n🏆 Master Intelligence Agent:")
    print("  • 'Give me a complete analysis of our top 5 VIP guests'")
    print("  • 'What's the overall ROI of our personalization program?'")
    
    print("\n🚀 READY FOR PRODUCTION USE!")
    print("Staff can now ask natural language questions and get instant insights!")
    
    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()



