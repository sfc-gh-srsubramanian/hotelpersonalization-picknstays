"""
Personalization & Upsell Hub Dashboard
Target Users: Revenue Managers, Sales Teams, Marketing Managers
"""
import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), 'shared'))
from data_loader import get_personalization_scores, get_guest_360_data
from viz_components import (
    create_kpi_card, format_currency, format_number, format_percentage,
    create_gauge_chart, create_pie_chart, create_bar_chart, create_scatter_plot,
    apply_custom_css
)

# Note: set_page_config() is handled by main app
apply_custom_css()

st.title("🚀 Personalization & Upsell Hub")
st.markdown("**Revenue Optimization Through AI-Powered Personalization**")
st.markdown("---")

# Load data
scores_df = get_personalization_scores()
guests_df = get_guest_360_data()

# Check if we have data
if scores_df.empty:
    st.error("No personalization scores data available. Please ensure the data has been generated.")
    st.stop()

# Merge for enriched analysis - scores_df already has CUSTOMER_SEGMENT, LOYALTY_TIER, TOTAL_REVENUE
# Only get CHURN_RISK from guests_df if available
if not guests_df.empty and 'CHURN_RISK' in guests_df.columns:
    merged_df = pd.merge(
        scores_df, 
        guests_df[['GUEST_ID', 'CHURN_RISK']], 
        on='GUEST_ID', 
        how='left'
    )
else:
    merged_df = scores_df.copy()

# Sidebar filters
with st.sidebar:
    st.header("🎯 Filters")
    
    score_threshold = st.slider("Min Upsell Propensity Score", 0, 100, 70)
    
    if not merged_df.empty and 'CUSTOMER_SEGMENT' in merged_df.columns:
        segment_options = sorted([x for x in merged_df['CUSTOMER_SEGMENT'].dropna().unique() if x])
        selected_segments = st.multiselect(
            "Customer Segments",
            options=segment_options,
            default=segment_options
        )
    else:
        selected_segments = []
        st.warning("No customer segment data available")
    
    if not merged_df.empty and 'LOYALTY_TIER' in merged_df.columns:
        tier_options = sorted([x for x in merged_df['LOYALTY_TIER'].dropna().unique() if x])
        selected_tiers = st.multiselect(
            "Loyalty Tiers",
            options=tier_options,
            default=tier_options
        )
    else:
        selected_tiers = []
        st.warning("No loyalty tier data available")

# Apply filters
if not merged_df.empty:
    filter_mask = pd.Series([True] * len(merged_df), index=merged_df.index)
    
    if selected_segments and 'CUSTOMER_SEGMENT' in merged_df.columns:
        filter_mask &= merged_df['CUSTOMER_SEGMENT'].isin(selected_segments)
    
    if selected_tiers and 'LOYALTY_TIER' in merged_df.columns:
        filter_mask &= merged_df['LOYALTY_TIER'].isin(selected_tiers)
    
    filtered_df = merged_df[filter_mask]
else:
    filtered_df = pd.DataFrame()

# Summary Metrics
col1, col2, col3, col4 = st.columns(4)

with col1:
    create_kpi_card("Total Guests", format_number(len(filtered_df)))
with col2:
    avg_readiness = filtered_df['PERSONALIZATION_READINESS_SCORE'].mean()
    create_kpi_card("Avg Personalization Score", f"{avg_readiness:.1f}")
with col3:
    high_spa = len(filtered_df[filtered_df['SPA_UPSELL_PROPENSITY'] > score_threshold])
    create_kpi_card("High Spa Propensity", format_number(high_spa))
with col4:
    high_churn = len(filtered_df[filtered_df['CHURN_RISK'] == 'High'])
    create_kpi_card("High Churn Risk", format_number(high_churn))

st.markdown("---")

# Tabs
tab1, tab2, tab3, tab4 = st.tabs([
    "📊 Opportunity Matrix",
    "🎯 Propensity Analysis",
    "👥 Segmentation",
    "⚠️ Churn Management"
])

with tab1:
    st.markdown("## 📊 Upsell Opportunity Matrix")
    
    # Create opportunity matrix (scatter plot)
    fig = create_scatter_plot(
        filtered_df,
        x='UPSELL_PROPENSITY_SCORE',
        y='TOTAL_REVENUE',
        size='PERSONALIZATION_READINESS_SCORE',
        color='CUSTOMER_SEGMENT',
        hover_data=['FIRST_NAME', 'LAST_NAME', 'LOYALTY_TIER'],
        title='Guest Value vs Upsell Propensity (size = personalization readiness)'
    )
    fig.add_vline(x=70, line_dash="dash", line_color="red", annotation_text="High Propensity")
    fig.add_hline(y=filtered_df['TOTAL_REVENUE'].median(), line_dash="dash", line_color="green", annotation_text="Median Value")
    st.plotly_chart(fig, use_container_width=True)
    
    # High priority targets
    st.markdown("### 🎯 Priority Targets")
    priority_guests = filtered_df[
        (filtered_df['UPSELL_PROPENSITY_SCORE'] > 70) &
        (filtered_df['TOTAL_REVENUE'] > filtered_df['TOTAL_REVENUE'].median())
    ].sort_values('UPSELL_PROPENSITY_SCORE', ascending=False)
    
    if not priority_guests.empty:
        display_cols = ['FIRST_NAME', 'LAST_NAME', 'LOYALTY_TIER', 'CUSTOMER_SEGMENT', 
                       'UPSELL_PROPENSITY_SCORE', 'TOTAL_REVENUE']
        priority_display = priority_guests[display_cols].head(20).copy()
        priority_display['TOTAL_REVENUE'] = priority_display['TOTAL_REVENUE'].apply(format_currency)
        st.dataframe(priority_display, use_container_width=True)
        
        # Download button
        csv = priority_guests.to_csv(index=False)
        st.download_button(
            label="📥 Download Target List (CSV)",
            data=csv,
            file_name="upsell_targets.csv",
            mime="text/csv"
        )
    else:
        st.info("No priority targets found with current filters")

with tab2:
    st.markdown("## 🎯 Propensity Score Analysis")
    
    # Debug info
    if filtered_df.empty:
        st.error("⚠️ No data available after filtering. Please adjust your filters.")
        st.stop()
    
    # Show data info
    st.info(f"📊 Analyzing {len(filtered_df):,} guests")
    
    col1, col2 = st.columns(2)
    
    with col1:
        # Category breakdown
        if not filtered_df.empty:
            category_scores = pd.DataFrame({
                'Category': ['Spa', 'Dining', 'Tech', 'Pool'],
                'Avg Score': [
                    filtered_df['SPA_UPSELL_PROPENSITY'].mean(),
                    filtered_df['DINING_UPSELL_PROPENSITY'].mean(),
                    filtered_df['TECH_UPSELL_PROPENSITY'].mean(),
                    filtered_df['POOL_SERVICES_UPSELL_PROPENSITY'].mean()
                ],
                'High Scorers': [
                    len(filtered_df[filtered_df['SPA_UPSELL_PROPENSITY'] > score_threshold]),
                    len(filtered_df[filtered_df['DINING_UPSELL_PROPENSITY'] > score_threshold]),
                    len(filtered_df[filtered_df['TECH_UPSELL_PROPENSITY'] > score_threshold]),
                    len(filtered_df[filtered_df['POOL_SERVICES_UPSELL_PROPENSITY'] > score_threshold])
                ]
            })
            
            fig = create_bar_chart(category_scores, 'Category', 'Avg Score', 
                                  'Average Propensity Score by Category')
            fig.update_yaxes(range=[0, 100])
            st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        if not filtered_df.empty:
            fig = create_bar_chart(category_scores, 'Category', 'High Scorers',
                                  f'Number of High-Propensity Guests (>{score_threshold})')
            st.plotly_chart(fig, use_container_width=True)
    
    # Distribution histograms
    st.markdown("### Score Distributions")
    
    if not filtered_df.empty:
        # Check if we have actual data in the columns
        has_spa_data = filtered_df['SPA_UPSELL_PROPENSITY'].notna().any()
        has_dining_data = filtered_df['DINING_UPSELL_PROPENSITY'].notna().any()
        has_tech_data = filtered_df['TECH_UPSELL_PROPENSITY'].notna().any()
        has_pool_data = filtered_df['POOL_SERVICES_UPSELL_PROPENSITY'].notna().any()
        
        if not (has_spa_data or has_dining_data or has_tech_data or has_pool_data):
            st.warning("⚠️ No propensity score data available. The scores may not have been calculated yet.")
        else:
            col1, col2 = st.columns(2)
            
            with col1:
                if has_spa_data:
                    fig = px.histogram(
                        filtered_df.dropna(subset=['SPA_UPSELL_PROPENSITY']), 
                        x='SPA_UPSELL_PROPENSITY', 
                        title='Spa Upsell Propensity Distribution',
                        nbins=20,
                        labels={'SPA_UPSELL_PROPENSITY': 'Spa Upsell Propensity Score', 'count': 'Number of Guests'}
                    )
                    fig.update_layout(showlegend=False, bargap=0.1)
                    st.plotly_chart(fig, use_container_width=True)
                else:
                    st.warning("No Spa propensity data")
            
            with col2:
                if has_dining_data:
                    fig = px.histogram(
                        filtered_df.dropna(subset=['DINING_UPSELL_PROPENSITY']), 
                        x='DINING_UPSELL_PROPENSITY',
                        title='Dining Upsell Propensity Distribution',
                        nbins=20,
                        labels={'DINING_UPSELL_PROPENSITY': 'Dining Upsell Propensity Score', 'count': 'Number of Guests'}
                    )
                    fig.update_layout(showlegend=False, bargap=0.1)
                    st.plotly_chart(fig, use_container_width=True)
                else:
                    st.warning("No Dining propensity data")
            
            # Additional distributions
            col3, col4 = st.columns(2)
            
            with col3:
                if has_tech_data:
                    fig = px.histogram(
                        filtered_df.dropna(subset=['TECH_UPSELL_PROPENSITY']), 
                        x='TECH_UPSELL_PROPENSITY',
                        title='Tech Upsell Propensity Distribution',
                        nbins=20,
                        labels={'TECH_UPSELL_PROPENSITY': 'Tech Upsell Propensity Score', 'count': 'Number of Guests'}
                    )
                    fig.update_layout(showlegend=False, bargap=0.1)
                    st.plotly_chart(fig, use_container_width=True)
                else:
                    st.warning("No Tech propensity data")
            
            with col4:
                if has_pool_data:
                    fig = px.histogram(
                        filtered_df.dropna(subset=['POOL_SERVICES_UPSELL_PROPENSITY']), 
                        x='POOL_SERVICES_UPSELL_PROPENSITY',
                        title='Pool Services Upsell Propensity Distribution',
                        nbins=20,
                        labels={'POOL_SERVICES_UPSELL_PROPENSITY': 'Pool Services Upsell Propensity Score', 'count': 'Number of Guests'}
                    )
                    fig.update_layout(showlegend=False, bargap=0.1)
                    st.plotly_chart(fig, use_container_width=True)
                else:
                    st.warning("No Pool Services propensity data")
    else:
        st.warning("No data available for score distributions. Please adjust your filters.")

with tab3:
    st.markdown("## 👥 Customer Segmentation Analysis")
    
    # Segment distribution
    col1, col2 = st.columns(2)
    
    with col1:
        segment_counts = filtered_df['CUSTOMER_SEGMENT'].value_counts().reset_index()
        segment_counts.columns = ['Segment', 'Count']
        
        fig = create_pie_chart(segment_counts, 'Count', 'Segment',
                              'Guest Distribution by Segment')
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        # Revenue by segment
        segment_revenue = filtered_df.groupby('CUSTOMER_SEGMENT')['TOTAL_REVENUE'].sum().reset_index()
        segment_revenue.columns = ['Segment', 'Revenue']
        
        fig = create_bar_chart(segment_revenue, 'Segment', 'Revenue',
                              'Total Revenue by Segment')
        st.plotly_chart(fig, use_container_width=True)
    
    # Segment performance table
    st.markdown("### Segment Performance Metrics")
    segment_metrics = filtered_df.groupby('CUSTOMER_SEGMENT').agg({
        'GUEST_ID': 'count',
        'TOTAL_REVENUE': 'sum',
        'UPSELL_PROPENSITY_SCORE': 'mean',
        'PERSONALIZATION_READINESS_SCORE': 'mean',
        'LOYALTY_PROPENSITY_SCORE': 'mean'
    }).round(2)
    segment_metrics.columns = ['Guest Count', 'Total Revenue', 'Avg Upsell Score', 'Avg Personalization', 'Avg Loyalty']
    segment_metrics_display = segment_metrics.copy()
    segment_metrics_display['Total Revenue'] = segment_metrics_display['Total Revenue'].apply(format_currency)
    segment_metrics_display['Guest Count'] = segment_metrics_display['Guest Count'].apply(format_number)
    st.dataframe(segment_metrics_display, use_container_width=True)

with tab4:
    st.markdown("## ⚠️ Churn Risk Management")
    
    # Churn distribution
    col1, col2 = st.columns(2)
    
    with col1:
        churn_counts = filtered_df['CHURN_RISK'].value_counts().reset_index()
        churn_counts.columns = ['Risk Level', 'Count']
        
        fig = create_pie_chart(churn_counts, 'Count', 'Risk Level',
                              'Churn Risk Distribution')
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        # Revenue at risk
        revenue_at_risk = filtered_df.groupby('CHURN_RISK')['TOTAL_REVENUE'].sum().reset_index()
        revenue_at_risk.columns = ['Risk Level', 'Revenue']
        
        fig = create_bar_chart(revenue_at_risk, 'Risk Level', 'Revenue',
                              'Revenue at Risk by Churn Level')
        st.plotly_chart(fig, use_container_width=True)
    
    # High risk guests
    st.markdown("### 🚨 High Risk Guests - Immediate Action Required")
    high_risk = filtered_df[filtered_df['CHURN_RISK'] == 'High'].sort_values('TOTAL_REVENUE', ascending=False)
    
    if not high_risk.empty:
        display_cols = ['FIRST_NAME', 'LAST_NAME', 'LOYALTY_TIER', 'TOTAL_REVENUE',
                       'PERSONALIZATION_READINESS_SCORE', 'LOYALTY_PROPENSITY_SCORE']
        high_risk_display = high_risk[display_cols].head(20).copy()
        high_risk_display['TOTAL_REVENUE'] = high_risk_display['TOTAL_REVENUE'].apply(format_currency)
        st.dataframe(high_risk_display, use_container_width=True)
        
        # Download
        csv = high_risk.to_csv(index=False)
        st.download_button(
            label="📥 Download High Risk List (CSV)",
            data=csv,
            file_name="high_risk_guests.csv",
            mime="text/csv"
        )
        
        st.markdown("### Recommended Actions")
        st.success("🎁 Offer exclusive loyalty rewards")
        st.success("📞 Proactive outreach from guest relations")
        st.success("💰 Personalized discount offers")
        st.success("⭐ Tier upgrade consideration")
    else:
        st.info("No high-risk guests in current filters")

st.markdown("---")
st.markdown("*Data refreshed every 5 minutes | AI-powered propensity scoring*")
