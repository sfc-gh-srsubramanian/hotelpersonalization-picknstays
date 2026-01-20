"""
Hotel Personalization Pick'N Stays - Main Application
Executive dashboard for Summit Hospitality Group portfolio intelligence
"""

import streamlit as st
from snowflake.snowpark.context import get_active_session

# Page configuration
st.set_page_config(
    page_title="Hotel Personalization Pick'N Stays",
    page_icon="🏨",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Initialize Snowpark session
session = get_active_session()

# Custom CSS for better styling
st.markdown("""
    <style>
    .main-header {
        font-size: 2.5rem;
        font-weight: bold;
        color: #1E3A8A;
        text-align: center;
        padding: 1rem 0;
        border-bottom: 3px solid #1E3A8A;
        margin-bottom: 2rem;
    }
    .sidebar .sidebar-content {
        background-color: #f0f2f6;
    }
    /* Hide default Streamlit page navigation */
    [data-testid="stSidebarNav"] {
        display: none;
    }
    </style>
""", unsafe_allow_html=True)

# Main header
st.markdown('<div class="main-header">🏨 Hotel Personalization Pick\'N Stays</div>', unsafe_allow_html=True)

# Sidebar navigation
st.sidebar.title("🏨 Navigation")
st.sidebar.markdown("---")

page = st.sidebar.radio(
    "Select Dashboard:",
    [
        "🏠 Intelligence Hub Home",
        "📈 Portfolio Overview",
        "🎯 Loyalty Intelligence",
        "💬 CX & Service Signals"
    ],
    index=0
)

st.sidebar.markdown("---")

# Global Refresh Data button
if st.sidebar.button("🔄 Refresh Data", help="Clear all cached data and reload from database"):
    st.cache_data.clear()
    st.cache_resource.clear()
    st.experimental_rerun()

st.sidebar.markdown("---")
st.sidebar.info("""
**About This Platform:**

AI-powered executive intelligence with:
- 🌍 Global portfolio analytics (100 properties)
- 🎯 Loyalty segment intelligence  
- 💬 Service quality monitoring
- 📊 Real-time operational KPIs
- 🤖 Natural language AI agents

**Data Sources:**
- 100 properties (50 AMER, 30 EMEA, 20 APAC)
- 100,000 guest profiles  
- 1.9M stays (12 months)
- 50,000 loyalty members
- 5,000+ CX & service cases
""")

st.sidebar.markdown("---")
st.sidebar.caption("© 2026 Hotel Intelligence Hub | Powered by Snowflake ❄️")

# Load the selected page content
if page == "🏠 Intelligence Hub Home":
    exec(open('pages/home_content.py').read())

elif page == "📈 Portfolio Overview":
    exec(open('pages/1_Portfolio_Overview.py').read())

elif page == "🎯 Loyalty Intelligence":
    exec(open('pages/2_Loyalty_Intelligence.py').read())

elif page == "💬 CX & Service Signals":
    exec(open('pages/3_CX_Service_Signals.py').read())
