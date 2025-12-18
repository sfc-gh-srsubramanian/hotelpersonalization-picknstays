-- Hotel Personalization System - Snowflake Intelligence Agents
-- Creates conversational agents for natural language queries about guest personalization

USE DATABASE HOTEL_PERSONALIZATION;

-- =====================================================
-- AGENT 1: GUEST INSIGHTS AGENT
-- =====================================================

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Guest Insights Agent"
COMMENT = "Conversational agent for guest behavior analysis and personalization insights"
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: "You are a hotel guest insights specialist focused on personalization and guest experience optimization. You analyze guest behavior, preferences, satisfaction scores, and booking patterns to provide actionable insights for hotel operations. Always provide specific data-driven recommendations and explain the business impact of your findings. When discussing guest segments, include loyalty tiers and personalization opportunities."

tools:
  - tool_spec:
      type: "cortex_search"
      name: "search_guest_data"
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "guest_analytics_queries"

tool_resources:
  search_guest_data:
    id_column: "GUEST_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.GUEST_ANALYTICS"
  guest_analytics_queries:
    semantic_model_file: "@HOTEL_PERSONALIZATION.SEMANTIC.GUEST_ANALYTICS_MODEL/guest_analytics.yaml"
$$;

-- =====================================================
-- AGENT 2: PERSONALIZATION RECOMMENDATIONS AGENT
-- =====================================================

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Personalization Agent"
COMMENT = "Agent specialized in personalized guest experiences and upsell recommendations"
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: "You are a hotel personalization expert who helps create hyper-personalized guest experiences. You analyze guest preferences, past behavior, and propensity scores to recommend room setups, upsells, dining options, and activities. Focus on actionable personalization strategies that increase guest satisfaction and revenue. Always consider the guest's loyalty tier, preferences, and booking history when making recommendations."

tools:
  - tool_spec:
      type: "cortex_search"
      name: "search_personalization_data"
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "personalization_queries"

tool_resources:
  search_personalization_data:
    id_column: "GUEST_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.PERSONALIZATION_INSIGHTS"
  personalization_queries:
    semantic_model_file: "@HOTEL_PERSONALIZATION.SEMANTIC.PERSONALIZATION_MODEL/personalization.yaml"
$$;

-- =====================================================
-- AGENT 3: REVENUE OPTIMIZATION AGENT
-- =====================================================

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Revenue Optimization Agent"
COMMENT = "Agent focused on revenue optimization and business performance analytics"
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: "You are a hotel revenue optimization specialist who analyzes business performance metrics, guest lifetime value, and revenue opportunities. You provide insights on pricing strategies, upsell opportunities, customer segmentation for revenue growth, and operational efficiency. Focus on actionable recommendations that drive revenue while maintaining guest satisfaction. Always include specific metrics and ROI projections when possible."

tools:
  - tool_spec:
      type: "cortex_search"
      name: "search_revenue_data"
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "revenue_analytics_queries"

tool_resources:
  search_revenue_data:
    id_column: "HOTEL_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.REVENUE_OPTIMIZATION"
  revenue_analytics_queries:
    semantic_model_file: "@HOTEL_PERSONALIZATION.SEMANTIC.REVENUE_MODEL/revenue_optimization.yaml"
$$;

-- =====================================================
-- AGENT 4: GUEST EXPERIENCE AGENT
-- =====================================================

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Guest Experience Optimization Agent"
COMMENT = "Agent specialized in guest satisfaction and experience enhancement"
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: "You are a guest experience specialist focused on improving satisfaction scores, reducing churn, and enhancing the overall hotel experience. You analyze guest feedback, satisfaction trends, service issues, and social media sentiment to recommend experience improvements. Provide specific actionable recommendations for operations teams, including pre-arrival setup, service recovery, and proactive guest care strategies."

tools:
  - tool_spec:
      type: "cortex_search"
      name: "search_experience_data"
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "experience_analytics_queries"

tool_resources:
  search_experience_data:
    id_column: "GUEST_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.GUEST_ANALYTICS"
  experience_analytics_queries:
    semantic_model_file: "@HOTEL_PERSONALIZATION.SEMANTIC.EXPERIENCE_MODEL/guest_experience.yaml"
$$;

-- Verification
SELECT 'Snowflake Intelligence Agents Created Successfully' as status;



