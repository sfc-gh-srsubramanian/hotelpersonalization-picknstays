"""
Guest 360 Dashboard - Comprehensive Guest Analytics & Profile Viewer
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
st.title("🎯 Guest 360 Analytics")
st.markdown("**Comprehensive Guest Analytics & Profile Viewer**")
st.markdown("---")

# Load all guest data
guests_df = get_guest_360_data()

if guests_df.empty:
    st.error("No guest data available")
    st.stop()

# Summary KPIs
col1, col2, col3, col4, col5 = st.columns(5)

with col1:
    create_kpi_card("Total Guests", format_number(len(guests_df)))

with col2:
    create_kpi_card("Total Revenue", format_currency(guests_df['TOTAL_REVENUE'].sum()))

with col3:
    create_kpi_card("Avg Booking Value", format_currency(guests_df['AVG_BOOKING_VALUE'].mean()))

with col4:
    platinum_count = len(guests_df[guests_df['LOYALTY_TIER'] == 'Platinum'])
    create_kpi_card("Platinum Members", format_number(platinum_count))

with col5:
    high_risk = len(guests_df[guests_df['CHURN_RISK'] == 'High'])
    create_kpi_card("High Churn Risk", format_number(high_risk))

st.markdown("---")

# Filters in sidebar
with st.sidebar:
    st.header("🔍 Filters")
    
    # Loyalty Tier filter
    loyalty_tiers = ['All'] + sorted(guests_df['LOYALTY_TIER'].dropna().unique().tolist())
    selected_tier = st.selectbox("Loyalty Tier", loyalty_tiers)
    
    # Customer Segment filter
    segments = ['All'] + sorted(guests_df['CUSTOMER_SEGMENT'].dropna().unique().tolist())
    selected_segment = st.selectbox("Customer Segment", segments)
    
    # Churn Risk filter
    churn_risks = ['All'] + sorted(guests_df['CHURN_RISK'].dropna().unique().tolist())
    selected_risk = st.selectbox("Churn Risk", churn_risks)
    
    # Revenue range filter
    st.subheader("Revenue Range")
    min_revenue = st.number_input("Min Revenue ($)", value=0, step=1000)
    max_revenue = st.number_input("Max Revenue ($)", value=int(guests_df['TOTAL_REVENUE'].max()), step=1000)
    
    # Search
    st.subheader("Search")
    search_term = st.text_input("Name or Email", "")

# Apply filters
filtered_df = guests_df.copy()

if selected_tier != 'All':
    filtered_df = filtered_df[filtered_df['LOYALTY_TIER'] == selected_tier]

if selected_segment != 'All':
    filtered_df = filtered_df[filtered_df['CUSTOMER_SEGMENT'] == selected_segment]

if selected_risk != 'All':
    filtered_df = filtered_df[filtered_df['CHURN_RISK'] == selected_risk]

filtered_df = filtered_df[
    (filtered_df['TOTAL_REVENUE'] >= min_revenue) &
    (filtered_df['TOTAL_REVENUE'] <= max_revenue)
]

if search_term:
    mask = (
        filtered_df['FIRST_NAME'].str.contains(search_term, case=False, na=False) |
        filtered_df['LAST_NAME'].str.contains(search_term, case=False, na=False) |
        filtered_df['EMAIL'].str.contains(search_term, case=False, na=False)
    )
    filtered_df = filtered_df[mask]

st.markdown(f"### 📋 Guest List ({len(filtered_df)} guests)")

# Tabs for different views
tab1, tab2, tab3 = st.tabs(["📊 Guest Table", "📈 Analytics", "👤 Guest Profile"])

with tab1:
    st.markdown("#### All Guests Overview")
    
    # Sort options
    sort_col1, sort_col2 = st.columns(2)
    with sort_col1:
        sort_by = st.selectbox("Sort by", [
            'TOTAL_REVENUE', 'TOTAL_BOOKINGS', 'LOYALTY_POINTS', 
            'AVG_AMENITY_SATISFACTION', 'TOTAL_AMENITY_SPEND'
        ])
    with sort_col2:
        sort_order = st.radio("Order", ['Descending', 'Ascending'], horizontal=True)
    
    # Sort dataframe
    ascending = (sort_order == 'Ascending')
    display_df = filtered_df.sort_values(by=sort_by, ascending=ascending)
    
    # Select columns to display
    display_columns = [
        'GUEST_ID', 'FIRST_NAME', 'LAST_NAME', 'EMAIL', 
        'LOYALTY_TIER', 'CUSTOMER_SEGMENT', 'CHURN_RISK',
        'TOTAL_BOOKINGS', 'TOTAL_REVENUE', 'AVG_BOOKING_VALUE',
        'LOYALTY_POINTS', 'TOTAL_AMENITY_SPEND', 'AVG_AMENITY_SATISFACTION'
    ]
    
    # Format display dataframe
    formatted_df = display_df[display_columns].copy()
    formatted_df['TOTAL_REVENUE'] = formatted_df['TOTAL_REVENUE'].apply(format_currency)
    formatted_df['AVG_BOOKING_VALUE'] = formatted_df['AVG_BOOKING_VALUE'].apply(format_currency)
    formatted_df['TOTAL_AMENITY_SPEND'] = formatted_df['TOTAL_AMENITY_SPEND'].apply(format_currency)
    formatted_df['LOYALTY_POINTS'] = formatted_df['LOYALTY_POINTS'].apply(format_number)
    formatted_df['AVG_AMENITY_SATISFACTION'] = formatted_df['AVG_AMENITY_SATISFACTION'].apply(lambda x: f"{x:.1f}/5.0")
    
    # Display as interactive table
    st.dataframe(
        formatted_df.reset_index(drop=True),
        use_container_width=True,
        height=600
    )
    
    # Download button
    csv = display_df[display_columns].to_csv(index=False)
    st.download_button(
        label="📥 Download Guest Data (CSV)",
        data=csv,
        file_name=f"guest_360_data_{datetime.now().strftime('%Y%m%d')}.csv",
        mime="text/csv"
    )

with tab2:
    st.markdown("#### Guest Analytics")
    
    col1, col2 = st.columns(2)
    
    with col1:
        # Loyalty tier distribution
        st.markdown("##### Loyalty Tier Distribution")
        tier_counts = filtered_df['LOYALTY_TIER'].value_counts()
        fig = px.pie(
            values=tier_counts.values,
            names=tier_counts.index,
            title="Guests by Loyalty Tier"
        )
        st.plotly_chart(fig, use_container_width=True)
        
        # Customer segment distribution
        st.markdown("##### Customer Segment Distribution")
        segment_counts = filtered_df['CUSTOMER_SEGMENT'].value_counts()
        fig = px.bar(
            x=segment_counts.index,
            y=segment_counts.values,
            labels={'x': 'Segment', 'y': 'Count'},
            title="Guests by Segment"
        )
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        # Churn risk distribution
        st.markdown("##### Churn Risk Distribution")
        risk_counts = filtered_df['CHURN_RISK'].value_counts()
        fig = px.pie(
            values=risk_counts.values,
            names=risk_counts.index,
            title="Guests by Churn Risk",
            color=risk_counts.index,
            color_discrete_map={'High': 'red', 'Medium': 'orange', 'Low': 'green'}
        )
        st.plotly_chart(fig, use_container_width=True)
        
        # Revenue by segment
        st.markdown("##### Revenue by Segment")
        segment_revenue = filtered_df.groupby('CUSTOMER_SEGMENT')['TOTAL_REVENUE'].sum().sort_values(ascending=False)
        fig = px.bar(
            x=segment_revenue.index,
            y=segment_revenue.values,
            labels={'x': 'Segment', 'y': 'Total Revenue ($)'},
            title="Revenue by Customer Segment"
        )
        st.plotly_chart(fig, use_container_width=True)
    
    # Top spending guests
    st.markdown("##### 🏆 Top 10 Guests by Revenue")
    top_guests = filtered_df.nlargest(10, 'TOTAL_REVENUE')[
        ['FIRST_NAME', 'LAST_NAME', 'LOYALTY_TIER', 'TOTAL_REVENUE', 'TOTAL_BOOKINGS', 'AVG_AMENITY_SATISFACTION']
    ]
    top_guests_display = top_guests.copy()
    top_guests_display['TOTAL_REVENUE'] = top_guests_display['TOTAL_REVENUE'].apply(format_currency)
    top_guests_display['AVG_AMENITY_SATISFACTION'] = top_guests_display['AVG_AMENITY_SATISFACTION'].apply(lambda x: f"{x:.1f}/5.0")
    st.dataframe(top_guests_display.reset_index(drop=True), use_container_width=True)

with tab3:
    st.markdown("#### Individual Guest Profile")
    
    # Guest selector
    if not filtered_df.empty:
        guest_options = filtered_df.apply(
            lambda row: f"{row['FIRST_NAME']} {row['LAST_NAME']} ({row['LOYALTY_TIER']}) - ${row['TOTAL_REVENUE']:,.0f}",
            axis=1
        )
        
        selected_idx = st.selectbox(
            "Select a guest to view detailed profile:",
            range(len(filtered_df)),
            format_func=lambda i: guest_options.iloc[i]
        )
        
        guest = filtered_df.iloc[selected_idx]
        
        st.markdown("---")
        
        # Guest Profile Header
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.markdown(f"### {guest['FIRST_NAME']} {guest['LAST_NAME']}")
            st.markdown(f"**Tier:** {guest['LOYALTY_TIER']}")
            st.markdown(f"**Segment:** {guest['CUSTOMER_SEGMENT']}")
            st.markdown(f"**Email:** {guest['EMAIL']}")
        
        with col2:
            create_kpi_card("Lifetime Revenue", format_currency(guest['TOTAL_REVENUE']))
            create_kpi_card("Avg Booking Value", format_currency(guest['AVG_BOOKING_VALUE']))
        
        with col3:
            create_kpi_card("Total Bookings", format_number(guest['TOTAL_BOOKINGS']))
            create_kpi_card("Loyalty Points", format_number(guest['LOYALTY_POINTS']))
        
        with col4:
            create_kpi_card("Amenity Spend", format_currency(guest['TOTAL_AMENITY_SPEND']))
            create_kpi_card("Satisfaction", f"{guest['AVG_AMENITY_SATISFACTION']:.1f}/5.0")
        
        st.markdown("---")
        
        # Guest details in columns
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("##### 🎯 Guest Profile")
            st.markdown(f"**Churn Risk:** {guest['CHURN_RISK']}")
            st.markdown(f"**Tech Profile:** {guest['TECH_ADOPTION_PROFILE']}")
            st.markdown(f"**Nationality:** {guest['NATIONALITY']}")
            st.markdown(f"**Language:** {guest['LANGUAGE_PREFERENCE']}")
            st.markdown(f"**Location:** {guest['CITY']}, {guest['STATE_PROVINCE']}, {guest['COUNTRY']}")
        
        with col2:
            st.markdown("##### 💰 Spending Breakdown")
            spending_data = {
                'Category': ['Spa', 'Restaurant', 'Bar', 'Room Service', 'WiFi', 'Smart TV', 'Pool Services'],
                'Amount': [
                    guest['TOTAL_SPA_SPEND'],
                    guest['TOTAL_RESTAURANT_SPEND'],
                    guest['TOTAL_BAR_SPEND'],
                    guest['TOTAL_ROOM_SERVICE_SPEND'],
                    guest['TOTAL_WIFI_SPEND'],
                    guest['TOTAL_SMART_TV_SPEND'],
                    guest['TOTAL_POOL_SERVICES_SPEND']
                ]
            }
            spending_df = pd.DataFrame(spending_data)
            spending_df = spending_df[spending_df['Amount'] > 0].sort_values('Amount', ascending=False)
            
            if not spending_df.empty:
                fig = px.bar(
                    spending_df,
                    x='Amount',
                    y='Category',
                    orientation='h',
                    title="Amenity Spending by Category"
                )
                st.plotly_chart(fig, use_container_width=True)
            else:
                st.info("No amenity spending data")
        
        # Usage metrics
        st.markdown("##### 📊 Amenity Usage")
        col1, col2, col3 = st.columns(3)
        
        with col1:
            st.metric("WiFi Sessions", format_number(guest['TOTAL_WIFI_SESSIONS']))
            st.metric("Avg WiFi Duration", f"{guest['AVG_WIFI_DURATION']:.0f} min")
            st.metric("WiFi Data", f"{guest['TOTAL_WIFI_DATA_MB']:,.0f} MB")
        
        with col2:
            st.metric("Smart TV Sessions", format_number(guest['TOTAL_SMART_TV_SESSIONS']))
            st.metric("Avg TV Duration", f"{guest['AVG_SMART_TV_DURATION']:.0f} min")
            st.metric("Infrastructure Satisfaction", f"{guest['AVG_INFRASTRUCTURE_SATISFACTION']:.1f}/5.0")
        
        with col3:
            st.metric("Pool Sessions", format_number(guest['TOTAL_POOL_SESSIONS']))
            st.metric("Avg Pool Duration", f"{guest['AVG_POOL_DURATION']:.0f} min")
            st.metric("Amenity Diversity", f"{guest['AMENITY_DIVERSITY_SCORE']:.0f}/100")
    
    else:
        st.warning("No guests match the current filters")
