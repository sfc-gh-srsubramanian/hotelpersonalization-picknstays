# 🚀 Hotel Personalization System - Deployment Guide

## 📁 **Clean Project Structure**

```
Hotel-Personalization-System/
├── README.md                           # Main project documentation
├── DEPLOYMENT_GUIDE.md                 # This deployment guide
├── deploy.sh                           # Automated bash deployment (RECOMMENDED)
├── run.sh                              # Runtime operations and validation
├── clean.sh                            # Cleanup and resource removal
├── 
├── scripts/                               # All SQL scripts (numbered for execution order)
│   ├── 01_account_setup.sql           # Database and schema creation
│   ├── 02_schema_setup.sql            # All table definitions
│   ├── 03_data_generation.sql         # Synthetic data generation
│   ├── 04_semantic_views.sql          # Semantic views for AI agents
│   ├── 05_intelligence_agents.sql     # AI agent creation
│   └── 08_sample_queries.sql          # Example queries
│
├── python/                            # Python utilities (legacy)
│   ├── deployment/                    # Legacy deployment scripts (not used)
│   └── utilities/                     # Utility scripts
│
├── docs/                              # Documentation
│   ├── DESIGN.md                      # System design documentation
│   ├── hotel_architecture_diagram.xml # Draw.io architecture diagram
│   └── references/
│       ├── AGENT_SAMPLE_QUESTIONS.md  # Comprehensive agent questions
│       └── AGENT_QUICK_REFERENCE.md   # Quick reference card
│
└── solution_presentation/             # Solution overview and presentation
    ├── Hotel_Personalization_Solution_Overview.md
    └── images/                        # Generated diagrams
```

## 🎯 **Quick Deployment**

### **Option 1: Automated Bash Deployment (⭐ RECOMMENDED)**

The `deploy.sh` script provides the fastest and most reliable deployment:

```bash
# Navigate to project directory
cd "/path/to/Hotel-Personalization-System"

# Full deployment (10-15 minutes)
./deploy.sh

# Or with custom options:
./deploy.sh --prefix DEV              # Deploy with DEV_ prefix for testing
./deploy.sh -c prod                   # Use 'prod' connection
./deploy.sh --skip-agents             # Skip Intelligence Agents creation
./deploy.sh --only-sql                # Deploy only SQL infrastructure
```

**What deploy.sh does:**
1. ✅ Validates prerequisites (Snowflake CLI installed and configured)
2. ✅ Creates database, schemas, roles, and warehouse
3. ✅ Deploys all tables across Bronze, Silver, Gold layers
4. ✅ Generates 10,000+ synthetic data records
5. ✅ Creates 9 semantic views for natural language querying (includes NEW guest preferences view)
6. ✅ Deploys 5 Snowflake Intelligence Agents (optional, Master Agent has 48+ sample questions)
7. ✅ Registers agents with Snowflake Intelligence for UI visibility
8. ✅ Runs validation queries to confirm success

**After deployment, use run.sh for operations:**
```bash
./run.sh status                       # Check resource and data status
./run.sh validate                     # Run validation queries
./run.sh query "SELECT * FROM..."     # Execute custom SQL
./run.sh test-agents                  # Test Intelligence Agents
./run.sh streamlit                    # Check Streamlit app and get access info
```

### **Option 2: Manual SQL Deployment**

Execute SQL files in numbered order using Snowflake CLI:

```bash
# Execute each file in sequence
snow sql -f scripts/01_account_setup.sql -c demo
snow sql -f scripts/02_schema_setup.sql -c demo
snow sql -f scripts/03_data_generation.sql -c demo
snow sql -f scripts/04_semantic_views.sql -c demo
snow sql -f scripts/05_intelligence_agents.sql -c demo
```

Or using SnowSQL:
```bash
snowsql -c demo -f scripts/01_account_setup.sql
snowsql -c demo -f scripts/02_schema_setup.sql
# ... continue with remaining files
```

## 🔐 **Prerequisites**

Before deploying, ensure you have:

### **1. Snowflake CLI Installed**
```bash
pip install snowflake-cli-labs

# Verify installation
snow --version
```

### **2. Snowflake Connection Configured**
```bash
# Add a connection (interactive)
snow connection add demo

# Or manually edit ~/.snowflake/connections.toml
```

### **3. Required Privileges**
Your Snowflake user needs:
- CREATE DATABASE
- CREATE WAREHOUSE  
- CREATE ROLE
- USAGE on SNOWFLAKE_INTELLIGENCE database (for AI agents)

### **4. Snowflake Edition**
- **Minimum**: Enterprise Edition
- **For AI Agents**: Business Critical or higher (with Snowflake Intelligence enabled)

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
- **5 Specialized Agents** for different hotel operations (Master Agent with 48+ sample questions)
- **9 Semantic Views** for natural language queries (includes NEW guest preferences view)
- **48+ Sample questions** for executive training (8 new preference queries)

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
SELECT 'Guest Profiles' as table_name, COUNT(*) as record_count 
FROM HOTEL_PERSONALIZATION.BRONZE.GUEST_PROFILES
UNION ALL
SELECT 'Booking History', COUNT(*) 
FROM HOTEL_PERSONALIZATION.BRONZE.BOOKING_HISTORY
UNION ALL
SELECT 'Amenity Transactions', COUNT(*) 
FROM HOTEL_PERSONALIZATION.BRONZE.AMENITY_TRANSACTIONS
UNION ALL
SELECT 'Guest 360 View (Gold)', COUNT(*) 
FROM HOTEL_PERSONALIZATION.GOLD.GUEST_360_VIEW_ENHANCED
UNION ALL
SELECT 'Personalization Scores (Gold)', COUNT(*) 
FROM HOTEL_PERSONALIZATION.GOLD.PERSONALIZATION_SCORES_ENHANCED;
```

### **Test AI Agents:**
Try these sample questions with your agents:
- *"Show me our top 10 most valuable guests by lifetime revenue"*
- *"Which guests have the highest upsell potential this month?"*
- *"What personalized room setups should we prepare for arriving Diamond guests?"*

## 🔧 **Troubleshooting**

### **Common Issues:**

1. **Snowflake CLI Not Found:**
   ```bash
   # Install Snowflake CLI
   pip install snowflake-cli-labs
   
   # Configure connection
   snow connection add demo
   ```

2. **Authentication Error:**
   - Verify your Snowflake connection is configured: `snow connection test -c demo`
   - Check credentials in `~/.snowflake/connections.toml`
   - For key-pair auth, ensure private key path is correct

3. **Permission Denied:**
   - Deploy script requires `ACCOUNTADMIN` or equivalent privileges
   - Ensure your user has CREATE DATABASE and CREATE WAREHOUSE permissions

4. **Agent Creation Fails:**
   - Verify your Snowflake edition supports Snowflake Intelligence (Business Critical or higher)
   - Check that semantic views were created successfully before agents
   - Use `--skip-agents` flag to deploy without agents if needed
   - Note: Agents are automatically registered with `SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT` for UI visibility

5. **Data Generation Takes Too Long:**
   - Increase warehouse size in `scripts/01_account_setup.sql` (default: MEDIUM)
   - Consider reducing data volume in `scripts/03_data_generation.sql` for testing

### **Getting Help:**

**Documentation Resources:**
- Review `README.md` for complete system overview
- Check `docs/DESIGN.md` for architecture details
- See `docs/references/` for comprehensive agent questions and guides
- Use sample queries in `scripts/08_sample_queries.sql` for testing

**Validation Commands:**
```bash
./run.sh status                       # Check deployment status
./run.sh validate                     # Run validation queries
./run.sh test-agents                  # Test AI agents
./run.sh streamlit                    # Check Streamlit dashboards
```

**Support:**
- GitHub Issues: Report problems or request features
- Snowflake Community: Connect with other developers
- Contact your Snowflake account team for production deployments

## 🧹 **Cleanup & Resource Removal**

To remove all deployed resources, use the `clean.sh` script:

```bash
# Interactive cleanup (asks for confirmation)
./clean.sh

# Non-interactive cleanup (auto-confirms)
./clean.sh --force

# Keep Intelligence Agents, remove everything else
./clean.sh --keep-agents

# Cleanup with custom connection
./clean.sh -c prod

# Cleanup with environment prefix
./clean.sh --prefix DEV
```

**What gets removed:**
- ❌ Agent registrations from Snowflake Intelligence (Step 0)
- ❌ Intelligence Agents (unless --keep-agents specified)
- ❌ Semantic views
- ❌ All tables and data (Bronze, Silver, Gold layers)
- ❌ Project-specific roles
- ❌ Warehouse (if created by deployment)
- ❌ Database (HOTEL_PERSONALIZATION)

**Note:** This operation cannot be undone. Ensure you have backups if needed.

## 🎉 **Success Indicators**

Your deployment is successful when:

✅ **Database created** with all 5 schemas  
✅ **1000+ guest records** generated  
✅ **All data layers populated** (Bronze → Silver → Gold)  
✅ **9 semantic views created** without errors (includes NEW guest preferences view)  
✅ **5 AI agents deployed** and accessible (Master Agent with 48+ questions)  
✅ **Agents registered** with Snowflake Intelligence and visible in UI  
✅ **Security roles configured** with proper permissions  

**Ready to revolutionize hotel personalization!** 🌟


























