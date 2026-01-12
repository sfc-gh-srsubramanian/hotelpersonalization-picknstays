"""
Amenity Performance Analytics Dashboard
Target Users: Operations Managers, Amenity Service Managers, F&B Directors
"""
import streamlit as st
import pandas as pd
import plotly.express as px
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), 'shared'))
from data_loader import get_amenity_analytics, get_amenity_spending, get_amenity_usage
from viz_components import (
    create_kpi_card, format_currency, format_number, format_percentage,
    create_pie_chart, create_bar_chart, create_gauge_chart, create_treemap,
    apply_custom_css
)

# Note: set_page_config() is handled by main app
apply_custom_css()

st.title("🏊 Amenity Performance Analytics")
st.markdown("**Comprehensive Service & Infrastructure Performance Metrics**")
st.markdown("---")

# Load data
amenity_df = get_amenity_analytics()
spending_df = get_amenity_spending()
usage_df = get_amenity_usage()

# Summary metrics
col1, col2, col3, col4 = st.columns(4)

total_revenue = spending_df['AMOUNT'].sum() if not spending_df.empty else 0
total_transactions = len(spending_df) if not spending_df.empty else 0
avg_transaction = spending_df['AMOUNT'].mean() if not spending_df.empty else 0
avg_satisfaction = spending_df['GUEST_SATISFACTION'].mean() if not spending_df.empty and 'GUEST_SATISFACTION' in spending_df.columns else 4.0

with col1:
    create_kpi_card("Total Revenue", format_currency(total_revenue))
with col2:
    create_kpi_card("Transactions", format_number(total_transactions))
with col3:
    create_kpi_card("Avg Transaction", format_currency(avg_transaction))
with col4:
    create_kpi_card("Avg Satisfaction", f"{avg_satisfaction:.1f}/5.0")

st.markdown("---")

# Tabs
tab1, tab2, tab3, tab4 = st.tabs([
    "💰 Revenue Analysis",
    "⭐ Satisfaction Metrics",
    "🏗️ Infrastructure Usage",
    "📊 Performance Scorecards"
])

with tab1:
    st.markdown("## 💰 Revenue Analysis")
    
    if not spending_df.empty and 'AMENITY_CATEGORY' in spending_df.columns:
        col1, col2 = st.columns(2)
        
        with col1:
            # Revenue by category
            category_revenue = spending_df.groupby('AMENITY_CATEGORY')['AMOUNT'].sum().reset_index()
            category_revenue.columns = ['Category', 'Revenue']
            category_revenue = category_revenue.sort_values('Revenue', ascending=False)
            
            fig = create_pie_chart(category_revenue, 'Revenue', 'Category',
                                  'Revenue Distribution by Amenity Category')
            st.plotly_chart(fig, use_container_width=True)
        
        with col2:
            fig = create_bar_chart(category_revenue, 'Category', 'Revenue',
                                  'Revenue by Category (Bar Chart)')
            st.plotly_chart(fig, use_container_width=True)
        
        # Transaction volume by category
        st.markdown("### Transaction Volume Analysis")
        category_volume = spending_df.groupby('AMENITY_CATEGORY').size().reset_index()
        category_volume.columns = ['Category', 'Transactions']
        category_volume = category_volume.sort_values('Transactions', ascending=False)
        
        fig = create_bar_chart(category_volume, 'Category', 'Transactions',
                              'Transaction Volume by Category')
        st.plotly_chart(fig, use_container_width=True)
        
        # Top services
        if 'AMENITY_TYPE' in spending_df.columns:
            st.markdown("### Top 10 Revenue-Generating Services")
            top_services = spending_df.groupby('AMENITY_TYPE')['AMOUNT'].sum().reset_index()
            top_services.columns = ['Service', 'Revenue']
            top_services = top_services.sort_values('Revenue', ascending=False).head(10)
            
            st.dataframe(top_services, use_container_width=True)
    else:
        st.info("Detailed amenity spending data not available")

with tab2:
    st.markdown("## ⭐ Satisfaction Metrics")
    
    if not spending_df.empty and 'GUEST_SATISFACTION' in spending_df.columns and 'AMENITY_CATEGORY' in spending_df.columns:
        # Satisfaction by category
        col1, col2 = st.columns(2)
        
        with col1:
            satisfaction_by_category = spending_df.groupby('AMENITY_CATEGORY')['GUEST_SATISFACTION'].mean().reset_index()
            satisfaction_by_category.columns = ['Category', 'Avg Satisfaction']
            satisfaction_by_category = satisfaction_by_category.sort_values('Avg Satisfaction', ascending=False)
            
            fig = create_bar_chart(satisfaction_by_category, 'Category', 'Avg Satisfaction',
                                  'Average Satisfaction by Category')
            fig.update_yaxes(range=[0, 5])
            st.plotly_chart(fig, use_container_width=True)
        
        with col2:
            # Gauge charts for top categories
            for _, row in satisfaction_by_category.head(3).iterrows():
                fig = create_gauge_chart(row['Avg Satisfaction'], row['Category'], 5)
                st.plotly_chart(fig, use_container_width=True)
        
        # Satisfaction distribution
        st.markdown("### Satisfaction Score Distribution")
        fig = px.histogram(spending_df, x='GUEST_SATISFACTION',
                          title='Distribution of Satisfaction Scores',
                          nbins=5)
        st.plotly_chart(fig, use_container_width=True)
    else:
        st.info("Satisfaction data not available")

with tab3:
    st.markdown("## 🏗️ Infrastructure Usage Analytics")
    
    if not usage_df.empty:
        col1, col2 = st.columns(2)
        
        with col1:
            if 'AMENITY_CATEGORY' in usage_df.columns:
                # Usage by category
                usage_counts = usage_df.groupby('AMENITY_CATEGORY').size().reset_index()
                usage_counts.columns = ['Category', 'Sessions']
                
                fig = create_pie_chart(usage_counts, 'Sessions', 'Category',
                                      'Infrastructure Usage Sessions by Category')
                st.plotly_chart(fig, use_container_width=True)
        
        with col2:
            if 'USAGE_DURATION_MINUTES' in usage_df.columns and 'AMENITY_CATEGORY' in usage_df.columns:
                # Average duration
                avg_duration = usage_df.groupby('AMENITY_CATEGORY')['USAGE_DURATION_MINUTES'].mean().reset_index()
                avg_duration.columns = ['Category', 'Avg Duration (min)']
                
                fig = create_bar_chart(avg_duration, 'Category', 'Avg Duration (min)',
                                      'Average Session Duration by Category')
                st.plotly_chart(fig, use_container_width=True)
        
        # Tech adoption insights
        st.markdown("### Technology Adoption Insights")
        if 'TECH_PROFILE' in usage_df.columns:
            tech_profile_counts = usage_df.groupby('TECH_PROFILE').size().reset_index()
            tech_profile_counts.columns = ['Tech Profile', 'Users']
            
            col1, col2, col3 = st.columns(3)
            for idx, row in tech_profile_counts.iterrows():
                with [col1, col2, col3][idx % 3]:
                    create_kpi_card(row['Tech Profile'], format_number(row['Users']))
    else:
        st.info("Infrastructure usage data not available")

with tab4:
    st.markdown("## 📊 Performance Scorecards")
    
    if not amenity_df.empty:
        st.markdown("### Service Performance Overview")
        
        # Display available metrics
        display_cols = [col for col in amenity_df.columns if col in [
            'AMENITY_CATEGORY', 'AMENITY_TYPE', 'TOTAL_REVENUE', 'TOTAL_TRANSACTIONS',
            'UNIQUE_GUESTS', 'AVG_TRANSACTION_VALUE', 'AVG_SATISFACTION'
        ]]
        
        if display_cols:
            st.dataframe(amenity_df[display_cols], use_container_width=True)
        else:
            st.dataframe(amenity_df, use_container_width=True)
        
        # Performance indicators
        if 'TOTAL_REVENUE' in amenity_df.columns:
            st.markdown("### Top Performers")
            top_performers = amenity_df.nlargest(5, 'TOTAL_REVENUE')
            for _, row in top_performers.iterrows():
                category = row.get('AMENITY_CATEGORY', 'Unknown')
                revenue = row.get('TOTAL_REVENUE', 0)
                st.success(f"⭐ {category}: {format_currency(revenue)}")
    else:
        st.info("Amenity analytics data not available")

st.markdown("---")
st.markdown("*Data refreshed every 5 minutes | Real-time service performance tracking*")
