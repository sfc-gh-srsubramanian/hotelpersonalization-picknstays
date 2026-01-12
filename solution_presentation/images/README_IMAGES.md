# Solution Presentation Images

This folder contains visual assets for the Hotel Personalization solution presentation.

## Current Images

✅ **architecture_overview.png** - Core medallion architecture (Bronze → Silver → Gold → Semantic)  
✅ **data_sources.png** - Data source systems and ingestion  
✅ **intelligence_agents.png** - Snowflake Intelligence Agents overview  
✅ **medallion_architecture.png** - Detailed medallion layer breakdown  
✅ **ml_scoring_models.png** - Machine learning scoring models  
✅ **unified_amenity_analytics.png** - Amenity analytics framework  

## Recommended Image Updates

### 1. Update architecture_overview.png

**Current State**: Shows layers up to Semantic Layer (with AI Agents)

**Recommended Update**: Add a "Consumption Layer" at the bottom showing:
- **Streamlit Dashboard** icon/box with "5 Interactive Pages"
- **Snowflake Intelligence UI** access
- **Direct SQL/API Access**
- **BI Tool Integration** (Tableau, PowerBI, etc.)

**Suggested Layout**:
```
┌─────────────────────────────────────────────────┐
│         Data Sources (5 systems)                │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│    BRONZE LAYER - 13 Raw Tables                 │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│    SILVER LAYER - 7 Enriched Tables             │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│    GOLD LAYER - 3 Analytics Tables              │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│    SEMANTIC LAYER                               │
│    3 Views + 5 Intelligence Agents              │
└─────────────────┬───────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────────┐
│    CONSUMPTION LAYER                            │
│  ┌───────────┐  ┌──────────┐  ┌──────────────┐ │
│  │ Streamlit │  │ Snowflake│  │  BI Tools    │ │
│  │ Dashboard │  │   Intel  │  │ Integration  │ │
│  │ 5 Pages   │  │    UI    │  │ (Tableau,etc)│ │
│  └───────────┘  └──────────┘  └──────────────┘ │
└─────────────────────────────────────────────────┘
```

### 2. Optional: Create Streamlit Dashboard Screenshots

If you'd like to include actual dashboard screenshots, capture these 5 pages:

1. **streamlit_guest_360.png** - Guest 360 Dashboard page
   - Show the guest table with filters and analytics tabs
   
2. **streamlit_personalization_hub.png** - Personalization Hub page
   - Show the opportunity matrix scatter plot
   
3. **streamlit_amenity_performance.png** - Amenity Performance page
   - Show revenue analysis and satisfaction charts
   
4. **streamlit_revenue_analytics.png** - Revenue Analytics page
   - Show revenue mix breakdown
   
5. **streamlit_executive_overview.png** - Executive Overview page
   - Show the 6-KPI business health scorecard

**How to Capture Screenshots**:
1. Deploy the Streamlit app: `./deploy.sh --only-dashboards`
2. Access via Snowsight: Projects → Streamlit → "Hotel Personalization - Pic'N Stays"
3. Navigate to each page and capture screenshots (1920x1080 recommended)
4. Save to this folder with the naming convention above
5. Update `Hotel_Personalization_Solution_Overview.md` to reference the images

## Image Creation Tools

- **Diagram Updates**: Use tools like:
  - draw.io (diagrams.net)
  - Lucidchart
  - Excalidraw
  - PowerPoint/Keynote
  
- **Screenshots**: Use tools like:
  - macOS: Cmd+Shift+4
  - Windows: Snipping Tool or Snip & Sketch
  - Chrome DevTools for consistent sizing

## Color Scheme

To maintain consistency with existing diagrams:
- **Bronze Layer**: Light yellow (#FFF9C4)
- **Silver Layer**: Light blue (#BBDEFB)
- **Gold Layer**: Light yellow (#FFF59D)
- **Semantic Layer**: Light purple (#E1BEE7)
- **Consumption Layer**: Light green (#C8E6C9) - suggested
- **Data Sources**: Light blue (#B3E5FC)

## File Format Recommendations

- **PNG**: Preferred for screenshots and diagrams (transparency support)
- **Resolution**: Minimum 1200px width for clarity in presentations
- **Compression**: Use moderate compression to balance quality and file size
