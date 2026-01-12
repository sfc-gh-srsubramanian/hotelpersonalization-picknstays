#!/bin/bash
###############################################################################
# Script Validation - Deployment and Cleanup Flow
###############################################################################
# This script validates the logic and flow of deploy.sh and clean.sh
# without actually executing Snowflake commands
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "========================================================================="
echo "Hotel Personalization Platform - Script Validation"
echo "========================================================================="
echo ""

VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0

###############################################################################
# Test 1: Verify all agent names are consistent
###############################################################################
echo -e "${BLUE}Test 1: Agent Name Consistency${NC}"
echo "-------------------------------------------------------------------------"

AGENT_NAMES=(
    "Hotel Guest Analytics Agent"
    "Hotel Personalization Specialist"
    "Hotel Amenities Intelligence Agent"
    "Guest Experience Optimizer"
    "Hotel Intelligence Master Agent"
)

# Check sql/05_intelligence_agents.sql
echo "Checking sql/05_intelligence_agents.sql..."
for agent in "${AGENT_NAMES[@]}"; do
    # Check CREATE AGENT statements
    if grep -q "CREATE OR REPLACE AGENT GOLD.\"$agent\"" sql/05_intelligence_agents.sql; then
        echo "  ✓ CREATE AGENT found: $agent"
    else
        echo -e "  ${RED}✗ CREATE AGENT missing: $agent${NC}"
        ((VALIDATION_ERRORS++))
    fi
    
    # Check ADD AGENT statements
    if grep -q "ADD AGENT IDENTIFIER(\$FULL_PREFIX || '.GOLD.\"$agent\"')" sql/05_intelligence_agents.sql; then
        echo "  ✓ ADD AGENT registration found: $agent"
    else
        echo -e "  ${RED}✗ ADD AGENT registration missing: $agent${NC}"
        ((VALIDATION_ERRORS++))
    fi
done

# Check clean.sh
echo ""
echo "Checking clean.sh..."
for agent in "${AGENT_NAMES[@]}"; do
    # Check de-registration (Step 0)
    if grep -q "\"$agent\"" clean.sh | grep -q "DROP AGENT"; then
        echo "  ✓ DROP AGENT de-registration found: $agent"
    else
        echo -e "  ${YELLOW}⚠ DROP AGENT de-registration check: $agent${NC}"
        ((VALIDATION_WARNINGS++))
    fi
done

echo -e "${GREEN}✓${NC} Test 1 Complete"
echo ""

###############################################################################
# Test 2: Verify variable consistency
###############################################################################
echo -e "${BLUE}Test 2: Variable Consistency${NC}"
echo "-------------------------------------------------------------------------"

# Check deploy.sh variables
echo "Checking deploy.sh variables..."
if grep -q "SET FULL_PREFIX = '\${FULL_PREFIX}';" deploy.sh; then
    echo "  ✓ FULL_PREFIX variable set in deploy.sh"
else
    echo -e "  ${RED}✗ FULL_PREFIX variable missing in deploy.sh${NC}"
    ((VALIDATION_ERRORS++))
fi

if grep -q "SET PROJECT_ROLE = '\${ROLE}';" deploy.sh; then
    echo "  ✓ PROJECT_ROLE variable set in deploy.sh"
else
    echo -e "  ${RED}✗ PROJECT_ROLE variable missing in deploy.sh${NC}"
    ((VALIDATION_ERRORS++))
fi

# Check clean.sh variables
echo ""
echo "Checking clean.sh variables..."
if grep -q 'DATABASE="${FULL_PREFIX}"' clean.sh; then
    echo "  ✓ DATABASE variable derived from FULL_PREFIX"
else
    echo -e "  ${RED}✗ DATABASE variable not properly derived${NC}"
    ((VALIDATION_ERRORS++))
fi

echo -e "${GREEN}✓${NC} Test 2 Complete"
echo ""

###############################################################################
# Test 3: Verify cleanup order
###############################################################################
echo -e "${BLUE}Test 3: Cleanup Order Validation${NC}"
echo "-------------------------------------------------------------------------"

echo "Verifying cleanup step order..."

# Extract step numbers from clean.sh
STEP_0=$(grep -n "# Step 0: De-register Agents from Snowflake Intelligence" clean.sh | cut -d: -f1)
STEP_1=$(grep -n "# Step 1: Drop Intelligence Agents" clean.sh | cut -d: -f1)
STEP_2=$(grep -n "# Step 2: Drop Semantic Views" clean.sh | cut -d: -f1)
STEP_3=$(grep -n "# Step 3: Drop Warehouse" clean.sh | cut -d: -f1)
STEP_4=$(grep -n "# Step 4: Drop Database" clean.sh | cut -d: -f1)
STEP_5=$(grep -n "# Step 5: Drop Role" clean.sh | cut -d: -f1)

if [ -n "$STEP_0" ] && [ -n "$STEP_1" ] && [ "$STEP_0" -lt "$STEP_1" ]; then
    echo "  ✓ Step 0 (De-register) comes before Step 1 (Drop Agents)"
else
    echo -e "  ${RED}✗ Step 0 and Step 1 order incorrect${NC}"
    ((VALIDATION_ERRORS++))
fi

if [ -n "$STEP_1" ] && [ -n "$STEP_2" ] && [ "$STEP_1" -lt "$STEP_2" ]; then
    echo "  ✓ Step 1 (Drop Agents) comes before Step 2 (Drop Views)"
else
    echo -e "  ${RED}✗ Step 1 and Step 2 order incorrect${NC}"
    ((VALIDATION_ERRORS++))
fi

if [ -n "$STEP_2" ] && [ -n "$STEP_4" ] && [ "$STEP_2" -lt "$STEP_4" ]; then
    echo "  ✓ Step 2 (Drop Views) comes before Step 4 (Drop Database)"
else
    echo -e "  ${RED}✗ Step 2 and Step 4 order incorrect${NC}"
    ((VALIDATION_ERRORS++))
fi

echo -e "${GREEN}✓${NC} Test 3 Complete"
echo ""

###############################################################################
# Test 4: Verify SQL file syntax
###############################################################################
echo -e "${BLUE}Test 4: SQL File Validation${NC}"
echo "-------------------------------------------------------------------------"

echo "Checking sql/05_intelligence_agents.sql structure..."

# Check for required sections
if grep -q "CREATE SNOWFLAKE INTELLIGENCE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT" sql/05_intelligence_agents.sql; then
    echo "  ✓ CREATE SNOWFLAKE INTELLIGENCE statement found"
else
    echo -e "  ${RED}✗ CREATE SNOWFLAKE INTELLIGENCE statement missing${NC}"
    ((VALIDATION_ERRORS++))
fi

if grep -q "ALTER SNOWFLAKE INTELLIGENCE IF EXISTS SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT" sql/05_intelligence_agents.sql; then
    echo "  ✓ ALTER SNOWFLAKE INTELLIGENCE statements found"
else
    echo -e "  ${RED}✗ ALTER SNOWFLAKE INTELLIGENCE statements missing${NC}"
    ((VALIDATION_ERRORS++))
fi

# Count number of ADD AGENT statements (should be 5)
ADD_AGENT_COUNT=$(grep -c "ADD AGENT IDENTIFIER(\$FULL_PREFIX" sql/05_intelligence_agents.sql || echo "0")
if [ "$ADD_AGENT_COUNT" -eq 5 ]; then
    echo "  ✓ Found 5 ADD AGENT statements (correct)"
else
    echo -e "  ${RED}✗ Found $ADD_AGENT_COUNT ADD AGENT statements (expected 5)${NC}"
    ((VALIDATION_ERRORS++))
fi

echo -e "${GREEN}✓${NC} Test 4 Complete"
echo ""

###############################################################################
# Test 5: Verify agent path format
###############################################################################
echo -e "${BLUE}Test 5: Agent Path Format Validation${NC}"
echo "-------------------------------------------------------------------------"

echo "Checking agent path formats..."

# Check clean.sh uses correct path format
if grep -q '\${DATABASE}.GOLD.\\"' clean.sh; then
    echo "  ✓ clean.sh uses correct agent path format: \${DATABASE}.GOLD.\"AgentName\""
else
    echo -e "  ${RED}✗ clean.sh agent path format incorrect${NC}"
    ((VALIDATION_ERRORS++))
fi

# Check sql file uses IDENTIFIER with concatenation
if grep -q "IDENTIFIER(\$FULL_PREFIX || '.GOLD" sql/05_intelligence_agents.sql; then
    echo "  ✓ sql/05_intelligence_agents.sql uses correct IDENTIFIER format"
else
    echo -e "  ${RED}✗ sql/05_intelligence_agents.sql IDENTIFIER format incorrect${NC}"
    ((VALIDATION_ERRORS++))
fi

echo -e "${GREEN}✓${NC} Test 5 Complete"
echo ""

###############################################################################
# Test 6: Verify --keep-agents flag handling
###############################################################################
echo -e "${BLUE}Test 6: --keep-agents Flag Handling${NC}"
echo "-------------------------------------------------------------------------"

echo "Checking --keep-agents flag logic..."

# Check that both Step 0 and Step 1 respect KEEP_AGENTS flag
STEP_0_KEEP_CHECK=$(grep -A 20 "# Step 0: De-register Agents" clean.sh | grep -c 'if \[ "\$KEEP_AGENTS" = false \]' || echo "0")
STEP_1_KEEP_CHECK=$(grep -A 20 "# Step 1: Drop Intelligence Agents" clean.sh | grep -c 'if \[ "\$KEEP_AGENTS" = false \]' || echo "0")

if [ "$STEP_0_KEEP_CHECK" -ge 1 ]; then
    echo "  ✓ Step 0 respects --keep-agents flag"
else
    echo -e "  ${RED}✗ Step 0 does not respect --keep-agents flag${NC}"
    ((VALIDATION_ERRORS++))
fi

if [ "$STEP_1_KEEP_CHECK" -ge 1 ]; then
    echo "  ✓ Step 1 respects --keep-agents flag"
else
    echo -e "  ${RED}✗ Step 1 does not respect --keep-agents flag${NC}"
    ((VALIDATION_ERRORS++))
fi

echo -e "${GREEN}✓${NC} Test 6 Complete"
echo ""

###############################################################################
# Test 7: Verify deploy.sh agent deployment messaging
###############################################################################
echo -e "${BLUE}Test 7: Deployment Messaging${NC}"
echo "-------------------------------------------------------------------------"

echo "Checking deploy.sh success messages..."

if grep -q "Registering agents with Snowflake Intelligence" deploy.sh; then
    echo "  ✓ Registration message found in deploy.sh"
else
    echo -e "  ${YELLOW}⚠ Registration message missing in deploy.sh${NC}"
    ((VALIDATION_WARNINGS++))
fi

if grep -q "Agents now visible in Snowflake Intelligence UI" deploy.sh; then
    echo "  ✓ UI visibility message found in deploy.sh"
else
    echo -e "  ${YELLOW}⚠ UI visibility message missing in deploy.sh${NC}"
    ((VALIDATION_WARNINGS++))
fi

echo -e "${GREEN}✓${NC} Test 7 Complete"
echo ""

###############################################################################
# Summary
###############################################################################
echo "========================================================================="
echo "Validation Summary"
echo "========================================================================="
echo ""

if [ $VALIDATION_ERRORS -eq 0 ] && [ $VALIDATION_WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ ALL VALIDATIONS PASSED${NC}"
    echo ""
    echo "✅ deploy.sh: Ready for deployment"
    echo "✅ clean.sh: Ready for cleanup operations"
    echo "✅ sql/05_intelligence_agents.sql: Properly configured"
    echo ""
    echo "Scripts are validated and ready to use!"
    exit 0
elif [ $VALIDATION_ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ VALIDATIONS PASSED WITH WARNINGS${NC}"
    echo ""
    echo "Warnings: $VALIDATION_WARNINGS"
    echo ""
    echo "Scripts should work but have minor issues to review."
    exit 0
else
    echo -e "${RED}✗ VALIDATION FAILED${NC}"
    echo ""
    echo "Errors: $VALIDATION_ERRORS"
    echo "Warnings: $VALIDATION_WARNINGS"
    echo ""
    echo "Please fix the errors before deploying."
    exit 1
fi
