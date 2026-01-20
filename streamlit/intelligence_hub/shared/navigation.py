"""
Shared Navigation Component for Intelligence Hub
"""

import streamlit as st

def render_sidebar_nav(current_page="home"):
    """
    Render consistent sidebar navigation across all pages
    
    Args:
        current_page: One of 'home', 'portfolio', 'loyalty', 'cx'
    """
    
    pages = {
        'home': '🏠 Home',
        'portfolio': '📈 Portfolio Overview',
        'loyalty': '🎯 Loyalty Intelligence',
        'cx': '💬 CX & Service Signals'
    }
    
    # Logo
    st.sidebar.image("https://via.placeholder.com/200x60/1E3A8A/FFFFFF?text=Summit+Hospitality")
    st.sidebar.markdown("---")
    
    # Navigation Section
    st.sidebar.markdown("### 📊 Navigation")
    st.sidebar.markdown("")
    
    nav_html = '<div style="background-color: white; padding: 1rem; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">'
    nav_html += '<p style="font-weight: 600; color: #1E3A8A; margin-bottom: 0.75rem;">Select Dashboard:</p>'
    nav_html += '<div style="margin-left: 0.5rem;">'
    
    for key, label in pages.items():
        if key == current_page:
            nav_html += f'<p style="margin: 0.5rem 0;"><strong>{label}</strong> <span style="color: #10B981;">← Current</span></p>'
        else:
            nav_html += f'<p style="margin: 0.5rem 0; color: #64748B;">{label}</p>'
    
    nav_html += '</div>'
    nav_html += '<p style="margin-top: 1rem; font-size: 0.875rem; color: #64748B;">💡 Use sidebar navigation to switch dashboards</p>'
    nav_html += '</div>'
    
    st.sidebar.markdown(nav_html, unsafe_allow_html=True)
    st.sidebar.markdown("---")
    
    # About Section
    st.sidebar.markdown("### 📘 About This Platform")
    st.sidebar.markdown("""
    **AI-powered executive intelligence with:**
    
    - 🌍 Global portfolio analytics
    - 🎯 Loyalty segment intelligence  
    - 💬 Service quality monitoring
    - 📊 Real-time operational KPIs
    - 🤖 Natural language AI agents
    """)
    st.sidebar.markdown("---")
    
    # Data Coverage
    st.sidebar.markdown("### 📊 Data Sources")
    
    col1, col2 = st.sidebar.columns(2)
    with col1:
        st.metric("Properties", "100", help="50 AMER, 30 EMEA, 20 APAC")
        st.metric("Bookings", "120K", help="Last 18 months + 30 days ahead")
    with col2:
        st.metric("Guests", "40K", help="Active guest profiles")
        st.metric("Data Points", "45K+", help="CX & service intelligence")
    
    st.sidebar.markdown("---")
    
    # Quick Actions
    st.sidebar.markdown("### ⚡ Quick Actions")
    
    if st.sidebar.button("🔄 Clear Cache"):
        st.cache_data.clear()
        st.sidebar.success("✅ Cache cleared!")
    
    st.sidebar.markdown("---")
    
    # Footer
    st.sidebar.caption("**Powered by Snowflake ❄️**")
    st.sidebar.caption("Intelligence Hub v2.0")
