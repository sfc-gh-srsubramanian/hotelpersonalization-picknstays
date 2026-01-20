# 📊 Streamlit Dashboards - Deployment Guide

## Overview

5 enterprise-grade Streamlit dashboards have been created for the Hotel Personalization Platform:

1. **Guest 360 Dashboard** - Comprehensive guest profiles and journey visualization
2. **Personalization Hub** - AI-powered upsell and revenue optimization
3. **Amenity Performance** - Service and infrastructure analytics
4. **Revenue Analytics** - Financial performance and forecasting
5. **Executive Overview** - Strategic KPIs and business intelligence

---

## 📁 Dashboard Files

All dashboards are located in the `streamlit/` directory:

```
streamlit/
├── guest_360_dashboard.py          # Guest 360 Dashboard
├── personalization_hub.py           # Personalization Hub
├── amenity_performance.py           # Amenity Performance
├── revenue_analytics.py             # Revenue Analytics
├── executive_overview.py            # Executive Overview
└── shared/
    ├── data_loader.py              # Shared data loading functions
    └── viz_components.py           # Shared visualization components
```

---

## 🚀 Deployment Methods

### Method 1: Automated Deployment (via deploy.sh)

The `deploy.sh` script includes Step 7 for automated dashboard deployment:

```bash
./deploy.sh -c USWEST_DEMOACCOUNT
```

This will:
1. Create `STREAMLIT` schema in the database
2. Create a stage for dashboard files
3. Deploy all 5 dashboards using `snow streamlit deploy`
4. Grant appropriate RBAC permissions

### Method 2: Manual Deployment (Snowflake CLI)

If automated deployment encounters issues, deploy manually:

```bash
cd streamlit

# Deploy Guest 360 Dashboard
snow streamlit deploy \
  -c USWEST_DEMOACCOUNT \
  --database "HOTEL_PERSONALIZATION" \
  --schema "STREAMLIT" \
  --name "GUEST_360_DASHBOARD" \
  --file "guest_360_dashboard.py" \
  --replace

# Deploy Personalization Hub
snow streamlit deploy \
  -c USWEST_DEMOACCOUNT \
  --database "HOTEL_PERSONALIZATION" \
  --schema "STREAMLIT" \
  --name "PERSONALIZATION_HUB" \
  --file "personalization_hub.py" \
  --replace

# Deploy Amenity Performance
snow streamlit deploy \
  -c USWEST_DEMOACCOUNT \
  --database "HOTEL_PERSONALIZATION" \
  --schema "STREAMLIT" \
  --name "AMENITY_PERFORMANCE" \
  --file "amenity_performance.py" \
  --replace

# Deploy Revenue Analytics
snow streamlit deploy \
  -c USWEST_DEMOACCOUNT \
  --database "HOTEL_PERSONALIZATION" \
  --schema "STREAMLIT" \
  --name "REVENUE_ANALYTICS" \
  --file "revenue_analytics.py" \
  --replace

# Deploy Executive Overview
snow streamlit deploy \
  -c USWEST_DEMOACCOUNT \
  --database "HOTEL_PERSONALIZATION" \
  --schema "STREAMLIT" \
  --name "EXECUTIVE_OVERVIEW" \
  --file "executive_overview.py" \
  --replace
```

### Method 3: Snowsight UI Deployment

1. Log into Snowsight
2. Navigate to **Streamlit** section
3. Click **+ Streamlit App**
4. Choose **Upload from local file**
5. Upload each dashboard file
6. Configure:
   - **Database**: `HOTEL_PERSONALIZATION`
   - **Schema**: `STREAMLIT`
   - **Warehouse**: `HOTEL_PERSONALIZATION_WH`

---

## 🔐 RBAC Permissions

The deployment automatically grants permissions as follows:

| Dashboard | Admin | Guest Analyst | Revenue Analyst | Experience Analyst |
|-----------|-------|---------------|-----------------|-------------------|
| Guest 360 Dashboard | ✅ | ✅ | ❌ | ✅ |
| Personalization Hub | ✅ | ❌ | ✅ | ❌ |
| Amenity Performance | ✅ | ❌ | ❌ | ✅ |
| Revenue Analytics | ✅ | ❌ | ✅ | ❌ |
| Executive Overview | ✅ | ❌ | ✅ | ❌ |

**Roles**:
- `HOTEL_PERSONALIZATION_ROLE_ADMIN` - Full access to all dashboards
- `HOTEL_PERSONALIZATION_ROLE_GUEST_ANALYST` - Guest-focused analytics
- `HOTEL_PERSONALIZATION_ROLE_REVENUE_ANALYST` - Revenue and personalization
- `HOTEL_PERSONALIZATION_ROLE_EXPERIENCE_ANALYST` - Guest experience and amenities

---

## 📦 Required Python Packages

All dashboards use packages available in Snowflake's Anaconda channel:

- `streamlit` - Dashboard framework
- `pandas` - Data manipulation
- `plotly` - Interactive visualizations
- `snowflake-snowpark-python` - Snowflake data access

**No additional package installation required** - these are pre-installed in Streamlit in Snowflake.

---

## 🎯 Dashboard Features

### 1. Guest 360 Dashboard
- **Target Users**: Guest Service Managers, Concierge, Front Desk
- **Features**:
  - Guest search and profile overview
  - Stay history timeline
  - Spending analysis by category
  - Amenity usage heatmaps
  - AI-powered recommendations
  - Churn risk indicators

### 2. Personalization Hub
- **Target Users**: Revenue Managers, Sales, Marketing
- **Features**:
  - Opportunity matrix (value vs. propensity)
  - Propensity score distributions
  - Customer segmentation analysis
  - Churn risk management
  - Campaign target list export

### 3. Amenity Performance
- **Target Users**: Operations Managers, F&B Directors
- **Features**:
  - Revenue breakdown by service category
  - Satisfaction metrics and gauges
  - Infrastructure usage analytics
  - Performance scorecards
  - Peak time analysis

### 4. Revenue Analytics
- **Target Users**: Revenue Managers, Finance Teams
- **Features**:
  - Revenue mix (rooms vs. amenities)
  - Booking channel analysis
  - Customer segment performance
  - Trend analysis and forecasting
  - ADR, RevPAR, TRevPAR metrics

### 5. Executive Overview
- **Target Users**: C-Suite, Board Members
- **Features**:
  - Business health scorecard (6 key KPIs)
  - Customer lifetime value analysis
  - Segment performance matrix
  - AI-powered insights and recommendations
  - Top performers recognition

---

## 🔧 Troubleshooting

### Issue: "Current session is restricted. USE ROLE not allowed"

**Solution**: The connection has role restrictions. Use ACCOUNTADMIN role or remove `USE ROLE` statements from SQL files.

### Issue: Dashboard shows "No data available"

**Checklist**:
1. ✅ Ensure data is loaded: `SELECT COUNT(*) FROM GOLD.GUEST_360_VIEW_ENHANCED`
2. ✅ Check warehouse is running: `SHOW WAREHOUSES LIKE 'HOTEL_PERSONALIZATION_WH'`
3. ✅ Verify permissions: User role has SELECT on GOLD tables
4. ✅ Refresh cache: Click "Rerun" button in Streamlit

### Issue: Import errors in dashboard

**Solution**: All required packages are pre-installed. If errors occur:
1. Check Python version compatibility (should use Python 3.11)
2. Verify `shared/` modules are uploaded alongside main dashboard files
3. Ensure relative imports are correct

### Issue: Plotly charts not rendering

**Solution**: 
1. Plotly is included in Snowflake's Anaconda channel
2. If issues persist, use `st.plotly_chart(fig, use_container_width=True)`
3. Check browser console for JavaScript errors

---

## 📊 Accessing Dashboards

Once deployed, access dashboards via Snowsight:

1. Log into Snowsight
2. Navigate to **Streamlit** section in left sidebar
3. Select database: `HOTEL_PERSONALIZATION`
4. Select schema: `STREAMLIT`
5. Click on any dashboard to launch

**Direct URLs** (after deployment):
- Format: `https://<account>.snowflakecomputing.com/streamlit/<database>.<schema>.<dashboard_name>`

---

## 🧹 Cleanup

To remove all dashboards:

```bash
./clean.sh
```

This will:
1. Drop all 5 Streamlit apps
2. Drop the STREAMLIT stage
3. Remove all associated permissions

---

## 📈 Performance Optimization

### Data Caching
All data loading functions use `@st.cache_data(ttl=300)` for 5-minute caching:
- Reduces query load on warehouse
- Improves dashboard responsiveness
- Automatic cache invalidation

### Query Optimization
- Dashboards use Snowpark DataFrame API for efficient queries
- Filters applied at database level (not in Python)
- Aggregations performed in Snowflake

### Best Practices
1. Use appropriate warehouse size (MEDIUM recommended)
2. Enable auto-suspend for cost optimization
3. Monitor query performance in Query History
4. Use filters to limit data volume

---

## 🎨 Customization

### Branding
Update `shared/viz_components.py` → `apply_custom_css()` function to customize:
- Colors and themes
- Fonts and typography
- Layout and spacing
- Logo and branding elements

### Data Sources
Modify `shared/data_loader.py` to:
- Add new data sources
- Change caching TTL
- Customize query logic
- Add data transformations

### Visualizations
Extend `shared/viz_components.py` to:
- Add new chart types
- Create custom components
- Modify color schemes
- Add interactive features

---

## 📝 Next Steps

1. **Deploy Dashboards**: Use one of the deployment methods above
2. **Grant Access**: Assign users to appropriate roles
3. **Training**: Provide user training on dashboard features
4. **Feedback**: Collect user feedback for improvements
5. **Monitor**: Track dashboard usage and performance

---

## 🆘 Support

For issues or questions:
1. Check this guide first
2. Review Snowflake Streamlit documentation
3. Check `streamlit/` code for inline comments
4. Review deployment logs for error messages

---

**Dashboard Suite Version**: 1.0  
**Last Updated**: 2026-01-11  
**Snowflake Compatibility**: Streamlit in Snowflake (SiS)  
**Python Version**: 3.11
