#!/bin/bash
###############################################################################
# run.sh - Runtime Operations for Hotel Personalization Platform
#
# Commands:
#   status     - Check status of resources and data
#   validate   - Run validation queries on all layers
#   query      - Execute a custom SQL query
#   test-agents - Test Intelligence Agents with sample questions
#
# Usage:
#   ./run.sh status                        # Check resource status
#   ./run.sh validate                      # Run validation
#   ./run.sh query "SELECT..."             # Execute custom query
#   ./run.sh test-agents                   # Test AI agents
#   ./run.sh -c prod status                # Use 'prod' connection
###############################################################################

set -e
set -o pipefail

# Configuration
CONNECTION_NAME="demo"
ENV_PREFIX=""
COMMAND=""
QUERY_ARG=""

# Project settings
PROJECT_PREFIX="HOTEL_PERSONALIZATION"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
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
Usage: $0 [OPTIONS] COMMAND [ARGS]

Runtime operations for Hotel Personalization Platform.

Commands:
  status             Check status of Snowflake resources and data volumes
  validate           Run validation queries across Bronze, Silver, Gold layers
  query "SQL"        Execute a custom SQL query against the platform
  test-agents        Test Intelligence Agents with sample questions

Options:
  -c, --connection NAME    Snowflake CLI connection name (default: demo)
  -p, --prefix PREFIX      Environment prefix for resources (e.g., DEV, PROD)
  -h, --help               Show this help message

Examples:
  $0 status                                    # Check resource status
  $0 validate                                  # Run full validation
  $0 query "SELECT * FROM GOLD.GUEST_360_VIEW_ENHANCED LIMIT 5"
  $0 test-agents                               # Test all AI agents
  $0 -c prod status                            # Use 'prod' connection
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
        status|validate|test-agents)
            COMMAND="$1"
            shift
            ;;
        query)
            COMMAND="query"
            QUERY_ARG="$2"
            shift 2
            ;;
        *)
            error_exit "Unknown option: $1\nUse --help for usage information"
            ;;
    esac
done

# Require a command
if [ -z "$COMMAND" ]; then
    usage
fi

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

###############################################################################
# Command: status - Check resource status
###############################################################################
cmd_status() {
    echo "========================================================================="
    echo "Hotel Personalization Platform - Status Check"
    echo "========================================================================="
    echo ""
    echo "Configuration:"
    echo "  Connection: $CONNECTION_NAME"
    echo "  Database: $DATABASE"
    echo "  Role: $ROLE"
    echo "  Warehouse: $WAREHOUSE"
    echo ""
    
    # Check database
    echo "Checking database..."
    DB_EXISTS=$(snow sql $SNOW_CONN -q "SHOW DATABASES LIKE '${DATABASE}'" -o tsv 2>/dev/null | wc -l || echo "0")
    if [ "$DB_EXISTS" -gt 0 ]; then
        echo -e "  ${GREEN}✓${NC} Database exists"
    else
        echo -e "  ${RED}✗${NC} Database not found"
        return 1
    fi
    
    # Check schemas
    echo "Checking schemas..."
    for schema in BRONZE SILVER GOLD BUSINESS_VIEWS SEMANTIC_VIEWS; do
        SCHEMA_EXISTS=$(snow sql $SNOW_CONN -q "SHOW SCHEMAS LIKE '${schema}' IN DATABASE ${DATABASE}" -o tsv 2>/dev/null | wc -l || echo "0")
        if [ "$SCHEMA_EXISTS" -gt 0 ]; then
            echo -e "    ${GREEN}✓${NC} $schema"
        else
            echo -e "    ${RED}✗${NC} $schema"
        fi
    done
    
    # Check data volumes
    echo ""
    echo "Checking data volumes..."
    snow sql $SNOW_CONN -q "
        USE ROLE ${ROLE};
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 'BRONZE.GUEST_PROFILES' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM BRONZE.GUEST_PROFILES
        UNION ALL
        SELECT 'BRONZE.BOOKING_HISTORY', COUNT(*) FROM BRONZE.BOOKING_HISTORY
        UNION ALL
        SELECT 'BRONZE.STAY_HISTORY', COUNT(*) FROM BRONZE.STAY_HISTORY
        UNION ALL
        SELECT 'BRONZE.AMENITY_TRANSACTIONS', COUNT(*) FROM BRONZE.AMENITY_TRANSACTIONS
        UNION ALL
        SELECT 'BRONZE.AMENITY_USAGE', COUNT(*) FROM BRONZE.AMENITY_USAGE
        UNION ALL
        SELECT 'GOLD.GUEST_360_VIEW_ENHANCED', COUNT(*) FROM GOLD.GUEST_360_VIEW_ENHANCED
        UNION ALL
        SELECT 'GOLD.PERSONALIZATION_SCORES_ENHANCED', COUNT(*) FROM GOLD.PERSONALIZATION_SCORES_ENHANCED
        UNION ALL
        SELECT 'GOLD.AMENITY_ANALYTICS', COUNT(*) FROM GOLD.AMENITY_ANALYTICS
        ORDER BY TABLE_NAME;
    "
    
    # Check semantic views
    echo ""
    echo "Checking semantic views..."
    for view in GUEST_ANALYTICS_VIEW PERSONALIZATION_INSIGHTS_VIEW AMENITY_ANALYTICS_VIEW; do
        VIEW_EXISTS=$(snow sql $SNOW_CONN -q "SHOW VIEWS LIKE '${view}' IN SCHEMA ${DATABASE}.SEMANTIC_VIEWS" -o tsv 2>/dev/null | wc -l || echo "0")
        if [ "$VIEW_EXISTS" -gt 0 ]; then
            echo -e "  ${GREEN}✓${NC} $view"
        else
            echo -e "  ${RED}✗${NC} $view"
        fi
    done
    
    # Check agents
    echo ""
    echo "Checking Intelligence Agents..."
    for agent in "Hotel Guest Analytics Agent" "Hotel Personalization Specialist" "Hotel Amenities Intelligence Agent" "Guest Experience Optimizer" "Hotel Intelligence Master Agent"; do
        AGENT_EXISTS=$(snow sql $SNOW_CONN -q "SHOW AGENTS LIKE '${agent}' IN SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS" -o tsv 2>/dev/null | wc -l || echo "0")
        if [ "$AGENT_EXISTS" -gt 0 ]; then
            echo -e "  ${GREEN}✓${NC} $agent"
        else
            echo -e "  ${YELLOW}○${NC} $agent (not deployed)"
        fi
    done
    
    echo ""
    echo -e "${GREEN}Status check complete!${NC}"
    echo ""
}

###############################################################################
# Command: validate - Run validation queries
###############################################################################
cmd_validate() {
    echo "========================================================================="
    echo "Hotel Personalization Platform - Validation"
    echo "========================================================================="
    echo ""
    
    echo "Running validation queries..."
    echo "-------------------------------------------------------------------------"
    
    # Test Bronze layer
    echo ""
    echo "${CYAN}[1/5]${NC} Testing Bronze layer..."
    snow sql $SNOW_CONN -q "
        USE ROLE ${ROLE};
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 
            'Guest Profiles' AS metric,
            COUNT(*) AS count,
            COUNT(DISTINCT email) AS unique_emails
        FROM BRONZE.GUEST_PROFILES
        
        UNION ALL
        
        SELECT 
            'Bookings',
            COUNT(*),
            COUNT(DISTINCT guest_id)
        FROM BRONZE.BOOKING_HISTORY
        
        UNION ALL
        
        SELECT 
            'Amenity Transactions',
            COUNT(*),
            COUNT(DISTINCT guest_id)
        FROM BRONZE.AMENITY_TRANSACTIONS;
    "
    
    # Test Silver layer
    echo ""
    echo "${CYAN}[2/5]${NC} Testing Silver layer enrichment..."
    snow sql $SNOW_CONN -q "
        USE ROLE ${ROLE};
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 
            'Guests Standardized' AS table_name,
            COUNT(*) AS records,
            COUNT(DISTINCT generation) AS distinct_generations
        FROM SILVER.GUESTS_STANDARDIZED
        
        UNION ALL
        
        SELECT 
            'Amenity Spending Enriched',
            COUNT(*),
            COUNT(DISTINCT service_group)
        FROM SILVER.AMENITY_SPENDING_ENRICHED;
    "
    
    # Test Gold layer
    echo ""
    echo "${CYAN}[3/5]${NC} Testing Gold layer analytics..."
    snow sql $SNOW_CONN -q "
        USE ROLE ${ROLE};
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 
            customer_segment,
            COUNT(*) AS guest_count,
            ROUND(AVG(total_revenue), 2) AS avg_revenue,
            ROUND(AVG(total_amenity_spend), 2) AS avg_amenity_spend
        FROM GOLD.GUEST_360_VIEW_ENHANCED
        GROUP BY customer_segment
        ORDER BY avg_revenue DESC;
    "
    
    # Test ML Scores
    echo ""
    echo "${CYAN}[4/5]${NC} Testing ML scoring models..."
    snow sql $SNOW_CONN -q "
        USE ROLE ${ROLE};
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 
            customer_segment,
            ROUND(AVG(personalization_readiness_score), 1) AS avg_personalization_score,
            ROUND(AVG(upsell_propensity_score), 1) AS avg_upsell_score,
            ROUND(AVG(spa_upsell_propensity), 1) AS avg_spa_score,
            ROUND(AVG(tech_upsell_propensity), 1) AS avg_tech_score
        FROM GOLD.PERSONALIZATION_SCORES_ENHANCED
        GROUP BY customer_segment
        ORDER BY avg_upsell_score DESC;
    "
    
    # Test Amenity Analytics
    echo ""
    echo "${CYAN}[5/5]${NC} Testing Amenity Analytics..."
    snow sql $SNOW_CONN -q "
        USE ROLE ${ROLE};
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 
            service_group,
            amenity_category,
            COUNT(*) AS record_count,
            SUM(total_revenue) AS revenue,
            ROUND(AVG(avg_satisfaction), 2) AS satisfaction
        FROM GOLD.AMENITY_ANALYTICS
        GROUP BY service_group, amenity_category
        ORDER BY revenue DESC NULLS LAST
        LIMIT 10;
    "
    
    echo ""
    echo "-------------------------------------------------------------------------"
    echo -e "${GREEN}✓ Validation complete!${NC}"
    echo "All layers tested successfully"
    echo ""
}

###############################################################################
# Command: query - Execute custom SQL
###############################################################################
cmd_query() {
    if [ -z "$QUERY_ARG" ]; then
        error_exit "No query provided.\nUsage: ./run.sh query \"SELECT ...\""
    fi
    
    echo "========================================================================="
    echo "Executing custom query..."
    echo "========================================================================="
    echo ""
    echo "Query:"
    echo "$QUERY_ARG"
    echo ""
    echo "Results:"
    echo "-------------------------------------------------------------------------"
    
    snow sql $SNOW_CONN -q "
        USE ROLE ${ROLE};
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        ${QUERY_ARG}
    "
    
    echo ""
}

###############################################################################
# Command: test-agents - Test Intelligence Agents
###############################################################################
cmd_test_agents() {
    echo "========================================================================="
    echo "Hotel Personalization - Intelligence Agents Test"
    echo "========================================================================="
    echo ""
    
    # Check if AGENT_DETAILED_QUESTIONS.md exists
    if [ ! -f "docs/AGENT_DETAILED_QUESTIONS.md" ]; then
        echo -e "${YELLOW}[WARNING]${NC} AGENT_DETAILED_QUESTIONS.md not found"
        echo "Testing with basic queries..."
        echo ""
    fi
    
    echo "Testing sample questions with Intelligence Agents..."
    echo "-------------------------------------------------------------------------"
    echo ""
    
    # Test Guest Analytics Agent
    echo "${CYAN}[1/5]${NC} Testing Hotel Guest Analytics Agent..."
    echo "Question: Show me our top 5 guests by total revenue"
    echo ""
    snow sql $SNOW_CONN -q "
        SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
            'SNOWFLAKE_INTELLIGENCE.AGENTS.\"Hotel Guest Analytics Agent\"',
            'Show me our top 5 guests by total revenue'
        ) AS response;
    " -o plain 2>&1 || echo -e "${YELLOW}Agent query failed - agent may not be deployed${NC}"
    echo ""
    
    # Test Personalization Specialist
    echo "${CYAN}[2/5]${NC} Testing Hotel Personalization Specialist..."
    echo "Question: Which guests have the highest spa upsell propensity?"
    echo ""
    snow sql $SNOW_CONN -q "
        SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
            'SNOWFLAKE_INTELLIGENCE.AGENTS.\"Hotel Personalization Specialist\"',
            'Which guests have the highest spa upsell propensity?'
        ) AS response;
    " -o plain 2>&1 || echo -e "${YELLOW}Agent query failed - agent may not be deployed${NC}"
    echo ""
    
    # Test Amenities Intelligence Agent
    echo "${CYAN}[3/5]${NC} Testing Hotel Amenities Intelligence Agent..."
    echo "Question: What is our amenity revenue breakdown by service category?"
    echo ""
    snow sql $SNOW_CONN -q "
        SELECT SNOWFLAKE.CORTEX.COMPLETE_AGENT(
            'SNOWFLAKE_INTELLIGENCE.AGENTS.\"Hotel Amenities Intelligence Agent\"',
            'What is our amenity revenue breakdown by service category?'
        ) AS response;
    " -o plain 2>&1 || echo -e "${YELLOW}Agent query failed - agent may not be deployed${NC}"
    echo ""
    
    echo "-------------------------------------------------------------------------"
    echo -e "${GREEN}Agent testing complete!${NC}"
    echo ""
    echo "Note: Full agent testing requires agents to be deployed."
    echo "See docs/AGENT_DETAILED_QUESTIONS.md for comprehensive test questions."
    echo ""
}

###############################################################################
# Execute command
###############################################################################
case "$COMMAND" in
    status)
        cmd_status
        ;;
    validate)
        cmd_validate
        ;;
    query)
        cmd_query
        ;;
    test-agents)
        cmd_test_agents
        ;;
    *)
        error_exit "Unknown command: $COMMAND"
        ;;
esac

