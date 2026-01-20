"""
Tab 1: Portfolio Overview - Executive Command Center
Regional and brand-level performance metrics
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import sys
sys.path.append('../shared')

from shared.data_loader_intel import (
    load_portfolio_kpis,
    get_available_regions,
    get_available_brands
)
from shared.viz_components_intel import create_kpi_card, create_bar_chart, create_line_chart, create_heatmap
from shared.formatters import format_currency, format_percent, format_number

st.title("📈 Portfolio Overview")
st.markdown("Executive command center for regional and brand-level performance")

# =====================================================================
# Filters
# =====================================================================
st.markdown("### 🔍 Filters")
col1, col2, col3 = st.columns(3)

with col1:
    regions = ['All'] + get_available_regions()
    selected_region = st.selectbox("Region", regions)

with col2:
    brands = ['All'] + get_available_brands()
    selected_brand = st.selectbox("Brand", brands)

with col3:
    days_back = st.slider("Days of History", min_value=7, max_value=90, value=30)

# Apply filters
region_filter = None if selected_region == 'All' else selected_region
brand_filter = None if selected_brand == 'All' else selected_brand

# Load data
df_kpis = load_portfolio_kpis(days_back=days_back, region=region_filter, brand=brand_filter)

if df_kpis.empty:
    st.warning("No data available for selected filters. Please adjust your selection.")
    st.stop()

# =====================================================================
# KPI Cards
# =====================================================================
st.markdown("---")
st.markdown("### 📊 Key Performance Indicators")
st.caption("📈 Trend arrows compare the recent half vs. first half of the selected time period (e.g., for 30 days: recent 15 days vs. prior 15 days)")

# Calculate aggregate KPIs
# Split data into recent (last 50%) and prior (first 50%) periods for trend comparison
total_days = (df_kpis['PERFORMANCE_DATE'].max() - df_kpis['PERFORMANCE_DATE'].min()).days
midpoint_date = df_kpis['PERFORMANCE_DATE'].min() + pd.Timedelta(days=total_days // 2)

latest_kpis = df_kpis[df_kpis['PERFORMANCE_DATE'] >= midpoint_date]
prior_kpis = df_kpis[df_kpis['PERFORMANCE_DATE'] < midpoint_date]

# Calculate portfolio-level metrics using pre-calculated daily values
# These are already correctly calculated in the Gold table, we just need to average them

# Latest period metrics (average of daily hotel-level metrics)
avg_occupancy = latest_kpis['OCCUPANCY_PCT'].mean()
avg_adr = latest_kpis['ADR'].mean()
avg_revpar = latest_kpis['REVPAR'].mean()
avg_repeat_rate = latest_kpis['REPEAT_STAY_RATE_PCT'].mean()
avg_satisfaction = latest_kpis['SATISFACTION_INDEX'].mean()

# Prior period metrics for deltas (average of daily hotel-level metrics)
if not prior_kpis.empty:
    prior_occupancy = prior_kpis['OCCUPANCY_PCT'].mean()
    prior_adr = prior_kpis['ADR'].mean()
    prior_revpar = prior_kpis['REVPAR'].mean()
    prior_satisfaction = prior_kpis['SATISFACTION_INDEX'].mean()
else:
    prior_occupancy = avg_occupancy
    prior_adr = avg_adr
    prior_revpar = avg_revpar
    prior_satisfaction = avg_satisfaction

delta_occupancy = ((avg_occupancy - prior_occupancy) / prior_occupancy * 100) if prior_occupancy > 0 else 0
delta_adr = ((avg_adr - prior_adr) / prior_adr * 100) if prior_adr > 0 else 0
delta_revpar = ((avg_revpar - prior_revpar) / prior_revpar * 100) if prior_revpar > 0 else 0
delta_satisfaction = ((avg_satisfaction - prior_satisfaction) / prior_satisfaction * 100) if prior_satisfaction > 0 else 0

col1, col2, col3, col4, col5 = st.columns(5)

with col1:
    st.metric(
        "Occupancy %", 
        f"{avg_occupancy:.1f}%", 
        f"{delta_occupancy:+.1f}%",
        help="Percentage of available rooms occupied. Calculated as: (Total Occupied Rooms / Total Available Rooms) × 100. Industry benchmark: 65-75%"
    )

with col2:
    st.metric(
        "ADR", 
        f"${avg_adr:.0f}",
        f"{delta_adr:+.1f}%",
        help="Average Daily Rate - Average revenue per occupied room per day. Higher ADR indicates premium positioning."
    )

with col3:
    st.metric(
        "RevPAR", 
        f"${avg_revpar:.0f}", 
        f"{delta_revpar:+.1f}%",
        help="Revenue Per Available Room - Key performance metric combining occupancy and pricing. Calculated as: ADR × Occupancy Rate. Primary metric for hotel performance."
    )

with col4:
    st.metric(
        "Repeat Stay Rate %", 
        f"{avg_repeat_rate:.1f}%",
        help="Percentage of guests who have stayed more than once. Higher rates indicate strong loyalty."
    )

with col5:
    st.metric(
        "Guest Satisfaction", 
        f"{avg_satisfaction:.1f}/100", 
        f"{delta_satisfaction:+.1f}%",
        help="Average guest satisfaction score (70-100 scale). Based on post-stay surveys and feedback. Target: 85+"
    )

# =====================================================================
# Charts
# =====================================================================
st.markdown("---")
st.markdown("### 📊 Performance Analysis")

chart_col1, chart_col2 = st.columns(2)

with chart_col1:
    # RevPAR by Brand - use pre-calculated daily RevPAR values from FULL dataset
    st.markdown("#### RevPAR by Brand")
    brand_metrics = df_kpis.groupby('BRAND').agg({
        'REVPAR': 'mean',
        'OCCUPANCY_PCT': 'mean',
        'ADR': 'mean'
    }).reset_index()
    brand_metrics = brand_metrics.sort_values('REVPAR', ascending=False)
    brand_metrics['REVPAR_DISPLAY'] = brand_metrics['REVPAR'].apply(lambda x: f"${x:.0f}")
    
    # Use native Streamlit bar chart
    chart_data = brand_metrics.set_index('BRAND')['REVPAR']
    st.bar_chart(chart_data, height=400)
    
    # Show values in a clean table below
    display_df = brand_metrics[['BRAND', 'REVPAR', 'OCCUPANCY_PCT', 'ADR']].copy()
    display_df.columns = ['Brand', 'RevPAR ($)', 'Occupancy (%)', 'ADR ($)']
    display_df['RevPAR ($)'] = display_df['RevPAR ($)'].apply(lambda x: f"${x:.2f}")
    display_df['Occupancy (%)'] = display_df['Occupancy (%)'].apply(lambda x: f"{x:.1f}%")
    display_df['ADR ($)'] = display_df['ADR ($)'].apply(lambda x: f"${x:.2f}")
    st.dataframe(display_df, use_container_width=True)

with chart_col2:
    # RevPAR by Region - use pre-calculated daily RevPAR values from FULL dataset
    st.markdown("#### RevPAR by Region")
    region_metrics = df_kpis.groupby('REGION').agg({
        'REVPAR': 'mean',
        'OCCUPANCY_PCT': 'mean',
        'ADR': 'mean'
    }).reset_index()
    region_metrics = region_metrics.sort_values('REVPAR', ascending=False)
    
    # Use native Streamlit bar chart
    chart_data = region_metrics.set_index('REGION')['REVPAR']
    st.bar_chart(chart_data, height=400)
    
    # Show values in a clean table below
    display_df = region_metrics[['REGION', 'REVPAR', 'OCCUPANCY_PCT', 'ADR']].copy()
    display_df.columns = ['Region', 'RevPAR ($)', 'Occupancy (%)', 'ADR ($)']
    display_df['RevPAR ($)'] = display_df['RevPAR ($)'].apply(lambda x: f"${x:.2f}")
    display_df['Occupancy (%)'] = display_df['Occupancy (%)'].apply(lambda x: f"{x:.1f}%")
    display_df['ADR ($)'] = display_df['ADR ($)'].apply(lambda x: f"${x:.2f}")
    st.dataframe(display_df, use_container_width=True)

# Occupancy & ADR Trend
st.markdown("#### Occupancy & ADR Trend Over Time")
daily_trend = df_kpis.groupby('PERFORMANCE_DATE').agg({
    'OCCUPANCY_PCT': 'mean',
    'ADR': 'mean'
}).reset_index().sort_values('PERFORMANCE_DATE')

fig3 = go.Figure()
fig3.add_trace(go.Scatter(
    x=daily_trend['PERFORMANCE_DATE'],
    y=daily_trend['OCCUPANCY_PCT'],
    mode='lines+markers',
    name='Occupancy %',
    yaxis='y1',
    line=dict(color='#4A90E2', width=2),  # Blue line
    marker=dict(size=4)
))
fig3.add_trace(go.Scatter(
    x=daily_trend['PERFORMANCE_DATE'],
    y=daily_trend['ADR'],
    mode='lines+markers',
    name='ADR ($)',
    yaxis='y2',
    line=dict(color='#E24A4A', width=2),  # Red line
    marker=dict(size=4)
))
fig3.update_layout(
    height=350,
    yaxis=dict(title='Occupancy %', side='left', range=[0, 100], tickformat='.1f'),
    yaxis2=dict(title='ADR ($)', overlaying='y', side='right', tickformat='$,.0f'),
    template='plotly_white',
    hovermode='x unified'
)
st.plotly_chart(fig3, use_container_width=True)

# Experience Health Heatmap
st.markdown("#### Experience Health by Region (Satisfaction Index)")
heatmap_data = df_kpis.pivot_table(
    values='SATISFACTION_INDEX',
    index='BRAND',
    columns='REGION',
    aggfunc='mean'
)

# Display as a formatted table (simpler and guaranteed to work)
if heatmap_data.empty:
    st.warning("No satisfaction data available")
else:
    # Format values for display
    heatmap_display = heatmap_data.copy()
    for col in heatmap_display.columns:
        heatmap_display[col] = heatmap_display[col].apply(lambda x: f"{x:.1f}" if pd.notna(x) else "—")
    st.dataframe(heatmap_display, use_container_width=True)

# =====================================================================
# Outliers & Exceptions Table
# =====================================================================
st.markdown("---")
st.markdown("### ⚠️ Outliers & Exceptions")
st.caption("Properties requiring attention based on performance deviations")
st.caption("**Color Guide:** 🟢 Green = Strong | 🔵 Blue = Good | 🟡 Yellow = Watch | 🟠 Orange = Concern | 🔴 Red = Critical")
st.caption("**Guest Knowledge (%)** = Percentage of guests with personalization data (preferences, history, profile completeness) - Higher is better for targeted service")

# Calculate property-level metrics and deviations using full dataset
property_metrics = df_kpis.copy()
property_metrics['revpar_delta_pct'] = ((property_metrics['REVPAR'] - property_metrics.groupby('BRAND')['REVPAR'].transform('mean')) / property_metrics.groupby('BRAND')['REVPAR'].transform('mean') * 100)
property_metrics['satisfaction_delta'] = property_metrics['SATISFACTION_INDEX'] - property_metrics.groupby('REGION')['SATISFACTION_INDEX'].transform('mean')

# Flag outliers
outliers = property_metrics[
    (abs(property_metrics['revpar_delta_pct']) > 15) |
    (abs(property_metrics['satisfaction_delta']) > 0.3) |
    (property_metrics['SERVICE_CASE_RATE_PER_1000_STAYS'] > 100)
].copy()

if not outliers.empty:
    # Use Hotel Name (Brand + Region) instead of IDs
    outliers['Hotel'] = outliers['BRAND'] + ' - ' + outliers['REGION']
    outliers_display = outliers[[
        'Hotel', 'BRAND', 'REGION', 'revpar_delta_pct', 'satisfaction_delta',
        'SERVICE_CASE_RATE_PER_1000_STAYS', 'PERSONALIZATION_COVERAGE_PCT'
    ]].rename(columns={
        'revpar_delta_pct': 'RevPAR Δ vs Brand (%)',
        'satisfaction_delta': 'Satisfaction Δ vs Region',
        'SERVICE_CASE_RATE_PER_1000_STAYS': 'Service Case Rate',
        'PERSONALIZATION_COVERAGE_PCT': 'Guest Knowledge (%)'
    }).sort_values('RevPAR Δ vs Brand (%)', ascending=False).reset_index(drop=True)
    
    # Color coding function for performance metrics
    def color_performance(val, col_name):
        """Apply color based on performance - green for good, red for bad"""
        # Return empty string for non-numeric columns
        if col_name not in ['RevPAR Δ vs Brand (%)', 'Satisfaction Δ vs Region', 'Service Case Rate', 'Guest Knowledge (%)']:
            return ''
        
        # Check for NaN or None
        if pd.isna(val):
            return ''
        
        try:
            # Convert to float (should already be numeric from apply before format)
            val = float(val)
        except:
            return ''
        
        if col_name == 'RevPAR Δ vs Brand (%)':
            # GREEN = Above brand average (positive), RED = Below brand average (negative)
            if val >= 15:
                return 'background-color: #d4edda; color: #155724'  # Strong green
            elif val >= 5:
                return 'background-color: #d1ecf1; color: #0c5460'  # Light blue/green
            elif val >= -5:
                return 'background-color: #fff3cd; color: #856404'  # Yellow (near average)
            elif val >= -15:
                return 'background-color: #ffe5d0; color: #8b4513'  # Light orange
            else:
                return 'background-color: #f8d7da; color: #721c24'  # Red (significantly below)
        
        elif col_name == 'Satisfaction Δ vs Region':
            # GREEN = Above region average (positive), RED = Below region average (negative)
            if val >= 1.0:
                return 'background-color: #d4edda; color: #155724'  # Strong green
            elif val >= 0.1:
                return 'background-color: #d1ecf1; color: #0c5460'  # Light blue/green
            elif val >= -0.1:
                return 'background-color: #fff3cd; color: #856404'  # Yellow (near average)
            elif val >= -1.0:
                return 'background-color: #ffe5d0; color: #8b4513'  # Light orange
            else:
                return 'background-color: #f8d7da; color: #721c24'  # Red (significantly below)
        
        elif col_name == 'Service Case Rate':
            # GREEN = Low service cases (good), RED = High service cases (bad)
            # 0 cases = excellent (green), high cases = problems (red)
            if val <= 20:
                return 'background-color: #d4edda; color: #155724'  # Green (low/no issues)
            elif val <= 50:
                return 'background-color: #d1ecf1; color: #0c5460'  # Light blue (acceptable)
            elif val <= 100:
                return 'background-color: #fff3cd; color: #856404'  # Yellow (watch)
            elif val <= 150:
                return 'background-color: #ffe5d0; color: #8b4513'  # Orange (concerning)
            else:
                return 'background-color: #f8d7da; color: #721c24'  # Red (critical)
        
        elif col_name == 'Guest Knowledge (%)':
            # GREEN = High personalization coverage (good), RED = Low coverage (bad)
            # High % = we know guests well, Low % = need more data
            if val >= 60:
                return 'background-color: #d4edda; color: #155724'  # Green (excellent coverage)
            elif val >= 40:
                return 'background-color: #d1ecf1; color: #0c5460'  # Light blue (good)
            elif val >= 25:
                return 'background-color: #fff3cd; color: #856404'  # Yellow (moderate)
            elif val >= 15:
                return 'background-color: #ffe5d0; color: #8b4513'  # Orange (low)
            else:
                return 'background-color: #f8d7da; color: #721c24'  # Red (very low)
        
        return ''
    
    # Apply styling with color coding using apply (column-wise)
    # Note: apply() runs BEFORE format(), so we get raw numeric values
    def apply_colors(row):
        styles = [''] * len(row)
        for idx, col_name in enumerate(outliers_display.columns):
            if col_name in ['RevPAR Δ vs Brand (%)', 'Satisfaction Δ vs Region', 'Service Case Rate', 'Guest Knowledge (%)']:
                styles[idx] = color_performance(row[col_name], col_name)
        return styles
    
    styled_df = outliers_display.style.apply(apply_colors, axis=1).format({
        'RevPAR Δ vs Brand (%)': '{:+.1f}%',
        'Satisfaction Δ vs Region': '{:+.2f}',
        'Service Case Rate': '{:.1f}',
        'Guest Knowledge (%)': '{:.1f}%'
    }).hide(axis='index')
    
    # Add CSV download button
    csv_data = outliers_display.to_csv(index=False)
    st.download_button(
        label="📥 Download to CSV",
        data=csv_data,
        file_name="outliers_exceptions.csv",
        mime="text/csv",
        key="download_outliers_csv"
    )
    
    st.dataframe(styled_df, height=300, use_container_width=True)
else:
    st.info("No significant outliers detected in current period. All properties performing within normal range.")

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
    "What's driving RevPAR changes across brands this month?",
    "Which regions improved guest satisfaction—and why?",
    "Call out the top 3 operational issues impacting loyalty",
    "Do brands with higher guest-knowledge coverage perform better?"
]

# Render the chatbot interface
render_agent_chat(
    page_context="portfolio",
    suggested_prompts=prompts,
    agent_name="Hotel Intelligence Master Agent",
    placeholder_text="Ask about portfolio performance, RevPAR, occupancy, or guest satisfaction..."
)
