"""
Executive Overview Dashboard
Target Users: C-Suite Executives, Board Members, Property Owners
"""
import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), 'shared'))
from data_loader import (
    get_guest_360_data, get_summary_metrics, get_personalization_scores,
    get_amenity_analytics
)
from viz_components import (
    create_kpi_card, format_currency, format_number, format_percentage,
    create_gauge_chart, create_pie_chart, create_bar_chart, create_line_chart,
    apply_custom_css
)

st.set_page_config(page_title="Executive Overview", page_icon="📊", layout="wide")
apply_custom_css()

st.title("📊 Executive Overview Dashboard")
st.markdown("**Strategic Business Intelligence & KPIs**")
st.markdown("---")

# Load data
guests_df = get_guest_360_data()
scores_df = get_personalization_scores()
metrics = get_summary_metrics()

# Business Health Scorecard
st.markdown("## 🎯 Business Health Scorecard")

col1, col2, col3, col4, col5, col6 = st.columns(6)

with col1:
    total_guests = len(guests_df) if not guests_df.empty else 0
    create_kpi_card("Total Guests", format_number(total_guests))

with col2:
    total_revenue = guests_df['TOTAL_REVENUE'].sum() if not guests_df.empty else 0
    create_kpi_card("Total Revenue", format_currency(total_revenue))

with col3:
    avg_satisfaction = guests_df['AVG_SATISFACTION_SCORE'].mean() if not guests_df.empty else 0
    create_kpi_card("Avg Satisfaction", f"{avg_satisfaction:.2f}/5.0")

with col4:
    if not guests_df.empty and 'LOYALTY_TIER' in guests_df.columns:
        loyalty_enrolled = len(guests_df[guests_df['LOYALTY_TIER'].notna()])
        loyalty_rate = (loyalty_enrolled / total_guests * 100) if total_guests > 0 else 0
        create_kpi_card("Loyalty Rate", format_percentage(loyalty_rate))
    else:
        create_kpi_card("Loyalty Rate", "N/A")

with col5:
    if not guests_df.empty and 'TOTAL_BOOKINGS' in guests_df.columns:
        repeat_guests = len(guests_df[guests_df['TOTAL_BOOKINGS'] > 1])
        repeat_rate = (repeat_guests / total_guests * 100) if total_guests > 0 else 0
        create_kpi_card("Repeat Rate", format_percentage(repeat_rate))
    else:
        create_kpi_card("Repeat Rate", "N/A")

with col6:
    if not guests_df.empty and 'CHURN_RISK' in guests_df.columns:
        high_churn = len(guests_df[guests_df['CHURN_RISK'] == 'High'])
        churn_rate = (high_churn / total_guests * 100) if total_guests > 0 else 0
        create_kpi_card("High Churn Risk", format_percentage(churn_rate))
    else:
        create_kpi_card("Churn Rate", "N/A")

st.markdown("---")

# Main content in tabs
tab1, tab2, tab3, tab4 = st.tabs([
    "💼 Strategic Metrics",
    "👥 Segment Performance",
    "🚀 AI Insights",
    "🏆 Top Performers"
])

with tab1:
    st.markdown("## 💼 Strategic Business Metrics")
    
    col1, col2 = st.columns(2)
    
    with col1:
        # Customer lifetime value metrics
        st.markdown("### Customer Value Metrics")
        
        if not guests_df.empty:
            avg_ltv = guests_df['TOTAL_REVENUE'].mean()
            median_ltv = guests_df['TOTAL_REVENUE'].median()
            max_ltv = guests_df['TOTAL_REVENUE'].max()
            
            create_kpi_card("Avg Lifetime Value", format_currency(avg_ltv))
            create_kpi_card("Median Lifetime Value", format_currency(median_ltv))
            create_kpi_card("Highest Lifetime Value", format_currency(max_ltv))
            
            # LTV distribution
            fig = px.histogram(guests_df, x='TOTAL_REVENUE',
                              title='Customer Lifetime Value Distribution',
                              nbins=30)
            st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        # Booking and revenue metrics
        st.markdown("### Revenue & Engagement Metrics")
        
        if not guests_df.empty:
            avg_bookings = guests_df['TOTAL_BOOKINGS'].mean()
            total_bookings = guests_df['TOTAL_BOOKINGS'].sum()
            revenue_per_booking = (total_revenue / total_bookings) if total_bookings > 0 else 0
            
            create_kpi_card("Avg Bookings/Guest", f"{avg_bookings:.1f}")
            create_kpi_card("Total Bookings", format_number(total_bookings))
            create_kpi_card("Revenue/Booking", format_currency(revenue_per_booking))
            
            # Satisfaction gauge
            fig = create_gauge_chart(avg_satisfaction, "Overall Guest Satisfaction", 5)
            st.plotly_chart(fig, use_container_width=True)

with tab2:
    st.markdown("## 👥 Customer Segment Performance")
    
    if not guests_df.empty and 'CUSTOMER_SEGMENT' in guests_df.columns:
        col1, col2 = st.columns(2)
        
        with col1:
            # Segment distribution
            segment_counts = guests_df['CUSTOMER_SEGMENT'].value_counts().reset_index()
            segment_counts.columns = ['Segment', 'Count']
            
            fig = create_pie_chart(segment_counts, 'Count', 'Segment',
                                  'Guest Distribution by Segment')
            st.plotly_chart(fig, use_container_width=True)
        
        with col2:
            # Revenue by segment
            segment_revenue = guests_df.groupby('CUSTOMER_SEGMENT')['TOTAL_REVENUE'].sum().reset_index()
            segment_revenue.columns = ['Segment', 'Revenue']
            segment_revenue = segment_revenue.sort_values('Revenue', ascending=False)
            
            fig = create_bar_chart(segment_revenue, 'Segment', 'Revenue',
                                  'Revenue Contribution by Segment')
            st.plotly_chart(fig, use_container_width=True)
        
        # Segment performance matrix
        st.markdown("### Segment Performance Matrix")
        segment_matrix = guests_df.groupby('CUSTOMER_SEGMENT').agg({
            'GUEST_ID': 'count',
            'TOTAL_REVENUE': ['sum', 'mean'],
            'TOTAL_BOOKINGS': 'mean',
            'AVG_SATISFACTION_SCORE': 'mean',
            'LOYALTY_POINTS': 'mean'
        }).round(2)
        segment_matrix.columns = ['Guest Count', 'Total Revenue', 'Avg Revenue', 'Avg Bookings', 'Avg Satisfaction', 'Avg Loyalty Points']
        st.dataframe(segment_matrix, use_container_width=True)
        
        # Loyalty tier distribution
        if 'LOYALTY_TIER' in guests_df.columns:
            st.markdown("### Loyalty Program Performance")
            tier_counts = guests_df['LOYALTY_TIER'].value_counts().reset_index()
            tier_counts.columns = ['Tier', 'Count']
            
            fig = create_bar_chart(tier_counts, 'Tier', 'Count',
                                  'Guest Distribution by Loyalty Tier')
            st.plotly_chart(fig, use_container_width=True)

with tab3:
    st.markdown("## 🚀 AI-Powered Business Insights")
    
    if not scores_df.empty:
        col1, col2 = st.columns(2)
        
        with col1:
            # Personalization readiness
            st.markdown("### Personalization Readiness")
            avg_readiness = scores_df['PERSONALIZATION_READINESS_SCORE'].mean()
            
            fig = create_gauge_chart(avg_readiness, "Avg Personalization Readiness", 100)
            st.plotly_chart(fig, use_container_width=True)
            
            # High potential guests
            high_potential = len(scores_df[
                (scores_df['PERSONALIZATION_READINESS_SCORE'] > 70) &
                (scores_df['UPSELL_PROPENSITY_SCORE'] > 70)
            ])
            create_kpi_card("High-Potential Guests", format_number(high_potential))
        
        with col2:
            # Upsell opportunities
            st.markdown("### Upsell Opportunity Analysis")
            
            upsell_metrics = pd.DataFrame({
                'Category': ['Spa', 'Dining', 'Tech', 'Pool'],
                'Avg Propensity': [
                    scores_df['SPA_UPSELL_PROPENSITY'].mean(),
                    scores_df['DINING_UPSELL_PROPENSITY'].mean(),
                    scores_df['TECH_UPSELL_PROPENSITY'].mean(),
                    scores_df['POOL_SERVICES_UPSELL_PROPENSITY'].mean()
                ],
                'High Scorers (>70)': [
                    len(scores_df[scores_df['SPA_UPSELL_PROPENSITY'] > 70]),
                    len(scores_df[scores_df['DINING_UPSELL_PROPENSITY'] > 70]),
                    len(scores_df[scores_df['TECH_UPSELL_PROPENSITY'] > 70]),
                    len(scores_df[scores_df['POOL_SERVICES_UPSELL_PROPENSITY'] > 70])
                ]
            })
            
            fig = create_bar_chart(upsell_metrics, 'Category', 'High Scorers (>70)',
                                  'Upsell Opportunity Count by Category')
            st.plotly_chart(fig, use_container_width=True)
        
        # Key recommendations
        st.markdown("### 🎯 Strategic Recommendations")
        
        # Generate recommendations based on data
        recommendations = []
        
        if not guests_df.empty:
            high_churn_pct = (len(guests_df[guests_df['CHURN_RISK'] == 'High']) / len(guests_df) * 100)
            if high_churn_pct > 20:
                recommendations.append(f"⚠️ **ALERT**: {high_churn_pct:.1f}% of guests at high churn risk - implement retention program")
        
        if not scores_df.empty:
            avg_spa_score = scores_df['SPA_UPSELL_PROPENSITY'].mean()
            if avg_spa_score > 65:
                recommendations.append(f"💆 **SPA OPPORTUNITY**: High spa interest (avg score {avg_spa_score:.1f}) - expand spa offerings")
            
            avg_loyalty = scores_df['LOYALTY_PROPENSITY_SCORE'].mean()
            if avg_loyalty > 70:
                recommendations.append(f"⭐ **LOYALTY**: Strong loyalty propensity ({avg_loyalty:.1f}) - enhance loyalty program benefits")
        
        if not guests_df.empty:
            low_satisfaction = len(guests_df[guests_df['AVG_SATISFACTION_SCORE'] < 3])
            if low_satisfaction > 0:
                recommendations.append(f"📉 **SATISFACTION**: {low_satisfaction} guests with low satisfaction - immediate follow-up needed")
        
        if recommendations:
            for rec in recommendations:
                st.warning(rec)
        else:
            st.success("✅ Business metrics are healthy - continue current strategies")

with tab4:
    st.markdown("## 🏆 Top Performers & Recognition")
    
    if not guests_df.empty:
        col1, col2 = st.columns(2)
        
        with col1:
            # Top revenue guests
            st.markdown("### 🥇 Top 10 Revenue-Generating Guests")
            top_revenue = guests_df.nlargest(10, 'TOTAL_REVENUE')[[
                'FIRST_NAME', 'LAST_NAME', 'LOYALTY_TIER', 'TOTAL_REVENUE', 'TOTAL_BOOKINGS'
            ]]
            st.dataframe(top_revenue, use_container_width=True)
        
        with col2:
            # Most loyal guests (by bookings)
            st.markdown("### ⭐ Most Loyal Guests (By Bookings)")
            if 'TOTAL_BOOKINGS' in guests_df.columns:
                top_loyal = guests_df.nlargest(10, 'TOTAL_BOOKINGS')[[
                    'FIRST_NAME', 'LAST_NAME', 'LOYALTY_TIER', 'TOTAL_BOOKINGS', 'TOTAL_REVENUE'
                ]]
                st.dataframe(top_loyal, use_container_width=True)
        
        # VIP guests summary
        st.markdown("### 💎 VIP Guest Summary")
        if 'CUSTOMER_SEGMENT' in guests_df.columns:
            vip_guests = guests_df[guests_df['CUSTOMER_SEGMENT'] == 'VIP']
            if not vip_guests.empty:
                col_a, col_b, col_c, col_d = st.columns(4)
                
                with col_a:
                    create_kpi_card("VIP Count", format_number(len(vip_guests)))
                with col_b:
                    vip_revenue = vip_guests['TOTAL_REVENUE'].sum()
                    create_kpi_card("VIP Revenue", format_currency(vip_revenue))
                with col_c:
                    vip_pct = (vip_revenue / total_revenue * 100) if total_revenue > 0 else 0
                    create_kpi_card("VIP % of Revenue", format_percentage(vip_pct))
                with col_d:
                    vip_avg = vip_guests['TOTAL_REVENUE'].mean()
                    create_kpi_card("Avg VIP Value", format_currency(vip_avg))

# Footer
st.markdown("---")
st.markdown("*Executive Dashboard | Auto-refresh enabled | Data updated every 5 minutes*")
st.markdown("*Powered by Snowflake Cortex Intelligence | AI-Driven Insights*")
