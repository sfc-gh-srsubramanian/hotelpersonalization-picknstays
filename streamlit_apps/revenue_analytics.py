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
from data_loader import get_guest_360_data
from viz_components import (
    create_kpi_card, format_currency, format_number, format_percentage,
    create_bar_chart, create_line_chart, apply_custom_css
)

# Note: set_page_config() is handled by main app
apply_custom_css()

st.title("💰 Revenue Analytics & Optimization")
st.markdown("**Comprehensive Revenue Performance & Forecasting**")

# Add cache clear button in sidebar
with st.sidebar:
    if st.button("🔄 Refresh Data"):
        st.cache_data.clear()
        st.rerun()

st.markdown("---")

# Load data from GOLD layer (single source of truth)
guests_df = get_guest_360_data()

# Calculate key metrics from GOLD layer
total_revenue = guests_df['TOTAL_REVENUE'].sum() if not guests_df.empty else 0
total_amenity_revenue = guests_df['TOTAL_AMENITY_SPEND'].sum() if not guests_df.empty else 0
total_room_revenue = total_revenue - total_amenity_revenue  # Room revenue = Total - Amenities
total_bookings = guests_df['TOTAL_BOOKINGS'].sum() if not guests_df.empty else 0
avg_booking_value = guests_df['AVG_BOOKING_VALUE'].mean() if not guests_df.empty else 0

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
        # Amenity revenue breakdown (from GOLD layer aggregated columns)
        if not guests_df.empty:
            amenity_breakdown = pd.DataFrame({
                'Category': ['Spa', 'Restaurant', 'Bar', 'Room Service', 'WiFi', 'Smart TV', 'Pool Services'],
                'Revenue': [
                    guests_df['TOTAL_SPA_SPEND'].sum(),
                    guests_df['TOTAL_RESTAURANT_SPEND'].sum(),
                    guests_df['TOTAL_BAR_SPEND'].sum(),
                    guests_df['TOTAL_ROOM_SERVICE_SPEND'].sum(),
                    guests_df['TOTAL_WIFI_SPEND'].sum(),
                    guests_df['TOTAL_SMART_TV_SPEND'].sum(),
                    guests_df['TOTAL_POOL_SERVICES_SPEND'].sum()
                ]
            })
            amenity_breakdown = amenity_breakdown.sort_values('Revenue', ascending=False)
            
            fig = create_bar_chart(amenity_breakdown, 'Category', 'Revenue',
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
    
    # Show GOLD layer booking metrics
    if not guests_df.empty:
        col1, col2, col3 = st.columns(3)
        
        with col1:
            total_bookings_count = guests_df['TOTAL_BOOKINGS'].sum()
            create_kpi_card("Total Bookings", format_number(total_bookings_count))
        
        with col2:
            avg_bookings_per_guest = guests_df['TOTAL_BOOKINGS'].mean()
            create_kpi_card("Avg Bookings/Guest", f"{avg_bookings_per_guest:.1f}")
        
        with col3:
            avg_stay_length = guests_df['AVG_STAY_LENGTH'].mean()
            create_kpi_card("Avg Stay Length", f"{avg_stay_length:.1f} nights")
        
        st.markdown("---")
        
        # Booking distribution by segment
        st.markdown("### Booking Distribution by Customer Segment")
        col1, col2 = st.columns(2)
        
        with col1:
            if 'CUSTOMER_SEGMENT' in guests_df.columns:
                segment_bookings = guests_df.groupby('CUSTOMER_SEGMENT')['TOTAL_BOOKINGS'].sum().reset_index()
                segment_bookings.columns = ['Segment', 'Total Bookings']
                segment_bookings = segment_bookings.sort_values('Total Bookings', ascending=False)
                
                fig = create_bar_chart(segment_bookings, 'Segment', 'Total Bookings',
                                      'Total Bookings by Customer Segment')
                st.plotly_chart(fig, use_container_width=True)
        
        with col2:
            if 'LOYALTY_TIER' in guests_df.columns:
                tier_bookings = guests_df.groupby('LOYALTY_TIER')['TOTAL_BOOKINGS'].sum().reset_index()
                tier_bookings.columns = ['Tier', 'Total Bookings']
                tier_bookings = tier_bookings.sort_values('Total Bookings', ascending=False)
                
                fig = create_bar_chart(tier_bookings, 'Tier', 'Total Bookings',
                                      'Total Bookings by Loyalty Tier')
                st.plotly_chart(fig, use_container_width=True)
        
        # Booking value analysis
        st.markdown("### Booking Value Distribution")
        booking_value_segments = pd.DataFrame({
            'Segment': guests_df['CUSTOMER_SEGMENT'],
            'Avg Booking Value': guests_df['AVG_BOOKING_VALUE'],
            'Total Bookings': guests_df['TOTAL_BOOKINGS']
        })
        avg_by_segment = booking_value_segments.groupby('Segment')['Avg Booking Value'].mean().reset_index()
        avg_by_segment = avg_by_segment.sort_values('Avg Booking Value', ascending=False)
        avg_by_segment_display = avg_by_segment.copy()
        avg_by_segment_display['Avg Booking Value'] = avg_by_segment_display['Avg Booking Value'].apply(format_currency)
        st.dataframe(avg_by_segment_display, use_container_width=True)

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
            'AVG_AMENITY_SATISFACTION': 'mean'
        }).round(2)
        segment_metrics.columns = ['Guest Count', 'Total Revenue', 'Avg Revenue/Guest', 'Avg Bookings', 'Avg Satisfaction']
        segment_metrics_display = segment_metrics.copy()
        segment_metrics_display['Guest Count'] = segment_metrics_display['Guest Count'].apply(format_number)
        segment_metrics_display['Total Revenue'] = segment_metrics_display['Total Revenue'].apply(format_currency)
        segment_metrics_display['Avg Revenue/Guest'] = segment_metrics_display['Avg Revenue/Guest'].apply(format_currency)
        st.dataframe(segment_metrics_display, use_container_width=True)

with tab4:
    st.markdown("## 📈 Revenue Performance Analysis")
    
    if not guests_df.empty:
        # Revenue distribution analysis
        st.markdown("### Revenue Distribution by Customer Value")
        
        col1, col2 = st.columns(2)
        
        with col1:
            # Revenue quartiles
            quartiles = guests_df['TOTAL_REVENUE'].quantile([0.25, 0.50, 0.75, 0.90, 0.95]).reset_index()
            quartiles.columns = ['Percentile', 'Revenue']
            quartiles['Percentile'] = quartiles['Percentile'].apply(lambda x: f"{int(x*100)}th")
            quartiles['Revenue'] = quartiles['Revenue'].apply(format_currency)
            
            st.markdown("#### Revenue Percentiles")
            st.dataframe(quartiles, use_container_width=True)
            
            # High value guests
            high_value_count = len(guests_df[guests_df['TOTAL_REVENUE'] > guests_df['TOTAL_REVENUE'].quantile(0.90)])
            high_value_revenue = guests_df[guests_df['TOTAL_REVENUE'] > guests_df['TOTAL_REVENUE'].quantile(0.90)]['TOTAL_REVENUE'].sum()
            high_value_pct = (high_value_revenue / total_revenue * 100) if total_revenue > 0 else 0
            
            st.info(f"💎 **Top 10% of Guests** ({format_number(high_value_count)}): Generate **{format_currency(high_value_revenue)}** ({high_value_pct:.1f}% of total revenue)")
        
        with col2:
            # Revenue concentration by segment
            st.markdown("#### Revenue Concentration by Segment")
            segment_contribution = guests_df.groupby('CUSTOMER_SEGMENT').agg({
                'GUEST_ID': 'count',
                'TOTAL_REVENUE': 'sum'
            }).reset_index()
            segment_contribution.columns = ['Segment', 'Guests', 'Revenue']
            segment_contribution['% of Total Revenue'] = (segment_contribution['Revenue'] / total_revenue * 100).round(1)
            segment_contribution = segment_contribution.sort_values('Revenue', ascending=False)
            
            segment_contribution_display = segment_contribution.copy()
            segment_contribution_display['Guests'] = segment_contribution_display['Guests'].apply(format_number)
            segment_contribution_display['Revenue'] = segment_contribution_display['Revenue'].apply(format_currency)
            
            st.dataframe(segment_contribution_display, use_container_width=True)
        
        # Booking frequency vs revenue analysis
        st.markdown("### Booking Frequency vs Average Revenue")
        
        if not guests_df.empty and 'TOTAL_BOOKINGS' in guests_df.columns and 'TOTAL_REVENUE' in guests_df.columns:
            # Show data info
            total_guests = len(guests_df)
            guests_with_bookings = len(guests_df[guests_df['TOTAL_BOOKINGS'] > 0])
            st.info(f"📊 Analyzing {format_number(total_guests)} guests ({format_number(guests_with_bookings)} with bookings)")
            
            # Filter out guests with 0 bookings and aggregate
            frequency_data = guests_df[guests_df['TOTAL_BOOKINGS'] > 0].copy()
            
            if not frequency_data.empty:
                frequency_analysis = frequency_data.groupby('TOTAL_BOOKINGS').agg({
                    'GUEST_ID': 'count',
                    'TOTAL_REVENUE': 'mean',
                    'AVG_BOOKING_VALUE': 'mean'
                }).reset_index()
                frequency_analysis.columns = ['Booking Count', 'Guests', 'Avg Total Revenue', 'Avg Booking Value']
                
                # Limit to reasonable range for visualization
                max_bookings = min(20, int(frequency_analysis['Booking Count'].max()))
                frequency_analysis = frequency_analysis[frequency_analysis['Booking Count'] <= max_bookings]
                
                if not frequency_analysis.empty and len(frequency_analysis) > 0:
                    # Create bar chart with improved styling
                    fig = go.Figure()
                    
                    # Convert to string labels for better category handling
                    x_labels = [f"{int(x)} Bookings" for x in frequency_analysis['Booking Count']]
                    
                    fig.add_trace(go.Bar(
                        x=x_labels,
                        y=frequency_analysis['Avg Total Revenue'].values,
                        name='Avg Total Revenue',
                        marker_color='royalblue',
                        marker_line_color='darkblue',
                        marker_line_width=1.5,
                        width=0.6,  # Explicit bar width
                        text=frequency_analysis['Avg Total Revenue'].apply(lambda x: format_currency(x)),
                        textposition='outside',
                        textfont=dict(size=12, color='black', family='Arial, sans-serif'),
                        hovertemplate='<b>%{x}</b><br>' +
                                      '<b>Avg Revenue:</b> %{text}<br>' +
                                      '<b>Guests:</b> %{customdata:,}<extra></extra>',
                        customdata=frequency_analysis['Guests'].values
                    ))
                    fig.update_layout(
                        title={
                            'text': 'Average Guest Revenue by Booking Frequency',
                            'x': 0.5,
                            'xanchor': 'center',
                            'font': {'size': 16, 'color': 'black', 'family': 'Arial, sans-serif'}
                        },
                        xaxis_title='Number of Bookings',
                        yaxis_title='Average Total Revenue ($)',
                        height=500,
                        showlegend=False,
                        plot_bgcolor='rgba(240, 240, 240, 0.5)',
                        paper_bgcolor='white',
                        xaxis=dict(
                            showgrid=False,
                            zeroline=False,
                            tickfont=dict(size=12, color='black')
                        ),
                        yaxis=dict(
                            rangemode='tozero',
                            showgrid=True,
                            gridcolor='rgba(200, 200, 200, 0.3)',
                            gridwidth=1,
                            zeroline=True,
                            zerolinecolor='gray',
                            zerolinewidth=1,
                            tickfont=dict(size=12, color='black')
                        ),
                        margin=dict(t=80, b=80, l=80, r=40),
                        bargap=0.3
                    )
                    st.plotly_chart(fig, use_container_width=True, key=f"booking_freq_chart_{len(frequency_analysis)}")
                    
                    # Show summary table
                    with st.expander("📊 View Detailed Frequency Data"):
                        freq_display = frequency_analysis.copy()
                        freq_display['Guests'] = freq_display['Guests'].apply(format_number)
                        freq_display['Avg Total Revenue'] = freq_display['Avg Total Revenue'].apply(format_currency)
                        freq_display['Avg Booking Value'] = freq_display['Avg Booking Value'].apply(format_currency)
                        st.dataframe(freq_display, use_container_width=True)
                else:
                    st.warning("No booking frequency data to display after aggregation.")
            else:
                st.warning("No guests found with bookings > 0. All guests may have 0 bookings.")
        else:
            missing_cols = []
            if 'TOTAL_BOOKINGS' not in guests_df.columns:
                missing_cols.append('TOTAL_BOOKINGS')
            if 'TOTAL_REVENUE' not in guests_df.columns:
                missing_cols.append('TOTAL_REVENUE')
            st.error(f"Missing required columns: {', '.join(missing_cols)}. Available columns: {', '.join(guests_df.columns.tolist())}")
    else:
        st.warning("No guest data available for revenue performance analysis")

st.markdown("---")
st.markdown("*Data refreshed every 5 minutes | Revenue insights for strategic decision-making*")
