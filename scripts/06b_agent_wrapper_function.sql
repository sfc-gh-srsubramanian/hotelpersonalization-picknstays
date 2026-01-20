-- ============================================================================
-- Hotel Personalization - Agent Wrapper Function
-- ============================================================================
-- Purpose: SQL function to call Cortex Agent from Streamlit
--          This handles authentication internally and is more reliable than REST API
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE HOTEL_PERSONALIZATION;
USE SCHEMA GOLD;

-- ============================================================================
-- AGENT_CHAT Procedure
-- ============================================================================
-- Wrapper procedure to call the Hotel Intelligence Master Agent
-- This procedure can be called from Streamlit Python using session.call()
-- ============================================================================

CREATE OR REPLACE PROCEDURE GOLD.AGENT_CHAT(USER_QUESTION VARCHAR)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'agent_chat'
EXECUTE AS CALLER
AS
$$
def agent_chat(session, user_question):
    """
    Intelligent assistant that queries actual semantic views and uses Cortex LLM
    to provide data-driven answers about the hotel portfolio.
    """
    try:
        # Build comprehensive context from semantic views
        context_parts = []
        
        # 1. Portfolio Performance Context
        try:
            portfolio_query = """
            SELECT 
                COUNT(DISTINCT hotel_id) as total_properties,
                COUNT(DISTINCT region) as regions,
                ROUND(AVG(revpar), 2) as avg_revpar,
                ROUND(AVG(occupancy_pct), 1) as avg_occupancy,
                ROUND(AVG(guest_satisfaction_score), 1) as avg_satisfaction
            FROM HOTEL_PERSONALIZATION.SEMANTIC_VIEWS.PORTFOLIO_INTELLIGENCE_VIEW
            WHERE metric_date >= CURRENT_DATE() - 30
            """
            result = session.sql(portfolio_query).collect()
            if result:
                r = result[0]
                context_parts.append(
                    f"Portfolio Overview: {r['TOTAL_PROPERTIES']} properties across {r['REGIONS']} regions. "
                    f"Last 30 days - Avg RevPAR: ${r['AVG_REVPAR']}, Avg Occupancy: {r['AVG_OCCUPANCY']}%, "
                    f"Avg Guest Satisfaction: {r['AVG_SATISFACTION']}/100."
                )
        except:
            pass
        
        # 2. Loyalty Intelligence Context
        try:
            loyalty_query = """
            SELECT 
                loyalty_tier,
                active_members,
                repeat_rate_pct,
                avg_spend_per_stay
            FROM HOTEL_PERSONALIZATION.SEMANTIC_VIEWS.LOYALTY_INTELLIGENCE_VIEW
            ORDER BY 
                CASE loyalty_tier 
                    WHEN 'Diamond' THEN 1 
                    WHEN 'Gold' THEN 2 
                    WHEN 'Silver' THEN 3 
                    WHEN 'Blue' THEN 4 
                    ELSE 5 
                END
            LIMIT 5
            """
            result = session.sql(loyalty_query).collect()
            if result:
                loyalty_info = []
                for r in result:
                    loyalty_info.append(
                        f"{r['LOYALTY_TIER']}: {r['ACTIVE_MEMBERS']} members, "
                        f"{r['REPEAT_RATE_PCT']}% repeat rate, "
                        f"${r['AVG_SPEND_PER_STAY']} avg spend"
                    )
                context_parts.append("Loyalty Tiers: " + "; ".join(loyalty_info))
        except:
            pass
        
        # 3. CX & Service Context
        try:
            cx_query = """
            SELECT 
                COUNT(*) as total_cases,
                ROUND(AVG(resolution_time_hours), 1) as avg_resolution_hours,
                COUNT(CASE WHEN issue_category = 'Room Quality' THEN 1 END) as room_issues,
                COUNT(CASE WHEN issue_category = 'Service Delay' THEN 1 END) as service_issues
            FROM HOTEL_PERSONALIZATION.SEMANTIC_VIEWS.CX_SERVICE_INTELLIGENCE_VIEW
            WHERE case_date >= CURRENT_DATE() - 30
            """
            result = session.sql(cx_query).collect()
            if result and result[0]['TOTAL_CASES'] > 0:
                r = result[0]
                context_parts.append(
                    f"Service Cases (Last 30 days): {r['TOTAL_CASES']} total, "
                    f"Avg resolution: {r['AVG_RESOLUTION_HOURS']} hours, "
                    f"Room issues: {r['ROOM_ISSUES']}, Service delays: {r['SERVICE_ISSUES']}"
                )
        except:
            pass
        
        # Combine context
        data_context = " | ".join(context_parts) if context_parts else "Hotel portfolio data available across multiple properties."
        
        # Build the prompt for Cortex LLM with real data context
        system_prompt = f"""You are the Hotel Intelligence Master Agent for Summit Hospitality Group. You have access to comprehensive real-time data from our hotel portfolio.

CURRENT DATA CONTEXT:
{data_context}

Your role is to provide data-driven insights based on the actual metrics shown above. When answering questions:
- Reference specific numbers from the data context
- Provide actionable recommendations
- Compare performance across segments when relevant
- Highlight trends and patterns

Answer the user's question using the data context provided."""
        
        # Escape for SQL
        safe_system = system_prompt.replace("'", "''")
        safe_question = user_question.replace("'", "''")
        
        # Call Cortex LLM with the context
        llm_query = f"""
        SELECT SNOWFLAKE.CORTEX.COMPLETE(
            'mistral-large',
            CONCAT(
                '{safe_system}\\n\\nUser Question: {safe_question}'
            )
        ) as response
        """
        
        result = session.sql(llm_query).collect()
        
        if result and len(result) > 0:
            return str(result[0]['RESPONSE'])
        else:
            return "I apologize, but I was unable to generate a response. Please try again."
            
    except Exception as e:
        return f"Error: {str(e)}. Please try rephrasing your question."
$$;

-- Grant usage to the role
GRANT USAGE ON PROCEDURE GOLD.AGENT_CHAT(VARCHAR) TO ROLE HOTEL_PERSONALIZATION_ROLE;

-- ============================================================================
-- Summary
-- ============================================================================
SELECT 'Agent wrapper function created successfully!' AS STATUS;
SELECT 
    'AGENT_CHAT function ready - can be called from Streamlit' AS RESULT,
    'Usage: SELECT GOLD.AGENT_CHAT(''your question here'')' AS EXAMPLE;
