"""
Data loading utilities for Hotel Intelligence Hub
Provides cached data loading functions for all Gold tables
"""

import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd

# Get Snowpark session
session = get_active_session()

# Note: We use fully qualified table names (DATABASE.SCHEMA.TABLE) in all queries
# since USE statements are not allowed in Streamlit apps

@st.cache_data(ttl=0)  # No cache - always fresh data
def load_portfolio_kpis(days_back=30, hotel_id=None, region=None, brand=None):
    """
    Load portfolio performance KPIs from Gold table
    
    Args:
        days_back: Number of days to look back (default 30)
        hotel_id: Optional filter by specific hotel
        region: Optional filter by region
        brand: Optional filter by brand
    
    Returns:
        pandas DataFrame with portfolio KPIs
    """
    query = f"""
    SELECT *
    FROM HOTEL_PERSONALIZATION.GOLD.PORTFOLIO_PERFORMANCE_KPIS
    WHERE performance_date >= DATEADD(day, -{days_back}, CURRENT_DATE())
    """
    
    if hotel_id:
        query += f" AND hotel_id = '{hotel_id}'"
    if region:
        query += f" AND region = '{region}'"
    if brand:
        query += f" AND brand = '{brand}'"
    
    query += " ORDER BY performance_date DESC, hotel_id"
    
    return session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def load_loyalty_segments():
    """
    Load loyalty segment intelligence from Gold table
    
    Returns:
        pandas DataFrame with loyalty segment data
    """
    query = """
    SELECT *
    FROM HOTEL_PERSONALIZATION.GOLD.LOYALTY_SEGMENT_INTELLIGENCE
    ORDER BY total_revenue DESC
    """
    return session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def load_cx_signals(region=None, brand=None):
    """
    Load CX and service signals from Gold table
    
    Args:
        region: Optional filter by region
        brand: Optional filter by brand
    
    Returns:
        pandas DataFrame with CX signals
    """
    query = """
    SELECT *
    FROM HOTEL_PERSONALIZATION.GOLD.EXPERIENCE_SERVICE_SIGNALS
    WHERE 1=1
    """
    
    if region:
        query += f" AND region = '{region}'"
    if brand:
        query += f" AND brand = '{brand}'"
    
    query += " ORDER BY at_risk_high_value_guests_count DESC, vip_watchlist_count DESC"
    
    return session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def load_service_cases_enriched(days_back=90, is_vip_only=False):
    """
    Load enriched service cases from Silver table
    
    Args:
        days_back: Number of days to look back
        is_vip_only: If True, only return VIP cases
    
    Returns:
        pandas DataFrame with enriched service cases
    """
    query = f"""
    SELECT *
    FROM HOTEL_PERSONALIZATION.SILVER.SERVICE_CASES_ENRICHED
    WHERE reported_at >= DATEADD(day, -{days_back}, CURRENT_DATE())
    """
    
    if is_vip_only:
        query += " AND is_vip = TRUE"
    
    query += " ORDER BY reported_at DESC"
    
    return session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def load_future_arrivals(days_ahead=7):
    """
    Load future bookings for VIP watchlist
    
    Args:
        days_ahead: Number of days ahead to look (default 7)
    
    Returns:
        pandas DataFrame with future arrivals and guest context
    """
    query = f"""
    WITH future_arrivals AS (
        SELECT 
            bh.booking_id,
            bh.guest_id,
            bh.hotel_id,
            bh.check_in_date,
            bh.check_out_date,
            bh.num_nights,
            bh.total_amount,
            hp.brand,
            hp.region,
            hp.city
        FROM HOTEL_PERSONALIZATION.BRONZE.BOOKING_HISTORY bh
        JOIN HOTEL_PERSONALIZATION.BRONZE.HOTEL_PROPERTIES hp ON bh.hotel_id = hp.hotel_id
        WHERE bh.check_in_date BETWEEN CURRENT_DATE() AND DATEADD(day, {days_ahead}, CURRENT_DATE())
          AND LOWER(bh.booking_status) = 'confirmed'
    ),
    guest_metrics AS (
        SELECT 
            guest_id,
            SUM(total_charges) as lifetime_value,
            COUNT(stay_id) as total_stays,
            AVG(guest_satisfaction_score) as avg_satisfaction
        FROM HOTEL_PERSONALIZATION.BRONZE.STAY_HISTORY
        GROUP BY guest_id
    ),
    guest_context AS (
        SELECT 
            fa.*,
            gp.first_name,
            gp.last_name,
            gp.email,
            lm.tier_level,
            COALESCE(gm.lifetime_value, 0) as lifetime_value,
            COALESCE(gm.total_stays, 0) as total_stays,
            COALESCE(gm.avg_satisfaction, 0) as avg_satisfaction,
            -- Count of service cases in last 90 days
            COUNT(DISTINCT sc.case_id) as prior_issue_count,
            -- Most recent sentiment
            MAX(sd.sentiment_score) as latest_sentiment_score,
            -- Preference tags (simplified - just first preference)
            MAX(rp.room_type_preference) as room_preference
        FROM future_arrivals fa
        LEFT JOIN HOTEL_PERSONALIZATION.BRONZE.GUEST_PROFILES gp ON fa.guest_id = gp.guest_id
        LEFT JOIN HOTEL_PERSONALIZATION.BRONZE.LOYALTY_PROGRAM lm ON fa.guest_id = lm.guest_id
        LEFT JOIN guest_metrics gm ON fa.guest_id = gm.guest_id
        LEFT JOIN HOTEL_PERSONALIZATION.BRONZE.SERVICE_CASES sc ON fa.guest_id = sc.guest_id 
            AND sc.reported_at >= DATEADD(day, -90, CURRENT_DATE())
        LEFT JOIN HOTEL_PERSONALIZATION.BRONZE.SENTIMENT_DATA sd ON fa.guest_id = sd.guest_id
        LEFT JOIN HOTEL_PERSONALIZATION.BRONZE.ROOM_PREFERENCES rp ON fa.guest_id = rp.guest_id
        GROUP BY 
            fa.booking_id, fa.guest_id, fa.hotel_id, fa.check_in_date, fa.check_out_date,
            fa.num_nights, fa.total_amount, fa.brand, fa.region, fa.city,
            gp.first_name, gp.last_name, gp.email,
            lm.tier_level, gm.lifetime_value, gm.total_stays, gm.avg_satisfaction
    )
    SELECT 
        *,
        CASE 
            WHEN lifetime_value > 10000 AND prior_issue_count > 0 THEN 90
            WHEN tier_level IN ('Diamond', 'Gold') AND prior_issue_count > 0 THEN 75
            WHEN latest_sentiment_score < 0 THEN 60
            WHEN prior_issue_count > 2 THEN 50
            ELSE 20
        END as churn_risk_score
    FROM guest_context
    ORDER BY churn_risk_score DESC, check_in_date
    """
    return session.sql(query).to_pandas()

@st.cache_data(ttl=600)  # 10-minute cache for list data
def get_available_regions():
    """Get list of available regions"""
    query = "SELECT DISTINCT region FROM HOTEL_PERSONALIZATION.BRONZE.HOTEL_PROPERTIES ORDER BY region"
    return session.sql(query).to_pandas()['REGION'].tolist()

@st.cache_data(ttl=600)
def get_available_brands():
    """Get list of available brands"""
    query = "SELECT DISTINCT brand FROM HOTEL_PERSONALIZATION.BRONZE.HOTEL_PROPERTIES ORDER BY brand"
    return session.sql(query).to_pandas()['BRAND'].tolist()

@st.cache_data(ttl=600)
def get_available_hotels():
    """Get list of available hotels with details"""
    query = """
    SELECT hotel_id, hotel_name, brand, region, city
    FROM HOTEL_PERSONALIZATION.BRONZE.HOTEL_PROPERTIES
    ORDER BY hotel_name
    """
    return session.sql(query).to_pandas()

def clear_all_caches():
    """Clear all cached data"""
    st.cache_data.clear()
