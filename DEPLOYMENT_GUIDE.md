# 🚀 Hotel Personalization System - Deployment Guide

## 📁 **Clean Project Structure**

```
Hotel-Personalization-System/
├── README.md                           # Main project documentation
├── DEPLOYMENT_GUIDE.md                 # This deployment guide
├── 
├── sql/                               # All SQL scripts organized by layer
│   ├── setup/
│   │   └── 01_setup_database.sql      # Database and schema creation
│   ├── bronze/
│   │   ├── 02_bronze_layer_tables.sql # Raw data tables
│   │   ├── 03_sample_data_generation.sql # Sample data (Part 1)
│   │   └── 04_booking_stay_data.sql   # Sample data (Part 2)
│   ├── silver/
│   │   └── 05_silver_layer.sql        # Cleaned and standardized data
│   ├── gold/
│   │   └── 06_gold_layer.sql          # Analytics-ready aggregations
│   ├── semantic_views/
│   │   └── create_semantic_views.sql  # Natural language query views
│   ├── agents/
│   │   └── create_intelligence_agents.sql # AI agents
│   ├── security/
│   │   └── 32_create_hotel_project_roles.sql # RBAC roles
│   └── 08_sample_queries.sql          # Example queries
│
├── python/                            # Python deployment scripts
│   ├── deployment/
│   │   ├── complete_deployment.py     # Main deployment script
│   │   └── 33_execute_role_creation.py # Role creation utility
│   └── utilities/                     # Future utility scripts
│
├── docs/                              # Documentation
│   ├── DESIGN.md                      # System design documentation
│   ├── hotel_architecture_diagram.xml # Draw.io architecture diagram
│   └── references/
│       ├── AGENT_SAMPLE_QUESTIONS.md  # Comprehensive agent questions
│       └── AGENT_QUICK_REFERENCE.md   # Quick reference card
│
└── archive/                           # Archived iteration files
    └── [All development iteration files]
```

## 🎯 **Quick Deployment**

### **Option 1: Automated Python Deployment (Recommended)**

```bash
# Navigate to project directory
cd "/path/to/Hotel-Personalization-System"

# Run complete deployment
python python/deployment/complete_deployment.py
```

### **Option 2: Manual SQL Deployment**

Execute SQL files in this order:

```sql
-- 1. Setup
@sql/setup/01_setup_database.sql

-- 2. Security
@sql/security/32_create_hotel_project_roles.sql

-- 3. Data Layers
@sql/bronze/02_bronze_layer_tables.sql
@sql/bronze/03_sample_data_generation.sql
@sql/bronze/04_booking_stay_data.sql
@sql/silver/05_silver_layer.sql
@sql/gold/06_gold_layer.sql

-- 4. Semantic Layer
@sql/semantic_views/create_semantic_views.sql

-- 5. AI Agents
@sql/agents/create_intelligence_agents.sql
```

## 🔐 **Authentication Setup**

The deployment uses key-pair authentication. Ensure you have:

1. **Private Key**: `~/.ssh/snowflake_rsa_key`
2. **Public Key**: Already configured in Snowflake for user `SRSUBRAMANIAN`
3. **Account**: `snowflake_partner_se_training-srsubramanian`

## 📊 **What Gets Created**

### **Database Structure:**
- **Database**: `HOTEL_PERSONALIZATION`
- **Schemas**: `BRONZE`, `SILVER`, `GOLD`, `BUSINESS_VIEWS`, `SEMANTIC_VIEWS`

### **Data Volume:**
- **1000+ Guests** with realistic profiles
- **2000+ Bookings** with seasonal patterns
- **5000+ Preference records** with detailed customization
- **918 Revenue opportunities** worth $1.26M+

### **AI Capabilities:**
- **5 Specialized Agents** for different hotel operations
- **3 Semantic Views** for natural language queries
- **100+ Sample questions** for staff training

### **Security:**
- **6 Role-based access** levels
- **Proper permissions** for each data layer
- **Project isolation** from other Snowflake projects

## 🤖 **AI Agents Created**

1. **🧠 Guest Analytics Agent** - Behavior analysis & loyalty insights
2. **🎯 Personalization Specialist** - Room preferences & customization  
3. **💰 Revenue Optimizer** - Upselling & profit maximization
4. **😊 Experience Optimizer** - Satisfaction & churn prevention
5. **🏆 Intelligence Master Agent** - Strategic insights & executive analysis

## 🎪 **Testing Your Deployment**

### **Verify Data:**
```sql
-- Check data volume
SELECT 'Guests' as table_name, COUNT(*) as record_count FROM HOTEL_PERSONALIZATION.BRONZE.GUESTS
UNION ALL
SELECT 'Bookings', COUNT(*) FROM HOTEL_PERSONALIZATION.BRONZE.BOOKINGS
UNION ALL
SELECT 'Revenue Opportunities', COUNT(*) FROM HOTEL_PERSONALIZATION.GOLD.REVENUE_OPPORTUNITIES;
```

### **Test AI Agents:**
Try these sample questions with your agents:
- *"Show me our top 10 most valuable guests by lifetime revenue"*
- *"Which guests have the highest upsell potential this month?"*
- *"What personalized room setups should we prepare for arriving Diamond guests?"*

## 🔧 **Troubleshooting**

### **Common Issues:**

1. **Authentication Error:**
   - Verify private key path: `~/.ssh/snowflake_rsa_key`
   - Ensure public key is set in Snowflake user profile

2. **Permission Denied:**
   - Script uses `ACCOUNTADMIN` role for initial setup
   - Ensure your user has appropriate privileges

3. **Agent Creation Fails:**
   - Verify `SNOWFLAKE_INTELLIGENCE` database exists
   - Check that semantic views were created successfully

### **Getting Help:**
- Check the `archive/` folder for detailed development history
- Review `docs/references/` for comprehensive documentation
- Use sample queries in `sql/08_sample_queries.sql` for testing

## 🎉 **Success Indicators**

Your deployment is successful when:

✅ **Database created** with all 5 schemas  
✅ **1000+ guest records** generated  
✅ **All data layers populated** (Bronze → Silver → Gold)  
✅ **3 semantic views created** without errors  
✅ **5 AI agents deployed** and accessible  
✅ **Security roles configured** with proper permissions  

**Ready to revolutionize hotel personalization!** 🌟


























