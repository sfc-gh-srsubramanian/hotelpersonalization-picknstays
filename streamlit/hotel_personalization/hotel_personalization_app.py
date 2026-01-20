"""
Hotel Personalization - Pic'N Stays
Unified Streamlit Application with Multi-Page Navigation
"""
import streamlit as st

# Page configuration
st.set_page_config(
    page_title="Hotel Personalization - Pic'N Stays",
    page_icon="🏨",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for better styling
st.markdown("""
    <style>
    .main-header {
        font-size: 2.5rem;
        font-weight: bold;
        color: #1f77b4;
        text-align: center;
        padding: 1rem 0;
        border-bottom: 3px solid #1f77b4;
        margin-bottom: 2rem;
    }
    .sidebar .sidebar-content {
        background-color: #f0f2f6;
    }
    </style>
""", unsafe_allow_html=True)

# Main header
st.markdown('<div class="main-header">🏨 Hotel Personalization - Pic\'N Stays</div>', unsafe_allow_html=True)

# Sidebar navigation
st.sidebar.title("📊 Navigation")
st.sidebar.markdown("---")

page = st.sidebar.radio(
    "Select Dashboard:",
    [
        "🏠 Executive Overview",
        "👤 Guest 360 View",
        "🎯 Personalization Hub",
        "🛎️ Amenity Performance",
        "💰 Revenue Analytics"
    ],
    index=0
)

st.sidebar.markdown("---")
st.sidebar.info("""
**About This Platform:**

AI-powered guest experience management with:
- Guest 360° analytics
- ML-based personalization scoring  
- Amenity performance tracking
- Revenue optimization insights

**Data Sources:**
- 10,000 guest profiles
- 25,000 bookings
- 30,000+ amenity transactions
""")

st.sidebar.markdown("---")
st.sidebar.caption("© 2026 Hotel Personalization Platform")

# Load the selected page content
if page == "🏠 Executive Overview":
    exec(open('executive_overview.py').read())

elif page == "👤 Guest 360 View":
    exec(open('guest_360_dashboard.py').read())

elif page == "🎯 Personalization Hub":
    exec(open('personalization_hub.py').read())

elif page == "🛎️ Amenity Performance":
    exec(open('amenity_performance.py').read())

elif page == "💰 Revenue Analytics":
    exec(open('revenue_analytics.py').read())
