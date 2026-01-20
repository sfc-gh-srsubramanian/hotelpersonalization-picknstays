# Hotel Intelligence Hub - User Guide

## Table of Contents
1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Dashboard Tabs](#dashboard-tabs)
4. [KPI Definitions](#kpi-definitions)
5. [Use Cases by Persona](#use-cases-by-persona)
6. [AI-Powered Analysis](#ai-powered-analysis)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

---

## Overview

### What is the Hotel Intelligence Hub?

The **Hotel Intelligence Hub** is an executive dashboard application providing portfolio-level intelligence across Summit Hospitality Group's **100 global properties** (50 AMER, 30 EMEA, 20 APAC). It is designed specifically for C-suite executives and senior leadership to monitor portfolio performance, understand guest loyalty drivers, and manage service quality proactively.

### Key Capabilities

- **Portfolio Performance Monitoring**: Track occupancy, RevPAR, ADR, and satisfaction across all properties, brands, and regions
- **Loyalty Intelligence**: Understand what drives repeat stays and identify retention opportunities
- **CX Operations**: Monitor service quality and proactively manage VIP guest arrivals
- **Global Coverage**: Analyze performance across AMER, EMEA, and APAC regions
- **Self-Explanatory Metrics**: Every KPI includes a definition tooltip for clarity
- **AI Integration**: Pre-configured natural language queries for deeper analysis

### Target Personas

**1. Brand & Portfolio Leadership** (COO, EVP Operations, Regional Leaders)
- **Primary Tab**: Portfolio Overview
- **Key Questions**: "Where are we winning/losing and why?"
- **Use Cases**: Outlier identification, regional consistency, performance benchmarking

**2. Loyalty & Customer Strategy** (CMO, VP Loyalty, VP Customer)
- **Primary Tab**: Loyalty Intelligence
- **Key Questions**: "What drives loyalty—and where should we invest?"
- **Use Cases**: Segment behavior analysis, retention strategies, LTV optimization

**3. Guest Services Leadership** (CX Leaders, Service Recovery Teams)
- **Primary Tab**: CX & Service Signals
- **Key Questions**: "Do we know our best guests and prevent churn?"
- **Use Cases**: VIP recognition, proactive service, issue trend identification

---

## Getting Started

### Accessing the Dashboard

#### Via Snowsight UI (Recommended)

1. **Log in to Snowsight**: Navigate to `https://app.snowflake.com`
2. **Go to Projects**: Click on **Projects** in the left sidebar
3. **Select Streamlit**: Choose **Streamlit** from the project types
4. **Open Intelligence Hub**: Click on `HOTEL_PERSONALIZATION.GOLD` → **"Hotel Intelligence Hub"**

#### Via Direct URL

Replace `[your-account-locator]` with your Snowflake account identifier:

```
https://app.snowflake.com/[your-account-locator]/#/streamlit-apps/HOTEL_PERSONALIZATION.GOLD.HOTEL_INTELLIGENCE_HUB
```

#### Via Command Line (Status Check)

```bash
# Check Intelligence Hub deployment status
./run.sh intel-hub

# Redeploy Intelligence Hub
./deploy.sh --only-intel-hub
```

### Navigation

The Intelligence Hub consists of three main tabs accessible via the sidebar:

1. **📈 Portfolio Overview** - Executive command center
2. **🎯 Loyalty Intelligence** - Segment behavior & retention
3. **💬 CX & Service Signals** - Service quality & VIP management

Use the sidebar to navigate between tabs. Filters are available at the top of each tab.

### Understanding KPI Tooltips

Every KPI card includes a **ℹ️ icon** with expandable definitions. Click to view:
- **Metric Definition**: What the KPI measures
- **Calculation Method**: How it's computed
- **Industry Benchmark**: Target range or threshold
- **Business Context**: Why it matters

---

## Dashboard Tabs

### 1. Portfolio Overview 📈

**Purpose**: Regional and brand-level performance monitoring

#### Filters
- **Region**: All, AMER, EMEA, APAC
- **Brand**: All, Summit Peak Reserve (Luxury), Summit Ice (Select), Summit Permafrost (Extended Stay), The Snowline (Urban/Modern)
- **Time Period**: Last 7, 30, or 90 days

#### KPI Cards

**Occupancy %**
- Definition: Percentage of available rooms occupied
- Target: 65-75% (industry benchmark)
- What to Watch: <60% indicates underperformance; >85% may indicate pricing opportunity

**ADR (Average Daily Rate)**
- Definition: Average revenue per occupied room per day
- What to Watch: Declining ADR may indicate pricing pressure or market shifts

**RevPAR (Revenue Per Available Room)**
- Definition: Primary hotel performance metric (ADR × Occupancy)
- What to Watch: Primary indicator of property health; benchmark against brand and region

**Repeat Stay Rate %**
- Definition: Percentage of guests who have stayed more than once
- Target: >40% indicates strong loyalty
- What to Watch: Declining rate may signal loyalty program or service quality issues

**Guest Satisfaction Index**
- Definition: Average satisfaction score (1-5 scale) from post-stay surveys
- Target: 4.0+ for competitive positioning
- What to Watch: Scores <3.8 require immediate attention

#### Charts

**RevPAR by Brand/Region**: Identifies top and bottom performers
- **Use**: Benchmark brand performance and identify outliers
- **Action**: Click bars to drill into specific properties

**Occupancy & ADR Trend**: Dual-axis time series showing relationship
- **Use**: Identify if RevPAR changes are driven by occupancy or pricing
- **Action**: Look for inverse trends (occupancy up, ADR down) indicating pricing issues

**Experience Health Heatmap**: Satisfaction by Brand × Region
- **Use**: Identify geographic or brand-specific satisfaction issues
- **Action**: Dark red cells (<3.5) require immediate root cause analysis

#### Outliers & Exceptions Table

Properties flagged for:
- **RevPAR Δ vs Brand**: >15% deviation from brand average
- **Satisfaction Δ vs Region**: >0.3 points from regional norm
- **Service Case Rate**: >100 cases per 1,000 stays
- **Guest Knowledge**: Low/Medium personalization coverage

**Action Items**:
- 🔴 **High Priority**: Properties with multiple red flags
- 🟡 **Medium Priority**: Single deviation requiring monitoring
- 🟢 **Low Priority**: Performance within normal range

#### Suggested AI Prompts

Use these with the Hotel Intelligence Master Agent:
- "What's driving RevPAR changes across brands this month?"
- "Which regions improved guest satisfaction—and why?"
- "Call out the top 3 operational issues impacting loyalty"
- "Do brands with higher guest-knowledge coverage perform better?"

---

### 2. Loyalty Intelligence 🎯

**Purpose**: Understanding what drives repeat stays and segment profitability

#### KPI Cards

**Active Loyalty Members**
- Definition: Members with ≥1 stay in the period
- What to Watch: Declining active members indicates program disengagement

**Repeat Stay Rate**
- Definition: % of guests with multiple stays (by tier)
- Target: Diamond >60%, Platinum >50%, Gold >40%
- What to Watch: Gaps between tiers may indicate tier benefit misalignment

**Avg Spend per Stay**
- Definition: Total spend including room, amenities, services
- What to Watch: Compare to segment lifetime value for profitability assessment

**High-Value Guest Share %**
- Definition: % of total revenue from $10K+ LTV guests
- Typical: 20-40% (Pareto principle)
- What to Watch: Over-concentration (>60%) increases churn risk

**At-Risk Segments**
- Definition: Segments with <20% repeat rate
- What to Watch: High-spend, low-repeat segments are priority for intervention

#### Charts

**Repeat Rate by Loyalty Tier**
- **Use**: Validate tier program effectiveness
- **Action**: If premium tiers have lower repeat rates than lower tiers, benefits may be misaligned

**Spend Mix by Tier** (Stacked Bar)
- **Use**: Understand revenue composition (Room/F&B/Spa/Other)
- **Action**: High F&B but low Spa in premium tiers = upsell opportunity

**Experience Affinity Distribution** (Pie Chart)
- **Use**: Understand what drives loyalty (Dining/Wellness/Convenience)
- **Action**: Invest in high-affinity categories to boost retention

#### Top Loyalty Opportunities Table

Displays top 15 segments by revenue with:
- **Repeat Rate %**: Retention strength
- **Avg Spend ($)**: Value per stay
- **Top Friction Point**: Most common issue (billing, room readiness, noise)
- **Focus Area**: Strategic recommendation (Retention/Upsell/Engagement)
- **Experience Affinity**: Preferred amenity category
- **Growth Opportunity**: Underutilized service with potential

**How to Use**:
1. **High Spend + Low Repeat**: Priority for retention programs
2. **High Repeat + Medium Spend**: Upsell opportunity
3. **Growth Opportunity**: Service expansion or promotion focus

**Column Tooltips**: Click on column definition expanders for detailed explanations

#### High-Performing vs. At-Risk Segments

**High-Performing** (Repeat Rate >50%)
- **Use**: Identify best practices to replicate
- **Action**: Document what's working and apply to other segments

**At-Risk** (Repeat Rate <30%)
- **Use**: Prioritize intervention resources
- **Action**: Analyze friction points and implement recovery strategies

#### Suggested AI Prompts

- "Which amenities correlate most with repeat stays for Platinum guests?"
- "Which loyalty segment is growing fastest—and what's driving it?"
- "Where are we under-delivering experiences our best guests value?"
- "Show me loyalty trends for business travelers in AMER over the last quarter"

---

### 3. CX & Service Signals 💬

**Purpose**: Service quality monitoring and proactive VIP management

#### Filters
- **Region**: All, AMER, EMEA, APAC
- **Brand**: All brands

#### KPI Cards

**Service Case Rate**
- Definition: Service incidents per 1,000 stays
- Target: 50-100 (industry benchmark)
- What to Watch: >150 indicates systemic operational issues

**Avg Resolution Time**
- Definition: Hours to resolve service cases
- Target: Critical <4h, High <8h, Medium <24h
- What to Watch: Increasing trend may indicate staffing or process issues

**Negative Sentiment Rate %**
- Definition: % of feedback with negative sentiment (score <-20)
- Target: <5%
- What to Watch: Spikes often correlate with specific incidents or operational changes

**Service Recovery Success %**
- Definition: % of recovery attempts accepted by guests
- Target: >70% for VIPs, >60% overall
- What to Watch: Low success may indicate insufficient recovery offers or poor execution

**At-Risk High-Value Guests**
- Definition: $10K+ LTV guests with recent negative sentiment or service issues
- What to Watch: Immediate retention intervention required

#### Charts

**Top Service Issue Drivers** (Ranked Bar)
- **Use**: Identify recurring operational issues
- **Action**: Top 3 issues should have active resolution plans

**Service Case Rate by Brand** (Comparison Bar)
- **Use**: Benchmark operational excellence across portfolio
- **Action**: High-rate brands may need process improvements or staffing adjustments

**Recovery Success by Brand** (Performance Bar)
- **Use**: Measure effectiveness of service recovery programs
- **Action**: Low-performing brands require training or empowerment improvements

#### VIP Watchlist Table (Next 7 Days)

**Purpose**: Proactive service for high-value guests with context

**Columns**:
- **Guest ID** (anonymized): First 8 characters + ***
- **Tier**: Diamond, Platinum, Gold (loyalty level)
- **Arrival Date**: Check-in date for arrival preparation
- **Brand**: Property where guest is checking in
- **Property**: City location
- **Past Issues**: Count of service cases in last 90 days
  - 0 = No history
  - 1 = Monitor
  - 2+ = **Requires attention**
- **Preference Tags**: Known preferences (room type, floor, quiet room, high-speed WiFi)
- **LTV ($)**: Lifetime value for prioritization
- **Churn Risk**: Predictive score (0-100) based on history, sentiment, issues
- **Risk Level**: Color-coded assessment
  - 🔴 **High (75+)**: Immediate pre-arrival contact required
  - 🟡 **Medium (50-74)**: Service team briefing recommended
  - 🟢 **Low (<50)**: Standard service protocol

**How to Use**:
1. **Sort by Churn Risk** (default): Focus on highest-risk guests first
2. **Filter by Tier**: Prioritize Diamond/Platinum guests
3. **Check Past Issues**: Review history for context
4. **Note Preferences**: Ensure room assignment matches preferences
5. **Export to CSV**: Download for operational team distribution

**Proactive Actions**:
- **🔴 High Risk Guests**:
  - Pre-arrival contact (phone or email) to acknowledge past issues
  - Room upgrade if available
  - Service manager greeting upon arrival
  - Ensure preference match (room type, floor, amenities)
  
- **🟡 Medium Risk Guests**:
  - Service team briefing with guest history
  - Preference verification and room assignment
  - Check-in acknowledgment of loyalty status
  
- **🟢 Low Risk Guests**:
  - Standard service protocol with preference matching
  - Loyalty recognition at check-in

#### Recommended Actions Section

**Immediate Actions**:
- Pre-arrival contact for all guests with churn risk >75
- Room assignment review for guests with specific preferences
- Service team briefing on high-LTV guests with past issues
- Proactive upgrades for VIPs with multiple prior issues

**Operational Improvements**:
- Root cause analysis for top issue driver
- Staff training focus on worst-performing brand
- Process review for service recovery effectiveness
- Guest preference capture to increase coverage

#### Suggested AI Prompts

- "What are the top 2 issues driving dissatisfaction for high-value guests?"
- "Which properties need attention based on service recovery performance?"
- "Summarize what's driving negative sentiment this month"
- "Show me Diamond guests arriving tomorrow with 2+ past service issues"

---

## KPI Definitions

### Portfolio Overview Metrics

| KPI | Definition | Calculation | Target/Benchmark |
|-----|-----------|-------------|------------------|
| **Occupancy %** | Percentage of available rooms occupied | (Occupied Rooms / Total Rooms) × 100 | 65-75% (industry) |
| **ADR** | Average Daily Rate - revenue per occupied room | Total Room Revenue / Rooms Sold | Varies by brand/market |
| **RevPAR** | Revenue Per Available Room | ADR × Occupancy Rate | Primary performance metric |
| **Repeat Stay Rate %** | Guests who have stayed more than once | (Repeat Guests / Total Guests) × 100 | >40% indicates strong loyalty |
| **Satisfaction Index** | Average guest satisfaction score | Sum(Ratings) / Count(Ratings) | 4.0+ on 5-point scale |
| **Personalization Coverage %** | Stays with known guest preferences | (Stays with Preferences / Total Stays) × 100 | Higher = better personalization |

### Loyalty Intelligence Metrics

| KPI | Definition | Calculation | Target/Benchmark |
|-----|-----------|-------------|------------------|
| **Active Members** | Loyalty members with ≥1 stay in period | COUNT(DISTINCT guest_id WHERE stays > 0) | Growth month-over-month |
| **Repeat Stay Rate** | Percentage returning for additional stays | (Guests with >1 Stay / Total Guests) × 100 | Diamond >60%, Platinum >50% |
| **Avg Spend per Stay** | Average total spend per booking | Total Revenue / Total Stays | Varies by tier |
| **High-Value Guest Share %** | Revenue from $10K+ LTV guests | (HV Guest Revenue / Total Revenue) × 100 | Typical: 20-40% |
| **Revenue Mix** | Breakdown by category | Category Revenue / Total Revenue | Room typically 60-70% |

### CX & Service Metrics

| KPI | Definition | Calculation | Target/Benchmark |
|-----|-----------|-------------|------------------|
| **Service Case Rate** | Incidents per 1,000 stays | (Total Cases / Total Stays) × 1,000 | 50-100 (industry) |
| **Avg Resolution Time** | Hours to resolve cases | SUM(Resolution Hours) / Case Count | Critical <4h, High <8h |
| **Negative Sentiment Rate %** | Feedback with negative sentiment | (Negative Count / Total Feedback) × 100 | <5% target |
| **Recovery Success %** | Recovery attempts accepted | (Accepted / Total Attempts) × 100 | >70% VIPs, >60% overall |
| **Churn Risk Score** | Likelihood of guest not returning (0-100) | Model: recency + sentiment + issues | >75 = high risk |

---

## Use Cases by Persona

### Brand & Portfolio Leadership

#### Weekly Executive Briefing
1. Open **Portfolio Overview** tab
2. Review KPI cards for portfolio-wide trends
3. Check **Experience Health Heatmap** for regional issues
4. Review **Outliers & Exceptions** table for properties requiring attention
5. Use **AI Prompts** to ask: "What's driving RevPAR changes this week?"

#### Regional Performance Comparison
1. Filter by **Region**: AMER
2. Note RevPAR, Occupancy, Satisfaction
3. Change filter to **EMEA**, then **APAC**
4. Compare metrics to identify regional leaders and laggards
5. Drill into outliers for root cause analysis

#### Brand Benchmarking
1. Filter by **Brand**: Summit Peak Reserve (Luxury)
2. Review performance KPIs
3. Repeat for each brand (Summit Ice, Summit Permafrost, The Snowline)
4. Compare RevPAR, satisfaction, repeat stay rate across brands
5. Identify best practices from high-performing brands

### Loyalty & Customer Strategy

#### Segment Retention Analysis
1. Open **Loyalty Intelligence** tab
2. Review **Repeat Stay Rate** KPI card
3. Examine **Repeat Rate by Loyalty Tier** chart
4. Identify at-risk segments (repeat rate <30%)
5. Review **Top Friction Driver** for root causes
6. Develop targeted retention campaigns

#### Revenue Optimization by Segment
1. Review **Top Loyalty Opportunities** table
2. Sort by **Avg Spend per Stay** (descending)
3. Identify high-spend, low-repeat segments (upsell opportunity)
4. Check **Growth Opportunity** column for underutilized services
5. Develop targeted upsell campaigns (e.g., Spa for Dining-affinity guests)

#### Experience Investment Prioritization
1. Review **Experience Affinity Distribution** pie chart
2. Identify dominant driver (Dining/Wellness/Convenience)
3. Compare to **Revenue Mix** to ensure alignment
4. Use **Growth Opportunity** insights to identify investment areas
5. Model ROI: Focus on high-affinity categories with low penetration

### Guest Services Leadership

#### Daily VIP Arrival Preparation
1. Open **CX & Service Signals** tab
2. Review **VIP Watchlist** table
3. Sort by **Churn Risk** (descending)
4. Identify 🔴 High Risk guests (score >75)
5. Review **Past Issues** and **Preference Tags**
6. Initiate pre-arrival contact and room assignment
7. **Export CSV** and distribute to property teams

#### Service Quality Monitoring
1. Review **Service Case Rate** KPI
2. Check **Top Service Issue Drivers** chart
3. Identify top 3 recurring issues
4. Filter by **Brand** to compare across portfolio
5. Develop action plans for systemic issues
6. Track **Recovery Success %** to measure improvement

#### Proactive Churn Prevention
1. Review **At-Risk High-Value Guests** KPI
2. Identify count and total LTV at risk
3. Filter **VIP Watchlist** by **Tier** = Diamond
4. Review **Churn Risk Score** >75
5. Schedule immediate retention calls
6. Prepare recovery offers (upgrades, points, experiences)

---

## AI-Powered Analysis

### Hotel Intelligence Master Agent

The Intelligence Hub integrates with the **Hotel Intelligence Master Agent**, which has access to all 6 semantic views:
1. Portfolio Intelligence
2. Loyalty Intelligence
3. CX Service Intelligence
4. Guest Analytics (existing)
5. Personalization Scores (existing)
6. Amenity Intelligence (existing)

### How to Access

1. **Navigate to Snowsight** → **Snowflake Intelligence** → **Agents**
2. **Select**: Hotel Intelligence Master Agent
3. **Type natural language questions**
4. **Review SQL-based answers** with supporting data

### Pre-Configured Prompts

Copy these into the Agent chat interface:

#### Portfolio Analysis
```
What's driving RevPAR changes across brands this month?
Which regions improved guest satisfaction—and why?
Call out the top 3 operational issues impacting loyalty.
Do brands with higher guest-knowledge coverage perform better?
Compare Summit Ice vs. Summit Peak Reserve channel performance.
```

#### Loyalty Intelligence
```
Which amenities correlate most with repeat stays for Platinum guests?
Which loyalty segment is growing fastest—and what's driving it?
Where are we under-delivering experiences our best guests value?
Show me loyalty trends for business travelers in AMER over the last quarter.
Which segments have declining satisfaction trends?
```

#### CX & Service
```
What are the top 2 issues driving dissatisfaction for high-value guests?
Which properties need attention based on service recovery performance?
Summarize what's driving negative sentiment this month.
Show me Diamond guests arriving tomorrow with 2+ past service issues.
Which brands have the highest service recovery success rates?
```

### Advanced Queries

The Agent can handle complex multi-factor queries:
- "Compare RevPAR performance across AMER regions for luxury properties in Q4"
- "Show me the correlation between personalization coverage and repeat stay rates by brand"
- "Identify properties with declining satisfaction AND increasing service case rates"
- "Which loyalty segments have both high repeat rates and high spa revenue?"

---

## Best Practices

### Dashboard Usage

**1. Start Broad, Then Narrow**
- Begin with portfolio-level views (no filters)
- Identify outliers or trends
- Apply region/brand filters to drill into specifics

**2. Compare Performance**
- Always benchmark against brand averages
- Compare current period to prior period
- Use regional comparisons for context

**3. Focus on Actionable Insights**
- Prioritize at-risk guests (high churn risk)
- Address outlier properties (>15% RevPAR deviation)
- Track declining trends (satisfaction, repeat rate)

**4. Use Filters Effectively**
- Region filter: Compare AMER vs. EMEA vs. APAC
- Brand filter: Isolate luxury vs. select service performance
- Time period: 7 days for operational, 30/90 for strategic

**5. Export Data for Deeper Analysis**
- VIP Watchlist → CSV for operational teams
- Loyalty Opportunities → Export for marketing campaigns
- Outliers & Exceptions → Share with property managers

### Data Refresh & Caching

**Cache Duration**: 5 minutes
- Data is cached for performance
- Click **"Clear Cache"** in sidebar for immediate refresh
- Auto-refresh occurs every 5 minutes

**When to Refresh**:
- After major incidents or operational changes
- Before executive presentations
- When comparing to external reports (ensure latest data)

### KPI Tooltip Best Practices

**Always Check Definitions Before Escalating**:
- Hover over ℹ️ icon for each KPI
- Review calculation method to understand context
- Check industry benchmark to assess severity
- Use tooltip information in executive communications

**Example**:
- Before: "RevPAR is down 12%"
- After: "RevPAR is down 12% to $142, which is still above our brand target of $135 and within normal seasonal variance"

### Collaboration & Sharing

**Executive Briefings**:
1. Export VIP Watchlist to CSV
2. Screenshot outliers table for property follow-up
3. Share AI Agent query results via email
4. Use Snowsight's built-in sharing for dashboards

**Cross-Functional Alignment**:
- **Portfolio + Loyalty Teams**: Share segment opportunities table
- **CX + Operations**: Coordinate on VIP watchlist and service issues
- **Revenue + Marketing**: Align on upsell segments and campaigns

---

## Troubleshooting

### Common Issues

#### Dashboard Not Loading
**Symptoms**: Blank screen or "Loading..." that doesn't complete

**Solutions**:
1. **Check Warehouse Status**: Verify `HOTEL_PERSONALIZATION_WH` is running
2. **Refresh Browser**: Hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
3. **Clear Cache**: Click "Clear Cache" in sidebar
4. **Check Connection**: Run `./run.sh intel-hub` to verify deployment

#### No Data in Tables
**Symptoms**: Empty tables or "No data available" message

**Solutions**:
1. **Verify Filters**: Reset all filters to "All"
2. **Check Date Range**: Ensure you're not looking at future dates
3. **Validate Deployment**: Run `./run.sh intel-hub` to check data volumes
4. **Redeploy if Needed**: `./deploy.sh --only-intel-hub`

#### KPI Values Seem Incorrect
**Symptoms**: Metrics don't match expectations or external reports

**Solutions**:
1. **Check Tooltip**: Hover over ℹ️ to review calculation method
2. **Verify Filters**: Ensure correct region/brand/time period selected
3. **Clear Cache**: Click "Clear Cache" to force data refresh
4. **Compare to Source**: Query Gold tables directly via `./run.sh query` to verify

#### Slow Performance
**Symptoms**: Long load times (>30 seconds)

**Solutions**:
1. **Warehouse Size**: Increase warehouse from X-Small to Small if needed
2. **Reduce Date Range**: Use 30 days instead of 90 for faster queries
3. **Clear Cache**: Old cache entries can slow down new queries
4. **Check Concurrency**: Multiple users may be competing for warehouse resources

### Error Messages

**"Session has expired"**
- **Cause**: Snowflake session timeout
- **Solution**: Refresh browser tab to re-authenticate

**"Warehouse is suspended"**
- **Cause**: Auto-suspend triggered after inactivity
- **Solution**: Wait 10-15 seconds for auto-resume, or manually resume warehouse

**"Permission denied"**
- **Cause**: Insufficient role privileges
- **Solution**: Contact admin to verify `HOTEL_PERSONALIZATION_ROLE` access

### Getting Help

**Internal Support**:
1. Check this guide's troubleshooting section
2. Run `./run.sh intel-hub` for diagnostic information
3. Review deployment logs: `/tmp/intel_hub_deploy.log`
4. Contact your Snowflake administrator

**Redeployment** (Last Resort):
```bash
# Clean and full redeploy
./clean.sh
./deploy.sh
```

**CLI Commands for Diagnostics**:
```bash
# Check Intelligence Hub status
./run.sh intel-hub

# Query specific tables
./run.sh query "SELECT COUNT(*) FROM GOLD.PORTFOLIO_PERFORMANCE_KPIS"
./run.sh query "SELECT COUNT(*) FROM GOLD.LOYALTY_SEGMENT_INTELLIGENCE"

# Check Streamlit app status
snow sql -c demo -q "SHOW STREAMLITS IN SCHEMA HOTEL_PERSONALIZATION.GOLD"
```

---

## Appendix

### Data Volumes

**Intelligence Hub Specific**:
- **100 Properties**: 50 AMER, 30 EMEA, 20 APAC
- **~22K Service Cases**: 18 months of service incident history
- **~3,000 Future Bookings**: 30-day lookahead for VIP arrivals
- **~40K Total Intelligence Records**: Service, sentiment, recovery data

**Shared Platform Data**:
- **10,000 Guest Profiles**: Complete guest history
- **25,000 Bookings**: Full reservation history
- **20,000 Completed Stays**: Historical stay data
- **30,000+ Amenity Transactions**: Revenue and usage data

### Semantic Views

The Intelligence Hub queries 3 dedicated semantic views:
1. **PORTFOLIO_INTELLIGENCE_VIEW**: Daily KPIs by property, brand, region
2. **LOYALTY_INTELLIGENCE_VIEW**: Segment behavior and revenue mix
3. **CX_SERVICE_INTELLIGENCE_VIEW**: Service quality and VIP context

### Deployment Details

**Technology Stack**:
- **Platform**: Streamlit in Snowflake (native integration)
- **Data Layer**: Snowflake Gold tables (pre-aggregated)
- **Caching**: 5-minute TTL for query results
- **Warehouse**: `HOTEL_PERSONALIZATION_WH` (auto-resume/suspend)

**File Structure**:
```
streamlit/intelligence_hub/
├── hotel_intelligence_hub.py       # Main app file
├── pages/
│   ├── 1_Portfolio_Overview.py     # Portfolio tab
│   ├── 2_Loyalty_Intelligence.py   # Loyalty tab
│   └── 3_CX_Service_Signals.py     # CX tab
├── shared/
│   ├── data_loader_intel.py        # Data loading utilities
│   ├── viz_components_intel.py     # Visualization components
│   ├── formatters.py               # Number formatting helpers
│   └── kpi_definitions.py          # KPI tooltip definitions
├── snowflake.yml                   # Streamlit config
└── environment.yml                 # Python dependencies
```

### Glossary

- **ADR**: Average Daily Rate
- **AMER**: Americas region (US, Canada, Mexico)
- **APAC**: Asia-Pacific region (Asia, Australia, Oceania)
- **Churn Risk**: Likelihood of guest not returning
- **EMEA**: Europe, Middle East, Africa region
- **LTV**: Lifetime Value (total guest spend across all stays)
- **RevPAR**: Revenue Per Available Room
- **VIP**: Diamond or Platinum tier loyalty member with $10K+ LTV

---

**Version**: 2.0  
**Last Updated**: January 2026  
**For Support**: Contact your Snowflake administrator or refer to main `README.md`
