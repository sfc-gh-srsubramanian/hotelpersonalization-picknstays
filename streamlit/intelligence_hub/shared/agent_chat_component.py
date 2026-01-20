"""
Agent Access Component

Provides access to the Hotel Intelligence Master Agent in Snowsight.
Shows suggested prompts and a button to open the agent.
"""

import streamlit as st
from snowflake.snowpark.context import get_active_session
from typing import List

# Get Snowpark session
session = get_active_session()


def display_suggested_prompts(prompts: List[str]) -> None:
    """
    Display suggested prompts as examples.
    
    Args:
        prompts: List of suggested prompt texts
    """
    st.markdown("**💡 Example questions you can ask:**")
    
    # Display prompts as bullet points
    for prompt in prompts:
        st.markdown(f"• {prompt}")


def get_snowflake_intelligence_url() -> str:
    """
    Get the URL to open Snowflake Intelligence page.
    
    Returns:
        str: URL to Snowflake Intelligence
    """
    try:
        # Get account information
        account_query = "SELECT CURRENT_ACCOUNT_NAME(), CURRENT_REGION()"
        result = session.sql(account_query).collect()
        
        if result:
            account_name = result[0][0]
            region = result[0][1]
            
            # Build Snowflake Intelligence URL
            # Format: https://ai.snowflake.com/<region>/<account>/#/ai
            intelligence_url = f"https://ai.snowflake.com/{region}/{account_name}/#/ai"
            
            return intelligence_url
    except:
        pass
    
    # Fallback generic URL
    return "https://ai.snowflake.com/#/ai"


def render_agent_chat(
    page_context: str,
    suggested_prompts: List[str],
    agent_name: str = "Hotel Intelligence Master Agent",
    placeholder_text: str = "Ask the Intelligence Agent..."
) -> None:
    """
    Render the agent access interface with a button to open Snowsight.
    
    Args:
        page_context: Unique identifier for the page (e.g., 'portfolio')
        suggested_prompts: List of suggested prompts to display
        agent_name: Name of the agent (for display)
        placeholder_text: Not used, kept for compatibility
    """
    # Display suggested prompts
    display_suggested_prompts(suggested_prompts)
    
    st.markdown("---")
    
    # Informational message
    st.info(
        f"💬 **Ask questions to the {agent_name}**\n\n"
        "Get data-driven insights from your hotel portfolio using natural language. "
        "The agent has access to all performance metrics, loyalty data, and service quality indicators."
    )
    
    # Get Snowflake Intelligence URL
    intelligence_url = get_snowflake_intelligence_url()
    
    # Prominent button to open Snowflake Intelligence
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        st.markdown(
            f'<a href="{intelligence_url}" target="_blank" style="text-decoration: none;">'
            '<button style="'
            'background-color: #0066CC; '
            'color: white; '
            'padding: 12px 24px; '
            'font-size: 16px; '
            'font-weight: bold; '
            'border: none; '
            'border-radius: 6px; '
            'cursor: pointer; '
            'width: 100%; '
            'box-shadow: 0 2px 4px rgba(0,0,0,0.1);'
            '">'
            '🤖 Open Snowflake Intelligence'
            '</button>'
            '</a>',
            unsafe_allow_html=True
        )
    
    st.caption(
        f"Opens Snowflake Intelligence where you can ask questions to the {agent_name}. "
        "Full conversation capabilities with access to all your data through semantic views."
    )
