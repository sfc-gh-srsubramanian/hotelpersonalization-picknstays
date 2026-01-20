"""
Debug page to show raw data directly from database (no caching)
"""

import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd

st.title("🔍 Debug Data View")
st.markdown("**This page shows raw data directly from the database with NO caching**")

# Get session
session = get_active_session()
# Note: USE statements not allowed in Streamlit, using fully qualified table names

# Clear ALL caches
if st.button("🗑️ Clear ALL Caches"):
    st.cache_data.clear()
    st.cache_resource.clear()
    st.success("All caches cleared! Refresh the page.")

st.markdown("---")
st.markdown("### 📊 Portfolio KPIs (Last 30 Days) - Raw Query")

# Execute query without any caching
query = """
SELECT 
    COUNT(DISTINCT performance_date) as num_days,
    COUNT(DISTINCT hotel_id) as num_hotels,
    SUM(total_revenue) as total_revenue,
    SUM(total_rooms) as total_room_days,
    SUM(rooms_occupied) as total_occupied_days,
    ROUND(SUM(rooms_occupied) * 100.0 / SUM(total_rooms), 2) as calc_occupancy_pct,
    ROUND(SUM(total_revenue) / NULLIF(SUM(rooms_occupied), 0), 2) as calc_adr,
    ROUND(SUM(total_revenue) / NULLIF(SUM(total_rooms), 0), 2) as calc_revpar,
    ROUND(AVG(satisfaction_index), 2) as avg_satisfaction
FROM HOTEL_PERSONALIZATION.GOLD.PORTFOLIO_PERFORMANCE_KPIS
WHERE performance_date >= DATEADD(day, -30, CURRENT_DATE())
"""

try:
    df = session.sql(query).to_pandas()
    
    st.success("✅ Query executed successfully (no cache)")
    
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric("Occupancy %", f"{df['CALC_OCCUPANCY_PCT'].iloc[0]:.2f}%")
    
    with col2:
        st.metric("ADR", f"${df['CALC_ADR'].iloc[0]:.0f}")
    
    with col3:
        st.metric("RevPAR", f"${df['CALC_REVPAR'].iloc[0]:.0f}")
    
    with col4:
        st.metric("Satisfaction", f"{df['AVG_SATISFACTION'].iloc[0]:.1f}/100")
    
    st.markdown("---")
    st.markdown("### 📋 Raw Query Results")
    st.dataframe(df, use_container_width=False)
    
    st.markdown("---")
    st.markdown("### 📅 Date Range Check")
    date_query = """
    SELECT 
        MIN(performance_date) as earliest_date,
        MAX(performance_date) as latest_date,
        COUNT(DISTINCT performance_date) as total_days,
        MAX(refreshed_at) as last_refresh
    FROM HOTEL_PERSONALIZATION.GOLD.PORTFOLIO_PERFORMANCE_KPIS
    WHERE performance_date >= DATEADD(day, -30, CURRENT_DATE())
    """
    df_dates = session.sql(date_query).to_pandas()
    st.dataframe(df_dates, use_container_width=False)
    
except Exception as e:
    st.error(f"❌ Error executing query: {str(e)}")
    st.exception(e)

st.markdown("---")
st.markdown("### 🔧 Connection Info")
st.write(f"Current database: {session.sql('SELECT CURRENT_DATABASE()').collect()[0][0]}")
st.write(f"Current schema: {session.sql('SELECT CURRENT_SCHEMA()').collect()[0][0]}")
st.write(f"Current role: {session.sql('SELECT CURRENT_ROLE()').collect()[0][0]}")
