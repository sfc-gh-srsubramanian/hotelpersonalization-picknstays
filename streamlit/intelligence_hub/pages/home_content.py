"""
Home Page Content for Intelligence Hub
"""

# Welcome message
st.markdown("""
Welcome to the **Hotel Intelligence Hub** - your comprehensive command center for portfolio performance, 
loyalty intelligence, and customer experience analytics across Summit Hospitality Group's global portfolio.
""")

# Navigation instructions
st.markdown("""
### 🗺️ Navigate the Hub

Use the sidebar to explore three specialized dashboards:

**📈 Portfolio Overview**  
Regional and brand-level performance metrics including occupancy, RevPAR, satisfaction scores, and operational KPIs. 
Identify outliers and track experience health across your portfolio.

**🎯 Loyalty Intelligence**  
Deep dive into guest segments, repeat stay drivers, revenue mix analysis, and retention opportunities. 
Understand what keeps your best guests coming back.

**💬 CX & Service Signals**  
Operational intelligence on service quality, issue drivers, sentiment trends, and at-risk guest identification. 
Proactive insights for service recovery and VIP guest management.
""")

# Quick stats overview
st.markdown("### 📊 Quick Portfolio Snapshot")

col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric(
        label="Global Properties",
        value="100",
        help="50 AMER + 30 EMEA + 20 APAC"
    )

with col2:
    st.metric(
        label="Brand Categories",
        value="4",
        help="Luxury, Select Service, Extended Stay, Urban/Modern"
    )

with col3:
    st.metric(
        label="Active Regions",
        value="3",
        help="Americas, EMEA, Asia-Pacific"
    )

with col4:
    st.metric(
        label="Data Sources",
        value="20+",
        help="PMS, Booking, CX, Sentiment, Amenities, Loyalty"
    )

# Getting started section
st.markdown("---")
st.markdown("### 🚀 Getting Started")

tab1, tab2, tab3 = st.tabs(["💡 Key Questions", "📖 Best Practices", "🤖 AI Assistant"])

with tab1:
    st.markdown("""
    **Portfolio Performance Questions:**
    - What's driving RevPAR changes across brands this month?
    - Which regions improved guest satisfaction—and why?
    - Do brands with higher guest-knowledge coverage perform better?
    
    **Loyalty & Retention Questions:**
    - Which amenities correlate most with repeat stays for Platinum guests?
    - Which loyalty segment is growing fastest—and what's driving it?
    - Where are we under-delivering experiences our best guests value?
    
    **CX & Service Questions:**
    - What are the top 2 issues driving dissatisfaction for high-value guests?
    - Which properties need attention based on service recovery performance?
    - What should teams know about our most valuable guests arriving today?
    """)

with tab2:
    st.markdown("""
    **Dashboard Best Practices:**
    
    1. **Start Broad, Then Narrow**: Begin with portfolio-level views, then drill into specific regions or brands
    2. **Compare Performance**: Always benchmark against brand averages and prior periods
    3. **Focus on Actionable**: Prioritize at-risk guests, outlier properties, and declining trends
    4. **Use Filters**: Regional and brand filters help isolate patterns
    5. **Export Data**: Download tables for deeper analysis or team presentations
    6. **Check Definitions**: Hover over ℹ️ icons for metric definitions and calculation methods
    """)

with tab3:
    st.markdown("""
    **AI-Powered Natural Language Queries:**
    
    The Hotel Intelligence Master Agent can answer complex questions using natural language:
    
    ```
    "Show me Diamond guests arriving tomorrow with past service issues"
    "Compare RevPAR performance across AMER regions for the last 30 days"
    "Which loyalty segments have declining satisfaction trends?"
    "What are the recurring service issues in EMEA luxury properties?"
    ```
    
    Access the AI Assistant through Snowflake Snowsight → Snowflake Intelligence → Agents
    
    **Agent Capabilities:**
    - Portfolio performance analysis
    - Loyalty segment insights
    - Service quality tracking
    - At-risk guest identification
    - Trend analysis across time periods
    - Regional and brand comparisons
    """)

# Footer
st.markdown("---")
st.markdown("""
<div style="text-align: center; color: #64748B; font-size: 0.9rem;">
Summit Hospitality Group | Hotel Intelligence Hub v2.0 | Powered by Snowflake ❄️
</div>
""", unsafe_allow_html=True)
