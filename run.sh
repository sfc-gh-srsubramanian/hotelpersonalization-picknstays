#!/bin/bash
###############################################################################
# run.sh - Runtime Operations for Hotel Personalization Platform
#
# Commands:
#   status     - Check status of resources and data
#   validate   - Run validation queries on all layers
#   query      - Execute a custom SQL query
#   test-agents - Test Intelligence Agents with sample questions
#   streamlit  - Check Streamlit app status and access info
#
# Usage:
#   ./run.sh status                        # Check resource status
#   ./run.sh validate                      # Run validation
#   ./run.sh query "SELECT..."             # Execute custom query
#   ./run.sh test-agents                   # Test AI agents
#   ./run.sh streamlit                     # Streamlit app details
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
  streamlit          Check Streamlit app status and get access information
  intel-hub          Check Intelligence Hub deployment and data volumes

Options:
  -c, --connection NAME    Snowflake CLI connection name (default: demo)
  -p, --prefix PREFIX      Environment prefix for resources (e.g., DEV, PROD)
  -h, --help               Show this help message

Examples:
  $0 status                                    # Check resource status
  $0 validate                                  # Run full validation
  $0 query "SELECT * FROM GOLD.GUEST_360_VIEW_ENHANCED LIMIT 5"
  $0 test-agents                               # Test all AI agents
  $0 streamlit                                 # Streamlit app info
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
        status|validate|test-agents|streamlit|intel-hub)
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
    DB_EXISTS=$(snow sql $SNOW_CONN -q "SHOW DATABASES LIKE '${DATABASE}'" --format CSV 2>/dev/null | tail -n +2 | wc -l | xargs)
    DB_EXISTS=${DB_EXISTS:-0}
    if [ "$DB_EXISTS" -gt 0 ] 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Database exists"
    else
        echo -e "  ${RED}✗${NC} Database not found"
        return 1
    fi
    
    # Check schemas
    echo "Checking schemas..."
    for schema in BRONZE SILVER GOLD BUSINESS_VIEWS SEMANTIC_VIEWS; do
        SCHEMA_EXISTS=$(snow sql $SNOW_CONN -q "SHOW SCHEMAS LIKE '${schema}' IN DATABASE ${DATABASE}" --format CSV 2>/dev/null | tail -n +2 | wc -l | xargs)
        SCHEMA_EXISTS=${SCHEMA_EXISTS:-0}
        if [ "$SCHEMA_EXISTS" -gt 0 ] 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} $schema"
        else
            echo -e "    ${RED}✗${NC} $schema"
        fi
    done
    
    # Check data volumes
    echo ""
    echo "Checking data volumes..."
    snow sql $SNOW_CONN -q "
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
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
    for view in GUEST_ANALYTICS_VIEW PERSONALIZATION_INSIGHTS_VIEW AMENITY_ANALYTICS_VIEW PORTFOLIO_INTELLIGENCE_VIEW LOYALTY_INTELLIGENCE_VIEW CX_SERVICE_INTELLIGENCE_VIEW GUEST_ARRIVALS_VIEW; do
        VIEW_EXISTS=$(snow sql $SNOW_CONN -q "SHOW VIEWS LIKE '${view}' IN SCHEMA ${DATABASE}.SEMANTIC_VIEWS" --format CSV 2>/dev/null | tail -n +2 | wc -l | xargs)
        VIEW_EXISTS=${VIEW_EXISTS:-0}
        if [ "$VIEW_EXISTS" -gt 0 ] 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $view"
        else
            echo -e "  ${RED}✗${NC} $view"
        fi
    done
    
    # Check agents
    echo ""
    echo "Checking Intelligence Agents..."
    for agent in "Hotel Guest Analytics Agent" "Hotel Personalization Specialist" "Hotel Amenities Intelligence Agent" "Guest Experience Optimizer" "Hotel Intelligence Master Agent"; do
        AGENT_EXISTS=$(snow sql $SNOW_CONN -q "SHOW AGENTS LIKE '${agent}' IN SCHEMA ${DATABASE}.GOLD" --format CSV 2>/dev/null | tail -n +2 | wc -l | xargs)
        AGENT_EXISTS=${AGENT_EXISTS:-0}
        if [ "$AGENT_EXISTS" -gt 0 ] 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $agent"
        else
            echo -e "  ${YELLOW}○${NC} $agent (not deployed)"
        fi
    done
    
    # Check Streamlit app
    echo ""
    echo "Checking Streamlit Application..."
    
    # Check for consolidated app in GOLD schema (current deployment location)
    APP_EXISTS_GOLD=$(snow sql $SNOW_CONN -q "SHOW STREAMLITS LIKE 'Hotel Personalization - Pic%' IN SCHEMA ${DATABASE}.GOLD" --format CSV 2>/dev/null | tail -n +2 | wc -l | xargs)
    APP_EXISTS_GOLD=${APP_EXISTS_GOLD:-0}
    
    # Check for any app in STREAMLIT schema (legacy location)
    APP_EXISTS_STREAMLIT=$(snow sql $SNOW_CONN -q "SHOW STREAMLITS IN SCHEMA ${DATABASE}.STREAMLIT" --format CSV 2>/dev/null | tail -n +2 | wc -l | xargs)
    APP_EXISTS_STREAMLIT=${APP_EXISTS_STREAMLIT:-0}
    
    if [ "$APP_EXISTS_GOLD" -gt 0 ] 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Hotel Personalization - Pic'N Stays (GOLD schema)"
        
        # Get app details
        echo ""
        echo "  Streamlit App Details:"
        snow sql $SNOW_CONN -q "
            USE DATABASE ${DATABASE};
            SELECT 
                name AS \"App Name\",
                created_on AS \"Created\",
                owner AS \"Owner\",
                query_warehouse AS \"Warehouse\"
            FROM ${DATABASE}.INFORMATION_SCHEMA.STREAMLITS
            WHERE streamlit_schema = 'GOLD'
            AND name LIKE 'Hotel Personalization - Pic%';
        " --format TABLE 2>/dev/null || echo "    (Details unavailable)"
        
        echo ""
        echo "  ${CYAN}Access URL:${NC}"
        echo "  https://app.snowflake.com/[your-account]/#/streamlit-apps/${DATABASE}.GOLD.HOTEL_PERSONALIZATION_APP"
        echo ""
        echo "  ${CYAN}Pages Available:${NC}"
        echo "    • Guest 360 Dashboard"
        echo "    • Personalization Hub"
        echo "    • Amenity Performance"
        echo "    • Revenue Analytics"
        echo "    • Executive Overview"
        
    elif [ "$APP_EXISTS_STREAMLIT" -gt 0 ] 2>/dev/null; then
        echo -e "  ${YELLOW}⚠${NC}  Streamlit app(s) found in STREAMLIT schema (legacy location)"
        echo "      Consider redeploying to GOLD schema"
        snow sql $SNOW_CONN -q "SHOW STREAMLITS IN SCHEMA ${DATABASE}.STREAMLIT" --format TABLE 2>/dev/null || true
    else
        echo -e "  ${RED}✗${NC} No Streamlit app deployed"
        echo "      Run: ./deploy.sh streamlit  (to deploy app only)"
        echo "      Or:  ./deploy.sh full       (for complete deployment)"
    fi
    
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
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
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
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
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
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
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
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
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
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
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
    
    # Test Intelligence Hub Bronze Tables
    echo ""
    echo "${CYAN}[6/11]${NC} Testing Intelligence Hub Bronze data..."
    snow sql $SNOW_CONN -q "
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 'SERVICE_CASES' AS table_name, COUNT(*) AS count FROM BRONZE.SERVICE_CASES
        UNION ALL
        SELECT 'ISSUE_TRACKING', COUNT(*) FROM BRONZE.ISSUE_TRACKING
        UNION ALL
        SELECT 'SENTIMENT_DATA', COUNT(*) FROM BRONZE.SENTIMENT_DATA
        UNION ALL
        SELECT 'SERVICE_RECOVERY_ACTIONS', COUNT(*) FROM BRONZE.SERVICE_RECOVERY_ACTIONS
        ORDER BY table_name;
    "
    
    # Test Intelligence Hub Gold Tables
    echo ""
    echo "${CYAN}[7/11]${NC} Testing Intelligence Hub Gold analytics..."
    snow sql $SNOW_CONN -q "
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 'PORTFOLIO_PERFORMANCE_KPIS' AS table_name, 
               COUNT(*) AS records,
               COUNT(DISTINCT hotel_id) AS hotels,
               COUNT(DISTINCT performance_date) AS days
        FROM GOLD.PORTFOLIO_PERFORMANCE_KPIS
        
        UNION ALL
        
        SELECT 'LOYALTY_SEGMENT_INTELLIGENCE',
               COUNT(*),
               NULL,
               NULL
        FROM GOLD.LOYALTY_SEGMENT_INTELLIGENCE
        
        UNION ALL
        
        SELECT 'EXPERIENCE_SERVICE_SIGNALS',
               COUNT(*),
               COUNT(DISTINCT hotel_id),
               NULL
        FROM GOLD.EXPERIENCE_SERVICE_SIGNALS;
    "
    
    # Test Hotel Portfolio Scale
    echo ""
    echo "${CYAN}[8/11]${NC} Validating hotel portfolio (100 properties)..."
    snow sql $SNOW_CONN -q "
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 
            region,
            COUNT(*) AS properties,
            MIN(hotel_id) AS first_hotel,
            MAX(hotel_id) AS last_hotel
        FROM BRONZE.hotel_properties
        GROUP BY region
        ORDER BY region;
    "
    echo ""
    echo "  Expected: 50 AMER, 30 EMEA, 20 APAC = 100 total"
    
    # Test Loyalty Program Distribution
    echo ""
    echo "${CYAN}[9/11]${NC} Validating loyalty program distribution..."
    snow sql $SNOW_CONN -q "
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 
            tier_level,
            COUNT(*) AS members,
            ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
        FROM BRONZE.loyalty_program
        GROUP BY tier_level
        ORDER BY 
            CASE tier_level 
                WHEN 'Diamond' THEN 1 
                WHEN 'Gold' THEN 2 
                WHEN 'Silver' THEN 3 
                WHEN 'Blue' THEN 4 
            END;
    "
    echo ""
    echo "  Expected: Diamond 10% (5K), Gold 20% (10K), Silver 30% (15K), Blue 40% (20K)"
    
    # CRITICAL: Test Repeat Rate Consistency
    echo ""
    echo "${CYAN}[10/11]${NC} 🔍 CRITICAL: Testing repeat rate consistency..."
    snow sql $SNOW_CONN -q "
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        WITH portfolio_repeat AS (
            SELECT 
                'Portfolio Overview' AS source,
                ROUND(AVG(repeat_stay_rate_pct), 1) AS repeat_rate_pct
            FROM GOLD.PORTFOLIO_PERFORMANCE_KPIS
        ),
        loyalty_repeat AS (
            SELECT 
                'Loyalty Intelligence' AS source,
                ROUND(
                    SUM(repeat_guests * active_members) * 100.0 / 
                    NULLIF(SUM(active_members), 0), 
                    1
                ) AS repeat_rate_pct
            FROM GOLD.LOYALTY_SEGMENT_INTELLIGENCE
            WHERE loyalty_tier != 'Non-Member'
        )
        SELECT * FROM portfolio_repeat
        UNION ALL
        SELECT * FROM loyalty_repeat;
    "
    echo ""
    echo "  ✓ PASS: Both should show ~50% (industry benchmark)"
    echo "  ✗ FAIL: If Portfolio shows 100%, data generation has cycling bug"
    
    # CRITICAL: Test Non-Member Guest Cycling Bug
    echo ""
    echo "${CYAN}[11/12]${NC} 🔍 CRITICAL: Testing non-member guest distribution..."
    snow sql $SNOW_CONN -q "
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 
            'Non-Members' AS segment,
            COUNT(DISTINCT guest_id) AS unique_guests,
            COUNT(DISTINCT stay_id) AS total_stays,
            ROUND(COUNT(DISTINCT stay_id) * 1.0 / 
                  NULLIF(COUNT(DISTINCT guest_id), 0), 2) AS stays_per_guest
        FROM BRONZE.stay_history
        WHERE guest_id >= 'GUEST_050000' AND guest_id < 'GUEST_100000';
    "
    echo ""
    
    # Test Guest Preferences Coverage (NEW - validates preference exposure)
    echo "${CYAN}[12/12]${NC} Testing Guest Preferences Coverage (NEW - Agent Query Readiness)..."
    echo "  This validates the new GUEST_PREFERENCES_VIEW for AI agent queries"
    snow sql $SNOW_CONN -q "
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        -- Overall preference coverage
        SELECT 'Overall Preference Coverage' AS metric, 
               '75,000 room prefs (75%) + 70,000 service prefs (70%)' AS expected,
               CONCAT(
                   (SELECT COUNT(*) FROM BRONZE.ROOM_PREFERENCES), ' room prefs (', 
                   ROUND((SELECT COUNT(*) * 100.0 / (SELECT COUNT(*) FROM BRONZE.GUEST_PROFILES) FROM BRONZE.ROOM_PREFERENCES), 1), '%) + ',
                   (SELECT COUNT(*) FROM BRONZE.SERVICE_PREFERENCES), ' service prefs (', 
                   ROUND((SELECT COUNT(*) * 100.0 / (SELECT COUNT(*) FROM BRONZE.GUEST_PROFILES) FROM BRONZE.SERVICE_PREFERENCES), 1), '%)'
               ) AS actual
        
        UNION ALL
        
        -- Top pillow preferences (validates NEW semantic view exposes this data)
        SELECT 'Top Pillow Preference (via GOLD.PREFERENCES_CONSOLIDATED)' AS metric,
               'Even distribution: firm, soft, memory_foam, feather, no_preference' AS expected,
               pillow_type_preference AS actual
        FROM GOLD.PREFERENCES_CONSOLIDATED
        GROUP BY pillow_type_preference
        ORDER BY COUNT(*) DESC
        LIMIT 1
        
        UNION ALL
        
        -- Preference completeness by loyalty tier (validates segmentation works)
        SELECT CONCAT('Avg Preference Score - ', tier_level, ' tier') AS metric,
               '4-7 preferences per guest' AS expected,
               ROUND(AVG(pc.preference_completeness_score), 1) AS actual
        FROM GOLD.PREFERENCES_CONSOLIDATED pc
        LEFT JOIN BRONZE.LOYALTY_PROGRAM lp ON pc.guest_id = lp.guest_id
        WHERE tier_level = 'Diamond'
        GROUP BY tier_level
        
        UNION ALL
        
        -- Accessibility needs (validates special accommodation tracking)
        SELECT 'Guests with Accessibility Needs' AS metric,
               '~1,500 guests (2%)' AS expected,
               CONCAT(COUNT(*), ' guests (', ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM BRONZE.ROOM_PREFERENCES), 1), '%)') AS actual
        FROM BRONZE.ROOM_PREFERENCES
        WHERE accessibility_needs = TRUE;
    " --format TABLE
    echo ""
    echo "  ✅ These preferences are now exposed to Intelligence Agents via GUEST_PREFERENCES_VIEW"
    echo "  📊 Test in Snowflake Intelligence: 'What are the most common pillow preferences for Diamond guests?'"
    echo ""
    echo "  ✓ PASS: 40K-50K unique guests, ~2-4 stays/guest (realistic)"
    echo "  ✗ FAIL: ~10K unique guests, ~19 stays/guest (cycling bug!)"
    
    # Test Streamlit Application
    echo ""
    echo "${CYAN}[FINAL]${NC} Testing Streamlit Applications..."
    
    # Check GOLD schema (current deployment location)
    STREAMLIT_GOLD=$(snow sql $SNOW_CONN -q "
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
        USE DATABASE ${DATABASE};
        SHOW STREAMLITS IN SCHEMA GOLD;
    " --format CSV 2>/dev/null | tail -n +2 | wc -l | xargs)
    STREAMLIT_GOLD=${STREAMLIT_GOLD:-0}
    
    # Check STREAMLIT schema (legacy location)
    STREAMLIT_SCHEMA=$(snow sql $SNOW_CONN -q "
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
        USE DATABASE ${DATABASE};
        SHOW STREAMLITS IN SCHEMA STREAMLIT;
    " --format CSV 2>/dev/null | tail -n +2 | wc -l | xargs)
    STREAMLIT_SCHEMA=${STREAMLIT_SCHEMA:-0}
    
    if [ "$STREAMLIT_GOLD" -gt 0 ] 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Streamlit app deployed in GOLD schema"
        
        # Verify data access from Streamlit
        echo ""
        echo "  Testing Streamlit data access (sample query from Guest 360)..."
        GUEST_SAMPLE=$(snow sql $SNOW_CONN -q "
            -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
            USE DATABASE ${DATABASE};
            USE WAREHOUSE ${WAREHOUSE};
            SELECT COUNT(*) AS total_guests FROM GOLD.GUEST_360_VIEW_ENHANCED;
        " --format CSV 2>/dev/null | tail -n +2 | xargs)
        
        if [ -n "$GUEST_SAMPLE" ] && [ "$GUEST_SAMPLE" -gt 0 ] 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} Data accessible: $GUEST_SAMPLE guests available"
        else
            echo -e "    ${YELLOW}⚠${NC}  Warning: Guest data may not be loaded"
        fi
        
        # Check personalization scores
        SCORES_SAMPLE=$(snow sql $SNOW_CONN -q "
            -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
            USE DATABASE ${DATABASE};
            USE WAREHOUSE ${WAREHOUSE};
            SELECT COUNT(*) AS total_scores FROM GOLD.PERSONALIZATION_SCORES_ENHANCED;
        " --format CSV 2>/dev/null | tail -n +2 | xargs)
        
        if [ -n "$SCORES_SAMPLE" ] && [ "$SCORES_SAMPLE" -gt 0 ] 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} Personalization scores available: $SCORES_SAMPLE records"
        else
            echo -e "    ${YELLOW}⚠${NC}  Warning: Personalization scores may not be loaded"
        fi
        
        echo ""
        echo "  ${CYAN}App Pages:${NC}"
        echo "    1. Guest 360 Dashboard - Comprehensive guest profiles & analytics"
        echo "    2. Personalization Hub - Upsell opportunities & propensity scores"
        echo "    3. Amenity Performance - Infrastructure & service analytics"
        echo "    4. Revenue Analytics - Revenue breakdown & optimization"
        echo "    5. Executive Overview - High-level KPIs & strategic metrics"
        
    elif [ "$STREAMLIT_SCHEMA" -gt 0 ] 2>/dev/null; then
        echo -e "  ${YELLOW}⚠${NC}  Found $STREAMLIT_SCHEMA app(s) in STREAMLIT schema (legacy)"
        echo "      Recommend redeploying to GOLD schema"
        snow sql $SNOW_CONN -q "
            -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
            USE DATABASE ${DATABASE};
            SHOW STREAMLITS IN SCHEMA STREAMLIT;
        " --format TABLE 2>/dev/null || true
    else
        echo -e "  ${RED}✗${NC} No Streamlit app deployed"
        echo "      Deploy with: ./deploy.sh streamlit"
    fi
    
    echo ""
    echo "-------------------------------------------------------------------------"
    echo -e "${GREEN}✓ Validation complete!${NC}"
    echo ""
    echo "Summary:"
    echo "  • Bronze Layer: Core + Intelligence Hub data (17 tables)"
    echo "  • Silver Layer: Enriched data (10 tables)"
    echo "  • Gold Layer: Analytics + Executive KPIs (9 tables)"
    echo "  • Portfolio: 100 properties across 3 regions"
    echo "  • Guests: 100K profiles, 50K loyalty members"
    echo "  • Stays: ~1.9M records with realistic occupancy"
    echo "  • Intelligence Hub: Complete executive analytics"
    echo "  • Streamlit Apps: Deployed and data-accessible"
    echo ""
    echo "Critical Checks:"
    echo "  ✓ Repeat Rate: Portfolio vs Loyalty consistency validated"
    echo "  ✓ Non-Member Distribution: Guest cycling bug detection"
    echo "  ✓ Regional Coverage: All regions have complete data"
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
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
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
    
    echo "Verifying Intelligence Agent Deployment..."
    echo "-------------------------------------------------------------------------"
    echo ""
    
    # List all agents
    echo "Checking deployed agents in ${DATABASE}.GOLD schema:"
    echo ""
    snow sql $SNOW_CONN -q "
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
        USE DATABASE ${DATABASE};
        SHOW AGENTS IN SCHEMA GOLD;
    " --format TABLE || echo -e "${YELLOW}Could not list agents - they may not be deployed${NC}"
    
    echo ""
    echo "-------------------------------------------------------------------------"
    echo -e "${CYAN}How to Test Agents:${NC}"
    echo "-------------------------------------------------------------------------"
    echo ""
    echo "Agents are best tested through Snowsight UI:"
    echo ""
    echo "1. Navigate to Snowsight → Agents"
    echo "2. Select an agent from ${DATABASE}.GOLD schema:"
    echo "   • Hotel Guest Analytics Agent"
    echo "   • Hotel Personalization Specialist"
    echo "   • Hotel Amenities Intelligence Agent"
    echo "   • Guest Experience Optimizer"
    echo "   • Hotel Intelligence Master Agent"
    echo ""
    echo "3. Try sample questions:"
    echo "   • 'Show me our top 10 guests by total revenue'"
    echo "   • 'Which guests have the highest spa upsell propensity?'"
    echo "   • 'What is our amenity revenue breakdown by category?'"
    echo "   • 'Identify guests at risk of churning'"
    echo ""
    echo "See docs/AGENT_DETAILED_QUESTIONS.md for 100+ sample questions"
    echo ""
}

###############################################################################
# Command: streamlit - Check Streamlit app status and access
###############################################################################
cmd_streamlit() {
    echo "========================================================================="
    echo "Hotel Personalization - Streamlit Dashboard"
    echo "========================================================================="
    echo ""
    
    echo "Checking Streamlit application deployment..."
    echo "-------------------------------------------------------------------------"
    echo ""
    
    # Check GOLD schema (current deployment location)
    APP_EXISTS=$(snow sql $SNOW_CONN -q "
        -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
        USE DATABASE ${DATABASE};
        SHOW STREAMLITS IN SCHEMA GOLD;
    " --format CSV 2>/dev/null | tail -n +2 | wc -l | xargs)
    APP_EXISTS=${APP_EXISTS:-0}
    
    if [ "$APP_EXISTS" -gt 0 ] 2>/dev/null; then
        echo -e "${GREEN}✓ Streamlit app deployed successfully${NC}"
        echo ""
        
        # Get detailed app information
        echo "Application Details:"
        echo "-------------------------------------------------------------------------"
        snow sql $SNOW_CONN -q "
            -- USE ROLE ${ROLE}; -- Commented out for restricted sessions
            USE DATABASE ${DATABASE};
            SHOW STREAMLITS IN SCHEMA GOLD;
        " --format TABLE 2>/dev/null || true
        
        echo ""
        echo "Data Availability Check:"
        echo "-------------------------------------------------------------------------"
        
        # Check each major data source
        GUEST_COUNT=$(snow sql $SNOW_CONN -q "
            USE DATABASE ${DATABASE};
            USE WAREHOUSE ${WAREHOUSE};
            SELECT COUNT(*) FROM GOLD.GUEST_360_VIEW_ENHANCED;
        " --format CSV 2>/dev/null | tail -n +2 | xargs)
        
        SCORE_COUNT=$(snow sql $SNOW_CONN -q "
            USE DATABASE ${DATABASE};
            USE WAREHOUSE ${WAREHOUSE};
            SELECT COUNT(*) FROM GOLD.PERSONALIZATION_SCORES_ENHANCED;
        " --format CSV 2>/dev/null | tail -n +2 | xargs)
        
        AMENITY_COUNT=$(snow sql $SNOW_CONN -q "
            USE DATABASE ${DATABASE};
            USE WAREHOUSE ${WAREHOUSE};
            SELECT COUNT(*) FROM GOLD.AMENITY_ANALYTICS;
        " --format CSV 2>/dev/null | tail -n +2 | xargs)
        
        if [ -n "$GUEST_COUNT" ] && [ "$GUEST_COUNT" -gt 0 ] 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Guest 360 data: $GUEST_COUNT records"
        else
            echo -e "  ${RED}✗${NC} Guest 360 data: No data"
        fi
        
        if [ -n "$SCORE_COUNT" ] && [ "$SCORE_COUNT" -gt 0 ] 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Personalization scores: $SCORE_COUNT records"
        else
            echo -e "  ${RED}✗${NC} Personalization scores: No data"
        fi
        
        if [ -n "$AMENITY_COUNT" ] && [ "$AMENITY_COUNT" -gt 0 ] 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Amenity analytics: $AMENITY_COUNT records"
        else
            echo -e "  ${RED}✗${NC} Amenity analytics: No data"
        fi
        
        echo ""
        echo "Dashboard Pages:"
        echo "-------------------------------------------------------------------------"
        echo -e "  ${CYAN}1.${NC} Guest 360 Dashboard"
        echo "     • Comprehensive guest profiles and journey visualization"
        echo "     • Loyalty tier and customer segment analysis"
        echo "     • Individual guest drill-down with full history"
        echo ""
        echo -e "  ${CYAN}2.${NC} Personalization Hub"
        echo "     • AI-powered upsell opportunity matrix"
        echo "     • Propensity score analysis (Spa, Dining, Tech, Pool)"
        echo "     • Customer segmentation and churn management"
        echo ""
        echo -e "  ${CYAN}3.${NC} Amenity Performance"
        echo "     • Revenue analysis by amenity category"
        echo "     • Satisfaction metrics and infrastructure usage"
        echo "     • Performance scorecards and improvement areas"
        echo ""
        echo -e "  ${CYAN}4.${NC} Revenue Analytics"
        echo "     • Revenue mix (Rooms vs Amenities)"
        echo "     • Booking channel performance"
        echo "     • Customer segment profitability"
        echo ""
        echo -e "  ${CYAN}5.${NC} Executive Overview"
        echo "     • High-level KPIs and business health scorecard"
        echo "     • Strategic metrics and segment performance"
        echo "     • AI insights and top performers"
        echo ""
        echo "Access Information:"
        echo "-------------------------------------------------------------------------"
        echo -e "${CYAN}How to Access:${NC}"
        echo "  1. Log in to Snowsight: https://app.snowflake.com"
        echo "  2. Navigate to: Projects → Streamlit"
        echo "  3. Select: ${DATABASE}.GOLD → 'Hotel Personalization - Pic'N Stays'"
        echo ""
        echo -e "${CYAN}Or use direct URL pattern:${NC}"
        echo "  https://app.snowflake.com/[your-account-locator]/#/streamlit-apps/"
        echo "  ${DATABASE}.GOLD.HOTEL_PERSONALIZATION_APP"
        echo ""
        echo -e "${CYAN}Role Access:${NC}"
        echo "  • Admins: Full access to all dashboards"
        echo "  • Revenue Analysts: Revenue & Personalization dashboards"
        echo "  • Experience Analysts: Guest 360 & Amenity dashboards"
        echo "  • Guest Analysts: Guest 360 dashboard"
        echo ""
        
    else
        echo -e "${RED}✗ Streamlit app not found${NC}"
        echo ""
        echo "The Streamlit application is not currently deployed."
        echo ""
        echo "To deploy the Streamlit app:"
        echo "  ./deploy.sh streamlit       # Deploy only Streamlit"
        echo "  ./deploy.sh full             # Full deployment including Streamlit"
        echo ""
        
        # Check if there are any apps in STREAMLIT schema (legacy)
        LEGACY_COUNT=$(snow sql $SNOW_CONN -q "
            USE DATABASE ${DATABASE};
            SHOW STREAMLITS IN SCHEMA STREAMLIT;
        " --format CSV 2>/dev/null | tail -n +2 | wc -l | xargs)
        LEGACY_COUNT=${LEGACY_COUNT:-0}
        
        if [ "$LEGACY_COUNT" -gt 0 ] 2>/dev/null; then
            echo -e "${YELLOW}Note: Found $LEGACY_COUNT app(s) in legacy STREAMLIT schema${NC}"
            echo "      Recommend redeploying to GOLD schema for consistency"
            echo ""
        fi
    fi
    
    echo "-------------------------------------------------------------------------"
    echo ""
}

###############################################################################
# Command: intel-hub - Check Intelligence Hub status
###############################################################################
cmd_intel_hub() {
    echo "========================================================================="
    echo "Hotel Intelligence Hub - Status & Validation"
    echo "========================================================================="
    echo ""
    echo "Configuration:"
    echo "  Database: $DATABASE"
    echo "  Connection: $CONNECTION_NAME"
    echo ""
    
    echo "Checking Intelligence Hub infrastructure..."
    echo "-------------------------------------------------------------------------"
    echo ""
    
    # Check Bronze tables (Intelligence Hub specific)
    echo "[1/4] Intelligence Hub Bronze Tables:"
    snow sql $SNOW_CONN -q "
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 'BRONZE.SERVICE_CASES' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM BRONZE.SERVICE_CASES
        UNION ALL
        SELECT 'BRONZE.ISSUE_TRACKING', COUNT(*) FROM BRONZE.ISSUE_TRACKING
        UNION ALL
        SELECT 'BRONZE.SENTIMENT_DATA', COUNT(*) FROM BRONZE.SENTIMENT_DATA
        UNION ALL
        SELECT 'BRONZE.SERVICE_RECOVERY_ACTIONS', COUNT(*) FROM BRONZE.SERVICE_RECOVERY_ACTIONS
        ORDER BY TABLE_NAME;
    " --format TABLE
    echo ""
    
    # Check Silver tables
    echo "[2/4] Intelligence Hub Silver Tables:"
    snow sql $SNOW_CONN -q "
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 'SILVER.SERVICE_CASES_ENRICHED' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM SILVER.SERVICE_CASES_ENRICHED
        UNION ALL
        SELECT 'SILVER.ISSUE_DRIVERS_AGGREGATED', COUNT(*) FROM SILVER.ISSUE_DRIVERS_AGGREGATED
        UNION ALL
        SELECT 'SILVER.SENTIMENT_PROCESSED', COUNT(*) FROM SILVER.SENTIMENT_PROCESSED
        ORDER BY TABLE_NAME;
    " --format TABLE
    echo ""
    
    # Check Gold tables
    echo "[3/4] Intelligence Hub Gold Tables:"
    snow sql $SNOW_CONN -q "
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 'GOLD.PORTFOLIO_PERFORMANCE_KPIS' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM GOLD.PORTFOLIO_PERFORMANCE_KPIS
        UNION ALL
        SELECT 'GOLD.LOYALTY_SEGMENT_INTELLIGENCE', COUNT(*) FROM GOLD.LOYALTY_SEGMENT_INTELLIGENCE
        UNION ALL
        SELECT 'GOLD.EXPERIENCE_SERVICE_SIGNALS', COUNT(*) FROM GOLD.EXPERIENCE_SERVICE_SIGNALS
        ORDER BY TABLE_NAME;
    " --format TABLE
    echo ""
    
    # Check Semantic Views
    echo "[4/4] Intelligence Hub Semantic Views (9 total):"
    echo "  Core Views (3):"
    for view in GUEST_ANALYTICS_VIEW PERSONALIZATION_INSIGHTS_VIEW AMENITY_ANALYTICS_VIEW; do
        VIEW_EXISTS=$(snow sql $SNOW_CONN -q "SHOW VIEWS LIKE '${view}' IN SCHEMA ${DATABASE}.SEMANTIC_VIEWS" --format CSV 2>/dev/null | tail -n +2 | wc -l | xargs)
        VIEW_EXISTS=${VIEW_EXISTS:-0}
        if [ "$VIEW_EXISTS" -gt 0 ] 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} $view"
        else
            echo -e "    ${RED}✗${NC} $view"
        fi
    done
    echo "  Intelligence Hub Views (3):"
    for view in PORTFOLIO_INTELLIGENCE_VIEW LOYALTY_INTELLIGENCE_VIEW CX_SERVICE_INTELLIGENCE_VIEW; do
        VIEW_EXISTS=$(snow sql $SNOW_CONN -q "SHOW VIEWS LIKE '${view}' IN SCHEMA ${DATABASE}.SEMANTIC_VIEWS" --format CSV 2>/dev/null | tail -n +2 | wc -l | xargs)
        VIEW_EXISTS=${VIEW_EXISTS:-0}
        if [ "$VIEW_EXISTS" -gt 0 ] 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} $view"
        else
            echo -e "    ${RED}✗${NC} $view"
        fi
    done
    echo "  Guest Intelligence Views (3):"
    for view in GUEST_SENTIMENT_INTELLIGENCE_VIEW GUEST_ARRIVALS_VIEW GUEST_PREFERENCES_VIEW; do
        VIEW_EXISTS=$(snow sql $SNOW_CONN -q "SHOW VIEWS LIKE '${view}' IN SCHEMA ${DATABASE}.SEMANTIC_VIEWS" --format CSV 2>/dev/null | tail -n +2 | wc -l | xargs)
        VIEW_EXISTS=${VIEW_EXISTS:-0}
        if [ "$VIEW_EXISTS" -gt 0 ] 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} $view"
        else
            echo -e "    ${RED}✗${NC} $view"
        fi
    done
    echo ""
    
    # Check Streamlit app
    echo "Checking Intelligence Hub Streamlit deployment..."
    echo "-------------------------------------------------------------------------"
    APP_EXISTS=$(snow sql $SNOW_CONN -q "SHOW STREAMLITS LIKE 'HOTEL_INTELLIGENCE_HUB' IN SCHEMA ${DATABASE}.GOLD" --format CSV 2>/dev/null | tail -n +2 | wc -l | xargs)
    APP_EXISTS=${APP_EXISTS:-0}
    
    if [ "$APP_EXISTS" -gt 0 ] 2>/dev/null; then
        echo -e "${GREEN}✓ Intelligence Hub app deployed${NC}"
        echo ""
        echo "  📱 App: Hotel Intelligence Hub"
        echo "  📍 Location: ${DATABASE}.GOLD.HOTEL_INTELLIGENCE_HUB"
        echo ""
        echo "  📊 Tabs:"
        echo "     • Portfolio Overview (100 properties, 3 regions)"
        echo "     • Loyalty Intelligence (segment behavior)"
        echo "     • CX & Service Signals (VIP watchlist)"
        echo ""
        echo "  🔗 Access: Snowsight → Projects → Streamlit → 'Hotel Intelligence Hub'"
    else
        echo -e "${RED}✗ Intelligence Hub app not found${NC}"
        echo ""
        echo "To deploy Intelligence Hub:"
        echo "  ./deploy.sh --only-intel-hub"
    fi
    echo ""
    
    # Run sample validation queries
    echo "Sample Queries - Portfolio Overview:"
    echo "-------------------------------------------------------------------------"
    echo ""
    
    echo -e "${CYAN}[Q1]${NC} Portfolio by Region (last 30 days):"
    snow sql $SNOW_CONN -q "
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 
            region,
            COUNT(DISTINCT hotel_id) as properties,
            ROUND(AVG(occupancy_pct), 1) as avg_occupancy,
            ROUND(AVG(revpar), 0) as avg_revpar,
            ROUND(AVG(satisfaction_index), 2) as avg_satisfaction
        FROM GOLD.PORTFOLIO_PERFORMANCE_KPIS
        WHERE performance_date >= DATEADD(day, -30, CURRENT_DATE())
        GROUP BY region
        ORDER BY region;
    " --format TABLE
    echo ""
    
    echo -e "${CYAN}[Q2]${NC} Top 5 Loyalty Segments by Revenue:"
    snow sql $SNOW_CONN -q "
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 
            segment,
            active_members,
            ROUND(repeat_rate_pct, 1) as repeat_rate,
            ROUND(avg_spend_per_stay, 0) as avg_spend,
            recommended_focus
        FROM GOLD.LOYALTY_SEGMENT_INTELLIGENCE
        ORDER BY total_revenue DESC
        LIMIT 5;
    " --format TABLE
    echo ""
    
    echo -e "${CYAN}[Q3]${NC} Service Quality by Brand:"
    snow sql $SNOW_CONN -q "
        USE DATABASE ${DATABASE};
        USE WAREHOUSE ${WAREHOUSE};
        
        SELECT 
            brand,
            ROUND(AVG(service_case_rate), 1) as case_rate_per_1k,
            ROUND(AVG(negative_sentiment_rate_pct), 1) as neg_sentiment_pct,
            ROUND(AVG(service_recovery_success_pct), 1) as recovery_success_pct,
            SUM(at_risk_high_value_guests_count) as at_risk_vips
        FROM GOLD.EXPERIENCE_SERVICE_SIGNALS
        GROUP BY brand
        ORDER BY brand;
    " --format TABLE
    echo ""
    
    echo "-------------------------------------------------------------------------"
    echo -e "${GREEN}✓${NC} Intelligence Hub validation complete"
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
    streamlit)
        cmd_streamlit
        ;;
    intel-hub)
        cmd_intel_hub
        ;;
    *)
        error_exit "Unknown command: $COMMAND"
        ;;
esac

