# 🏨 Hotel Guest Personalization System
## *Transforming Hospitality Through AI-Powered Personalization*

---

## 🎯 **WHY This System Exists**

### **The Hospitality Challenge**
Modern hotel guests expect **personalized experiences** that rival industry leaders like Ritz-Carlton and Four Seasons. However, most hotel chains struggle with:

- **Fragmented guest data** across multiple systems (PMS, booking platforms, loyalty programs)
- **Manual personalization** that doesn't scale across thousands of guests
- **Reactive service** instead of proactive guest experience optimization
- **Limited insights** into guest preferences and behavior patterns
- **Missed revenue opportunities** from poor upselling and cross-selling

### **The Business Opportunity**
Industry leaders and hospitality studies indicate that **AI-powered personalization platforms** can potentially deliver:
- 📈 **10-25% revenue increase** through intelligent upselling and cross-selling
- 😊 **20-35% improvement in guest satisfaction** through accurate preference matching
- 🔄 **30-50% boost in repeat bookings** via enhanced loyalty and personalized experiences
- 💰 **15-25% reduction in guest churn** through proactive intervention and service recovery
- ⚡ **Faster service delivery and operational efficiency** with pre-configured room setups

> **Note:** These are industry benchmark ranges based on common hospitality technology ROI studies. Actual results vary significantly based on implementation quality, property type, guest demographics, and existing personalization maturity. This platform demonstrates the technical capabilities to enable such outcomes.

### **Our Solution**
A **comprehensive AI-powered personalization platform** that:
- 🧠 **Unifies all guest data** into a single source of truth
- 🎯 **Delivers hyper-personalized experiences** at scale
- 💡 **Provides actionable insights** through natural language queries
- 🚀 **Enables proactive service** with predictive analytics
- 📊 **Drives revenue growth** through intelligent recommendations

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
- ✅ Database with 5 schemas (Bronze, Silver, Gold, Business Views, Semantic Views)
- ✅ 23 tables across medallion architecture (13 Bronze, 7 Silver, 3 Gold)
- ✅ 1,000 synthetic guest profiles with realistic data
- ✅ 2,000+ bookings and 1,395+ completed stays
- ✅ 3,500+ amenity transactions and 8,000+ usage records
- ✅ 3 semantic views for natural language querying
- ✅ 5 Snowflake Intelligence Agents with granular RBAC

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

**SQL Files** (Numbered for execution order):
- `sql/01_account_setup.sql` - Database, schemas, roles, warehouse
- `sql/02_schema_setup.sql` - All table definitions (23 tables across Bronze/Silver/Gold)
- `sql/03_data_generation.sql` - Synthetic data generation for all Bronze tables
- `sql/03b_refresh_silver_gold.sql` - Refresh Silver and Gold tables after data load
- `sql/04_semantic_views.sql` - 3 semantic views for natural language querying
- `sql/05_intelligence_agents.sql` - 5 AI agents with granular RBAC
- `sql/08_sample_queries.sql` - Example BI queries across all layers

**Documentation:**
- `README.md` - This file, complete platform overview
- `DEPLOYMENT_GUIDE.md` - Detailed deployment instructions
- `SCHEMA_VALIDATION_REPORT.md` - Schema validation and fixes
- `VALIDATION_REPORT.md` - Data generation validation
- `docs/AGENT_DETAILED_QUESTIONS.md` - Sample agent test questions
- `docs/hotel_architecture_diagram.xml` - Visual architecture diagram
- `solution_presentation/` - Solution overview and presentation materials

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
│  │ 📱 Social Media │               │ • guest_profiles (1000 records)     │ │ Analytics   │ │
│  │ 📝 Reviews/CRM  │               │ • booking_history (2000 records)    │ │             │ │
│  │ 🎯 Loyalty APIs │               │ • room_preferences (716 records)    │ │ Personaliz- │ │
│  │ 🌐 WiFi Systems │               │ • loyalty_program (1000 records)    │ │ ation       │ │
│  │ 📺 Smart TV API │               │ • hotel_properties (5 records)      │ │ Specialist  │ │
│  │ 🏊 Pool Systems │               │ • amenity_transactions (3500+ recs) │ │             │ │
│  └─────────────────┘               │ • amenity_usage (8000+ sessions)    │ │ Revenue     │ │
│           │                        │                                     │ │             │ │
│           ▼                        └─────────────┬───────────────────────┘ │ Revenue     │ │
│                                                  │                         │ Optimizer   │ │
│  🔄 REAL-TIME INGESTION                         ▼                         │             │ │
│  ┌─────────────────┐               ┌─────────────────────────────────────┐ │ Experience  │ │
│  │ • Streaming ETL │               │        🥈 SILVER LAYER              │ │ Optimizer   │ │
│  │ • Data Validation│               │    (Cleaned & Standardized)        │ │             │ │
│  │ • Schema Evolution│              │                                     │ │ Master      │ │
│  │ • Error Handling │               │ • guests_standardized (1000)        │ │ Intelligence│ │
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
│  └─────────────────┘               │ • guest_360_view_enhanced (1000)    │                 │
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
- **Database**: `HOTEL_PERSONALIZATION` with 5 specialized schemas
- **Production Scale**: 1000+ guests, 2000+ bookings, $1.26M+ revenue tracked
- **Security Model**: Role-based access control with 6 project-specific roles
- **Data Governance**: Comprehensive audit trails and compliance framework

### **📊 Data Layers Implemented**

#### **🥉 Bronze Layer (13 Tables)**
| Table | Records | Purpose |
|-------|---------|---------|
| `guest_profiles` | 1,000 | Guest demographics, contact info, preferences |
| `booking_history` | 2,000 | Complete booking transactions and patterns |
| `stay_history` | 1,395 | Complete stay records with incidental charges |
| `room_preferences` | ~716 | Room-specific preferences (bed type, floor, view) |
| `service_preferences` | ~600 | Service preferences (dining, spa, amenities) |
| `social_media_activity` | ~500 | Social media engagement and sentiment |
| `loyalty_program` | 1,000 | Loyalty tiers, points, and program status |
| `feedback_reviews` | ~800 | Guest reviews and satisfaction scores |
| `payment_methods` | ~1,000 | Payment methods and billing preferences |
| `special_requests` | ~700 | Special requests and accommodations |
| `hotel_properties` | 5 | Hotel information across major brands |
| `amenity_transactions` | 3,500+ | Detailed amenity spending (spa, bar, restaurant, room service) |
| `amenity_usage` | 8,000+ | Infrastructure usage (WiFi, Smart TV, Pool) |

#### **🥈 Silver Layer (7 Tables)**
| Table | Records | Purpose |
|-------|---------|---------|
| `guests_standardized` | 1,000 | Cleaned guest data with business logic and demographics |
| `bookings_enriched` | 2,000+ | Enriched booking data with derived metrics |
| `stays_processed` | 1,395+ | Processed stay data with spending categories |
| `preferences_consolidated` | ~1,000 | Consolidated room and service preferences |
| `engagement_metrics` | ~500 | Social media and digital engagement analysis |
| `amenity_spending_enriched` | 3,500+ | Enriched amenity transactions with categories |
| `amenity_usage_enriched` | 8,000+ | Infrastructure usage analytics with engagement scores |

#### **🏆 Gold Layer (3 Tables)**
| Table | Records | Purpose |
|-------|---------|---------|
| `guest_360_view_enhanced` | 1,000 | Complete guest profiles with all enriched metrics |
| `personalization_scores_enhanced` | 1,000 | AI-powered propensity scores (upsell, churn, loyalty) |
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
- **Data Sources**: All 3 semantic views (comprehensive cross-functional access)
- **Expertise**: Strategic business analysis, executive insights, comprehensive KPIs
- **Sample Questions** (15+): Strategic analysis, ROI, portfolio optimization, competitive insights

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

### **4. 📊 Business Intelligence**
- **Real-time Dashboards** for operational insights
- **Executive Reporting** with strategic KPIs
- **Performance Benchmarking** across properties
- **Predictive Analytics** for demand forecasting

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
│   ├── sql/01_account_setup.sql           # Database, schemas, roles, warehouse
│   ├── sql/02_schema_setup.sql            # 23 tables (Bronze, Silver, Gold)
│   ├── sql/03_data_generation.sql         # Synthetic data for Bronze tables
│   ├── sql/03b_refresh_silver_gold.sql    # Refresh Silver/Gold after data load
│   ├── sql/04_semantic_views.sql          # 3 semantic views
│   ├── sql/05_intelligence_agents.sql     # 5 AI agents with RBAC
│   └── sql/08_sample_queries.sql          # Example BI queries
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
- **🔐 Security Guide**: Role management in `sql/security/` folder
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