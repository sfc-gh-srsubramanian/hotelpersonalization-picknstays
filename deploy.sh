#!/bin/bash
###############################################################################
# deploy.sh - Deploy Hotel Personalization Platform to Snowflake
#
# Creates all infrastructure and deploys the AI-powered guest experience platform:
#   1. Check prerequisites
#   2. Run account-level SQL setup (database, roles, warehouse)
#   3. Run schema-level SQL setup (tables, views)
#   4. Generate synthetic data into Bronze layer
#   4b. Refresh Silver and Gold layers with Bronze data
#   5. Create semantic views
#   6. Create intelligence agents (optional)
#
# Usage:
#   ./deploy.sh                       # Full deployment
#   ./deploy.sh -c prod               # Use 'prod' connection
#   ./deploy.sh --prefix DEV          # Deploy with DEV_ prefix
#   ./deploy.sh --skip-agents         # Skip agent creation
###############################################################################

set -e
set -o pipefail

# Configuration
CONNECTION_NAME="demo"
ENV_PREFIX=""
ONLY_COMPONENT=""
SKIP_AGENTS=false

# Project settings
PROJECT_PREFIX="HOTEL_PERSONALIZATION"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Error handler
error_exit() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

# Usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy Hotel Personalization Platform to Snowflake.

This platform enables AI-powered guest experience management with:
- Guest behavior analytics and 360-degree profiles
- ML-powered personalization and upsell propensity scoring
- Comprehensive amenity analytics (spa, dining, WiFi, Smart TV, pool)
- Natural language querying via Snowflake Intelligence Agents

Options:
  -c, --connection NAME    Snowflake CLI connection name (default: demo)
  -p, --prefix PREFIX      Environment prefix for resources (e.g., DEV, PROD)
  --skip-agents            Skip Intelligence Agents creation
  --only-sql               Deploy only SQL infrastructure
  --only-data              Deploy only data generation
  --only-semantic          Deploy only semantic views
  --only-agents            Deploy only intelligence agents
  -h, --help               Show this help message

Examples:
  $0                       # Full deployment
  $0 -c prod               # Use 'prod' connection
  $0 --prefix DEV          # Deploy with DEV_ prefix
  $0 --skip-agents         # Deploy without agents
  $0 --only-agents         # Redeploy only agents
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -c|--connection)
            CONNECTION_NAME="$2"
            shift 2
            ;;
        -p|--prefix)
            ENV_PREFIX="$2"
            shift 2
            ;;
        --skip-agents)
            SKIP_AGENTS=true
            shift
            ;;
        --only-sql)
            ONLY_COMPONENT="sql"
            shift
            ;;
        --only-data)
            ONLY_COMPONENT="data"
            shift
            ;;
        --only-semantic)
            ONLY_COMPONENT="semantic"
            shift
            ;;
        --only-agents)
            ONLY_COMPONENT="agents"
            shift
            ;;
        *)
            error_exit "Unknown option: $1\nUse --help for usage information"
            ;;
    esac
done

# Build connection string
SNOW_CONN="-c $CONNECTION_NAME"

# Compute full prefix
if [ -n "$ENV_PREFIX" ]; then
    FULL_PREFIX="${ENV_PREFIX}_${PROJECT_PREFIX}"
else
    FULL_PREFIX="${PROJECT_PREFIX}"
fi

# Derive all resource names
DATABASE="${FULL_PREFIX}"
ROLE="${FULL_PREFIX}_ROLE"
WAREHOUSE="${FULL_PREFIX}_WH"

# Helper function to check if a step should run
should_run_step() {
    local step_name="$1"
    if [ -z "$ONLY_COMPONENT" ]; then
        return 0
    fi
    case "$ONLY_COMPONENT" in
        sql)
            [[ "$step_name" == "account_sql" || "$step_name" == "schema_sql" ]]
            ;;
        data)
            [[ "$step_name" == "data_generation" ]]
            ;;
        semantic)
            [[ "$step_name" == "semantic_views" ]]
            ;;
        agents)
            [[ "$step_name" == "agents" ]]
            ;;
        *)
            return 1
            ;;
    esac
}

# Display banner
echo "========================================================================="
echo "Hotel Personalization Platform - Deployment"
echo "========================================================================="
echo ""
echo "AI-Powered Guest Experience Management"
echo "  • Guest 360 Analytics with Amenity Intelligence"
echo "  • ML Scoring: Upsell, Loyalty, Service-Specific Propensity"
echo "  • Natural Language Querying via Snowflake Intelligence"
echo ""
echo "Configuration:"
echo "  Connection: $CONNECTION_NAME"
if [ -n "$ENV_PREFIX" ]; then
    echo "  Environment Prefix: $ENV_PREFIX"
fi
if [ -n "$ONLY_COMPONENT" ]; then
    echo "  Deploy Only: $ONLY_COMPONENT"
fi
if [ "$SKIP_AGENTS" = true ]; then
    echo "  Agents: Skipped"
fi
echo "  Database: $DATABASE"
echo "  Role: $ROLE"
echo "  Warehouse: $WAREHOUSE"
echo ""

###############################################################################
# Step 1: Check Prerequisites
###############################################################################
echo "Step 1: Checking prerequisites..."
echo "-------------------------------------------------------------------------"

# Check for snow CLI
if ! command -v snow &> /dev/null; then
    error_exit "Snowflake CLI (snow) not found. Install with: pip install snowflake-cli"
fi
echo -e "${GREEN}✓${NC} Snowflake CLI found"

# Test Snowflake connection
echo "Testing Snowflake connection..."
if ! snow sql $SNOW_CONN -q "SELECT 1" &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} Failed to connect to Snowflake"
    snow connection test $SNOW_CONN 2>&1 || true
    exit 1
fi
echo -e "${GREEN}✓${NC} Connection '$CONNECTION_NAME' verified"

# Check required SQL files
for file in "sql/01_account_setup.sql" "sql/02_schema_setup.sql" "sql/03_data_generation.sql" "sql/04_semantic_views.sql"; do
    if [ ! -f "$file" ]; then
        error_exit "Required file not found: $file"
    fi
done
echo -e "${GREEN}✓${NC} Required SQL files present"

if [ "$SKIP_AGENTS" = false ] && should_run_step "agents"; then
    if [ ! -f "sql/05_intelligence_agents.sql" ]; then
        error_exit "Agent file not found: sql/05_intelligence_agents.sql"
    fi
    echo -e "${GREEN}✓${NC} Intelligence Agents SQL present"
fi
echo ""

###############################################################################
# Step 2: Run Account-Level SQL Setup
###############################################################################
if should_run_step "account_sql"; then
    echo "Step 2: Running account-level SQL setup..."
    echo "-------------------------------------------------------------------------"
    echo "Creating: Database, Schemas (Bronze/Silver/Gold), Role, Warehouse"
    echo ""
    
    {
        echo "-- Set session variables for account-level objects"
        echo "SET FULL_PREFIX = '${FULL_PREFIX}';"
        echo "SET PROJECT_ROLE = '${ROLE}';"
        echo "SET PROJECT_WH = '${WAREHOUSE}';"
        echo ""
        cat sql/01_account_setup.sql
    } | snow sql $SNOW_CONN -i
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓${NC} Account-level setup completed"
        echo "  • Database: $DATABASE"
        echo "  • Schemas: BRONZE, SILVER, GOLD, BUSINESS_VIEWS, SEMANTIC_VIEWS"
        echo "  • Role: $ROLE"
        echo "  • Warehouse: $WAREHOUSE"
    else
        error_exit "Account-level SQL setup failed"
    fi
    echo ""
else
    echo "Step 2: Skipped (--only-$ONLY_COMPONENT)"
    echo ""
fi

###############################################################################
# Step 3: Run Schema-Level SQL Setup
###############################################################################
if should_run_step "schema_sql"; then
    echo "Step 3: Running schema-level SQL setup..."
    echo "-------------------------------------------------------------------------"
    echo "Creating: All tables across Bronze, Silver, and Gold layers"
    echo ""
    
    {
        echo "USE ROLE ${ROLE};"
        echo "USE DATABASE ${DATABASE};"
        echo "USE WAREHOUSE ${WAREHOUSE};"
        echo ""
        echo "SET FULL_PREFIX = '${FULL_PREFIX}';"
        echo "SET PROJECT_ROLE = '${ROLE}';"
        echo ""
        cat sql/02_schema_setup.sql
    } | snow sql $SNOW_CONN -i
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓${NC} Schema-level setup completed"
        echo "  • Bronze Layer: 13 tables (raw data ingestion)"
        echo "  • Silver Layer: 7 tables (cleaned and enriched)"
        echo "  • Gold Layer: 3 tables (analytics-ready aggregations)"
    else
        error_exit "Schema-level SQL setup failed"
    fi
    echo ""
else
    echo "Step 3: Skipped (--only-$ONLY_COMPONENT)"
    echo ""
fi

###############################################################################
# Step 4: Generate Synthetic Data
###############################################################################
if should_run_step "data_generation"; then
    echo "Step 4: Generating synthetic data..."
    echo "-------------------------------------------------------------------------"
    echo "Loading: Hotels, Guests, Bookings, Stays, Amenity Transactions & Usage"
    echo ""
    
    {
        echo "USE ROLE ${ROLE};"
        echo "USE DATABASE ${DATABASE};"
        echo "USE WAREHOUSE ${WAREHOUSE};"
        echo ""
        echo "SET FULL_PREFIX = '${FULL_PREFIX}';"
        echo "SET PROJECT_ROLE = '${ROLE}';"
        echo ""
        cat sql/03_data_generation.sql
    } | snow sql $SNOW_CONN -i
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓${NC} Synthetic data generation completed"
        echo "  • Hotels: 50 properties"
        echo "  • Guests: 10,000 profiles"
        echo "  • Bookings: 25,000 reservations"
        echo "  • Stays: 20,000 completed stays"
        echo "  • Amenity Transactions: 30,000+ records"
        echo "  • Amenity Usage: 15,000+ sessions"
    else
        error_exit "Data generation failed"
    fi
    echo ""
else
    echo "Step 4: Skipped (--only-$ONLY_COMPONENT)"
    echo ""
fi

###############################################################################
# Step 4b: Refresh Silver and Gold Layers
###############################################################################
if should_run_step "data_generation"; then
    echo "Step 4b: Refreshing Silver and Gold layers..."
    echo "-------------------------------------------------------------------------"
    echo "Rebuilding: Silver and Gold tables with fresh Bronze data"
    echo ""
    
    {
        echo "USE ROLE ${ROLE};"
        echo "USE DATABASE ${DATABASE};"
        echo "USE WAREHOUSE ${WAREHOUSE};"
        echo ""
        echo "SET FULL_PREFIX = '${FULL_PREFIX}';"
        echo "SET PROJECT_ROLE = '${ROLE}';"
        echo ""
        cat sql/03b_refresh_silver_gold.sql
    } | snow sql $SNOW_CONN -i
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓${NC} Silver and Gold layers refreshed"
        echo "  • Silver Layer: 7 tables rebuilt (cleaned and enriched data)"
        echo "  • Gold Layer: 3 tables rebuilt (analytics-ready aggregations)"
    else
        error_exit "Silver/Gold refresh failed"
    fi
    echo ""
else
    echo "Step 4b: Skipped (--only-$ONLY_COMPONENT)"
    echo ""
fi

###############################################################################
# Step 5: Create Semantic Views
###############################################################################
if should_run_step "semantic_views"; then
    echo "Step 5: Creating semantic views..."
    echo "-------------------------------------------------------------------------"
    echo "Enabling natural language querying for business users"
    echo ""
    
    {
        echo "USE ROLE ${ROLE};"
        echo "USE DATABASE ${DATABASE};"
        echo "USE WAREHOUSE ${WAREHOUSE};"
        echo ""
        echo "SET FULL_PREFIX = '${FULL_PREFIX}';"
        echo "SET PROJECT_ROLE = '${ROLE}';"
        echo ""
        cat sql/04_semantic_views.sql
    } | snow sql $SNOW_CONN -i
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓${NC} Semantic views created"
        echo "  • GUEST_ANALYTICS_VIEW: Guest behavior and amenity usage"
        echo "  • PERSONALIZATION_INSIGHTS_VIEW: AI scoring and upsell propensity"
        echo "  • AMENITY_ANALYTICS_VIEW: Unified amenity performance metrics"
    else
        error_exit "Semantic views creation failed"
    fi
    echo ""
else
    echo "Step 5: Skipped (--only-$ONLY_COMPONENT)"
    echo ""
fi

###############################################################################
# Step 6: Create Intelligence Agents (Optional)
###############################################################################
if should_run_step "agents" && [ "$SKIP_AGENTS" = false ]; then
    echo "Step 6: Creating Snowflake Intelligence Agents..."
    echo "-------------------------------------------------------------------------"
    echo "Deploying AI agents for natural language querying"
    echo ""
    
    {
        echo "SET FULL_PREFIX = '${FULL_PREFIX}';"
        echo "SET PROJECT_ROLE = '${ROLE}';"
        echo ""
        cat sql/05_intelligence_agents.sql
    } | snow sql $SNOW_CONN -i
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓${NC} Intelligence Agents created"
        echo "  • Hotel Guest Analytics Agent"
        echo "  • Hotel Personalization Specialist"
        echo "  • Hotel Amenities Intelligence Agent"
        echo "  • Guest Experience Optimizer"
        echo "  • Hotel Intelligence Master Agent"
    else
        echo -e "${YELLOW}[WARNING]${NC} Intelligence Agents creation failed"
        echo "This is optional - core platform is still functional"
    fi
    echo ""
else
    if [ "$SKIP_AGENTS" = true ]; then
        echo "Step 6: Skipped (--skip-agents)"
    else
        echo "Step 6: Skipped (--only-$ONLY_COMPONENT)"
    fi
    echo ""
fi

###############################################################################
# Deployment Complete
###############################################################################
echo "========================================================================="
echo -e "${GREEN}Deployment Complete!${NC}"
echo "========================================================================="
echo ""
echo "Platform Details:"
echo "  Database: $DATABASE"
echo "  Role: $ROLE"
echo "  Warehouse: $WAREHOUSE"
echo ""
echo "Next Steps:"
echo "  1. Explore data: ./run.sh query 'SELECT * FROM GOLD.GUEST_360_VIEW_ENHANCED LIMIT 10'"
echo "  2. Run validation: ./run.sh validate"
if [ "$SKIP_AGENTS" = false ]; then
    echo "  3. Test agents: ./run.sh test-agents"
fi
echo ""
echo "Query the platform:"
echo "  • Guest Analytics: SELECT * FROM SEMANTIC_VIEWS.GUEST_ANALYTICS_VIEW"
echo "  • Personalization Scores: SELECT * FROM SEMANTIC_VIEWS.PERSONALIZATION_INSIGHTS_VIEW"
echo "  • Amenity Analytics: SELECT * FROM SEMANTIC_VIEWS.AMENITY_ANALYTICS_VIEW"
echo ""
echo "Clean up:"
echo "  • Remove deployment: ./clean.sh"
echo ""

