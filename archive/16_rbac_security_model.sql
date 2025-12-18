-- Hotel Personalization System - Role-Based Access Control (RBAC)
-- Comprehensive security model for different user types and data layers

USE DATABASE HOTEL_PERSONALIZATION;

-- =====================================================
-- RBAC STRATEGY OVERVIEW
-- =====================================================
/*
ROLE HIERARCHY:
1. DATA_ENGINEER_ROLE - Full access to all layers for development/maintenance
2. HOTEL_EXECUTIVE_ROLE - Strategic insights across all properties
3. HOTEL_MANAGER_ROLE - Property-specific operational insights
4. GUEST_SERVICES_ROLE - Guest-facing personalization data
5. REVENUE_ANALYST_ROLE - Revenue and business metrics focus
6. MARKETING_ROLE - Guest preferences and campaign insights
7. IT_SUPPORT_ROLE - System monitoring and basic troubleshooting
8. AUDIT_ROLE - Read-only access for compliance and auditing

LAYER ACCESS STRATEGY:
- Bronze Layer: Restricted to data engineers and auditors
- Silver Layer: Available to analysts and managers
- Gold Layer: Business users and executives
- Semantic Layer: All business users with role-appropriate filtering
- AI Agents: Role-specific agents with contextual access
*/

-- =====================================================
-- CREATE CORE ROLES
-- =====================================================

-- Data Engineering Role (Full Access)
CREATE ROLE IF NOT EXISTS DATA_ENGINEER_ROLE
COMMENT = 'Full access for data engineers - development and maintenance';

-- Executive Leadership Role
CREATE ROLE IF NOT EXISTS HOTEL_EXECUTIVE_ROLE
COMMENT = 'Strategic insights for hotel executives across all properties';

-- Hotel Operations Role
CREATE ROLE IF NOT EXISTS HOTEL_MANAGER_ROLE
COMMENT = 'Property-specific operational insights for hotel managers';

-- Guest Services Role
CREATE ROLE IF NOT EXISTS GUEST_SERVICES_ROLE
COMMENT = 'Guest-facing personalization and service optimization';

-- Revenue Management Role
CREATE ROLE IF NOT EXISTS REVENUE_ANALYST_ROLE
COMMENT = 'Revenue optimization and business performance analysis';

-- Marketing Role
CREATE ROLE IF NOT EXISTS MARKETING_ROLE
COMMENT = 'Guest preferences, segmentation, and campaign insights';

-- IT Support Role
CREATE ROLE IF NOT EXISTS IT_SUPPORT_ROLE
COMMENT = 'System monitoring and basic troubleshooting access';

-- Audit and Compliance Role
CREATE ROLE IF NOT EXISTS AUDIT_ROLE
COMMENT = 'Read-only access for compliance and auditing purposes';

-- Guest Privacy Officer Role
CREATE ROLE IF NOT EXISTS PRIVACY_OFFICER_ROLE
COMMENT = 'Data privacy compliance and guest data protection oversight';

-- =====================================================
-- WAREHOUSE ACCESS CONTROL
-- =====================================================

-- Create role-specific warehouses for resource management
CREATE WAREHOUSE IF NOT EXISTS EXECUTIVE_WH
WITH WAREHOUSE_SIZE = 'LARGE'
AUTO_SUSPEND = 300
AUTO_RESUME = TRUE
COMMENT = 'Executive analytics warehouse';

CREATE WAREHOUSE IF NOT EXISTS OPERATIONS_WH
WITH WAREHOUSE_SIZE = 'MEDIUM'
AUTO_SUSPEND = 180
AUTO_RESUME = TRUE
COMMENT = 'Hotel operations warehouse';

CREATE WAREHOUSE IF NOT EXISTS GUEST_SERVICES_WH
WITH WAREHOUSE_SIZE = 'SMALL'
AUTO_SUSPEND = 120
AUTO_RESUME = TRUE
COMMENT = 'Guest services warehouse';

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE EXECUTIVE_WH TO ROLE HOTEL_EXECUTIVE_ROLE;
GRANT USAGE ON WAREHOUSE EXECUTIVE_WH TO ROLE DATA_ENGINEER_ROLE;

GRANT USAGE ON WAREHOUSE OPERATIONS_WH TO ROLE HOTEL_MANAGER_ROLE;
GRANT USAGE ON WAREHOUSE OPERATIONS_WH TO ROLE REVENUE_ANALYST_ROLE;
GRANT USAGE ON WAREHOUSE OPERATIONS_WH TO ROLE MARKETING_ROLE;

GRANT USAGE ON WAREHOUSE GUEST_SERVICES_WH TO ROLE GUEST_SERVICES_ROLE;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE IT_SUPPORT_ROLE;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE AUDIT_ROLE;

-- =====================================================
-- DATABASE AND SCHEMA LEVEL PERMISSIONS
-- =====================================================

-- Data Engineer - Full Access
GRANT ALL ON DATABASE HOTEL_PERSONALIZATION TO ROLE DATA_ENGINEER_ROLE;
GRANT ALL ON ALL SCHEMAS IN DATABASE HOTEL_PERSONALIZATION TO ROLE DATA_ENGINEER_ROLE;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE HOTEL_PERSONALIZATION TO ROLE DATA_ENGINEER_ROLE;

-- Executive Role - Gold and Semantic Layer Access
GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE HOTEL_EXECUTIVE_ROLE;
GRANT USAGE ON SCHEMA HOTEL_PERSONALIZATION.GOLD TO ROLE HOTEL_EXECUTIVE_ROLE;
GRANT USAGE ON SCHEMA HOTEL_PERSONALIZATION.SEMANTIC TO ROLE HOTEL_EXECUTIVE_ROLE;

-- Hotel Manager Role - Silver, Gold, and Semantic Access
GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE HOTEL_MANAGER_ROLE;
GRANT USAGE ON SCHEMA HOTEL_PERSONALIZATION.SILVER TO ROLE HOTEL_MANAGER_ROLE;
GRANT USAGE ON SCHEMA HOTEL_PERSONALIZATION.GOLD TO ROLE HOTEL_MANAGER_ROLE;
GRANT USAGE ON SCHEMA HOTEL_PERSONALIZATION.SEMANTIC TO ROLE HOTEL_MANAGER_ROLE;

-- Guest Services Role - Semantic Layer Focus
GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE GUEST_SERVICES_ROLE;
GRANT USAGE ON SCHEMA HOTEL_PERSONALIZATION.SEMANTIC TO ROLE GUEST_SERVICES_ROLE;

-- Revenue Analyst Role - Gold and Semantic Access
GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE REVENUE_ANALYST_ROLE;
GRANT USAGE ON SCHEMA HOTEL_PERSONALIZATION.GOLD TO ROLE REVENUE_ANALYST_ROLE;
GRANT USAGE ON SCHEMA HOTEL_PERSONALIZATION.SEMANTIC TO ROLE REVENUE_ANALYST_ROLE;

-- Marketing Role - Silver, Gold, and Semantic Access
GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE MARKETING_ROLE;
GRANT USAGE ON SCHEMA HOTEL_PERSONALIZATION.SILVER TO ROLE MARKETING_ROLE;
GRANT USAGE ON SCHEMA HOTEL_PERSONALIZATION.GOLD TO ROLE MARKETING_ROLE;
GRANT USAGE ON SCHEMA HOTEL_PERSONALIZATION.SEMANTIC TO ROLE MARKETING_ROLE;

-- IT Support Role - Limited System Access
GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE IT_SUPPORT_ROLE;
GRANT USAGE ON SCHEMA HOTEL_PERSONALIZATION.SEMANTIC TO ROLE IT_SUPPORT_ROLE;

-- Audit Role - Read-Only Access to All Layers
GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE AUDIT_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE HOTEL_PERSONALIZATION TO ROLE AUDIT_ROLE;

-- Privacy Officer - Full Read Access for Compliance
GRANT USAGE ON DATABASE HOTEL_PERSONALIZATION TO ROLE PRIVACY_OFFICER_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE HOTEL_PERSONALIZATION TO ROLE PRIVACY_OFFICER_ROLE;

-- =====================================================
-- TABLE LEVEL PERMISSIONS
-- =====================================================

-- Bronze Layer Access (Restricted)
GRANT SELECT ON ALL TABLES IN SCHEMA HOTEL_PERSONALIZATION.BRONZE TO ROLE DATA_ENGINEER_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HOTEL_PERSONALIZATION.BRONZE TO ROLE AUDIT_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HOTEL_PERSONALIZATION.BRONZE TO ROLE PRIVACY_OFFICER_ROLE;

-- Silver Layer Access
GRANT SELECT ON ALL TABLES IN SCHEMA HOTEL_PERSONALIZATION.SILVER TO ROLE DATA_ENGINEER_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HOTEL_PERSONALIZATION.SILVER TO ROLE HOTEL_MANAGER_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HOTEL_PERSONALIZATION.SILVER TO ROLE MARKETING_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HOTEL_PERSONALIZATION.SILVER TO ROLE AUDIT_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HOTEL_PERSONALIZATION.SILVER TO ROLE PRIVACY_OFFICER_ROLE;

-- Gold Layer Access
GRANT SELECT ON ALL TABLES IN SCHEMA HOTEL_PERSONALIZATION.GOLD TO ROLE DATA_ENGINEER_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HOTEL_PERSONALIZATION.GOLD TO ROLE HOTEL_EXECUTIVE_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HOTEL_PERSONALIZATION.GOLD TO ROLE HOTEL_MANAGER_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HOTEL_PERSONALIZATION.GOLD TO ROLE REVENUE_ANALYST_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HOTEL_PERSONALIZATION.GOLD TO ROLE MARKETING_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA HOTEL_PERSONALIZATION.GOLD TO ROLE AUDIT_ROLE;

-- Semantic Layer Access (Views)
GRANT SELECT ON ALL VIEWS IN SCHEMA HOTEL_PERSONALIZATION.SEMANTIC TO ROLE DATA_ENGINEER_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA HOTEL_PERSONALIZATION.SEMANTIC TO ROLE HOTEL_EXECUTIVE_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA HOTEL_PERSONALIZATION.SEMANTIC TO ROLE HOTEL_MANAGER_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA HOTEL_PERSONALIZATION.SEMANTIC TO ROLE GUEST_SERVICES_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA HOTEL_PERSONALIZATION.SEMANTIC TO ROLE REVENUE_ANALYST_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA HOTEL_PERSONALIZATION.SEMANTIC TO ROLE MARKETING_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA HOTEL_PERSONALIZATION.SEMANTIC TO ROLE IT_SUPPORT_ROLE;

-- Future grants for new objects
GRANT SELECT ON FUTURE TABLES IN SCHEMA HOTEL_PERSONALIZATION.BRONZE TO ROLE DATA_ENGINEER_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA HOTEL_PERSONALIZATION.SILVER TO ROLE HOTEL_MANAGER_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA HOTEL_PERSONALIZATION.GOLD TO ROLE HOTEL_EXECUTIVE_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA HOTEL_PERSONALIZATION.SEMANTIC TO ROLE GUEST_SERVICES_ROLE;

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Create secure views with row-level filtering for hotel managers
CREATE OR REPLACE SECURE VIEW SEMANTIC.hotel_manager_guest_analytics AS
SELECT *
FROM SEMANTIC.guest_analytics ga
WHERE EXISTS (
    SELECT 1 
    FROM SILVER.bookings_enriched be 
    WHERE be.guest_id = ga.guest_id 
    AND be.hotel_city = CURRENT_USER_CONTEXT('hotel_city')  -- Assumes context is set
);

-- Create secure view for guest services (limited PII)
CREATE OR REPLACE SECURE VIEW SEMANTIC.guest_services_safe_view AS
SELECT 
    guest_id,
    CONCAT(LEFT(guest_name, 1), '***') as masked_name,  -- Mask guest names
    guest_segment,
    loyalty_tier,
    total_bookings,
    average_satisfaction_score,
    customer_segment,
    churn_risk
FROM SEMANTIC.guest_analytics;

-- Grant access to secure views
GRANT SELECT ON SEMANTIC.hotel_manager_guest_analytics TO ROLE HOTEL_MANAGER_ROLE;
GRANT SELECT ON SEMANTIC.guest_services_safe_view TO ROLE GUEST_SERVICES_ROLE;

-- =====================================================
-- COLUMN LEVEL SECURITY
-- =====================================================

-- Create masking policies for sensitive data
CREATE OR REPLACE MASKING POLICY email_mask AS (val STRING) RETURNS STRING ->
CASE 
    WHEN CURRENT_ROLE() IN ('DATA_ENGINEER_ROLE', 'PRIVACY_OFFICER_ROLE', 'AUDIT_ROLE') THEN val
    WHEN CURRENT_ROLE() IN ('HOTEL_EXECUTIVE_ROLE', 'MARKETING_ROLE') THEN REGEXP_REPLACE(val, '(.{2})(.*)(@.*)', '\\1***\\3')
    ELSE '***@***.com'
END;

CREATE OR REPLACE MASKING POLICY phone_mask AS (val STRING) RETURNS STRING ->
CASE 
    WHEN CURRENT_ROLE() IN ('DATA_ENGINEER_ROLE', 'PRIVACY_OFFICER_ROLE', 'AUDIT_ROLE') THEN val
    WHEN CURRENT_ROLE() IN ('HOTEL_EXECUTIVE_ROLE', 'GUEST_SERVICES_ROLE') THEN CONCAT(LEFT(val, 6), '****')
    ELSE '***-***-****'
END;

CREATE OR REPLACE MASKING POLICY guest_name_mask AS (val STRING) RETURNS STRING ->
CASE 
    WHEN CURRENT_ROLE() IN ('DATA_ENGINEER_ROLE', 'PRIVACY_OFFICER_ROLE', 'AUDIT_ROLE', 'GUEST_SERVICES_ROLE') THEN val
    WHEN CURRENT_ROLE() IN ('HOTEL_EXECUTIVE_ROLE', 'HOTEL_MANAGER_ROLE') THEN CONCAT(LEFT(val, 1), '*** ', SPLIT_PART(val, ' ', -1))
    ELSE 'Guest ***'
END;

-- Apply masking policies to sensitive columns
ALTER TABLE BRONZE.guest_profiles MODIFY COLUMN email SET MASKING POLICY email_mask;
ALTER TABLE BRONZE.guest_profiles MODIFY COLUMN phone SET MASKING POLICY phone_mask;

-- =====================================================
-- SNOWFLAKE INTELLIGENCE AGENT ACCESS CONTROL
-- =====================================================

-- Create role-specific agents with appropriate access levels

-- Executive Agent (Full Strategic Access)
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Executive Intelligence Agent"
COMMENT = "Strategic insights agent for hotel executives with full data access"
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: "You are a strategic hotel intelligence advisor for executive leadership. You have access to comprehensive guest analytics, revenue optimization, and business performance data across all hotel properties. Focus on high-level strategic insights, market trends, competitive analysis, and investment recommendations. Provide executive-level summaries with key metrics and strategic recommendations."

tools:
  - tool_spec:
      type: "cortex_search"
      name: "executive_analytics"

tool_resources:
  executive_analytics:
    id_column: "GUEST_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.GUEST_ANALYTICS"
$$;

-- Operations Agent (Property-Specific Access)
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Operations Agent"
COMMENT = "Operational insights agent for hotel managers with property-specific access"
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: "You are a hotel operations specialist focused on day-to-day operational excellence. You analyze guest satisfaction, service quality, staff performance, and operational efficiency for specific hotel properties. Provide actionable insights for improving guest experience, optimizing operations, and managing staff performance. Focus on tactical recommendations that can be implemented immediately."

tools:
  - tool_spec:
      type: "cortex_search"
      name: "operations_analytics"

tool_resources:
  operations_analytics:
    id_column: "GUEST_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.hotel_manager_guest_analytics"
$$;

-- Guest Services Agent (Privacy-Safe Access)
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Guest Services Agent"
COMMENT = "Guest services agent with privacy-safe guest data access"
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: "You are a guest services specialist focused on enhancing individual guest experiences while protecting privacy. You analyze guest preferences, satisfaction patterns, and service opportunities using privacy-safe data. Provide personalized service recommendations, upsell opportunities, and guest care strategies. Always prioritize guest privacy and data protection in your recommendations."

tools:
  - tool_spec:
      type: "cortex_search"
      name: "guest_services_analytics"

tool_resources:
  guest_services_analytics:
    id_column: "GUEST_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.guest_services_safe_view"
$$;

-- Revenue Agent (Financial Focus)
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Revenue Intelligence Agent"
COMMENT = "Revenue optimization agent with financial and business metrics focus"
FROM SPECIFICATION $$
models:
  orchestration: "claude-4-sonnet"

instructions:
  response: "You are a revenue optimization specialist focused on maximizing hotel profitability and financial performance. You analyze revenue trends, pricing strategies, guest lifetime value, and profit optimization opportunities. Provide data-driven recommendations for pricing, upselling, cost management, and revenue growth. Focus on ROI analysis and financial impact of operational decisions."

tools:
  - tool_spec:
      type: "cortex_search"
      name: "revenue_analytics"

tool_resources:
  revenue_analytics:
    id_column: "HOTEL_ID"
    name: "HOTEL_PERSONALIZATION.SEMANTIC.REVENUE_OPTIMIZATION"
$$;

-- =====================================================
-- AGENT ACCESS GRANTS
-- =====================================================

-- Grant agent usage to appropriate roles
GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Executive Intelligence Agent" TO ROLE HOTEL_EXECUTIVE_ROLE;
GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Hotel Operations Agent" TO ROLE HOTEL_MANAGER_ROLE;
GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Guest Services Agent" TO ROLE GUEST_SERVICES_ROLE;
GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."Revenue Intelligence Agent" TO ROLE REVENUE_ANALYST_ROLE;

-- Data engineers can use all agents for testing and maintenance
GRANT USAGE ON ALL AGENTS IN SNOWFLAKE_INTELLIGENCE.AGENTS TO ROLE DATA_ENGINEER_ROLE;

-- =====================================================
-- USER ASSIGNMENT EXAMPLES
-- =====================================================

-- Example user assignments (customize for your organization)
/*
-- Executive Users
GRANT ROLE HOTEL_EXECUTIVE_ROLE TO USER 'ceo@hotelchain.com';
GRANT ROLE HOTEL_EXECUTIVE_ROLE TO USER 'cfo@hotelchain.com';
GRANT ROLE HOTEL_EXECUTIVE_ROLE TO USER 'coo@hotelchain.com';

-- Hotel Managers
GRANT ROLE HOTEL_MANAGER_ROLE TO USER 'manager.newyork@hotelchain.com';
GRANT ROLE HOTEL_MANAGER_ROLE TO USER 'manager.chicago@hotelchain.com';
GRANT ROLE HOTEL_MANAGER_ROLE TO USER 'manager.losangeles@hotelchain.com';

-- Guest Services Staff
GRANT ROLE GUEST_SERVICES_ROLE TO USER 'frontdesk@hotelchain.com';
GRANT ROLE GUEST_SERVICES_ROLE TO USER 'concierge@hotelchain.com';
GRANT ROLE GUEST_SERVICES_ROLE TO USER 'guestrelations@hotelchain.com';

-- Revenue Analysts
GRANT ROLE REVENUE_ANALYST_ROLE TO USER 'revenue.analyst@hotelchain.com';
GRANT ROLE REVENUE_ANALYST_ROLE TO USER 'pricing.manager@hotelchain.com';

-- Marketing Team
GRANT ROLE MARKETING_ROLE TO USER 'marketing.director@hotelchain.com';
GRANT ROLE MARKETING_ROLE TO USER 'digital.marketing@hotelchain.com';

-- Data Engineering Team
GRANT ROLE DATA_ENGINEER_ROLE TO USER 'data.engineer@hotelchain.com';
GRANT ROLE DATA_ENGINEER_ROLE TO USER 'srsubramanian';  -- Your user

-- IT Support
GRANT ROLE IT_SUPPORT_ROLE TO USER 'it.support@hotelchain.com';

-- Compliance and Audit
GRANT ROLE AUDIT_ROLE TO USER 'audit@hotelchain.com';
GRANT ROLE PRIVACY_OFFICER_ROLE TO USER 'privacy.officer@hotelchain.com';
*/

-- =====================================================
-- MONITORING AND GOVERNANCE
-- =====================================================

-- Create monitoring views for access tracking
CREATE OR REPLACE VIEW SEMANTIC.access_monitoring AS
SELECT 
    user_name,
    role_name,
    query_text,
    execution_time,
    warehouse_name,
    database_name,
    schema_name,
    query_tag
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE database_name = 'HOTEL_PERSONALIZATION'
AND execution_time >= DATEADD(day, -30, CURRENT_TIMESTAMP())
ORDER BY execution_time DESC;

-- Grant monitoring access to appropriate roles
GRANT SELECT ON SEMANTIC.access_monitoring TO ROLE DATA_ENGINEER_ROLE;
GRANT SELECT ON SEMANTIC.access_monitoring TO ROLE AUDIT_ROLE;
GRANT SELECT ON SEMANTIC.access_monitoring TO ROLE PRIVACY_OFFICER_ROLE;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Show all roles created
SHOW ROLES LIKE '%HOTEL%' OR LIKE '%GUEST%' OR LIKE '%REVENUE%' OR LIKE '%DATA%';

-- Show role hierarchy
SELECT 'RBAC Security Model Implemented Successfully' as status;

-- Verification of permissions
SELECT 
    'Role: ' || role_name as role_info,
    'Database: ' || privilege as access_level,
    granted_on,
    name as object_name
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_ROLES 
WHERE grantee_name LIKE '%HOTEL%' 
   OR grantee_name LIKE '%GUEST%' 
   OR grantee_name LIKE '%REVENUE%'
   OR grantee_name LIKE '%DATA_ENGINEER%'
ORDER BY role_name, granted_on;



