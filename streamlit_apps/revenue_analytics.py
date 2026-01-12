"""
Revenue Analytics & Optimization Dashboard
Target Users: Revenue Managers, Finance Teams, General Managers
"""
import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), 'shared'))
from data_loader import (
    get_guest_360_data, get_bookings_enriched, get_stays_processed,
    get_amenity_spending
)
from viz_components import (
    create_kpi_card, format_currency, format_number, format_percentage,
    create_bar_chart, create_line_chart, apply_custom_css
)

# Note: set_page_config() is handled by main app
apply_custom_css()

st.title("💰 Revenue Analytics & Optimization")
st.markdown("**Comprehensive Revenue Performance & Forecasting**")
st.markdown("---")

# Load data
guests_df = get_guest_360_data()
bookings_df = get_bookings_enriched()
stays_df = get_stays_processed()
amenities_df = get_amenity_spending()

# Calculate key metrics
total_room_revenue = stays_df['TOTAL_CHARGES'].sum() if not stays_df.empty else 0
total_amenity_revenue = amenities_df['AMOUNT'].sum() if not amenities_df.empty else 0
total_revenue = total_room_revenue + total_amenity_revenue
total_bookings = len(bookings_df) if not bookings_df.empty else 0
avg_booking_value = bookings_df['TOTAL_AMOUNT'].mean() if not bookings_df.empty and 'TOTAL_AMOUNT' in bookings_df.columns else 0

# Summary metrics
col1, col2, col3, col4 = st.columns(4)

with col1:
    create_kpi_card("Total Revenue", format_currency(total_revenue))
with col2:
    create_kpi_card("Room Revenue", format_currency(total_room_revenue))
with col3:
    create_kpi_card("Amenity Revenue", format_currency(total_amenity_revenue))
with col4:
    amenity_pct = (total_amenity_revenue / total_revenue * 100) if total_revenue > 0 else 0
    create_kpi_card("Amenity %", format_percentage(amenity_pct))

st.markdown("---")

# Tabs
tab1, tab2, tab3, tab4 = st.tabs([
    "📊 Revenue Mix",
    "🏨 Booking Analytics",
    "👥 Segment Performance",
    "📈 Trends & Forecast"
])

with tab1:
    st.markdown("## 📊 Revenue Mix Analysis")
    
    col1, col2 = st.columns(2)
    
    with col1:
        # Revenue source breakdown
        revenue_mix = pd.DataFrame({
            'Source': ['Room Revenue', 'Amenity Revenue'],
            'Amount': [total_room_revenue, total_amenity_revenue]
        })
        
        fig = go.Figure(data=[
            go.Pie(labels=revenue_mix['Source'], values=revenue_mix['Amount'],
                   hole=.3, marker_colors=['#1f77b4', '#ff7f0e'])
        ])
        fig.update_layout(title='Revenue Mix: Rooms vs Amenities')
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        # Amenity revenue breakdown
        if not amenities_df.empty and 'AMENITY_CATEGORY' in amenities_df.columns:
            amenity_revenue = amenities_df.groupby('AMENITY_CATEGORY')['AMOUNT'].sum().reset_index()
            amenity_revenue.columns = ['Category', 'Revenue']
            amenity_revenue = amenity_revenue.sort_values('Revenue', ascending=False)
            
            fig = create_bar_chart(amenity_revenue, 'Category', 'Revenue',
                                  'Amenity Revenue by Category')
            st.plotly_chart(fig, use_container_width=True)
    
    # Revenue per guest metrics
    st.markdown("### Revenue Per Guest Metrics")
    if not guests_df.empty:
        col1, col2, col3 = st.columns(3)
        
        with col1:
            avg_ltv = guests_df['TOTAL_REVENUE'].mean()
            create_kpi_card("Avg Lifetime Value", format_currency(avg_ltv))
        
        with col2:
            avg_booking_rev = guests_df['AVG_BOOKING_VALUE'].mean()
            create_kpi_card("Avg Booking Value", format_currency(avg_booking_rev))
        
        with col3:
            avg_amenity = guests_df['TOTAL_AMENITY_SPEND'].mean()
            create_kpi_card("Avg Amenity Spend", format_currency(avg_amenity))

with tab2:
    st.markdown("## 🏨 Booking Analytics")
    
    if not bookings_df.empty:
        col1, col2 = st.columns(2)
        
        with col1:
            # Booking channel analysis
            if 'BOOKING_CHANNEL' in bookings_df.columns:
                channel_revenue = bookings_df.groupby('BOOKING_CHANNEL').agg({
                    'BOOKING_ID': 'count',
                    'TOTAL_AMOUNT': 'sum'
                }).reset_index()
                channel_revenue.columns = ['Channel', 'Bookings', 'Revenue']
                
                fig = create_bar_chart(channel_revenue, 'Channel', 'Revenue',
                                      'Revenue by Booking Channel')
                st.plotly_chart(fig, use_container_width=True)
        
        with col2:
            # Lead time analysis
            if 'BOOKING_LEAD_TIME_CATEGORY' in bookings_df.columns:
                leadtime_bookings = bookings_df.groupby('BOOKING_LEAD_TIME_CATEGORY').size().reset_index()
                leadtime_bookings.columns = ['Lead Time', 'Bookings']
                
                fig = create_bar_chart(leadtime_bookings, 'Lead Time', 'Bookings',
                                      'Bookings by Lead Time Category')
                st.plotly_chart(fig, use_container_width=True)
        
        # Booking metrics table
        st.markdown("### Booking Channel Performance")
        if 'BOOKING_CHANNEL' in bookings_df.columns:
            channel_metrics = bookings_df.groupby('BOOKING_CHANNEL').agg({
                'BOOKING_ID': 'count',
                'TOTAL_AMOUNT': ['sum', 'mean']
            }).round(2)
            channel_metrics.columns = ['Total Bookings', 'Total Revenue', 'Avg Booking Value']
            st.dataframe(channel_metrics, use_container_width=True)

with tab3:
    st.markdown("## 👥 Customer Segment Performance")
    
    if not guests_df.empty and 'CUSTOMER_SEGMENT' in guests_df.columns:
        col1, col2 = st.columns(2)
        
        with col1:
            # Revenue by segment
            segment_revenue = guests_df.groupby('CUSTOMER_SEGMENT')['TOTAL_REVENUE'].sum().reset_index()
            segment_revenue.columns = ['Segment', 'Revenue']
            segment_revenue = segment_revenue.sort_values('Revenue', ascending=False)
            
            fig = create_bar_chart(segment_revenue, 'Segment', 'Revenue',
                                  'Total Revenue by Customer Segment')
            st.plotly_chart(fig, use_container_width=True)
        
        with col2:
            # Guest count by segment
            segment_counts = guests_df.groupby('CUSTOMER_SEGMENT').size().reset_index()
            segment_counts.columns = ['Segment', 'Guests']
            
            fig = create_bar_chart(segment_counts, 'Segment', 'Guests',
                                  'Guest Count by Segment')
            st.plotly_chart(fig, use_container_width=True)
        
        # Segment profitability table
        st.markdown("### Segment Profitability Analysis")
        segment_metrics = guests_df.groupby('CUSTOMER_SEGMENT').agg({
            'GUEST_ID': 'count',
            'TOTAL_REVENUE': ['sum', 'mean'],
            'TOTAL_BOOKINGS': 'mean',
            'AVG_SATISFACTION_SCORE': 'mean'
        }).round(2)
        segment_metrics.columns = ['Guest Count', 'Total Revenue', 'Avg Revenue/Guest', 'Avg Bookings', 'Avg Satisfaction']
        st.dataframe(segment_metrics, use_container_width=True)

with tab4:
    st.markdown("## 📈 Revenue Trends")
    
    # Analyze trends if date columns available
    if not stays_df.empty and 'ACTUAL_CHECK_IN' in stays_df.columns:
        # Convert to datetime
        stays_df['CHECK_IN_DATE'] = pd.to_datetime(stays_df['ACTUAL_CHECK_IN'])
        stays_df['MONTH'] = stays_df['CHECK_IN_DATE'].dt.to_period('M').astype(str)
        
        # Monthly revenue trend
        monthly_revenue = stays_df.groupby('MONTH')['TOTAL_CHARGES'].sum().reset_index()
        monthly_revenue.columns = ['Month', 'Revenue']
        
        fig = create_line_chart(monthly_revenue, 'Month', 'Revenue',
                               'Monthly Room Revenue Trend')
        st.plotly_chart(fig, use_container_width=True)
        
        # Monthly bookings trend
        if not bookings_df.empty and 'CREATED_AT' in bookings_df.columns:
            bookings_df['BOOKING_DATE'] = pd.to_datetime(bookings_df['CREATED_AT'])
            bookings_df['MONTH'] = bookings_df['BOOKING_DATE'].dt.to_period('M').astype(str)
            
            monthly_bookings = bookings_df.groupby('MONTH').size().reset_index()
            monthly_bookings.columns = ['Month', 'Bookings']
            
            fig = create_line_chart(monthly_bookings, 'Month', 'Bookings',
                                   'Monthly Booking Volume Trend')
            st.plotly_chart(fig, use_container_width=True)
    else:
        st.info("Historical trend data requires time-series information")

st.markdown("---")
st.markdown("*Data refreshed every 5 minutes | Revenue insights for strategic decision-making*")
