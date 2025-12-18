-- Hotel Personalization System - Simplified Snowflake Intelligence Agents
-- Creates agents that work directly with semantic views without requiring YAML files

USE DATABASE HOTEL_PERSONALIZATION;

-- =====================================================
-- SIMPLIFIED AGENT 1: GUEST INSIGHTS AGENT
-- =====================================================

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Guest Analytics Agent"
COMMENT = "Conversational agent for guest behavior analysis and insights using semantic views"
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: "You are a hotel guest insights specialist. You analyze guest behavior, preferences, satisfaction, and booking patterns using the HOTEL_PERSONALIZATION database semantic views. Provide actionable insights for hotel operations teams. Focus on guest segmentation, loyalty analysis, satisfaction trends, and personalization opportunities. Always include specific metrics and business recommendations. When discussing guests, consider their loyalty tier, booking history, and satisfaction scores."

tools:
  - tool_spec:
      type: "cortex_search"
      name: "search_guest_insights"

tool_resources:
  search_guest_insights:
    id_column: "GUEST_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.GUEST_ANALYTICS"
$$;

-- =====================================================
-- SIMPLIFIED AGENT 2: PERSONALIZATION AGENT
-- =====================================================

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Personalization Specialist"
COMMENT = "Agent for personalized guest experiences and upsell recommendations"
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: "You are a hotel personalization expert specializing in creating hyper-personalized guest experiences. You analyze guest preferences, propensity scores, and behavioral data from the HOTEL_PERSONALIZATION semantic views to recommend room setups, upsells, dining options, and activities. Focus on actionable personalization strategies that increase guest satisfaction and revenue. Consider guest loyalty tier, preference completeness, and booking patterns when making recommendations."

tools:
  - tool_spec:
      type: "cortex_search"
      name: "search_personalization"

tool_resources:
  search_personalization:
    id_column: "GUEST_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.PERSONALIZATION_INSIGHTS"
$$;

-- =====================================================
-- SIMPLIFIED AGENT 3: REVENUE OPTIMIZATION AGENT
-- =====================================================

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Revenue Optimizer"
COMMENT = "Agent focused on revenue optimization and business performance"
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: "You are a hotel revenue optimization specialist. You analyze business performance metrics, guest lifetime value, and revenue opportunities using the HOTEL_PERSONALIZATION semantic views. Provide insights on pricing strategies, upsell opportunities, customer segmentation for revenue growth, and operational efficiency. Focus on actionable recommendations that drive revenue while maintaining guest satisfaction. Always include specific ROI projections and business impact analysis."

tools:
  - tool_spec:
      type: "cortex_search"
      name: "search_revenue_data"

tool_resources:
  search_revenue_data:
    id_column: "HOTEL_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.REVENUE_OPTIMIZATION"
$$;

-- =====================================================
-- SIMPLIFIED AGENT 4: GUEST EXPERIENCE AGENT
-- =====================================================

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Guest Experience Optimizer"
COMMENT = "Agent specialized in guest satisfaction and experience enhancement"
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: "You are a guest experience specialist focused on improving satisfaction scores, reducing churn, and enhancing hotel experiences. You analyze guest feedback, satisfaction trends, service issues, and social media sentiment using the HOTEL_PERSONALIZATION semantic views. Provide specific recommendations for operations teams including pre-arrival setup, service recovery, and proactive guest care. Focus on actionable strategies that improve guest satisfaction and loyalty."

tools:
  - tool_spec:
      type: "cortex_search"
      name: "search_experience_data"

tool_resources:
  search_experience_data:
    id_column: "GUEST_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.GUEST_ANALYTICS"
$$;

-- =====================================================
-- COMPREHENSIVE HOTEL INTELLIGENCE AGENT
-- =====================================================

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Intelligence Master Agent"
COMMENT = "Comprehensive agent with access to all hotel personalization data and insights"
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: "You are a comprehensive hotel intelligence specialist with access to all guest, personalization, and revenue data. You provide holistic insights combining guest behavior analysis, personalization opportunities, revenue optimization, and experience enhancement. You can answer complex questions that span multiple areas of hotel operations. Always provide data-driven recommendations with specific metrics, business impact, and actionable next steps. Consider the interconnections between guest satisfaction, personalization, and revenue when making recommendations."

tools:
  - tool_spec:
      type: "cortex_search"
      name: "search_all_guest_data"
  - tool_spec:
      type: "cortex_search" 
      name: "search_all_personalization_data"
  - tool_spec:
      type: "cortex_search"
      name: "search_all_revenue_data"

tool_resources:
  search_all_guest_data:
    id_column: "GUEST_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.GUEST_ANALYTICS"
  search_all_personalization_data:
    id_column: "GUEST_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.PERSONALIZATION_INSIGHTS"
  search_all_revenue_data:
    id_column: "HOTEL_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.REVENUE_OPTIMIZATION"
$$;

-- =====================================================
-- VERIFICATION
-- =====================================================

-- Show created agents
SHOW AGENTS IN SNOWFLAKE_INTELLIGENCE.AGENTS;

SELECT 'Simplified Snowflake Intelligence Agents Created Successfully' as status;
SELECT 'These agents can immediately work with your semantic views for natural language queries' as note;



