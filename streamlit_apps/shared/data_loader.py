"""
Shared Data Loading Functions for Hotel Personalization Dashboards
"""
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark import DataFrame
from snowflake.snowpark.functions import col, sum as sum_, avg, count, max as max_, min as min_
import streamlit as st

@st.cache_data(ttl=300)
def get_guest_360_data(limit=None):
    """Load guest 360 view data"""
    session = get_active_session()
    df = session.table("GOLD.GUEST_360_VIEW_ENHANCED")
    if limit:
        df = df.limit(limit)
    return df.to_pandas()

@st.cache_data(ttl=300)
def get_guest_by_id(guest_id):
    """Get detailed guest profile by ID"""
    session = get_active_session()
    df = session.table("GOLD.GUEST_360_VIEW_ENHANCED") \
        .filter(col("GUEST_ID") == guest_id)
    return df.to_pandas()

@st.cache_data(ttl=300)
def get_personalization_scores(limit=None):
    """Load personalization scores data"""
    session = get_active_session()
    df = session.table("GOLD.PERSONALIZATION_SCORES_ENHANCED")
    if limit:
        df = df.limit(limit)
    return df.to_pandas()

@st.cache_data(ttl=300)
def get_amenity_analytics():
    """Load amenity analytics data"""
    session = get_active_session()
    df = session.table("GOLD.AMENITY_ANALYTICS")
    return df.to_pandas()

@st.cache_data(ttl=300)
def get_stays_processed(limit=None):
    """Load processed stays data"""
    session = get_active_session()
    df = session.table("SILVER.STAYS_PROCESSED")
    if limit:
        df = df.limit(limit)
    return df.to_pandas()

@st.cache_data(ttl=300)
def get_bookings_enriched(limit=None):
    """Load enriched bookings data"""
    session = get_active_session()
    df = session.table("SILVER.BOOKINGS_ENRICHED")
    if limit:
        df = df.limit(limit)
    return df.to_pandas()

@st.cache_data(ttl=300)
def get_amenity_spending(guest_id=None):
    """Load amenity spending data"""
    session = get_active_session()
    df = session.table("SILVER.AMENITY_SPENDING_ENRICHED")
    if guest_id:
        df = df.filter(col("GUEST_ID") == guest_id)
    return df.to_pandas()

@st.cache_data(ttl=300)
def get_amenity_usage(guest_id=None):
    """Load amenity usage data"""
    session = get_active_session()
    df = session.table("SILVER.AMENITY_USAGE_ENRICHED")
    if guest_id:
        df = df.filter(col("GUEST_ID") == guest_id)
    return df.to_pandas()

@st.cache_data(ttl=300)
def search_guests(search_term):
    """Search guests by name or email"""
    session = get_active_session()
    search_pattern = f"%{search_term}%"
    df = session.table("GOLD.GUEST_360_VIEW_ENHANCED") \
        .filter(
            (col("FIRST_NAME").like(search_pattern)) |
            (col("LAST_NAME").like(search_pattern)) |
            (col("EMAIL").like(search_pattern))
        ) \
        .select("GUEST_ID", "FIRST_NAME", "LAST_NAME", "EMAIL", "LOYALTY_TIER", "TOTAL_REVENUE") \
        .limit(50)
    return df.to_pandas()

@st.cache_data(ttl=600)
def get_summary_metrics():
    """Get high-level summary metrics"""
    session = get_active_session()
    
    # Guest metrics
    guest_df = session.table("GOLD.GUEST_360_VIEW_ENHANCED")
    total_guests = guest_df.count()
    total_revenue = guest_df.select(sum_("TOTAL_REVENUE").alias("total")).to_pandas()['TOTAL'].iloc[0]
    avg_satisfaction = guest_df.select(avg("AVG_SATISFACTION_SCORE").alias("avg")).to_pandas()['AVG'].iloc[0]
    
    return {
        'total_guests': total_guests,
        'total_revenue': total_revenue,
        'avg_satisfaction': avg_satisfaction
    }

def clear_cache():
    """Clear all cached data"""
    st.cache_data.clear()
