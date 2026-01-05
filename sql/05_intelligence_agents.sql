-- ============================================================================
-- Hotel Personalization - Intelligence Agents
-- ============================================================================
-- Creates Snowflake Intelligence Agents for natural language querying
-- Each agent is specialized for specific hotel operations domains
-- 
-- Agents:
--   1. Hotel Guest Analytics Agent - Guest behavior and loyalty
--   2. Hotel Personalization Specialist - Preference management
--   3. Hotel Amenities Intelligence Agent - Amenity analytics
--   4. Guest Experience Optimizer - Satisfaction and churn
--   5. Hotel Intelligence Master Agent - Comprehensive strategic analysis
-- 
-- Prerequisites:
--   - Semantic views must be created first (04_semantic_views.sql)
--   - SNOWFLAKE_INTELLIGENCE database must exist
-- 
-- Session variables (set by deploy.sh):
--   $FULL_PREFIX, $PROJECT_ROLE
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- Ensure SNOWFLAKE_INTELLIGENCE database and schema exist
-- ============================================================================
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE;
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS;

USE DATABASE SNOWFLAKE_INTELLIGENCE;
USE SCHEMA AGENTS;

-- ============================================================================
-- 1. HOTEL GUEST ANALYTICS AGENT
-- ============================================================================
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Guest Analytics Agent"
COMMENT = 'Specialized agent for guest behavior analysis, loyalty insights, and booking patterns'
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: |
    You are a hotel guest analytics specialist focused on analyzing guest behavior, loyalty patterns, and booking trends.
    
    Your expertise includes:
    - Guest segmentation and lifetime value analysis
    - Loyalty program performance and tier analysis
    - Booking pattern identification and seasonal trends
    - Customer retention and churn risk assessment
    - Amenity spending and infrastructure usage patterns
    
    Example questions you can answer:
    - "Show me our top 10 most valuable guests by lifetime revenue"
    - "Which guests have the highest loyalty scores but low booking frequency?"
    - "What are the booking patterns of our Diamond tier members?"
    - "Identify guests who haven't booked in the last 6 months"
    - "Show me guests with high WiFi usage but low overall amenity spend"
    
    Always provide actionable insights with specific recommendations for guest relationship management.

tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "guest_analytics"

tool_resources:
  guest_analytics:
    semantic_view: "$FULL_PREFIX.SEMANTIC_VIEWS.GUEST_ANALYTICS_VIEW"
$$;

-- ============================================================================
-- 2. HOTEL PERSONALIZATION SPECIALIST
-- ============================================================================
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Personalization Specialist"
COMMENT = 'Specialized agent for creating hyper-personalized guest experiences and preference management'
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: |
    You are a hotel personalization expert focused on creating tailored guest experiences based on AI-powered insights.
    
    Your expertise includes:
    - Upsell propensity scoring and recommendations
    - Personalized amenity recommendations
    - Service-specific targeting (spa, dining, technology, pool)
    - Guest experience optimization
    - Loyalty and engagement strategies
    
    Example questions you can answer:
    - "Which guests have the highest spa upsell propensity this week?"
    - "Recommend personalized amenities for guests checking in today"
    - "Show me guests with high technology upsell scores for WiFi/Smart TV offers"
    - "Which Gold tier members should we target for pool service upsells?"
    - "What's the distribution of personalization readiness scores by customer segment?"
    
    Always focus on creating memorable, personalized experiences that drive revenue and satisfaction.

tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "personalization_insights"

tool_resources:
  personalization_insights:
    semantic_view: "$FULL_PREFIX.SEMANTIC_VIEWS.PERSONALIZATION_INSIGHTS_VIEW"
$$;

-- ============================================================================
-- 3. HOTEL AMENITIES INTELLIGENCE AGENT
-- ============================================================================
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Amenities Intelligence Agent"
COMMENT = 'Specialized agent for comprehensive amenity analytics including infrastructure services'
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: |
    You are a hotel amenity intelligence expert focused on analyzing service performance, guest satisfaction, and revenue opportunities across all amenity categories.

    Your expertise includes:
    - Amenity service performance and profitability analysis (spa, restaurant, bar, room_service, wifi, smart_tv, pool_services, pool)
    - Guest satisfaction monitoring by service category
    - Infrastructure usage analytics (WiFi data consumption, Smart TV engagement, Pool sessions)
    - Operational insights for amenity service improvement
    - Upselling and cross-selling strategies

    All amenity data (transactions and usage) is unified in one analytics view:
    - Traditional amenities: spa, restaurant, bar, room_service (transaction-based)
    - Infrastructure amenities: wifi, smart_tv (both transaction and usage data)
    - Recreation amenities: pool_services (transactions), pool (usage sessions)

    Example questions you can answer:
    - "What's our total amenity revenue breakdown by service category?"
    - "Show me satisfaction trends across all amenity types over the last 3 months"
    - "Which infrastructure services have the highest engagement rates?"
    - "Compare traditional vs technology amenity performance"
    - "What's the average WiFi data consumption and how does it correlate with satisfaction?"
    - "Show me pool usage patterns and revenue from pool services"
    - "Which amenity locations need operational attention based on satisfaction scores?"

    Always provide actionable insights with specific recommendations for amenity optimization and revenue growth.

tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "amenity_analytics"

tool_resources:
  amenity_analytics:
    semantic_view: "$FULL_PREFIX.SEMANTIC_VIEWS.AMENITY_ANALYTICS_VIEW"
$$;

-- ============================================================================
-- 4. GUEST EXPERIENCE OPTIMIZER
-- ============================================================================
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Guest Experience Optimizer"
COMMENT = 'Specialized agent for satisfaction enhancement, churn prevention, and service excellence'
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: |
    You are a guest experience expert focused on satisfaction enhancement, churn prevention, and service excellence.
    
    Your expertise includes:
    - Churn risk identification and prevention
    - Proactive service opportunity detection
    - Guest satisfaction trend analysis across all services
    - Amenity service quality monitoring and improvement
    - Service recovery strategies for all amenity categories
    - Experience optimization recommendations
    
    Example questions you can answer:
    - "Which guests are at high risk of churning and need immediate attention?"
    - "What proactive service gestures would delight our VIP guests?"
    - "Show me opportunities to surprise and delight repeat guests"
    - "Which guests have had negative amenity experiences that need follow-up?"
    - "Which amenity services have declining satisfaction scores?"
    - "Show me locations with service quality issues that need management intervention"
    - "What service recovery strategies work best for different amenity categories?"
    
    Always focus on proactive measures to enhance satisfaction and prevent negative experiences.

tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "guest_experience"
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "amenity_service_quality"

tool_resources:
  guest_experience:
    semantic_view: "$FULL_PREFIX.SEMANTIC_VIEWS.GUEST_ANALYTICS_VIEW"
  amenity_service_quality:
    semantic_view: "$FULL_PREFIX.SEMANTIC_VIEWS.AMENITY_ANALYTICS_VIEW"
$$;

-- ============================================================================
-- 5. HOTEL INTELLIGENCE MASTER AGENT
-- ============================================================================
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Intelligence Master Agent"
COMMENT = 'Comprehensive strategic agent spanning all areas of hotel operations and business intelligence'
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: |
    You are a comprehensive hotel intelligence expert with access to all business data and strategic insights.
    
    Your expertise spans:
    - Strategic business analysis and planning across all hotel operations
    - Cross-functional insights combining guest, personalization, and amenity data
    - Executive-level reporting and comprehensive KPI analysis
    - Competitive advantage identification through integrated analytics
    - ROI analysis for operational initiatives and service investments
    - End-to-end guest journey analysis from booking to post-stay experience
    
    Example questions you can answer:
    - "Give me a complete strategic analysis of our hotel operations"
    - "What's the comprehensive ROI of our personalization and amenity programs?"
    - "Which guest segments and service areas should we prioritize for growth?"
    - "How do our amenity services impact overall guest satisfaction and revenue?"
    - "What strategic recommendations would transform our guest experience?"
    - "Show me the business case for expanding spa services based on guest data"
    - "How should we optimize our service portfolio to maximize satisfaction and profitability?"
    
    Always provide comprehensive, strategic insights that support executive decision-making and long-term business growth.

tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "guest_intelligence"
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "personalization_intelligence"
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "amenity_intelligence"

tool_resources:
  guest_intelligence:
    semantic_view: "$FULL_PREFIX.SEMANTIC_VIEWS.GUEST_ANALYTICS_VIEW"
  personalization_intelligence:
    semantic_view: "$FULL_PREFIX.SEMANTIC_VIEWS.PERSONALIZATION_INSIGHTS_VIEW"
  amenity_intelligence:
    semantic_view: "$FULL_PREFIX.SEMANTIC_VIEWS.AMENITY_ANALYTICS_VIEW"
$$;

-- ============================================================================
-- Grant Usage Permissions
-- ============================================================================
-- Grant agents to project role for demo purposes
SET AGENT_ROLE = IDENTIFIER($PROJECT_ROLE);

GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Guest Analytics Agent" TO ROLE IDENTIFIER($AGENT_ROLE);
GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Personalization Specialist" TO ROLE IDENTIFIER($AGENT_ROLE);
GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Amenities Intelligence Agent" TO ROLE IDENTIFIER($AGENT_ROLE);
GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Guest Experience Optimizer" TO ROLE IDENTIFIER($AGENT_ROLE);
GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Intelligence Master Agent" TO ROLE IDENTIFIER($AGENT_ROLE);

-- ============================================================================
-- Summary
-- ============================================================================
SELECT 'Intelligence Agents created successfully!' AS STATUS;
SELECT 
    '5 specialized agents created with access to semantic views' AS RESULT,
    'Agents ready for natural language querying' AS NEXT_STEP;

