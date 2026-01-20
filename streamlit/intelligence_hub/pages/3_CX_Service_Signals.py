"""
Tab 3: CX & Service Signals
Operational intelligence on service quality, issue drivers, and at-risk guests
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import sys
sys.path.append('../shared')

from shared.data_loader_intel import (
    load_cx_signals,
    load_future_arrivals,
    get_available_regions,
    get_available_brands
)
from shared.viz_components_intel import create_kpi_card, create_bar_chart, create_heatmap
from shared.formatters import format_number, format_duration

st.title("💬 CX & Service Signals")
st.markdown("Operational intelligence for service quality and guest experience")

# =====================================================================
# Filters
# =====================================================================
st.markdown("### 🔍 Filters")
col1, col2 = st.columns(2)

with col1:
    regions = ['All'] + get_available_regions()
    selected_region = st.selectbox("Region", regions)

with col2:
    brands = ['All'] + get_available_brands()
    selected_brand = st.selectbox("Brand", brands)

# Apply filters
region_filter = None if selected_region == 'All' else selected_region
brand_filter = None if selected_brand == 'All' else selected_brand

# Load data
df_cx = load_cx_signals(region=region_filter, brand=brand_filter)
df_vip = load_future_arrivals(days_ahead=7)

if df_cx.empty:
    st.warning("No CX data available for selected filters.")
    st.stop()

# =====================================================================
# KPI Cards
# =====================================================================
st.markdown("---")
st.markdown("### 📊 Service Quality KPIs (Last 30 Days)")

# Calculate aggregate metrics
avg_case_rate = df_cx['SERVICE_CASE_RATE'].mean()
avg_resolution_time = df_cx['AVG_RESOLUTION_TIME_HOURS'].mean()
avg_negative_sentiment = df_cx['NEGATIVE_SENTIMENT_RATE_PCT'].mean()
avg_recovery_success = df_cx['SERVICE_RECOVERY_SUCCESS_PCT'].mean()
total_at_risk = df_cx['AT_RISK_HIGH_VALUE_GUESTS_COUNT'].sum()

col1, col2, col3, col4, col5 = st.columns(5)

with col1:
    st.metric(
        "Service Case Rate",
        f"{avg_case_rate:.1f}/1K",
        help="Number of service incidents per 1,000 stays. Lower is better. Industry benchmark: 50-100 cases per 1,000 stays."
    )

with col2:
    st.metric(
        "Avg Resolution Time",
        format_duration(avg_resolution_time),
        help="Average time (in hours) to resolve service cases. Target varies by severity: Critical <4h, High <8h, Medium <24h."
    )

with col3:
    st.metric(
        "Negative Sentiment Rate",
        f"{avg_negative_sentiment:.1f}%",
        help="Percentage of feedback with negative sentiment. Calculated from reviews and surveys. Target: <5%"
    )

with col4:
    st.metric(
        "Recovery Success Rate",
        f"{avg_recovery_success:.1f}%",
        help="Percentage of service recovery attempts accepted by guests. Measures effectiveness of recovery efforts. Target: >70%"
    )

with col5:
    st.metric(
        "At-Risk High-Value Guests",
        f"{int(total_at_risk):,}",
        help="Count of high-value guests ($10K+ LTV) with recent negative sentiment or service issues. Priority for retention."
    )

# =====================================================================
# Charts
# =====================================================================
st.markdown("---")
st.markdown("### 📊 Service Intelligence Analysis")

# Top Issue Drivers
st.markdown("#### Top Service Issue Drivers")
st.caption("Most common service issues across the portfolio")

# Aggregate top issues
all_issues = []
for col in ['TOP_ISSUE_DRIVER_1', 'TOP_ISSUE_DRIVER_2', 'TOP_ISSUE_DRIVER_3']:
    issues = df_cx[col].dropna().value_counts().to_dict()
    all_issues.extend([(k, v) for k, v in issues.items()])

issue_df = pd.DataFrame(all_issues, columns=['Issue', 'Count']).groupby('Issue')['Count'].sum().reset_index().sort_values('Count', ascending=True).tail(10)

fig1 = px.bar(
    issue_df,
    y='Issue',
    x='Count',
    title='Top 10 Service Issue Drivers',
    orientation='h',
    template='plotly_white',
    color='Count',
    color_continuous_scale='Reds'
)
fig1.update_layout(height=350, showlegend=False)
st.plotly_chart(fig1, use_container_width=True)

chart_col1, chart_col2 = st.columns(2)

with chart_col1:
    # Issue Heatmap by Brand
    st.markdown("#### Service Case Rate by Brand")
    brand_cases = df_cx.groupby('BRAND')['SERVICE_CASE_RATE'].mean().reset_index().sort_values('SERVICE_CASE_RATE', ascending=False)
    
    fig2 = px.bar(
        brand_cases,
        x='BRAND',
        y='SERVICE_CASE_RATE',
        title='Avg Service Case Rate by Brand',
        template='plotly_white',
        color='SERVICE_CASE_RATE',
        color_continuous_scale='Reds'
    )
    fig2.update_layout(height=300, showlegend=False)
    fig2.update_yaxes(title='Cases per 1,000 Stays')
    st.plotly_chart(fig2, use_container_width=True)

with chart_col2:
    # Recovery Success by Brand
    st.markdown("#### Recovery Success Rate by Brand")
    brand_recovery = df_cx.groupby('BRAND')['SERVICE_RECOVERY_SUCCESS_PCT'].mean().reset_index().sort_values('SERVICE_RECOVERY_SUCCESS_PCT', ascending=False)
    
    fig3 = px.bar(
        brand_recovery,
        x='BRAND',
        y='SERVICE_RECOVERY_SUCCESS_PCT',
        title='Avg Recovery Success by Brand',
        template='plotly_white',
        color='SERVICE_RECOVERY_SUCCESS_PCT',
        color_continuous_scale='Greens'
    )
    fig3.update_layout(height=300, showlegend=False)
    fig3.update_yaxes(title='Success Rate (%)')
    st.plotly_chart(fig3, use_container_width=True)

# =====================================================================
# VIP Watchlist Table
# =====================================================================
st.markdown("---")
st.markdown("### 🚨 VIP Watchlist: Upcoming Arrivals (Next 7 Days)")
st.caption("High-value guests with context for proactive service")

if df_vip.empty:
    st.info("No VIP arrivals with service context in the next 7 days.")
else:
    # Prepare VIP table
    vip_display = df_vip.copy()
    
    # Anonymize guest ID
    vip_display['GUEST_ID_HASH'] = vip_display['GUEST_ID'].str[:8] + '***'
    
    # Format preferences
    vip_display['PREFERENCES'] = vip_display['ROOM_PREFERENCE'].apply(
        lambda x: str(x) if pd.notna(x) else 'None'
    )
    
    # Map churn risk to color
    def risk_level(score):
        if score >= 75:
            return "🔴 High"
        elif score >= 50:
            return "🟡 Medium"
        else:
            return "🟢 Low"
    
    vip_display['RISK_LEVEL'] = vip_display['CHURN_RISK_SCORE'].apply(risk_level)
    
    # Select and rename columns
    vip_table = vip_display[[
        'GUEST_ID_HASH', 'TIER_LEVEL', 'CHECK_IN_DATE', 'BRAND', 'CITY',
        'PRIOR_ISSUE_COUNT', 'PREFERENCES', 'LIFETIME_VALUE', 'CHURN_RISK_SCORE', 'RISK_LEVEL'
    ]].rename(columns={
        'GUEST_ID_HASH': 'Guest ID',
        'TIER_LEVEL': 'Tier',
        'CHECK_IN_DATE': 'Arrival Date',
        'BRAND': 'Brand',
        'CITY': 'Property',
        'PRIOR_ISSUE_COUNT': 'Past Issues',
        'PREFERENCES': 'Preference Tags',
        'LIFETIME_VALUE': 'LTV ($)',
        'CHURN_RISK_SCORE': 'Churn Risk',
        'RISK_LEVEL': 'Risk Level'
    }).sort_values('Churn Risk', ascending=False).head(20)
    
    st.caption("💡 **Past Issues**: Service cases in last 90 days (2+ needs attention) | **Preference Tags**: Known guest preferences | **Churn Risk**: Predictive score 0-100 based on history & sentiment | **Risk Level**: 🔴 High (75+), 🟡 Medium (50-74), 🟢 Low (<50)")
    
    # Display table
    st.dataframe(
        vip_table.style.format({
            'LTV ($)': '${:,.0f}',
            'Churn Risk': '{:.0f}'
        }),
        height=400
    )
    
    # Export option
    csv = vip_table.to_csv(index=False)
    st.download_button(
        label="📥 Download VIP Watchlist (CSV)",
        data=csv,
        file_name="vip_watchlist.csv",
        mime="text/csv"
    )

# =====================================================================
# Proactive Service Recommendations
# =====================================================================
st.markdown("---")
st.markdown("### 💡 Recommended Actions")

rec_col1, rec_col2 = st.columns(2)

with rec_col1:
    st.markdown("#### 🎯 Immediate Actions")
    st.markdown("""
    - **Pre-arrival contact** for all guests with churn risk >75
    - **Room assignment review** for guests with specific preferences
    - **Service team briefing** on high-LTV guests with past issues
    - **Proactive upgrades** for VIPs with multiple prior issues
    """)

with rec_col2:
    st.markdown("#### 📈 Operational Improvements")
    top_issue = issue_df.iloc[-1]['Issue'] if not issue_df.empty else 'N/A'
    worst_brand = brand_cases.iloc[0]['BRAND'] if not brand_cases.empty else 'N/A'
    
    st.markdown(f"""
    - **Root cause analysis** for top issue: _{top_issue}_
    - **Staff training focus** on {worst_brand} properties
    - **Process review** for service recovery effectiveness
    - **Guest preference capture** to increase coverage
    """)

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
    "What are the top 2 issues driving dissatisfaction for high-value guests?",
    "Which properties need attention based on service recovery performance?",
    "Summarize what's driving negative sentiment this month",
    "Show me Diamond guests arriving tomorrow with 2+ past service issues"
]

# Render the chatbot interface
render_agent_chat(
    page_context="cx_service",
    suggested_prompts=prompts,
    agent_name="Hotel Intelligence Master Agent",
    placeholder_text="Ask about service cases, sentiment, recovery actions, or guest issues..."
)
