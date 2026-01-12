-- ============================================================================
-- Hotel Personalization - Streamlit Dashboards Deployment
-- ============================================================================
-- Deploys 5 enterprise Streamlit dashboards to Snowflake
-- 
-- Dashboards:
--   1. Guest 360 Dashboard - Comprehensive guest profiles
--   2. Personalization Hub - Upsell & revenue optimization
--   3. Amenity Performance - Service analytics
--   4. Revenue Analytics - Financial performance
--   5. Executive Overview - Strategic KPIs
-- 
-- Session variables (set by deploy.sh):
--   $FULL_PREFIX
-- ============================================================================

USE DATABASE IDENTIFIER($FULL_PREFIX);

-- Create Streamlit schema if not exists
CREATE SCHEMA IF NOT EXISTS STREAMLIT;
USE SCHEMA STREAMLIT;

-- Create stage for Streamlit files
CREATE STAGE IF NOT EXISTS STREAMLIT.STAGE;

-- Set variables for warehouse and role names
SET PROJECT_WH = $FULL_PREFIX || '_WH';
SET PROJECT_ROLE = $FULL_PREFIX || '_ROLE';
SET ROLE_ADMIN = $FULL_PREFIX || '_ROLE_ADMIN';
SET ROLE_GUEST_ANALYST = $FULL_PREFIX || '_ROLE_GUEST_ANALYST';
SET ROLE_REVENUE_ANALYST = $FULL_PREFIX || '_ROLE_REVENUE_ANALYST';
SET ROLE_EXPERIENCE_ANALYST = $FULL_PREFIX || '_ROLE_EXPERIENCE_ANALYST';

-- ============================================================================
-- 1. GUEST 360 DASHBOARD
-- ============================================================================
CREATE OR REPLACE STREAMLIT GUEST_360_DASHBOARD
    ROOT_LOCATION = '@STREAMLIT.STAGE'
    MAIN_FILE = 'guest_360_dashboard.py'
    QUERY_WAREHOUSE = IDENTIFIER($PROJECT_WH)
    COMMENT = 'Comprehensive Guest Profile & Journey Visualization Dashboard';

-- ============================================================================
-- 2. PERSONALIZATION HUB DASHBOARD
-- ============================================================================
CREATE OR REPLACE STREAMLIT PERSONALIZATION_HUB
    ROOT_LOCATION = '@STREAMLIT.STAGE'
    MAIN_FILE = 'personalization_hub.py'
    QUERY_WAREHOUSE = IDENTIFIER($PROJECT_WH)
    COMMENT = 'AI-Powered Personalization & Upsell Opportunity Dashboard';

-- ============================================================================
-- 3. AMENITY PERFORMANCE DASHBOARD
-- ============================================================================
CREATE OR REPLACE STREAMLIT AMENITY_PERFORMANCE
    ROOT_LOCATION = '@STREAMLIT.STAGE'
    MAIN_FILE = 'amenity_performance.py'
    QUERY_WAREHOUSE = IDENTIFIER($PROJECT_WH)
    COMMENT = 'Comprehensive Service & Infrastructure Performance Analytics';

-- ============================================================================
-- 4. REVENUE ANALYTICS DASHBOARD
-- ============================================================================
CREATE OR REPLACE STREAMLIT REVENUE_ANALYTICS
    ROOT_LOCATION = '@STREAMLIT.STAGE'
    MAIN_FILE = 'revenue_analytics.py'
    QUERY_WAREHOUSE = IDENTIFIER($PROJECT_WH)
    COMMENT = 'Revenue Performance & Optimization Dashboard';

-- ============================================================================
-- 5. EXECUTIVE OVERVIEW DASHBOARD
-- ============================================================================
CREATE OR REPLACE STREAMLIT EXECUTIVE_OVERVIEW
    ROOT_LOCATION = '@STREAMLIT.STAGE'
    MAIN_FILE = 'executive_overview.py'
    QUERY_WAREHOUSE = IDENTIFIER($PROJECT_WH)
    COMMENT = 'Executive Strategic Business Intelligence Dashboard';

-- ============================================================================
-- Grant Permissions to Project Roles
-- ============================================================================

-- Main project role gets access to all dashboards
GRANT USAGE ON STREAMLIT GUEST_360_DASHBOARD TO ROLE IDENTIFIER($PROJECT_ROLE);
GRANT USAGE ON STREAMLIT PERSONALIZATION_HUB TO ROLE IDENTIFIER($PROJECT_ROLE);
GRANT USAGE ON STREAMLIT AMENITY_PERFORMANCE TO ROLE IDENTIFIER($PROJECT_ROLE);
GRANT USAGE ON STREAMLIT REVENUE_ANALYTICS TO ROLE IDENTIFIER($PROJECT_ROLE);
GRANT USAGE ON STREAMLIT EXECUTIVE_OVERVIEW TO ROLE IDENTIFIER($PROJECT_ROLE);

-- Admin role gets access to all dashboards
GRANT USAGE ON STREAMLIT GUEST_360_DASHBOARD TO ROLE IDENTIFIER($ROLE_ADMIN);
GRANT USAGE ON STREAMLIT PERSONALIZATION_HUB TO ROLE IDENTIFIER($ROLE_ADMIN);
GRANT USAGE ON STREAMLIT AMENITY_PERFORMANCE TO ROLE IDENTIFIER($ROLE_ADMIN);
GRANT USAGE ON STREAMLIT REVENUE_ANALYTICS TO ROLE IDENTIFIER($ROLE_ADMIN);
GRANT USAGE ON STREAMLIT EXECUTIVE_OVERVIEW TO ROLE IDENTIFIER($ROLE_ADMIN);

-- Guest Analyst role
GRANT USAGE ON STREAMLIT GUEST_360_DASHBOARD TO ROLE IDENTIFIER($ROLE_GUEST_ANALYST);

-- Revenue Analyst role
GRANT USAGE ON STREAMLIT PERSONALIZATION_HUB TO ROLE IDENTIFIER($ROLE_REVENUE_ANALYST);
GRANT USAGE ON STREAMLIT REVENUE_ANALYTICS TO ROLE IDENTIFIER($ROLE_REVENUE_ANALYST);
GRANT USAGE ON STREAMLIT EXECUTIVE_OVERVIEW TO ROLE IDENTIFIER($ROLE_REVENUE_ANALYST);

-- Experience Analyst role
GRANT USAGE ON STREAMLIT AMENITY_PERFORMANCE TO ROLE IDENTIFIER($ROLE_EXPERIENCE_ANALYST);
GRANT USAGE ON STREAMLIT GUEST_360_DASHBOARD TO ROLE IDENTIFIER($ROLE_EXPERIENCE_ANALYST);

-- ============================================================================
-- Summary
-- ============================================================================
SELECT 'Streamlit Dashboards deployed successfully!' AS STATUS;
SELECT 
    '5 interactive dashboards created with RBAC permissions' AS RESULT,
    'Access dashboards via Snowsight Streamlit section' AS NEXT_STEP;
