#!/bin/bash
###############################################################################
# clean.sh - Remove All Hotel Personalization Platform Resources
#
# Deletes all project resources in the correct dependency order:
#   1. Intelligence Agents (optional)
#   2. Semantic Views
#   3. Warehouse
#   4. Database (cascades to all schemas, tables, views)
#   5. Role
#
# Usage:
#   ./clean.sh                 # Interactive (prompts for confirmation)
#   ./clean.sh --force         # Non-interactive
#   ./clean.sh -c prod --yes   # Use 'prod' connection, skip confirmation
###############################################################################

set -e
set -o pipefail

# Configuration
CONNECTION_NAME="demo"
ENV_PREFIX=""
FORCE=false
KEEP_AGENTS=false

# Project settings
PROJECT_PREFIX="HOTEL_PERSONALIZATION"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

Remove all Hotel Personalization Platform resources from Snowflake.

Options:
  -c, --connection NAME    Snowflake CLI connection name (default: demo)
  -p, --prefix PREFIX      Environment prefix for resources (e.g., DEV, PROD)
  --keep-agents            Keep Intelligence Agents (useful for redeployment)
  --force, --yes, -y       Skip confirmation prompt
  -h, --help               Show this help message

Examples:
  $0                       # Interactive cleanup
  $0 --force               # Non-interactive cleanup
  $0 -c prod --yes         # Use 'prod' connection, skip confirmation
  $0 --prefix DEV --force  # Clean DEV environment
  $0 --keep-agents         # Keep agents for reuse
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
        --keep-agents)
            KEEP_AGENTS=true
            shift
            ;;
        --force|--yes|-y)
            FORCE=true
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

# Derive resource names
DATABASE="${FULL_PREFIX}"
ROLE="${FULL_PREFIX}_ROLE"
WAREHOUSE="${FULL_PREFIX}_WH"

# Display warning
echo "========================================================================="
echo "Hotel Personalization Platform - Cleanup"
echo "========================================================================="
echo ""
echo -e "${YELLOW}WARNING: This will permanently delete all project resources!${NC}"
echo ""
echo "Resources to be deleted:"
echo "  - Database: $DATABASE"
echo "    • All schemas: BRONZE, SILVER, GOLD, BUSINESS_VIEWS, SEMANTIC_VIEWS"
echo "    • All tables: ~23 Bronze tables (15 core + 4 Intelligence Hub + 4 other)"
echo "    • All views: 9 semantic views (3 core + 3 Intelligence Hub + 3 guest intelligence)"
echo "  - Warehouse: $WAREHOUSE"
echo "  - Role: $ROLE"
if [ "$KEEP_AGENTS" = false ]; then
    echo "  - Intelligence Agents: All 5 agents"
else
    echo "  - Intelligence Agents: Preserved (--keep-agents)"
fi
echo ""
echo "Data volumes to be deleted:"
echo "  Core Data:"
echo "    • ~20,000 guest profiles (scaled 2x for 100 properties)"
echo "    • ~60,000 bookings (includes ~3,000 future bookings)"
echo "    • ~50,000 stays"
echo "    • ~60,000+ amenity transactions"
echo "    • ~30,000+ amenity usage records"
echo "  Intelligence Hub Data:"
echo "    • ~15,000 service cases (last 18 months)"
echo "    • ~22,000 issue tracking records"
echo "    • ~8,000 sentiment data points"
echo "    • ~2,000 service recovery actions"
echo ""

# Confirmation
if [ "$FORCE" = false ]; then
    read -p "Are you sure you want to delete all resources? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "Cleanup cancelled."
        exit 0
    fi
fi

echo ""
echo "Starting cleanup..."
echo ""

###############################################################################
# Step 0: De-register Agents from Snowflake Intelligence
###############################################################################
if [ "$KEEP_AGENTS" = false ]; then
    echo "Step 0: De-registering agents from Snowflake Intelligence..."
    echo "-------------------------------------------------------------------------"
    
    for agent in "Hotel Guest Analytics Agent" "Hotel Personalization Specialist" "Hotel Amenities Intelligence Agent" "Guest Experience Optimizer" "Hotel Intelligence Master Agent"; do
        echo "  De-registering: $agent"
        snow sql $SNOW_CONN -q "
            USE ROLE ACCOUNTADMIN;
            ALTER SNOWFLAKE INTELLIGENCE IF EXISTS SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT 
              DROP AGENT IF EXISTS IDENTIFIER('${DATABASE}.GOLD.\"${agent}\"');
        " 2>/dev/null || echo "    (Not registered or already removed)"
    done
    
    echo -e "${GREEN}✓${NC} Agents de-registered from Snowflake Intelligence"
    echo ""
else
    echo "Step 0: Skipping agent de-registration (--keep-agents)"
    echo ""
fi

###############################################################################
# Step 1: Drop Intelligence Agents (if not keeping)
###############################################################################
if [ "$KEEP_AGENTS" = false ]; then
    echo "Step 1: Dropping Intelligence Agents..."
    echo "-------------------------------------------------------------------------"
    
    for agent in "Hotel Guest Analytics Agent" "Hotel Personalization Specialist" "Hotel Amenities Intelligence Agent" "Guest Experience Optimizer" "Hotel Intelligence Master Agent"; do
        echo "  Dropping: $agent"
        snow sql $SNOW_CONN -q "
            USE ROLE ACCOUNTADMIN;
            DROP AGENT IF EXISTS ${DATABASE}.GOLD.\"${agent}\";
        " 2>/dev/null || echo "    (Not found or already dropped)"
    done
    
    echo -e "${GREEN}✓${NC} Intelligence Agents dropped"
    echo ""
else
    echo "Step 1: Skipping Intelligence Agents (--keep-agents)"
    echo ""
fi

###############################################################################
# Step 2: Drop Streamlit Dashboards
###############################################################################
echo "Step 2: Dropping Streamlit Dashboards..."
echo "-------------------------------------------------------------------------"

snow sql $SNOW_CONN -q "
    USE ROLE ACCOUNTADMIN;
    
    -- Drop the consolidated Streamlit app (current location)
    DROP STREAMLIT IF EXISTS ${DATABASE}.GOLD.HOTEL_PERSONALIZATION_APP;
    
    -- Drop any legacy individual dashboards (old locations - cleanup)
    DROP STREAMLIT IF EXISTS ${DATABASE}.STREAMLIT.HOTEL_PERSONALIZATION_APP;
    DROP STREAMLIT IF EXISTS ${DATABASE}.STREAMLIT.GUEST_360_DASHBOARD;
    DROP STREAMLIT IF EXISTS ${DATABASE}.STREAMLIT.PERSONALIZATION_HUB;
    DROP STREAMLIT IF EXISTS ${DATABASE}.STREAMLIT.AMENITY_PERFORMANCE;
    DROP STREAMLIT IF EXISTS ${DATABASE}.STREAMLIT.\"Revenue Analytics Dashboard\";
    DROP STREAMLIT IF EXISTS ${DATABASE}.STREAMLIT.EXECUTIVE_OVERVIEW;
    DROP STREAMLIT IF EXISTS ${DATABASE}.GOLD.\"Revenue Analytics Dashboard\";
    
    DROP STAGE IF EXISTS ${DATABASE}.STREAMLIT.STAGE;
" 2>/dev/null || true

echo -e "${GREEN}✓${NC} Streamlit Dashboards dropped"
echo ""

###############################################################################
# Step 3: Drop Semantic Views
###############################################################################
echo "Step 2: Dropping Semantic Views..."
echo "-------------------------------------------------------------------------"

snow sql $SNOW_CONN -q "
    USE ROLE ACCOUNTADMIN;
    
    -- Original semantic views (Core guest & personalization)
    DROP VIEW IF EXISTS ${DATABASE}.SEMANTIC_VIEWS.GUEST_ANALYTICS_VIEW;
    DROP VIEW IF EXISTS ${DATABASE}.SEMANTIC_VIEWS.PERSONALIZATION_INSIGHTS_VIEW;
    DROP VIEW IF EXISTS ${DATABASE}.SEMANTIC_VIEWS.AMENITY_ANALYTICS_VIEW;
    
    -- Intelligence Hub semantic views
    DROP VIEW IF EXISTS ${DATABASE}.SEMANTIC_VIEWS.PORTFOLIO_INTELLIGENCE_VIEW;
    DROP VIEW IF EXISTS ${DATABASE}.SEMANTIC_VIEWS.LOYALTY_INTELLIGENCE_VIEW;
    DROP VIEW IF EXISTS ${DATABASE}.SEMANTIC_VIEWS.CX_SERVICE_INTELLIGENCE_VIEW;
    
    -- Guest-level intelligence semantic views
    DROP VIEW IF EXISTS ${DATABASE}.SEMANTIC_VIEWS.GUEST_SENTIMENT_INTELLIGENCE_VIEW;
    DROP VIEW IF EXISTS ${DATABASE}.SEMANTIC_VIEWS.GUEST_ARRIVALS_VIEW;
    DROP VIEW IF EXISTS ${DATABASE}.SEMANTIC_VIEWS.GUEST_PREFERENCES_VIEW;
" 2>/dev/null || true

echo -e "${GREEN}✓${NC} Semantic Views dropped (9 views)"
echo ""

###############################################################################
# Step 4: Drop Warehouse
###############################################################################
echo "Step 3: Dropping Warehouse..."
echo "-------------------------------------------------------------------------"

snow sql $SNOW_CONN -q "
    USE ROLE ACCOUNTADMIN;
    DROP WAREHOUSE IF EXISTS ${WAREHOUSE};
" 2>/dev/null || true

echo -e "${GREEN}✓${NC} Warehouse dropped"
echo ""

###############################################################################
# Step 4: Drop Database (cascades to all schemas and tables)
###############################################################################
echo "Step 5: Dropping Database (includes all schemas, tables, views)..."
echo "-------------------------------------------------------------------------"

snow sql $SNOW_CONN -q "
    USE ROLE ACCOUNTADMIN;
    DROP DATABASE IF EXISTS ${DATABASE} CASCADE;
" 2>/dev/null || true

echo -e "${GREEN}✓${NC} Database dropped"
echo ""

###############################################################################
# Step 6: Drop Role
###############################################################################
echo "Step 5: Dropping Role..."
echo "-------------------------------------------------------------------------"

snow sql $SNOW_CONN -q "
    USE ROLE ACCOUNTADMIN;
    DROP ROLE IF EXISTS ${ROLE};
" 2>/dev/null || true

# Drop additional analyst roles
snow sql $SNOW_CONN -q "
    USE ROLE ACCOUNTADMIN;
    DROP ROLE IF EXISTS ${ROLE}_ADMIN;
    DROP ROLE IF EXISTS ${ROLE}_GUEST_ANALYST;
    DROP ROLE IF EXISTS ${ROLE}_REVENUE_ANALYST;
    DROP ROLE IF EXISTS ${ROLE}_EXPERIENCE_ANALYST;
    DROP ROLE IF EXISTS ${ROLE}_DATA_ENGINEER;
" 2>/dev/null || true

echo -e "${GREEN}✓${NC} Roles dropped"
echo ""

###############################################################################
# Cleanup Complete
###############################################################################
echo "========================================================================="
echo -e "${GREEN}Cleanup Complete!${NC}"
echo "========================================================================="
echo ""
echo "All resources have been removed:"
echo "  ✓ Database and all data"
echo "  ✓ Warehouse"
echo "  ✓ Roles"
if [ "$KEEP_AGENTS" = false ]; then
    echo "  ✓ Intelligence Agents"
fi
echo ""
echo "To redeploy the platform:"
echo "  ./deploy.sh"
echo ""

