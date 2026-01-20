# 🏨 Hotel Personalization Pick'N Stays
## *Executive Intelligence Hub & AI-Powered Personalization Platform*

---

## 🎯 **WHY This System Exists**

### **The Hospitality Challenge**
Modern hotel executives and operators face unprecedented complexity managing multi-property portfolios:

- **Fragmented data across 100+ properties** making portfolio-wide visibility impossible
- **No unified executive dashboard** for RevPAR, occupancy, and satisfaction metrics
- **Opaque loyalty member behavior** - unclear which Diamond/Gold members are at risk of churning
- **Reactive service management** - issues discovered after guest complaints, not proactively
- **Manual reporting** - executives wait days for insights that should be real-time
- **Poor guest personalization** across touchpoints due to siloed PMS, CRM, and loyalty systems

### **The Business Opportunity**
Industry leaders and hospitality studies indicate that **unified intelligence platforms** can potentially deliver:
- 📈 **8-15% portfolio RevPAR increase** through proactive outlier detection and remediation
- 🎯 **15-25% loyalty member retention improvement** via AI-driven at-risk segment identification
- 😊 **20-30% reduction in service case escalations** through proactive sentiment monitoring
- ⚡ **85% reduction in executive reporting time** (days → minutes) with self-service dashboards
- 💰 **10-25% revenue increase** through intelligent guest upselling and cross-selling

> **Note:** These are industry benchmark ranges based on common hospitality technology ROI studies. Actual results vary significantly based on implementation quality, property type, guest demographics, and existing personalization maturity. This platform demonstrates the technical capabilities to enable such outcomes.

### **Our Solution**
A **comprehensive AI-powered intelligence hub and personalization platform** that:
- 🎯 **Executive Intelligence Hub** with 3 dashboards: Portfolio Performance, Loyalty Intelligence, CX & Service Signals
- 🧠 **Unifies all guest, loyalty, and service data** into a single source of truth across 100+ global properties
- 💡 **Provides natural language insights** via Snowflake Intelligence Agents for self-service executive queries
- 🚀 **Enables proactive management** with outlier detection and at-risk segment alerts
- 📊 **Drives revenue growth** through guest personalization and intelligent recommendations

---

## 🚀 **QUICK START**

### Deploy in 3 Simple Steps

**Prerequisites:**
```bash
# Install Snowflake CLI
pip install snowflake-cli

# Configure your Snowflake connection
snow connection add demo
```

**Step 1: Deploy the Platform** (10-15 minutes)
```bash
./deploy.sh

# Or deploy to a specific environment:
./deploy.sh --prefix DEV
./deploy.sh -c prod  # Use 'prod' connection
```

**What Gets Deployed:**
- ✅ Database with 4 schemas (Bronze, Silver, Gold, Semantic Views)
- ✅ 33 tables across medallion architecture (17 Bronze, 9 Silver, 7 Gold)
- ✅ **100 global properties** across 3 regions (50 AMER, 30 EMEA, 20 APAC) and 4 brands
- ✅ **100,000 synthetic guest profiles** with realistic demographics and behavior
- ✅ **250,000+ bookings** (historical + future) and **1.9M+ stay records** (12 months of history)
- ✅ **50,000 loyalty members** across 4 tiers (Diamond, Gold, Silver, Blue) with 50% repeat rate
- ✅ **5M+ amenity usage records** (WiFi, TV, dining, pool, spa) with realistic patterns
- ✅ **30,000+ service cases** with sentiment analysis and issue tracking
- ✅ **7 semantic views** for natural language querying (portfolio, loyalty, service, guest analytics)
- ✅ **1 Master Intelligence Agent** with access to all semantic views
- ✅ **2 Streamlit Applications:**
  - **Hotel Personalization - PickNStays** (5 pages: Guest 360, Personalization Hub, Amenity Performance, Revenue Analytics, Executive Overview)
  - **Hotel Intelligence Hub** (3 executive dashboards: Portfolio Overview, Loyalty Intelligence, CX & Service Signals)

**Step 2: Validate the Deployment**
```bash
# Run validation queries across all layers
./run.sh validate

# Check resource status
./run.sh status

# Check Streamlit dashboard status and access info
./run.sh streamlit
```

**Step 3: Query and Explore**
```bash
# Execute custom queries
./run.sh query "SELECT * FROM GOLD.GUEST_360_VIEW_ENHANCED LIMIT 10"

# Test Intelligence Agents
./run.sh test-agents

# Query semantic views (use specific dimensions and metrics, not SELECT *)
./run.sh query "SELECT first_name, last_name, loyalty_tier, SUM(total_revenue) as revenue FROM TABLE(SEMANTIC_VIEWS.GUEST_ANALYTICS_VIEW(DIMENSIONS => ['first_name', 'last_name', 'loyalty_tier'], METRICS => ['TOTAL_REVENUE'])) GROUP BY 1,2,3 LIMIT 10"
```

**Note:** Semantic views require specific dimension/metric selection. They are primarily designed for Snowflake Intelligence Agents, not direct SQL queries.

### Available Scripts

- **`./deploy.sh`** - Full platform deployment
  - Deploys database, schemas, tables, data, semantic views, and agents
  - Uses Snowflake CLI for streamlined deployment
  
- **`./run.sh`** - Runtime operations and testing
  - `status` - Check resource and data status
  - `validate` - Run validation queries across all layers
  - `query "SQL"` - Execute custom SQL queries
  - `test-agents` - Test Intelligence Agents
  - `streamlit` - Check Streamlit app status and get access info

- **`./clean.sh`** - Remove all resources (use with caution)

### Quick Validation Examples

```sql
-- Top guests by revenue
SELECT 
    first_name, last_name, 
    customer_segment, total_revenue
FROM GOLD.GUEST_360_VIEW_ENHANCED
ORDER BY total_revenue DESC
LIMIT 10;

-- High upsell propensity guests
SELECT 
    guest_id, customer_segment,
    upsell_propensity_score,
    spa_upsell_propensity,
    tech_upsell_propensity
FROM GOLD.PERSONALIZATION_SCORES_ENHANCED
WHERE upsell_propensity_score >= 70
LIMIT 10;

-- Amenity performance by category
SELECT 
    service_group, amenity_category,
    SUM(total_revenue) as revenue,
    AVG(avg_satisfaction) as satisfaction
FROM GOLD.AMENITY_ANALYTICS
GROUP BY service_group, amenity_category
ORDER BY revenue DESC;
```

### Natural Language Queries with Intelligence Agents

```sql
-- Query the Guest Analytics Agent
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
    'HOTEL_PERSONALIZATION.GOLD."Hotel Guest Analytics Agent"',
    'Show me our top 10 guests by total revenue and their loyalty tiers'
) AS response;

-- Query the Personalization Specialist
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
    'HOTEL_PERSONALIZATION.GOLD."Hotel Personalization Specialist"',
    'Which guests have high spa upsell propensity scores this week?'
) AS response;

-- Query the Amenities Intelligence Agent
SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
    'HOTEL_PERSONALIZATION.GOLD."Hotel Amenities Intelligence Agent"',
    'What is our amenity revenue breakdown by service category?'
) AS response;
```

### Platform Components

**SQL Scripts** (Numbered for execution order):
- `scripts/01_account_setup.sql` - Database, schemas, roles, warehouse
- `scripts/01b_expand_to_100_properties.sql` - Expand from 50 to 100 global properties (AMER, EMEA, APAC)
- `scripts/02_schema_setup.sql` - All table definitions (33 tables across Bronze/Silver/Gold)
- `scripts/03_data_generation.sql` - Synthetic data generation for core Bronze tables (100K guests, 1.9M stays)
- `scripts/03a_future_bookings_enhancement.sql` - Generate ~3,000 future bookings for next 30 days
- `scripts/03b_intelligence_hub_data_generation.sql` - Generate Intelligence Hub data (service cases, sentiment, issues)
- `scripts/03b_refresh_silver_gold.sql` - Refresh all Silver and Gold tables with comprehensive KPIs
- `scripts/04_semantic_views.sql` - 7 semantic views for natural language querying
- `scripts/05_intelligence_agents.sql` - Hotel Intelligence Master Agent with 40+ sample questions
- `scripts/06_agent_chatbot_procedures.sql` - Agent integration procedures (deprecated - use Snowflake Intelligence UI)
- `scripts/08_sample_queries.sql` - Example BI queries across all layers

**Streamlit Applications:**
- `streamlit/hotel_personalization/` - Original personalization app (Guest 360, Amenity Performance, Revenue Analytics)
- `streamlit/intelligence_hub/` - Executive Intelligence Hub (Portfolio, Loyalty, CX & Service dashboards)

**Documentation:**
- `README.md` - This file, complete platform overview
- `DEPLOYMENT_GUIDE.md` - Detailed deployment instructions
- `STREAMLIT_DEPLOYMENT_GUIDE.md` - Streamlit app deployment guide
- `docs/INTELLIGENCE_HUB_GUIDE.md` - Intelligence Hub feature guide and use cases
- `docs/AGENT_DETAILED_QUESTIONS.md` - Sample agent test questions
- `docs/hotel_architecture_diagram.xml` - Visual architecture diagram
- `solution_presentation/Hotel_Personalization_Solution_Overview.md` - Original solution overview
- `solution_presentation/Hotel_Personalization_PickNStays_Solution_Overview.md` - Intelligence Hub solution overview
- `solution_presentation/Hotel_Personalization_PicksNstays_Presentation_Guide.md` - ISF-aligned presentation guide

### Estimated Costs

- **Deployment:** ~10 Snowflake credits (one-time)
- **Daily Operations:** ~2-5 credits
- **Agent Queries:** ~1 credit per 100 queries

### Clean Up

To remove all deployed resources:
```bash
./clean.sh

# Non-interactive cleanup
./clean.sh --force

# Keep Intelligence Agents
./clean.sh --keep-agents
```

---

## 🏗️ **SYSTEM ARCHITECTURE & DATA FLOW**

### **End-to-End Architecture Diagram**

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                           🏨 HOTEL PERSONALIZATION ECOSYSTEM                             │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│  📱 DATA SOURCES                    🔄 PROCESSING LAYERS                 🎯 CONSUMPTION  │
│  ┌─────────────────┐               ┌─────────────────────────────────────┐ ┌─────────────┐ │
│  │ 🏨 PMS Systems  │──────────────▶│        🥉 BRONZE LAYER              │ │ 🤖 AI AGENTS│ │
│  │ 📊 Booking APIs │               │     (Raw Data Ingestion)            │ │             │ │
│  │ 💳 Payment Data │               │                                     │ │ Guest       │ │
│  │ 📱 Social Media │               │ • guest_profiles (100K records)     │ │ Analytics   │ │
│  │ 📝 Reviews/CRM  │               │ • booking_history (250K records)    │ │             │ │
│  │ 🎯 Loyalty APIs │               │ • stay_history (1.9M records)       │ │ Portfolio & │ │
│  │ 🌐 WiFi Systems │               │ • loyalty_program (50K members)     │ │ Loyalty     │ │
│  │ 📺 Smart TV API │               │ • hotel_properties (100 global)     │ │ Intelligence│ │
│  │ 🏊 Pool Systems │               │ • amenity_usage (5M+ sessions)      │ │             │ │
│  └─────────────────┘               │ • service_cases (30K+ cases)        │ │ CX & Service│ │
│           │                        │                                     │ │             │ │
│           ▼                        └─────────────┬───────────────────────┘ │ Revenue     │ │
│                                                  │                         │ Optimizer   │ │
│  🔄 REAL-TIME INGESTION                         ▼                         │             │ │
│  ┌─────────────────┐               ┌─────────────────────────────────────┐ │ Experience  │ │
│  │ • Streaming ETL │               │        🥈 SILVER LAYER              │ │ Optimizer   │ │
│  │ • Data Validation│               │    (Cleaned & Standardized)        │ │             │ │
│  │ • Schema Evolution│              │                                     │ │ Master      │ │
│  │ • Error Handling │               │ • guests_standardized (10000)       │ │ Intelligence│ │
│  └─────────────────┘               │   - Age, generation, segments       │ │             │ │
│                                    │   - Booking patterns & metrics      │ │ Amenity     │ │
│           │                        │   - Loyalty tier analysis          │ │ Intelligence│ │
│           ▼                        │ • amenity_spending_enriched (3500+) │ └─────────────┘ │
│                                    │ • amenity_usage_enriched (8000+)    │                 │
│  🎛️ TRANSFORMATION ENGINE          │   - Tech adoption profiles         │ ┌─────────────┐ │
│           ▼                        │                                     │ │ 📊 BUSINESS │ │
│                                    └─────────────┬───────────────────────┘ │   USERS     │ │
│  🎛️ TRANSFORMATION ENGINE                        │                         │             │ │
│  ┌─────────────────┐                            ▼                         │ • Executives│ │
│  │ • Data Quality  │               ┌─────────────────────────────────────┐ │ • Managers  │ │
│  │ • Business Rules│               │        🏆 GOLD LAYER               │ │ • Analysts  │ │
│  │ • ML Feature Eng│               │     (Analytics Ready)               │ │ • Operations│ │
│  │ • Aggregations  │               │                                     │ └─────────────┘ │
│  └─────────────────┘               │ • guest_360_view_enhanced (10000)   │                 │
│                                    │   - Complete guest profiles        │ ┌─────────────┐ │
│           │                        │   - Infrastructure usage metrics  │ │ 📱 APPS &   │ │
│           ▼                        │   - Tech adoption profiles        │ │   SYSTEMS   │ │
│                                    │ • personalization_scores_enhanced   │ │             │ │
│  🧠 AI/ML PROCESSING               │   - Tech upsell propensity        │ │ • Mobile App│ │
│                                    │ • amenity_analytics (enhanced)      │ │             │ │
│                                    │ • infrastructure_usage_analytics   │ │             │ │
│  ┌─────────────────┐               │   - Readiness scores (0-100)       │ │ • Front Desk│ │
│  │ • Propensity    │               │   - Upsell propensity (0-100)      │ │ • Housekeep │ │
│  │   Scoring       │               │   - Loyalty propensity (0-100)     │ │ • Concierge │ │
│  │ • Segmentation  │               │                                     │ │ • Revenue   │ │
│  │ • Churn Predict │               └─────────────┬───────────────────────┘ │   Management│ │
│  │ • Recommendation│                            │                         └─────────────┘ │
│  └─────────────────┘                            ▼                                         │
│                                                                                           │
│           │                        ┌─────────────────────────────────────┐               │ │
│           ▼                        │     🔍 SEMANTIC VIEWS LAYER         │               │ │
│                                    │   (Natural Language Ready)          │               │ │
│  📊 SEMANTIC MODELING              │                                     │               │ │
│  ┌─────────────────┐               │ 🧠 guest_analytics                  │               │ │
│  │ • Business      │               │    - Guest behavior & segments      │               │ │
│  │   Definitions   │               │                                     │               │ │
│  │ • Relationships │               │ 🎯 personalization_insights         │               │ │
│  │ • Synonyms      │               │    - Preference & opportunities     │               │ │
│  │ • Hierarchies   │               │                                     │               │ │
│  └─────────────────┘               │ 💰 revenue_analytics                │               │ │
│                                    │    - Revenue & performance          │               │ │
│           │                        │                                     │               │ │
│           ▼                        │ 📊 booking_analytics                │               │ │
│                                    │    - Booking patterns & channels    │               │ │
│  🎯 BUSINESS INTELLIGENCE          │                                     │               │ │
│  ┌─────────────────┐               │ 🏠 room_preferences                 │               │ │
│  │ • KPI Dashboards│               │    - Room & service preferences     │               │ │
│  │ • Operational   │               │                                     │               │ │
│  │   Reports       │               └─────────────────────────────────────┘               │ │
│  │ • Executive     │                                                                     │ │
│  │   Insights      │               ┌─────────────────────────────────────┐               │ │
│  └─────────────────┘               │      📈 BUSINESS VIEWS LAYER        │               │ │
│                                    │    (Business-Friendly Views)        │               │ │
│                                    │                                     │               │ │
│                                    │ • guest_profile_summary (1000)      │               │ │
│                                    │ • personalization_opportunities     │               │ │
│                                    │   (918 actionable opportunities)    │               │ │
│                                    └─────────────────────────────────────┘               │ │
└─────────────────────────────────────────────────────────────────────────────────────────┘

                                    🔄 DATA FLOW DIRECTION
                     Raw Data → Cleaned Data → Analytics → Semantic Models → Business Insights
```

### **Medallion Architecture Flow**

```
📥 DATA INGESTION          🔄 DATA PROCESSING           📊 DATA CONSUMPTION
┌─────────────────┐       ┌─────────────────────────┐   ┌─────────────────┐
│                 │       │                         │   │                 │
│ 🥉 BRONZE       │────▶  │ 🥈 SILVER               │──▶│ 🏆 GOLD         │
│ Raw Data        │       │ Cleaned & Standardized  │   │ Analytics Ready │
│                 │       │                         │   │                 │
│ • Exact copy    │       │ • Data quality checks   │   │ • Aggregations  │
│ • All formats   │       │ • Schema standardization│   │ • Business KPIs │
│ • Immutable     │       │ • Business rules        │   │ • ML features   │
│ • Audit trail   │       │ • Deduplication         │   │ • Relationships │
│                 │       │ • Type conversions      │   │ • Calculations  │
└─────────────────┘       └─────────────────────────┘   └─────────────────┘
                                       │                          │
                                       ▼                          ▼
                          ┌─────────────────────────┐   ┌─────────────────┐
                          │                         │   │                 │
                          │ 🔍 SEMANTIC VIEWS       │   │ 📊 BUSINESS     │
                          │ Natural Language Ready  │   │ VIEWS           │
                          │                         │   │                 │
                          │ • Tables & Relationships│   │ • User-friendly │
                          │ • Dimensions & Metrics  │   │ • Pre-built     │
                          │ • Synonyms & Metadata  │   │ • Optimized     │
                          │ • AI Agent Integration  │   │ • Secure        │
                          └─────────────────────────┘   └─────────────────┘
```

---

## 🛠️ **WHAT WE BUILT**

### **🗄️ Database Architecture**
- **Database**: `HOTEL_PERSONALIZATION` with 4 specialized schemas (Bronze, Silver, Gold, Semantic Views)
- **Enterprise Scale**: 
  - **100,000 guests** with comprehensive profiles and preferences
  - **250,000+ bookings** (historical + future 30 days)
  - **1.9M+ stay records** (12 months of history with 60-70% occupancy)
  - **50,000 loyalty members** across 4 tiers with realistic repeat rates
  - **5M+ amenity usage records** with detailed behavior patterns
  - **30,000+ service cases** with sentiment analysis
- **Security Model**: Role-based access control with project-specific roles
- **Data Governance**: Comprehensive audit trails, PII masking, and compliance framework

### **🏨 Global Property Portfolio - 100 Properties Across 3 Regions**
This platform showcases a **global multi-brand hotel portfolio** with **100 properties** spanning three regions:

#### **Regional Distribution**
| Region | Properties | Coverage |
|--------|-----------|----------|
| **🇺🇸 AMER (Americas)** | 50 properties | HOTEL_000 - HOTEL_049 |
| **🇪🇺 EMEA (Europe, Middle East, Africa)** | 30 properties | HOTEL_050 - HOTEL_079 |
| **🌏 APAC (Asia-Pacific)** | 20 properties | HOTEL_080 - HOTEL_099 |

#### **Brand Portfolio Across All Regions**
| Brand | Category | Global Properties | Star Rating | Room Count | Target Market |
|-------|----------|------------------|-------------|------------|---------------|
| **Summit Peak Reserve** | Luxury | 25 | 5⭐ | 250-475 | Full-service luxury travelers, high-value international guests |
| **Summit Ice** | Select Service | 40 | 3-4⭐ | 120-170 | Business/leisure travelers seeking value across regions |
| **Summit Permafrost** | Extended Stay | 20 | 3⭐ | 100-150 | Corporate relocations, long-term stays, global mobility |
| **The Snowline by Summit** | Urban/Modern | 15 | 4⭐ | 80-120 | Millennial travelers, urban explorers, digital nomads |

**Geographic Coverage**: 100 properties across major markets in North America, Europe, Middle East, Africa, and Asia-Pacific including NYC, LA, SF, Chicago, London, Paris, Dubai, Singapore, Tokyo, Sydney, and more.

### **📊 Data Layers Implemented**

#### **🥉 Bronze Layer (13 Tables)**
| Table | Records | Purpose |
|-------|---------|---------|
| `guest_profiles` | 10,000 | Guest demographics, contact info, preferences |
| `booking_history` | 25,000+ | Complete booking transactions and patterns |
| `stay_history` | 20,000+ | Complete stay records with incidental charges |
| `room_preferences` | 10,000 | Room-specific preferences (bed type, floor, view) |
| `service_preferences` | 10,000 | Service preferences (dining, spa, amenities) |
| `social_media_activity` | 10,000+ | Social media engagement and sentiment |
| `loyalty_program` | 10,000 | Loyalty tiers, points, and program status |
| `feedback_reviews` | 10,000+ | Guest reviews and satisfaction scores |
| `payment_methods` | 10,000+ | Payment methods and billing preferences |
| `special_requests` | 10,000+ | Special requests and accommodations |
| `hotel_properties` | 50 | Summit Hospitality Group properties across 4 brands (10 Luxury, 20 Select Service, 10 Extended Stay, 10 Urban/Modern) |
| `amenity_transactions` | 30,000+ | Detailed amenity spending (spa, bar, restaurant, room service) |
| `amenity_usage` | 15,000+ | Infrastructure usage (WiFi, Smart TV, Pool) |

#### **🥈 Silver Layer (7 Tables)**
| Table | Records | Purpose |
|-------|---------|---------|
| `guests_standardized` | 10,000 | Cleaned guest data with business logic and demographics |
| `bookings_enriched` | 25,000+ | Enriched booking data with derived metrics |
| `stays_processed` | 20,000+ | Processed stay data with spending categories |
| `preferences_consolidated` | 10,000 | Consolidated room and service preferences |
| `engagement_metrics` | 10,000+ | Social media and digital engagement analysis |
| `amenity_spending_enriched` | 30,000+ | Enriched amenity transactions with categories |
| `amenity_usage_enriched` | 15,000+ | Infrastructure usage analytics with engagement scores |

#### **🏆 Gold Layer (3 Tables)**
| Table | Records | Purpose |
|-------|---------|---------|
| `guest_360_view_enhanced` | 10,000 | Complete guest profiles with all enriched metrics |
| `personalization_scores_enhanced` | 10,000 | AI-powered propensity scores (upsell, churn, loyalty) |
| `amenity_analytics` | Aggregated | Business intelligence for all amenity services |

#### **🔍 Semantic Views Layer (3 Views)**
| Semantic View | Purpose | AI Integration |
|---------------|---------|----------------|
| `GUEST_ANALYTICS_VIEW` | Guest behavior, booking patterns, loyalty analysis, amenity spend | Natural language queries via Agents |
| `PERSONALIZATION_INSIGHTS_VIEW` | Personalization scores, upsell propensity, customer segments | Cortex Analyst ready |
| `AMENITY_ANALYTICS_VIEW` | Infrastructure service performance, revenue analytics | Natural language queries via Agents |

### **🤖 AI-Powered Intelligence Agents (5 Agents)**

All agents are deployed in the **GOLD schema** and use **"auto" orchestration** model for optimal performance.

**Snowflake Intelligence Integration:**
- ✅ Agents are automatically registered with `SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT`
- ✅ Visible in the **Snowflake Intelligence** UI section (not just the Agents page)
- ✅ Accessible through the unified Snowflake Intelligence interface in Snowsight
- ✅ Properly de-registered during cleanup to maintain clean environment

#### **🧠 Hotel Guest Analytics Agent**
- **Location**: `HOTEL_PERSONALIZATION.GOLD."Hotel Guest Analytics Agent"`
- **Access**: `HOTEL_PERSONALIZATION_ROLE_GUEST_ANALYST`, `HOTEL_PERSONALIZATION_ROLE_ADMIN`
- **Data Sources**: `GUEST_ANALYTICS_VIEW` semantic view
- **Expertise**: Guest behavior, loyalty analysis, booking patterns, amenity spend
- **Sample Questions** (15+): Customer segments, loyalty tiers, spending patterns, guest profiles

#### **🎯 Hotel Personalization Specialist**
- **Location**: `HOTEL_PERSONALIZATION.GOLD."Hotel Personalization Specialist"`
- **Access**: `HOTEL_PERSONALIZATION_ROLE_REVENUE_ANALYST`, `HOTEL_PERSONALIZATION_ROLE_ADMIN`
- **Data Sources**: `PERSONALIZATION_INSIGHTS_VIEW` semantic view
- **Expertise**: Hyper-personalization, preference management, targeted offers
- **Sample Questions** (15+): Upsell opportunities, personalization readiness, preference insights

#### **🌐 Hotel Amenities Intelligence Agent**
- **Location**: `HOTEL_PERSONALIZATION.GOLD."Hotel Amenities Intelligence Agent"`
- **Access**: `HOTEL_PERSONALIZATION_ROLE_EXPERIENCE_ANALYST`, `HOTEL_PERSONALIZATION_ROLE_ADMIN`
- **Data Sources**: `AMENITY_ANALYTICS_VIEW` semantic view
- **Expertise**: Amenity performance, service analytics, infrastructure usage
- **Sample Questions** (15+): Amenity revenue, service satisfaction, usage patterns

#### **😊 Guest Experience Optimizer**
- **Location**: `HOTEL_PERSONALIZATION.GOLD."Guest Experience Optimizer"`
- **Access**: `HOTEL_PERSONALIZATION_ROLE_EXPERIENCE_ANALYST`, `HOTEL_PERSONALIZATION_ROLE_ADMIN`
- **Data Sources**: `GUEST_ANALYTICS_VIEW`, `AMENITY_ANALYTICS_VIEW` semantic views
- **Expertise**: Satisfaction enhancement, churn prevention, service excellence
- **Sample Questions** (15+): Satisfaction trends, churn risk, service quality issues

#### **🏆 Hotel Intelligence Master Agent**
- **Location**: `HOTEL_PERSONALIZATION.GOLD."Hotel Intelligence Master Agent"`
- **Access**: `HOTEL_PERSONALIZATION_ROLE_REVENUE_ANALYST`, `HOTEL_PERSONALIZATION_ROLE_ADMIN`
- **Data Sources**: All 7 semantic views (comprehensive cross-functional access):
  - `PORTFOLIO_INTELLIGENCE_VIEW` - Portfolio performance metrics (RevPAR, occupancy, ADR)
  - `LOYALTY_INTELLIGENCE_VIEW` - Loyalty member behavior and segments
  - `CX_SERVICE_INTELLIGENCE_VIEW` - Service cases and sentiment analysis
  - `GUEST_ANALYTICS_VIEW` - Guest demographics and behavior
  - `PERSONALIZATION_INSIGHTS_VIEW` - Upsell opportunities and propensity scores
  - `REVENUE_ANALYTICS_VIEW` - Revenue performance and trends
  - `GUEST_ARRIVALS_VIEW` - Future bookings and VIP arrivals
- **Expertise**: Executive intelligence, portfolio optimization, loyalty analytics, service quality monitoring
- **Sample Questions** (40+): Portfolio performance, loyalty member retention, service quality alerts, guest arrivals, regional benchmarking

### **📱 Interactive Streamlit Dashboard Applications**

#### **Application 1: Hotel Personalization - PickNStays**
**"Hotel Personalization - PickNStays"** - Original personalization app with 5 pages for guest intelligence and revenue optimization.

**Application 2: Hotel Intelligence Hub**
**"Hotel Personalization Pick'N Stays"** - Executive Intelligence Hub with 3 executive dashboards for portfolio management, loyalty intelligence, and service quality monitoring.

#### **Application Details**
- **Location**: `HOTEL_PERSONALIZATION.GOLD.HOTEL_PERSONALIZATION_APP`
- **Title**: Hotel Personalization - Pic'N Stays
- **Technology**: Streamlit in Snowflake (native Snowpark integration)
- **Data Access**: Real-time queries to GOLD layer tables
- **Warehouse**: `HOTEL_PERSONALIZATION_WH` (auto-resume/suspend)

#### **📊 Dashboard Pages**

##### **1. Guest 360 Dashboard** 🎯
**Purpose**: Comprehensive guest profile and journey visualization

**Features**:
- **Guest Table**: Interactive table with all guests, filterable by loyalty tier, customer segment, churn risk, revenue range
- **Analytics View**: 
  - Loyalty tier distribution (pie chart)
  - Customer segment analysis (bar chart)
  - Churn risk distribution (pie chart)
  - Revenue by segment breakdown
- **Individual Profile**: Deep-dive into any guest with:
  - Complete demographics and contact information
  - Loyalty status and points balance
  - Booking history and spending patterns
  - Amenity usage across all categories
  - Infrastructure engagement (WiFi, Smart TV, Pool)
  - Tech adoption profile and engagement scores

**Access**: Guest Analysts, Experience Analysts, Admins

##### **2. Personalization Hub** 🚀
**Purpose**: AI-powered upsell and revenue optimization

**Features**:
- **Opportunity Matrix**: Scatter plot of guest value vs upsell propensity
  - Size = Personalization readiness score
  - Color = Customer segment
  - Interactive selection of high-priority targets
- **Propensity Analysis**:
  - Average propensity scores by category (Spa, Dining, Tech, Pool)
  - Distribution histograms for each upsell category
  - High-propensity guest counts by threshold
- **Segmentation**: 
  - Guest distribution by segment and loyalty tier
  - Segment performance metrics (revenue, upsell scores, loyalty)
- **Churn Management**:
  - Churn risk distribution and revenue at risk
  - High-risk guest list for immediate action
  - Downloadable CSV export for CRM integration

**Access**: Revenue Analysts, Admins

##### **3. Amenity Performance** 🏊
**Purpose**: Service and infrastructure performance analytics

**Features**:
- **Revenue Analysis**:
  - Revenue by amenity category (bar chart)
  - Top 10 revenue-generating services
  - Category-level performance comparison
- **Satisfaction Metrics**:
  - Average satisfaction by category (5-point scale)
  - Satisfaction rate by category (percentage)
  - Service quality benchmarking
- **Infrastructure Usage**:
  - Total sessions by usage group (WiFi, Smart TV, Pool)
  - Average session duration analysis
  - Usage trends and engagement patterns
- **Performance Scorecards**:
  - Overall amenity performance table
  - Top performers with revenue and satisfaction
  - Areas for improvement with action recommendations

**Access**: Experience Analysts, Admins

#### **Intelligence Hub Dashboards** (Executive Focus)

##### **1. Portfolio Overview** 📊
**Purpose**: Real-time executive dashboard for 100-property portfolio performance

**Features**:
- **Executive KPIs**:
  - Average RevPAR across portfolio with trend comparison
  - Average Occupancy % with historical benchmarks
  - Average ADR (Average Daily Rate) metrics
  - Guest Satisfaction Score (0-100 scale)
- **Performance Metrics**:
  - RevPAR by Brand (Summit Peak Reserve, Summit Ice, Summit Permafrost, Snowline)
  - RevPAR by Region (AMER, EMEA, APAC)
  - Occupancy & ADR Trend Over Time (line chart)
  - RevPAR Heatmap (Brand vs Region)
- **Outliers & Exceptions** (color-coded for performance):
  - Underperforming properties (RevPAR Δ vs brand)
  - Satisfaction drops (Guest Satisfaction Δ vs region)
  - Service case rate spikes (elevated case rates)
  - Guest knowledge gaps (% of guests with profile data)
  - CSV download for analysis

**Access**: COO, Regional VPs, Property GMs, Revenue Managers

##### **2. Loyalty Intelligence** 💎
**Purpose**: AI-driven loyalty member behavior and retention insights

**Features**:
- **Loyalty KPIs**:
  - Active Loyalty Members (exclude non-members)
  - Average Repeat Stay Rate (industry benchmark: ~50%)
  - High-Value Guest Share (Diamond + Gold members)
  - At-Risk Segments (members with <40% repeat rate)
- **Repeat Rate Analysis**:
  - Repeat Stay Rate by Loyalty Tier (Diamond, Gold, Silver, Blue, Non-Member)
  - Visual distribution of repeat rates
- **Revenue & Spend Hierarchy**:
  - Average Spend Per Stay by Loyalty Tier
  - Revenue Mix by Loyalty Tier (total contribution)
- **Experience Drivers**:
  - Top amenity categories driving repeat stays
  - Service quality correlation with loyalty
  - Regional performance by loyalty tier

**Access**: VP of Loyalty, Revenue Managers, Marketing Teams

##### **3. CX & Service Signals** 😊
**Purpose**: Proactive service quality monitoring and sentiment analysis

**Features**:
- **Service KPIs**:
  - Total Service Cases (30K+ tracked)
  - Average Resolution Time (days)
  - Overall Guest Sentiment Score (0-100)
  - Recovery Action Success Rate (%)
- **Service Case Analysis**:
  - Cases by Category (Room Quality, Amenities, Staff Service, Billing, Technical, Noise)
  - Cases by Priority (Low, Medium, High, Critical)
  - Service case trends over time
- **Sentiment Analysis**:
  - Sentiment Distribution (Positive, Neutral, Negative)
  - Sentiment Trends by Region
  - Early warning alerts for sentiment drops
- **Issue Tracking**:
  - Open vs Resolved issues
  - Average time-to-resolution by category
  - Service recovery actions taken

**Access**: VP of Guest Experience, Property GMs, Service Quality Managers

##### **4. Revenue Analytics** 💰
**Purpose**: Financial performance and optimization (Original App)

**Features**:
- **Revenue Mix**:
  - Rooms vs Amenities breakdown (pie chart)
  - Amenity revenue by category (bar chart)
  - Revenue per guest metrics (LTV, booking value, amenity spend)
- **Booking Analytics**:
  - Revenue by booking channel (bar chart)
  - Bookings by lead time category
  - Channel performance metrics table
- **Segment Performance**:
  - Revenue by customer segment (bar chart)
  - Guest count by segment distribution
  - Segment profitability analysis with key metrics
- **Revenue Trends**: Time-series analysis for strategic planning

**Access**: Revenue Analysts, Admins

##### **5. Executive Overview** 📊
**Purpose**: Strategic KPIs and business health scorecard

**Features**:
- **Business Health Scorecard**: 6 key metrics
  - Total Guests
  - Total Revenue
  - Average Satisfaction
  - Loyalty Rate
  - Repeat Rate
  - High Churn Risk %
- **Strategic Metrics**:
  - Customer Lifetime Value distribution
  - High-value guest identification
  - Revenue concentration analysis
- **Segment Performance**: Strategic segment analysis
- **AI Insights**: ML-powered recommendations and alerts
- **Top Performers**: Revenue and satisfaction leaders

**Access**: Admins, Revenue Analysts

#### **🎨 Dashboard Features**

**User Experience**:
- ✅ **Modern UI** with Plotly visualizations
- ✅ **Interactive Filtering** across all pages
- ✅ **Real-time Data** from Snowflake GOLD layer
- ✅ **Responsive Design** for desktop and tablet
- ✅ **Export Capabilities** (CSV download for lists)
- ✅ **Smart Formatting** (K/M/B suffixes for large numbers)
- ✅ **Color-coded KPIs** for quick insights

**Performance**:
- ✅ **Cached Queries** (5-minute TTL for optimal performance)
- ✅ **Efficient Data Loading** via Snowpark sessions
- ✅ **Modular Architecture** with shared components
- ✅ **Optimized Aggregations** from pre-computed GOLD tables

**Access & Security**:
- ✅ **Snowsight Integration** - Access via Projects → Streamlit
- ✅ **Role-Based Access** - Leverages Snowflake RBAC
- ✅ **Session Management** - Automatic authentication via active session
- ✅ **Audit Logging** - All queries tracked in Snowflake query history

#### **📍 How to Access the Dashboard**

**Via Snowsight UI**:
1. Log in to Snowsight: `https://app.snowflake.com`
2. Navigate to: **Projects** → **Streamlit**
3. Select: `HOTEL_PERSONALIZATION.GOLD` → **"Hotel Personalization - Pic'N Stays"**

**Direct URL Pattern**:
```
https://app.snowflake.com/[your-account-locator]/#/streamlit-apps/HOTEL_PERSONALIZATION.GOLD.HOTEL_PERSONALIZATION_APP
```

**Via CLI**:
```bash
# Check dashboard status and get access info
./run.sh streamlit

# Redeploy dashboard
./deploy.sh --only-dashboards
```

---

### **🌐 Hotel Intelligence Hub - Executive Dashboard**

**"Hotel Intelligence Hub"** - A standalone executive dashboard for portfolio-level intelligence across Summit Hospitality Group's global operations.

#### **Application Details**
- **Location**: `HOTEL_PERSONALIZATION.GOLD.HOTEL_INTELLIGENCE_HUB`
- **Title**: Hotel Intelligence Hub
- **Purpose**: Executive command center for portfolio performance, loyalty intelligence, and CX operations
- **Technology**: Streamlit in Snowflake with KPI definition tooltips
- **Data Scope**: 100 properties globally (50 AMER, 30 EMEA, 20 APAC), 18 months history + 30 days future
- **Warehouse**: `HOTEL_PERSONALIZATION_WH` (auto-resume/suspend)

#### **📊 Dashboard Tabs**

##### **1. Portfolio Overview** 📈
**Purpose**: Executive command center for regional and brand-level performance

**Features**:
- **5 KPI Cards** (with definition tooltips):
  - Occupancy % - Rooms occupied vs available
  - ADR - Average Daily Rate
  - RevPAR - Revenue Per Available Room
  - Repeat Stay Rate % - Guest retention metric
  - Guest Satisfaction Index - Average score (1-5 scale)
- **Performance Charts**:
  - RevPAR by Brand/Region (bar charts)
  - Occupancy & ADR trends (dual-axis time series)
  - Experience Health Heatmap (Brand × Region satisfaction)
- **Outliers & Exceptions Table**:
  - Properties with RevPAR deviations >15% vs brand average
  - Satisfaction gaps vs regional norms
  - High service case rates (>100 per 1K stays)
  - Personalization coverage levels
- **AI Prompts**: Pre-configured questions for Hotel Intelligence Master Agent

**Filters**: Region (AMER/EMEA/APAC), Brand, Time Period

**Access**: Brand Leadership, Portfolio Leadership, Admins

##### **2. Loyalty Intelligence** 🎯
**Purpose**: Segment-level behavior, spend patterns, and retention opportunities

**Features**:
- **5 KPI Cards** (with tooltips):
  - Active Loyalty Members - Members with stays in period
  - Repeat Stay Rate - Segment retention %
  - Avg Spend per Stay - Guest value indicator
  - High-Value Guest Share % - Revenue concentration
  - At-Risk Segments - Low repeat rate segments
- **Segment Analysis Charts**:
  - Repeat Rate by Loyalty Tier (bar chart)
  - Spend Mix by Tier (stacked bar: Room/F&B/Spa/Other)
  - Experience Affinity Distribution (pie chart)
- **Top Loyalty Opportunities Table**:
  - 15 segments by revenue with metrics and recommendations
  - Strategic focus areas (Retention/Upsell/Engagement)
  - Experience affinity tags (Dining/Wellness/Convenience)
  - Growth opportunities (underutilized services)
- **High/At-Risk Segment Breakouts**: Quick identification of action items
- **AI Prompts**: Segment-specific analysis questions

**Filters**: None (global portfolio view)

**Access**: Loyalty Strategy, CMO, VP Customer, Admins

##### **3. CX & Service Signals** 💬
**Purpose**: Operational intelligence on service quality and VIP guest management

**Features**:
- **5 KPI Cards** (with tooltips):
  - Service Case Rate - Cases per 1,000 stays
  - Avg Resolution Time - Hours to resolve
  - Negative Sentiment Rate % - Feedback quality
  - Service Recovery Success % - Recovery effectiveness
  - At-Risk High-Value Guests - VIPs with issues
- **Service Intelligence Charts**:
  - Top Service Issue Drivers (ranked bar)
  - Service Case Rate by Brand (comparison bar)
  - Recovery Success by Brand (performance bar)
- **VIP Watchlist Table** (Next 7 Days):
  - Upcoming high-value guest arrivals
  - Past service issue counts (last 90 days)
  - Guest preference tags (room, floor, amenities)
  - Churn risk scores (0-100) with color coding
  - Risk level indicators (🔴 High / 🟡 Medium / 🟢 Low)
  - Lifetime value and loyalty tier
- **Proactive Action Recommendations**: Immediate and operational improvement actions
- **AI Prompts**: Service quality and VIP management questions
- **CSV Export**: Download VIP watchlist for operational teams

**Filters**: Region, Brand

**Access**: Guest Services Leadership, CX Teams, Service Recovery, Admins

#### **🎨 Intelligence Hub Features**

**User Experience**:
- ✅ **Self-Explanatory KPIs** - Tooltip definitions for all metrics (hover over ℹ️)
- ✅ **Executive-Friendly Formatting** - $1.2M, 85.3%, 4.5/5.0 notation
- ✅ **Actionable Tables** - Sorted by priority (risk, revenue, performance)
- ✅ **Color-Coded Alerts** - Red/Yellow/Green indicators for quick assessment
- ✅ **AI Integration** - Pre-configured prompts for Hotel Intelligence Master Agent
- ✅ **Export Capabilities** - Download VIP watchlist and segment data as CSV

**Performance**:
- ✅ **Cached Queries** (5-minute TTL from Gold tables)
- ✅ **Pre-Aggregated Metrics** - Daily portfolio KPIs, segment summaries, service signals
- ✅ **Real-Time Future Bookings** - 30-day lookahead for VIP arrivals

**Data Quality**:
- ✅ **18 Months Historical Data** - Service cases, sentiment, issue tracking
- ✅ **~3,000 Future Bookings** - Distributed daily for next 30 days
- ✅ **~40K Intelligence Hub Records** - Service cases, sentiment, recovery actions
- ✅ **100 Properties** - Complete regional coverage (AMER/EMEA/APAC)

#### **📍 How to Access Intelligence Hub**

**Via Snowsight UI**:
1. Log in to Snowsight: `https://app.snowflake.com`
2. Navigate to: **Projects** → **Streamlit**
3. Select: `HOTEL_PERSONALIZATION.GOLD` → **"Hotel Intelligence Hub"**

**Direct URL Pattern**:
```
https://app.snowflake.com/[your-account-locator]/#/streamlit-apps/HOTEL_PERSONALIZATION.GOLD.HOTEL_INTELLIGENCE_HUB
```

**Via CLI**:
```bash
# Check Intelligence Hub status and data volumes
./run.sh intel-hub

# Deploy/Redeploy Intelligence Hub
./deploy.sh --only-intel-hub

# Deploy everything (main dashboard + Intelligence Hub)
./deploy.sh
```

#### **🔄 Deployment Options**

```bash
# Full deployment (includes Intelligence Hub)
./deploy.sh

# Deploy only Intelligence Hub SQL + Streamlit
./deploy.sh --only-intel-hub

# Deploy SQL infrastructure only (no Streamlit apps)
./deploy.sh --only-sql

# Skip Intelligence Hub (deploy main platform only)
./deploy.sh --skip-intel-hub
```

#### **📊 Target Personas**

**1. Brand & Portfolio Leadership** (COO, EVP Operations, Regional Leaders)
- **Use Case**: Portfolio performance monitoring, regional consistency, outlier identification
- **Primary Tab**: Portfolio Overview
- **Key Questions**: "Where are we winning/losing and why?"

**2. Loyalty & Customer Strategy** (CMO, VP Loyalty, VP Customer)
- **Use Case**: Segment behavior analysis, retention strategies, lifetime value optimization
- **Primary Tab**: Loyalty Intelligence
- **Key Questions**: "What drives loyalty—and where should we invest?"

**3. Guest Services Leadership** (CX Leaders, Service Recovery Teams)
- **Use Case**: VIP recognition, proactive service, issue trend identification, recovery effectiveness
- **Primary Tab**: CX & Service Signals
- **Key Questions**: "Do we know our best guests and prevent churn?"

---

### **🔐 Security & Governance**

#### **Role-Based Access Control**
| Role | Purpose | Agent Access |
|------|---------|-------------|
| `HOTEL_PERSONALIZATION_ROLE` | Main project role | Full database access |
| `HOTEL_PERSONALIZATION_ROLE_ADMIN` | System administration | All 5 agents |
| `HOTEL_PERSONALIZATION_ROLE_GUEST_ANALYST` | Guest behavior analysis | Hotel Guest Analytics Agent |
| `HOTEL_PERSONALIZATION_ROLE_REVENUE_ANALYST` | Revenue optimization | Hotel Personalization Specialist, Hotel Intelligence Master Agent |
| `HOTEL_PERSONALIZATION_ROLE_EXPERIENCE_ANALYST` | Guest experience | Guest Experience Optimizer, Hotel Amenities Intelligence Agent |
| `HOTEL_PERSONALIZATION_ROLE_DATA_ENGINEER` | Data pipeline management | Full data management access |

#### **Data Protection Features**
- ✅ **Column-level security** for PII protection
- ✅ **Row-level security** for multi-tenant access
- ✅ **Audit trails** for compliance monitoring
- ✅ **Data masking** capabilities for sensitive information

---

## 🎯 **KEY BUSINESS CAPABILITIES**

### **1. 🎨 Hyper-Personalization at Scale**
- **918 Guests** with actionable personalization opportunities
- **Personalization Readiness Scores** (0-100 scale) for targeting
- **Room Setup Automation** based on preference profiles
- **Proactive Service Delivery** with predictive insights

### **2. 💰 Revenue Optimization**
- **$500K+ Annual Revenue Opportunity** identified through better personalization
- **$188K+ Amenity Revenue Tracked** across spa, dining, bar, and room service
- **Upsell Propensity Scoring** for targeted offers including service-specific scores
- **Customer Segmentation** for pricing strategies
- **Cross-selling Intelligence** across services and amenities with detailed analytics

### **3. 😊 Guest Experience Enhancement**
- **Churn Risk Assessment** with proactive intervention strategies
- **Satisfaction Trend Analysis** for service improvement including amenity-specific metrics
- **Preference Matching** for seamless experiences across all services
- **Loyalty Program Optimization** for retention with amenity engagement scoring
- **Service Quality Monitoring** across spa, dining, bar, and room service operations

### **4. 📊 Business Intelligence & Visualization**
- **Interactive Streamlit Dashboard** - "Hotel Personalization - Pic'N Stays" with 5 pages:
  - Guest 360 Dashboard (comprehensive profiles & analytics)
  - Personalization Hub (upsell opportunities & AI insights)
  - Amenity Performance (service analytics & infrastructure)
  - Revenue Analytics (financial performance & optimization)
  - Executive Overview (strategic KPIs & business health)
- **Real-time Data Visualization** with Plotly charts and KPIs
- **Role-Based Dashboard Access** for different user personas
- **Executive Reporting** with strategic KPIs and exportable insights
- **Performance Benchmarking** across properties and segments
- **Predictive Analytics** integrated with ML scoring models

### **5. 🎪 NEW: Amenity Intelligence**
- **Service Performance Analytics** across spa, dining, bar, and room service
- **Cross-Service Upselling** with AI-powered propensity scoring
- **Guest Satisfaction Monitoring** by service category with operational alerts
- **Revenue Optimization** through premium service identification and targeting
- **Operational Insights** for service quality improvement and resource allocation

---

## 🚀 **IMPLEMENTATION HIGHLIGHTS**

### **📈 Production-Scale Data**
- **1,000 Guest Profiles** with comprehensive demographics and preferences
- **2,000 Booking Records** with realistic patterns and revenue data
- **2,510 Amenity Transactions** across spa, dining, bar, and room service
- **5 Hotel Properties** across major brands (Hilton, Marriott, Hyatt, IHG)
- **Multiple Generations** represented (Gen Z, Millennials, Gen X, Boomers)
- **All Loyalty Tiers** (Blue, Silver, Gold, Diamond) with realistic distribution
- **4 Service Categories** with detailed transaction and satisfaction data

### **🎯 Customer Segmentation Results**
| Segment | Guests | Avg Revenue | Personalization Score |
|---------|--------|-------------|----------------------|
| VIP Champion | 5 | $10,000+ | 85+ |
| High Value | 76 | $5,000+ | 75+ |
| Loyal Premium | 180 | $3,000+ | 70+ |
| Premium | 320 | $1,000+ | 60+ |
| Regular | 419 | <$1,000 | 40+ |

### **💡 Personalization Insights**
- **186 Guests** with "Excellent" personalization potential
- **312 Guests** with "Good" personalization readiness
- **420 Guests** with "Fair" opportunities for enhancement
- **716 Room Preference Profiles** with detailed customization data

### **🔄 Revenue Opportunities**
- **High Upsell Potential**: 234 guests (70-100 propensity score)
- **Medium Upsell Potential**: 445 guests (50-69 propensity score)
- **Cross-selling Opportunities**: Identified across all service categories
- **Loyalty Tier Upgrades**: 156 guests ready for tier advancement

### **🎯 ENHANCED: Comprehensive Amenity & Infrastructure Intelligence**
- **$245,000+ Total Amenity Revenue** tracked across 3,500+ transactions
- **7 Service Categories**: Spa, Restaurant, Bar, Room Service, **WiFi Upgrades, Smart TV Premium, Pool Services**
- **Infrastructure Usage Analytics**: 8,000+ usage sessions across WiFi, Smart TV, and Pool amenities
- **Advanced AI Scoring**: Spa/dining upsell propensity + **tech upsell propensity + pool services propensity**
- **Technology Adoption Profiles**: Premium Tech Users, High Tech Users, Basic Tech Users
- **Cross-Service Intelligence**: Guest behavior patterns across traditional and infrastructure amenities
- **Infrastructure Engagement Scoring**: Comprehensive usage analytics and satisfaction tracking

---

## 💻 **TECHNICAL IMPLEMENTATION**

### **🛠️ Technology Stack**
- **Platform**: Snowflake Data Cloud
- **Architecture**: Medallion (Bronze → Silver → Gold → Semantic)
- **AI Integration**: Snowflake Cortex Intelligence
- **Security**: Role-based access control with project-specific roles
- **Query Interface**: Natural language via Snowflake Intelligence Agents

### **📁 Project Structure**
```
Hotel-Personalization-System/
├── 📊 SQL Scripts (Deployment Order)
│   ├── scripts/01_account_setup.sql           # Database, schemas, roles, warehouse
│   ├── scripts/02_schema_setup.sql            # 23 tables (Bronze, Silver, Gold)
│   ├── scripts/03_data_generation.sql         # Synthetic data for Bronze tables
│   ├── scripts/03b_refresh_silver_gold.sql    # Refresh Silver/Gold after data load
│   ├── scripts/04_semantic_views.sql          # 3 semantic views
│   ├── scripts/05_intelligence_agents.sql     # 5 AI agents with RBAC
│   └── scripts/08_sample_queries.sql          # Example BI queries
│
├── 🚀 Deployment Scripts
│   ├── deploy.sh                          # Main deployment script
│   ├── clean.sh                           # Resource cleanup
│   ├── run.sh                             # Runtime operations
│   └── python/deployment/
│       └── complete_deployment.py         # Python-based deployment
│
├── 📚 Documentation
│   ├── README.md                          # This comprehensive guide
│   ├── DEPLOYMENT_GUIDE.md                # Step-by-step deployment
│   ├── SCHEMA_VALIDATION_REPORT.md        # Schema validation results
│   ├── VALIDATION_REPORT.md               # Data generation validation
│   └── docs/
│       ├── DESIGN.md                      # System architecture
│       ├── AGENT_DETAILED_QUESTIONS.md    # Agent test questions
│       ├── hotel_architecture_diagram.xml # Architecture diagram
│       └── references/
│           ├── AGENT_SAMPLE_QUESTIONS.md  # 100+ sample questions
│           └── AGENT_QUICK_REFERENCE.md   # Quick reference
│
└── 🎨 Solution Presentation
    └── solution_presentation/
        ├── Hotel_Personalization_Solution_Overview.md
        └── images/                        # Solution diagrams
```

### **🔧 Deployment Scripts**
- **Complete Automation**: Single-command deployment with `23_final_deployment.py`
- **Role Management**: Automated role creation and permission assignment
- **Data Generation**: Realistic sample data with proper relationships
- **Verification**: Built-in testing and validation of all components

---

## 📊 **BUSINESS IMPACT & ROI**

### **💰 Revenue Impact (Demo Data Insights)**
- **$500K+ Revenue Opportunities Identified** in synthetic demo dataset (1,000 guests)
- **10-25% Revenue Increase Potential** through AI-powered targeted upselling
- **30-50% Improvement in Repeat Bookings** via enhanced personalized experiences
- **15-25% Reduction in Churn** through proactive intervention strategies

> **Demo Note:** The $500K figure is based on analysis of the 1,000 synthetic guest profiles included in this demonstration. These opportunities are identified by the platform's ML scoring models analyzing guest behavior patterns, preferences, and propensity scores.

### **😊 Guest Experience Improvements (Platform Capabilities)**
- **Enhanced Guest Satisfaction** through accurate preference matching and anticipatory service
- **Proactive Service Delivery** with pre-configured room setups based on historical preferences
- **Intelligent Recommendations** for dining, activities, and services using ML propensity scores
- **Seamless Experience** across all touchpoints and properties with unified guest profiles

### **⚡ Operational Efficiency**
- **Natural Language Queries** eliminate need for technical SQL knowledge
- **Real-time Insights** for immediate decision making
- **Automated Personalization** reduces manual configuration time
- **Predictive Analytics** enable proactive resource planning

---

## 🎯 **USE CASES & EXAMPLES**

### **🏨 Pre-Arrival Personalization**
**Ask Intelligence Agent:** *"Show me VIP guests with upcoming stays and their room preferences"*

Or query directly:
```sql
-- Get VIP guests with high upsell propensity
SELECT 
    g.first_name,
    g.last_name,
    g.loyalty_tier,
    g.customer_segment,
    p.spa_upsell_propensity,
    p.dining_upsell_propensity
FROM GOLD.GUEST_360_VIEW_ENHANCED g
JOIN GOLD.PERSONALIZATION_SCORES_ENHANCED p ON g.guest_id = p.guest_id
WHERE g.customer_segment IN ('VIP Champion', 'High Value')
  AND g.loyalty_tier IN ('Diamond', 'Platinum')
ORDER BY p.upsell_propensity_score DESC
LIMIT 20;
```

### **💰 Revenue Optimization**
**Ask Intelligence Agent:** *"Which guests have the highest spa and dining upsell potential?"*

Or query directly:
```sql
-- Identify high-value upsell opportunities
SELECT 
    g.first_name,
    g.last_name,
    g.total_revenue,
    p.spa_upsell_propensity,
    p.dining_upsell_propensity,
    p.tech_upsell_propensity,
    p.upsell_propensity_score
FROM GOLD.GUEST_360_VIEW_ENHANCED g
JOIN GOLD.PERSONALIZATION_SCORES_ENHANCED p ON g.guest_id = p.guest_id
WHERE p.upsell_propensity_score >= 70
  AND g.customer_segment IN ('VIP Champion', 'High Value')
ORDER BY p.upsell_propensity_score DESC, g.total_revenue DESC
LIMIT 50;
```

### **😊 Churn Prevention**
**Ask Intelligence Agent:** *"Show me high-value guests at risk of churning"*

Or query directly:
```sql
-- Find at-risk high-value guests needing attention
SELECT 
    first_name,
    last_name,
    customer_segment,
    churn_risk,
    total_revenue,
    loyalty_tier,
    total_bookings,
    avg_amenity_satisfaction
FROM GOLD.GUEST_360_VIEW_ENHANCED
WHERE churn_risk IN ('High', 'Medium')
  AND customer_segment IN ('VIP Champion', 'High Value', 'Premium')
ORDER BY total_revenue DESC
LIMIT 25;
```

---

## 🚀 **GETTING STARTED**

### **1. 🏗️ Deploy the System**
```bash
# Execute the complete deployment (recommended)
./deploy.sh

# Or deploy with custom connection
./deploy.sh -c your_connection_name

# Follow the deployment guide for details
cat DEPLOYMENT_GUIDE.md
```

### **2. 📊 Verify Installation**
```sql
-- Check data volumes
SELECT 'Guest Profiles' as table_name, COUNT(*) as record_count 
FROM HOTEL_PERSONALIZATION.BRONZE.GUEST_PROFILES
UNION ALL
SELECT 'Bookings', COUNT(*) 
FROM HOTEL_PERSONALIZATION.BRONZE.BOOKING_HISTORY
UNION ALL
SELECT 'Amenity Transactions', COUNT(*) 
FROM HOTEL_PERSONALIZATION.BRONZE.AMENITY_TRANSACTIONS
UNION ALL
SELECT 'Guest 360 View', COUNT(*) 
FROM HOTEL_PERSONALIZATION.GOLD.GUEST_360_VIEW_ENHANCED;
```

### **5. 🎯 Test Natural Language Queries**
Ask your AI agents questions like:
- *"Show me our top 10 most valuable guests by lifetime revenue"*
- *"Which guests have the highest upsell potential this month?"*
- *"What personalized room setups should we prepare for arriving Diamond guests?"*

---

---

## 🏆 **COMPETITIVE ADVANTAGES**

### **🌟 Industry-Leading Capabilities**
Your hotel personalization system now delivers capabilities that rival:
- **Ritz-Carlton's** legendary personalized service
- **Four Seasons'** attention to guest preferences  
- **Marriott's** loyalty program sophistication
- **Hilton's** revenue optimization strategies

### **🚀 Advanced Technology Integration**
- **Conversational AI** for instant insights without technical expertise
- **Semantic Data Models** for natural language understanding
- **Predictive Analytics** for proactive service delivery
- **Real-time Personalization** at enterprise scale

### **📈 Measurable Business Results**
- **Production-scale data** with 1000+ guest profiles
- **Actionable insights** with 918 personalization opportunities
- **Revenue intelligence** with $1.26M+ tracked performance
- **Strategic capabilities** for portfolio-wide optimization

---

## 🎉 **CONCLUSION**

This **Hotel Guest Personalization System** represents a **complete transformation** of how hotels can deliver personalized experiences at scale. By combining:

- 🏗️ **Robust data architecture** with medallion design patterns
- 🤖 **AI-powered intelligence** through Snowflake Cortex
- 🔐 **Enterprise security** with role-based access control
- 📊 **Business intelligence** through semantic data models
- 🎯 **Natural language interfaces** for all user types

**Your hotel chain now has the foundation to compete with industry leaders and deliver world-class personalized experiences that drive guest satisfaction, loyalty, and revenue growth.**

**Welcome to the future of AI-powered hospitality!** 🌟

---

## 📞 **Support & Documentation**

- **📚 Complete Documentation**: All implementation details in organized project structure
- **🎯 Sample Questions**: Multiple comprehensive guides:
  - `docs/AGENT_DETAILED_QUESTIONS.md` - Detailed questions by business category
  - `docs/references/AGENT_SAMPLE_QUESTIONS.md` - Practical staff guide with 100+ questions
  - `docs/references/AGENT_QUICK_REFERENCE.md` - Quick reference card
- **🔐 Security Guide**: Role management in `scripts/security/` folder
- **🚀 Deployment Guide**: Step-by-step instructions in `DEPLOYMENT_GUIDE.md`

---

## 📚 **About Industry Benchmarks & ROI Estimates**

### **Data Sources for Hospitality Personalization ROI**

The revenue and satisfaction improvement ranges mentioned in this README are based on commonly cited hospitality industry benchmarks. Typical sources for such estimates include:

**Industry Research:**
- Hospitality technology vendor case studies and ROI reports
- Hotel association research (AHLA, STR, Phocuswright)
- Customer experience research firms (Forrester, Gartner, McKinsey)
- Academic hospitality management journals

**Common Benchmark Ranges:**
- Revenue lift from personalization: 10-30% (varies by implementation and property type)
- Guest satisfaction improvements: 15-40% (measured via NPS, CSAT scores)
- Loyalty/repeat booking increases: 25-60% (for effectively personalized experiences)
- Churn reduction: 15-30% (through proactive service recovery)

**Important Considerations:**
- **Results vary significantly** based on baseline personalization maturity, property type (luxury vs. budget), guest demographics, and implementation quality
- **This is a demonstration platform** with synthetic data designed to showcase technical capabilities, not to guarantee specific business outcomes
- **Production ROI depends on** data quality, staff adoption, integration with existing systems, and ongoing optimization
- **Consult with** your business analytics team and Snowflake account representatives for tailored ROI projections based on your specific context

### **About This Demo Platform**

This platform demonstrates:
- ✅ Technical architecture for unifying guest data
- ✅ ML-powered scoring and segmentation capabilities  
- ✅ Natural language query interfaces via Snowflake Intelligence
- ✅ Production-ready code patterns and best practices

**This is NOT:**
- ❌ A guarantee of specific business outcomes
- ❌ A replacement for business case analysis
- ❌ Production-ready without customization for your data and processes

**For Production Deployment:** Work with Snowflake Solution Engineers to adapt this platform to your specific data sources, business rules, and ROI targets.

---

**Ready to transform your hotel operations with AI-powered personalization!** 🚀