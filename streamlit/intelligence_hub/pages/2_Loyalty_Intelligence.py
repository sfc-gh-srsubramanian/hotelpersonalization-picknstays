"""
Tab 2: Loyalty Intelligence
Segment-level behavior, spend patterns, and retention opportunities
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import sys
sys.path.append('../shared')

from shared.data_loader_intel import load_loyalty_segments
from shared.viz_components_intel import create_kpi_card, create_bar_chart, create_grouped_bar_chart
from shared.formatters import format_currency, format_percent, format_number

st.title("🎯 Loyalty Intelligence")
st.markdown("Deep dive into guest segments, repeat stay drivers, and retention opportunities")

# =====================================================================
# Load Data
# =====================================================================
df_segments = load_loyalty_segments()

if df_segments.empty:
    st.warning("No loyalty segment data available.")
    st.stop()

# =====================================================================
# KPI Cards
# =====================================================================
st.markdown("### 📊 Loyalty Program KPIs")

# Calculate aggregate metrics (ONLY for actual loyalty program members, not "Non-Member")
loyalty_segments = df_segments[df_segments['LOYALTY_TIER'] != 'Non-Member']
total_members = loyalty_segments['ACTIVE_MEMBERS'].sum()
avg_repeat_rate = (loyalty_segments['REPEAT_RATE_PCT'] * loyalty_segments['ACTIVE_MEMBERS']).sum() / total_members if total_members > 0 else 0
avg_spend = (loyalty_segments['AVG_SPEND_PER_STAY'] * loyalty_segments['ACTIVE_MEMBERS']).sum() / total_members if total_members > 0 else 0
high_value_members = loyalty_segments[loyalty_segments['AVG_SPEND_PER_STAY'] > 500]['ACTIVE_MEMBERS'].sum()
high_value_share = (high_value_members / total_members * 100) if total_members > 0 else 0
at_risk_count = loyalty_segments[loyalty_segments['REPEAT_RATE_PCT'] < 40]['ACTIVE_MEMBERS'].sum()

col1, col2, col3, col4, col5 = st.columns(5)

with col1:
    st.metric(
        "Active Loyalty Members", 
        f"{int(total_members):,}",
        help="Number of loyalty members with at least one stay in the period. Measures program engagement."
    )

with col2:
    st.metric(
        "Repeat Stay Rate", 
        f"{avg_repeat_rate:.1f}%",
        help="Percentage of guests in each loyalty tier who returned for additional stays. Key retention metric by tier."
    )

with col3:
    st.metric(
        "Avg Spend per Stay", 
        f"${avg_spend:,.0f}",
        help="Average total spend per stay including room, amenities, and services. Indicates guest value and upsell effectiveness."
    )

with col4:
    st.metric(
        "High-Value Guest Share", 
        f"{high_value_share:.1f}%",
        help="Percentage of total members spending $500+ per stay. Shows concentration among top guests."
    )

with col5:
    st.metric(
        "At-Risk Segments", 
        f"{int(at_risk_count):,}",
        help="Count of members in segments with <40% repeat rate. Requires retention focus."
    )

# =====================================================================
# Charts
# =====================================================================
st.markdown("---")
st.markdown("### 📊 Segment Analysis")

chart_col1, chart_col2 = st.columns(2)

with chart_col1:
    # Repeat Rate by Loyalty Tier
    st.markdown("#### Repeat Rate by Loyalty Tier")
    # Since we have one row per tier, just select and order the data
    tier_data = df_segments[['LOYALTY_TIER', 'REPEAT_RATE_PCT']].copy()
    
    # Define tier order: Blue → Silver → Gold → Diamond → Non-Member (ascending loyalty + non-member last)
    tier_order_map = {'Blue': 0, 'Silver': 1, 'Gold': 2, 'Diamond': 3, 'Non-Member': 4}
    tier_data['sort_order'] = tier_data['LOYALTY_TIER'].map(tier_order_map)
    tier_data = tier_data.sort_values('sort_order').drop('sort_order', axis=1).reset_index(drop=True)
    
    # Set LOYALTY_TIER as index for simple bar chart
    tier_data = tier_data.set_index('LOYALTY_TIER')
    
    # Use Streamlit's simple bar chart
    st.bar_chart(tier_data['REPEAT_RATE_PCT'], height=350)

with chart_col2:
    # Spend by Tier
    st.markdown("#### Avg Spend per Stay by Tier")
    # Since we have one row per tier, just select and order the data
    spend_data = df_segments[['LOYALTY_TIER', 'AVG_SPEND_PER_STAY']].copy()
    
    # Define tier order: Blue → Silver → Gold → Diamond → Non-Member (ascending loyalty + non-member last)
    tier_order_map = {'Blue': 0, 'Silver': 1, 'Gold': 2, 'Diamond': 3, 'Non-Member': 4}
    spend_data['sort_order'] = spend_data['LOYALTY_TIER'].map(tier_order_map)
    spend_data = spend_data.sort_values('sort_order').drop('sort_order', axis=1).reset_index(drop=True)
    
    # Set LOYALTY_TIER as index for simple bar chart
    spend_data = spend_data.set_index('LOYALTY_TIER')
    
    # Use Streamlit's simple bar chart (no color param - not supported in Snowflake Streamlit)
    st.bar_chart(spend_data['AVG_SPEND_PER_STAY'], height=350)

# Spend Mix by Tier - LINE CHART to show trends
st.markdown("#### Revenue Mix by Loyalty Tier (Trends)")
st.caption("How each revenue source changes across loyalty tiers - notice Spa/F&B trends")

# Since we have one row per tier, just select and order the data
spend_mix_data = df_segments[['LOYALTY_TIER', 'ROOM_REVENUE_PCT', 'FB_REVENUE_PCT', 'SPA_REVENUE_PCT', 'OTHER_REVENUE_PCT']].copy()

# Define tier order: Blue → Silver → Gold → Diamond → Non-Member (ascending loyalty + non-member last)
tier_order_map = {'Blue': 0, 'Silver': 1, 'Gold': 2, 'Diamond': 3, 'Non-Member': 4}
spend_mix_data['sort_order'] = spend_mix_data['LOYALTY_TIER'].map(tier_order_map)
spend_mix_data = spend_mix_data.sort_values('sort_order').drop('sort_order', axis=1).reset_index(drop=True)

# Rename columns for chart legend
spend_mix_data = spend_mix_data.rename(columns={
    'ROOM_REVENUE_PCT': 'Room',
    'FB_REVENUE_PCT': 'F&B',
    'SPA_REVENUE_PCT': 'Spa',
    'OTHER_REVENUE_PCT': 'Other'
})

# Set LOYALTY_TIER as index
spend_mix_data = spend_mix_data.set_index('LOYALTY_TIER')

# Use LINE CHART to show trends across tiers (makes Spa/Other trends visible!)
st.line_chart(spend_mix_data[['Room', 'F&B', 'Spa', 'Other']], height=350)

# =====================================================================
# Top Loyalty Opportunities Table
# =====================================================================
st.markdown("---")
st.markdown("### 🎯 Top Loyalty Opportunities")
st.caption("Segment-level insights and strategic recommendations")

# Prepare table data with tooltips
opportunities_df = df_segments[[
    'SEGMENT', 'REPEAT_RATE_PCT', 'AVG_SPEND_PER_STAY', 'TOP_FRICTION_DRIVER',
    'RECOMMENDED_FOCUS', 'EXPERIENCE_AFFINITY', 'UNDERUTILIZED_OPPORTUNITY'
]].copy()

opportunities_df = opportunities_df.rename(columns={
    'SEGMENT': 'Segment',
    'REPEAT_RATE_PCT': 'Repeat Rate (%)',
    'AVG_SPEND_PER_STAY': 'Avg Spend ($)',
    'TOP_FRICTION_DRIVER': 'Top Friction Point',
    'RECOMMENDED_FOCUS': 'Focus Area',
    'EXPERIENCE_AFFINITY': 'Experience Affinity',
    'UNDERUTILIZED_OPPORTUNITY': 'Growth Opportunity'
}).sort_values('Avg Spend ($)', ascending=False).head(15)

st.caption("💡 **Repeat Rate**: % of guests who made multiple stays | **Top Friction Point**: Most common service issue | **Experience Affinity**: Primary service preference | **Growth Opportunity**: High appeal, low penetration service")

st.dataframe(
    opportunities_df.style.format({
        'Repeat Rate (%)': '{:.1f}%',
        'Avg Spend ($)': '${:,.0f}'
    }),
    height=400
)

# =====================================================================
# Experience Drivers Analysis
# =====================================================================
st.markdown("---")
st.markdown("### 💡 Experience Drivers of Repeat Stays")

# Show experience affinity distribution
affinity_counts = df_segments['EXPERIENCE_AFFINITY'].value_counts().reset_index()
affinity_counts.columns = ['Experience Category', 'Segment Count']

fig4 = px.pie(
    affinity_counts,
    values='Segment Count',
    names='Experience Category',
    title='What Drives Guest Loyalty?',
    template='plotly_white',
    hole=0.4
)
fig4.update_traces(textposition='inside', textinfo='percent+label')
st.plotly_chart(fig4, use_container_width=True)

col1, col2 = st.columns(2)

with col1:
    st.markdown("#### ✅ High-Performing Segments")
    high_performers = df_segments[df_segments['REPEAT_RATE_PCT'] > 50].sort_values('TOTAL_REVENUE', ascending=False)[['SEGMENT', 'REPEAT_RATE_PCT', 'AVG_SPEND_PER_STAY', 'EXPERIENCE_AFFINITY']].head(5)
    if not high_performers.empty:
        st.dataframe(
            high_performers.rename(columns={
                'SEGMENT': 'Segment',
                'REPEAT_RATE_PCT': 'Repeat %',
                'AVG_SPEND_PER_STAY': 'Avg Spend',
                'EXPERIENCE_AFFINITY': 'Key Driver'
            })
        )
    else:
        st.info("No segments with repeat rate >50%")

with col2:
    st.markdown("#### ⚠️ At-Risk Segments")
    at_risk_segments = df_segments[df_segments['REPEAT_RATE_PCT'] < 30].sort_values('TOTAL_REVENUE', ascending=False)[['SEGMENT', 'REPEAT_RATE_PCT', 'TOP_FRICTION_DRIVER', 'RECOMMENDED_FOCUS']].head(5)
    if not at_risk_segments.empty:
        st.dataframe(
            at_risk_segments.rename(columns={
                'SEGMENT': 'Segment',
                'REPEAT_RATE_PCT': 'Repeat %',
                'TOP_FRICTION_DRIVER': 'Issue',
                'RECOMMENDED_FOCUS': 'Action'
            })
        )
    else:
        st.info("No at-risk segments detected")

# =====================================================================
# =====================================================================
# AI-Powered Analysis Chatbot
# =====================================================================
st.markdown("---")
st.markdown("### 🤖 AI-Powered Analysis")

# Import chat component
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from shared.agent_chat_component import render_agent_chat

# Define page-specific prompts
prompts = [
    "Which amenities correlate most with repeat stays for Diamond guests?",
    "Which loyalty segment is growing fastest—and what's driving it?",
    "Where are we under-delivering experiences our best guests value?",
    "Show me loyalty trends across all tiers over the last quarter"
]

# Render the chatbot interface
render_agent_chat(
    page_context="loyalty",
    suggested_prompts=prompts,
    agent_name="Hotel Intelligence Master Agent",
    placeholder_text="Ask about loyalty segments, repeat rates, or member behavior..."
)
