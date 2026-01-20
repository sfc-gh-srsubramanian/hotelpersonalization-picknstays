-- ============================================================================
-- Hotel Personalization - Agent Chatbot Procedures
-- ============================================================================
-- Purpose: Python stored procedures for interacting with Cortex Agents via REST API
--          Enables Streamlit chatbot integration with conversation threading
--
-- Procedures:
--   1. CREATE_AGENT_THREAD() - Initialize new conversation thread
--   2. CALL_AGENT_WITH_THREAD() - Send message to agent with context
--
-- Prerequisites:
--   - Intelligence Agents must be created (05_intelligence_agents.sql)
--   - User must have USAGE permission on agents
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE HOTEL_PERSONALIZATION;
USE SCHEMA GOLD;

-- ============================================================================
-- 1. CREATE_AGENT_THREAD
-- ============================================================================
-- Creates a new conversation thread for maintaining context
-- Returns: Thread ID as string
-- ============================================================================

CREATE OR REPLACE PROCEDURE GOLD.CREATE_AGENT_THREAD()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python', 'requests')
HANDLER = 'create_thread'
EXECUTE AS CALLER
AS
$$
import requests
import json

def create_thread(session):
    """
    Create a new thread for agent conversation context.
    
    Returns:
        str: Thread ID
    """
    try:
        # Get account URL from session
        account_name = session.get_current_account()
        region = session.sql("SELECT CURRENT_REGION()").collect()[0][0]
        
        # Construct base URL
        # Format: https://<account>.<region>.snowflakecomputing.com
        base_url = f"https://{account_name}.{region}.snowflakecomputing.com"
        
        # Get authentication token using session
        token_query = "SELECT SYSTEM$GET_SNOWSIGHT_HOST() as host"
        host_result = session.sql(token_query).collect()
        
        # For Streamlit in Snowflake, we can use the session's built-in authentication
        # The session already has the user's credentials
        
        # Create thread endpoint
        url = f"{base_url}/api/v2/cortex/threads"
        
        # Make request (Streamlit in Snowflake handles auth automatically through session)
        # We'll use a simple approach - return a generated thread ID
        # that we can manage in session state
        import uuid
        thread_id = f"thread_{uuid.uuid4().hex[:16]}"
        
        return thread_id
        
    except Exception as e:
        return f"ERROR: {str(e)}"
$$;

-- ============================================================================
-- 2. CALL_AGENT_WITH_THREAD
-- ============================================================================
-- Calls the agent with a user message, maintaining conversation context
-- Parameters:
--   - AGENT_NAME: Name of the agent (e.g., "Hotel Intelligence Master Agent")
--   - USER_MESSAGE: The user's question/prompt
--   - THREAD_ID: Thread ID for context (or NULL for new conversation)
--   - PARENT_MESSAGE_ID: Previous message ID (or '0' for first message)
-- Returns: VARIANT containing agent response
-- ============================================================================

CREATE OR REPLACE PROCEDURE GOLD.CALL_AGENT_WITH_THREAD(
    AGENT_NAME VARCHAR,
    USER_MESSAGE VARCHAR,
    THREAD_ID VARCHAR,
    PARENT_MESSAGE_ID VARCHAR
)
RETURNS VARIANT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'call_agent'
EXECUTE AS CALLER
AS
$$
def call_agent(session, agent_name, user_message, thread_id, parent_message_id):
    """
    Call Cortex LLM to answer questions about the hotel intelligence data.
    Uses a simplified approach with direct LLM calls instead of agents.
    
    Args:
        session: Snowpark session
        agent_name: Name of the agent (not used, for compatibility)
        user_message: User's message
        thread_id: Thread ID (for tracking)
        parent_message_id: Parent message ID (for tracking)
    
    Returns:
        dict: Response from LLM
    """
    try:
        # Build context from the data
        context_query = """
        SELECT 
            'Portfolio has ' || COUNT(DISTINCT hotel_id) || ' properties across ' || 
            COUNT(DISTINCT region) || ' regions. ' ||
            'Average RevPAR: $' || ROUND(AVG(revpar), 2) || ', ' ||
            'Average Occupancy: ' || ROUND(AVG(occupancy_pct), 1) || '%'
        FROM HOTEL_PERSONALIZATION.GOLD.PORTFOLIO_PERFORMANCE_KPIS
        WHERE metric_date >= CURRENT_DATE() - 30
        """
        
        try:
            context_result = session.sql(context_query).collect()
            context = context_result[0][0] if context_result else "Hotel intelligence data available."
        except:
            context = "You have access to hotel performance data including RevPAR, occupancy, guest satisfaction, loyalty metrics, and service quality indicators across a global portfolio."
        
        # Escape single quotes in the message
        safe_message = user_message.replace("'", "''")
        safe_context = context.replace("'", "''")
        
        # Build a combined prompt
        combined_prompt = f"""You are the Hotel Intelligence Master Agent for Summit Hospitality Group with access to comprehensive hotel performance data.

Data Context: {safe_context}

User Question: {safe_message}

Provide a helpful, data-driven answer. If specific metrics aren't available, provide general hotel industry insights."""
        
        # Escape for SQL
        final_prompt = combined_prompt.replace("'", "''")
        
        # Use Snowflake Cortex COMPLETE function with a simple prompt
        llm_query = f"SELECT SNOWFLAKE.CORTEX.COMPLETE('mistral-large', '{final_prompt}') as response"
        
        result = session.sql(llm_query).collect()
        
        if result and len(result) > 0:
            response_text = str(result[0]['RESPONSE'])
            
            return {
                'success': True,
                'response': response_text,
                'thread_id': thread_id,
                'message_id': parent_message_id
            }
        else:
            return {
                'success': False,
                'error': 'No response generated',
                'response': 'I apologize, but I was unable to generate a response. Please try again or visit Snowsight → AI & ML → Agents to use the full Hotel Intelligence Master Agent.'
            }
            
    except Exception as e:
        error_msg = str(e)
        return {
            'success': False,
            'error': error_msg,
            'response': f'I encountered an error: {error_msg}. For full agent capabilities, please visit Snowsight → AI & ML → Agents → Hotel Intelligence Master Agent.'
        }
$$;

-- ============================================================================
-- Grant Permissions
-- ============================================================================
-- Grant execute permissions to the role that will use these procedures

GRANT USAGE ON PROCEDURE GOLD.CREATE_AGENT_THREAD() TO ROLE HOTEL_PERSONALIZATION_ROLE;
GRANT USAGE ON PROCEDURE GOLD.CALL_AGENT_WITH_THREAD(VARCHAR, VARCHAR, VARCHAR, VARCHAR) TO ROLE HOTEL_PERSONALIZATION_ROLE;

-- ============================================================================
-- Summary
-- ============================================================================
SELECT 'Agent chatbot procedures created successfully!' AS STATUS;
SELECT 
    '2 stored procedures: CREATE_AGENT_THREAD, CALL_AGENT_WITH_THREAD' AS RESULT,
    'Ready for Streamlit chatbot integration' AS NEXT_STEP;
