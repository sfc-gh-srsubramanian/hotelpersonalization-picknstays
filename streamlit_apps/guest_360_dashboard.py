"""
Guest 360 Dashboard - Comprehensive Guest Profile and Journey Visualization
Target Users: Guest Service Managers, Concierge Teams, Front Desk Staff
"""
import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta
import sys
import os

# Add shared modules to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'shared'))
from data_loader import (
    get_guest_360_data, get_guest_by_id, search_guests,
    get_amenity_spending, get_amenity_usage, get_stays_processed
)
from viz_components import (
    create_kpi_card, format_currency, format_number, format_percentage,
    create_gauge_chart, create_pie_chart, create_bar_chart, create_line_chart,
    display_risk_badge, display_loyalty_badge, apply_custom_css
)

# Note: set_page_config() is handled by main app
# Apply custom styling
apply_custom_css()

# Header
st.title("🎯 Guest 360 Dashboard")
st.markdown("**Comprehensive Guest Profile & Journey Visualization**")
st.markdown("---")

# Sidebar - Guest Search
with st.sidebar:
    st.header("🔍 Guest Search")
    search_term = st.text_input("Search by name or email", "")
    
    if search_term:
        search_results = search_guests(search_term)
        if not search_results.empty:
            st.write(f"Found {len(search_results)} guests")
            selected_guest = st.selectbox(
                "Select Guest",
                options=search_results['GUEST_ID'].tolist(),
                format_func=lambda x: f"{search_results[search_results['GUEST_ID']==x]['FIRST_NAME'].iloc[0]} {search_results[search_results['GUEST_ID']==x]['LAST_NAME'].iloc[0]} ({search_results[search_results['GUEST_ID']==x]['LOYALTY_TIER'].iloc[0]})"
            )
        else:
            st.warning("No guests found")
            selected_guest = None
    else:
        # Default: show first guest or let user select from all
        all_guests = get_guest_360_data(limit=100)
        if not all_guests.empty:
            selected_guest = st.selectbox(
                "Select Guest (Top 100)",
                options=all_guests['GUEST_ID'].tolist(),
                format_func=lambda x: f"{all_guests[all_guests['GUEST_ID']==x]['FIRST_NAME'].iloc[0]} {all_guests[all_guests['GUEST_ID']==x]['LAST_NAME'].iloc[0]}"
            )
        else:
            st.error("No guest data available")
            selected_guest = None

# Main Dashboard
if selected_guest:
    # Load guest data
    guest_data = get_guest_by_id(selected_guest)
    
    if not guest_data.empty:
        guest = guest_data.iloc[0]
        
        # Guest Profile Header
        col1, col2, col3, col4 = st.columns([2, 2, 2, 2])
        
        with col1:
            st.markdown(f"### {guest['FIRST_NAME']} {guest['LAST_NAME']}")
            display_loyalty_badge(guest['LOYALTY_TIER'])
            st.markdown(f"**Segment:** {guest['CUSTOMER_SEGMENT']}")
            st.markdown(f"**Email:** {guest['EMAIL']}")
        
        with col2:
            create_kpi_card("Lifetime Value", format_currency(guest['TOTAL_REVENUE']))
            create_kpi_card("Total Bookings", format_number(guest['TOTAL_BOOKINGS']))
        
        with col3:
            create_kpi_card("Loyalty Points", format_number(guest['LOYALTY_POINTS']))
            create_kpi_card("Avg Satisfaction", f"{guest['AVG_SATISFACTION_SCORE']:.1f}/5.0")
        
        with col4:
            st.markdown("**Churn Risk**")
            display_risk_badge(guest['CHURN_RISK'])
            st.markdown(f"**Tech Profile:** {guest['TECH_ADOPTION_PROFILE']}")
        
        st.markdown("---")
        
        # Tabs for detailed information
        tab1, tab2, tab3, tab4, tab5 = st.tabs([
            "📊 Spending Analysis", 
            "🏨 Stay History", 
            "🎯 Amenity Usage",
            "💡 Preferences",
            "📈 Insights & Recommendations"
        ])
        
        with tab1:
            st.markdown("## 💰 Spending Analysis")
            
            col1, col2 = st.columns(2)
            
            with col1:
                # Spending breakdown pie chart
                spending_data = pd.DataFrame({
                    'Category': [
                        'Spa', 'Restaurant', 'Bar', 'Room Service', 
                        'WiFi', 'Smart TV', 'Pool Services'
                    ],
                    'Amount': [
                        guest['TOTAL_SPA_SPEND'],
                        guest['TOTAL_RESTAURANT_SPEND'],
                        guest['TOTAL_BAR_SPEND'],
                        guest['TOTAL_ROOM_SERVICE_SPEND'],
                        guest['TOTAL_WIFI_SPEND'],
                        guest['TOTAL_SMART_TV_SPEND'],
                        guest['TOTAL_POOL_SERVICES_SPEND']
                    ]
                })
                spending_data = spending_data[spending_data['Amount'] > 0]
                
                if not spending_data.empty:
                    fig = create_pie_chart(spending_data, 'Amount', 'Category', 
                                         'Spending Breakdown by Amenity Category')
                    st.plotly_chart(fig, use_container_width=True)
                else:
                    st.info("No amenity spending data available")
            
            with col2:
                # Spending KPIs
                st.markdown("### Spending Metrics")
                create_kpi_card("Total Amenity Spend", 
                              format_currency(guest['TOTAL_AMENITY_SPEND']))
                create_kpi_card("Avg Per Booking", 
                              format_currency(guest['AVG_BOOKING_VALUE']))
                create_kpi_card("Spending Category", 
                              guest['AMENITY_SPENDING_CATEGORY'])
                
                # Top transactions
                st.markdown("### 🎯 Transaction Summary")
                col_a, col_b = st.columns(2)
                with col_a:
                    st.metric("Spa Visits", format_number(guest['SPA_VISITS']))
                    st.metric("Restaurant Visits", format_number(guest['RESTAURANT_VISITS']))
                with col_b:
                    st.metric("Bar Visits", format_number(guest['BAR_VISITS']))
                    st.metric("Room Service Orders", format_number(guest['ROOM_SERVICE_ORDERS']))
        
        with tab2:
            st.markdown("## 🏨 Stay History")
            
            # Get stay history for this guest
            stays = get_stays_processed()
            guest_stays = stays[stays['GUEST_ID'] == selected_guest]
            
            if not guest_stays.empty:
                # Display stay timeline
                st.markdown(f"### Total Stays: {len(guest_stays)}")
                
                # Metrics
                col1, col2, col3, col4 = st.columns(4)
                with col1:
                    st.metric("Avg Stay Length", 
                             f"{guest['AVG_STAY_LENGTH']:.1f} nights")
                with col2:
                    avg_satisfaction = guest_stays['GUEST_SATISFACTION_SCORE'].mean()
                    st.metric("Avg Satisfaction", f"{avg_satisfaction:.1f}/5.0")
                with col3:
                    total_spend = guest_stays['TOTAL_CHARGES'].sum()
                    st.metric("Total Stay Revenue", format_currency(total_spend))
                with col4:
                    issues = guest_stays['HAD_SERVICE_ISSUES'].sum()
                    st.metric("Service Issues", format_number(issues))
                
                # Stay details table
                st.markdown("### Recent Stays")
                display_stays = guest_stays[[
                    'ACTUAL_CHECK_IN', 'ACTUAL_CHECK_OUT', 'ROOM_TYPE', 
                    'TOTAL_CHARGES', 'GUEST_SATISFACTION_SCORE', 
                    'SATISFACTION_CATEGORY'
                ]].sort_values('ACTUAL_CHECK_IN', ascending=False).head(10)
                
                st.dataframe(display_stays, use_container_width=True)
                
                # Satisfaction trend
                if len(guest_stays) > 1:
                    fig = create_line_chart(
                        guest_stays.sort_values('ACTUAL_CHECK_IN'),
                        'ACTUAL_CHECK_IN',
                        'GUEST_SATISFACTION_SCORE',
                        'Satisfaction Score Trend Over Time'
                    )
                    st.plotly_chart(fig, use_container_width=True)
            else:
                st.info("No stay history available for this guest")
        
        with tab3:
            st.markdown("## 🎯 Amenity & Infrastructure Usage")
            
            col1, col2 = st.columns(2)
            
            with col1:
                st.markdown("### Infrastructure Usage")
                
                # Usage metrics
                usage_data = pd.DataFrame({
                    'Service': ['WiFi', 'Smart TV', 'Pool'],
                    'Sessions': [
                        guest['TOTAL_WIFI_SESSIONS'],
                        guest['TOTAL_SMART_TV_SESSIONS'],
                        guest['TOTAL_POOL_SESSIONS']
                    ],
                    'Avg Duration (min)': [
                        guest['AVG_WIFI_DURATION'],
                        guest['AVG_SMART_TV_DURATION'],
                        guest['AVG_POOL_DURATION']
                    ]
                })
                
                fig = create_bar_chart(usage_data, 'Service', 'Sessions', 
                                     'Infrastructure Usage Sessions')
                st.plotly_chart(fig, use_container_width=True)
                
                # Engagement scores
                st.markdown("### Engagement Scores")
                create_kpi_card("Infrastructure Engagement", 
                              f"{guest['INFRASTRUCTURE_ENGAGEMENT_SCORE']:.0f}/100")
                create_kpi_card("Amenity Diversity", 
                              f"{guest['AMENITY_DIVERSITY_SCORE']:.0f}/100")
            
            with col2:
                st.markdown("### Usage Insights")
                
                # WiFi data consumption
                if guest['TOTAL_WIFI_DATA_MB'] > 0:
                    st.metric("WiFi Data Consumed", 
                             f"{guest['TOTAL_WIFI_DATA_MB']:,.0f} MB")
                
                # Satisfaction by category
                st.markdown("### Satisfaction by Service")
                satisfaction_data = pd.DataFrame({
                    'Service': ['Amenities', 'Infrastructure'],
                    'Score': [
                        guest['AVG_AMENITY_SATISFACTION'],
                        guest['AVG_INFRASTRUCTURE_SATISFACTION']
                    ]
                })
                
                fig = create_bar_chart(satisfaction_data, 'Service', 'Score',
                                     'Average Satisfaction Scores')
                fig.update_yaxis(range=[0, 5])
                st.plotly_chart(fig, use_container_width=True)
        
        with tab4:
            st.markdown("## 💡 Guest Preferences & Profile")
            
            col1, col2 = st.columns(2)
            
            with col1:
                st.markdown("### Demographics")
                st.markdown(f"**Gender:** {guest['GENDER']}")
                st.markdown(f"**Nationality:** {guest['NATIONALITY']}")
                st.markdown(f"**Language:** {guest['LANGUAGE_PREFERENCE']}")
                st.markdown(f"**Generation:** {guest['GENERATION']}")
                
                st.markdown("### Contact Preferences")
                st.markdown(f"**Marketing Opt-in:** {'Yes' if guest['MARKETING_OPT_IN'] else 'No'}")
            
            with col2:
                st.markdown("### Technology Profile")
                st.markdown(f"**Adoption Level:** {guest['TECH_ADOPTION_PROFILE']}")
                
                if guest['TOTAL_WIFI_SESSIONS'] > 10:
                    st.success("🌐 High WiFi User")
                if guest['TOTAL_SMART_TV_SESSIONS'] > 5:
                    st.success("📺 Smart TV Enthusiast")
                if guest['TOTAL_POOL_SESSIONS'] > 3:
                    st.success("🏊 Pool Services User")
        
        with tab5:
            st.markdown("## 📈 AI-Powered Insights & Recommendations")
            
            # Get personalization scores for this guest
            from data_loader import get_personalization_scores
            scores_df = get_personalization_scores()
            guest_scores = scores_df[scores_df['GUEST_ID'] == selected_guest]
            
            if not guest_scores.empty:
                scores = guest_scores.iloc[0]
                
                col1, col2 = st.columns(2)
                
                with col1:
                    st.markdown("### Propensity Scores")
                    
                    # Display gauge for personalization readiness
                    fig = create_gauge_chart(
                        scores['PERSONALIZATION_READINESS_SCORE'],
                        'Personalization Readiness',
                        100
                    )
                    st.plotly_chart(fig, use_container_width=True)
                    
                    # Upsell scores
                    upsell_data = pd.DataFrame({
                        'Category': ['Spa', 'Dining', 'Tech Services', 'Pool'],
                        'Score': [
                            scores['SPA_UPSELL_PROPENSITY'],
                            scores['DINING_UPSELL_PROPENSITY'],
                            scores['TECH_UPSELL_PROPENSITY'],
                            scores['POOL_SERVICES_UPSELL_PROPENSITY']
                        ]
                    }).sort_values('Score', ascending=False)
                    
                    fig = create_bar_chart(upsell_data, 'Category', 'Score',
                                         'Upsell Propensity by Category')
                    fig.update_yaxis(range=[0, 100])
                    st.plotly_chart(fig, use_container_width=True)
                
                with col2:
                    st.markdown("### Recommendations")
                    
                    # Generate recommendations based on scores
                    recommendations = []
                    
                    if scores['SPA_UPSELL_PROPENSITY'] > 70:
                        recommendations.append("🧖 **High Spa Interest**: Offer premium spa package")
                    if scores['DINING_UPSELL_PROPENSITY'] > 70:
                        recommendations.append("🍽️ **Dining Opportunity**: Promote signature restaurant")
                    if scores['TECH_UPSELL_PROPENSITY'] > 70:
                        recommendations.append("📱 **Tech Savvy**: Offer premium WiFi or smart room upgrades")
                    if scores['POOL_SERVICES_UPSELL_PROPENSITY'] > 70:
                        recommendations.append("🏊 **Pool Services**: Promote poolside cabana rentals")
                    
                    if guest['CHURN_RISK'] == 'High':
                        recommendations.append("⚠️ **CHURN ALERT**: Proactive retention outreach needed")
                    
                    if scores['LOYALTY_PROPENSITY_SCORE'] > 70:
                        recommendations.append("⭐ **Loyalty Opportunity**: Strong candidate for tier upgrade")
                    
                    if recommendations:
                        for rec in recommendations:
                            st.success(rec)
                    else:
                        st.info("Continue providing excellent service to maintain satisfaction")
                    
                    # Engagement score
                    st.markdown("### Engagement Metrics")
                    create_kpi_card("Amenity Engagement", 
                                  f"{scores['AMENITY_ENGAGEMENT_SCORE']:.0f}/100")
                    create_kpi_card("Infrastructure Engagement", 
                                  f"{scores['INFRASTRUCTURE_ENGAGEMENT_SCORE']:.0f}/100")
                    create_kpi_card("Loyalty Propensity", 
                                  f"{scores['LOYALTY_PROPENSITY_SCORE']:.0f}/100")
            else:
                st.info("Personalization scores not available for this guest")
    else:
        st.error("Guest data not found")
else:
    st.info("👈 Please select a guest from the sidebar to view their 360 profile")

# Footer
st.markdown("---")
st.markdown("*Data refreshed every 5 minutes | Powered by Snowflake Cortex Intelligence*")
