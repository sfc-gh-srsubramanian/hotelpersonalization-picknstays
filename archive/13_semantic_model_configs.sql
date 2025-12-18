-- Hotel Personalization System - Semantic Model Configurations
-- Creates the semantic model files for Snowflake Intelligence Agents

USE DATABASE HOTEL_PERSONALIZATION;
USE SCHEMA SEMANTIC;

-- =====================================================
-- CREATE STAGES FOR SEMANTIC MODEL FILES
-- =====================================================

-- Create stage for semantic model files
CREATE OR REPLACE STAGE GUEST_ANALYTICS_MODEL_STAGE
COMMENT = 'Stage for guest analytics semantic model configuration';

CREATE OR REPLACE STAGE PERSONALIZATION_MODEL_STAGE
COMMENT = 'Stage for personalization semantic model configuration';

CREATE OR REPLACE STAGE REVENUE_MODEL_STAGE
COMMENT = 'Stage for revenue optimization semantic model configuration';

CREATE OR REPLACE STAGE EXPERIENCE_MODEL_STAGE
COMMENT = 'Stage for guest experience semantic model configuration';

-- =====================================================
-- GUEST ANALYTICS SEMANTIC MODEL YAML
-- =====================================================

-- Create guest analytics semantic model YAML content
CREATE OR REPLACE FILE FORMAT yaml_format
TYPE = 'CSV'
FIELD_DELIMITER = NONE
RECORD_DELIMITER = NONE
SKIP_HEADER = 0;

-- Guest Analytics Model Configuration
PUT file:///tmp/guest_analytics.yaml @GUEST_ANALYTICS_MODEL_STAGE;

-- Note: In practice, you would create YAML files like this:
/*
guest_analytics.yaml content:

semantic_model:
  name: "guest_analytics"
  description: "Comprehensive guest behavior and analytics model"
  
  tables:
    - name: "guest_analytics"
      base_table: "HOTEL_PERSONALIZATION.SEMANTIC.guest_analytics"
      description: "Main guest analytics view with comprehensive metrics"
      
  dimensions:
    - name: "guest_name"
      type: "text"
      description: "Full name of the guest"
      synonyms: ["customer name", "full name", "guest full name"]
      
    - name: "guest_segment" 
      type: "text"
      description: "Customer segmentation category"
      synonyms: ["customer category", "guest category", "segment"]
      
    - name: "loyalty_tier"
      type: "text" 
      description: "Guest loyalty program tier"
      synonyms: ["loyalty level", "tier level", "membership tier"]
      
    - name: "generation"
      type: "text"
      description: "Generational demographic of guest"
      synonyms: ["age group", "demographic group"]
      
  measures:
    - name: "total_revenue"
      type: "sum"
      description: "Total lifetime revenue from guest"
      format: "currency"
      
    - name: "average_satisfaction"
      type: "average"
      description: "Average satisfaction score across all stays"
      format: "decimal"
      
    - name: "booking_count"
      type: "count"
      description: "Total number of bookings"
      
  filters:
    - name: "high_value_guests"
      expression: "total_revenue > 5000"
      description: "Guests with lifetime value over $5000"
      
    - name: "vip_tiers"
      expression: "loyalty_tier IN ('Diamond', 'Gold')"
      description: "VIP loyalty tier guests"
*/

-- =====================================================
-- PERSONALIZATION SEMANTIC MODEL YAML  
-- =====================================================

-- Personalization Model Configuration
/*
personalization.yaml content:

semantic_model:
  name: "personalization_insights"
  description: "Guest personalization and recommendation model"
  
  tables:
    - name: "personalization_insights"
      base_table: "HOTEL_PERSONALIZATION.SEMANTIC.personalization_insights"
      description: "Personalization scores and guest preferences"
      
  dimensions:
    - name: "customer_segment"
      type: "text"
      description: "Customer segmentation category"
      synonyms: ["guest segment", "customer category"]
      
    - name: "room_preference"
      type: "text"
      description: "Guest preferred room type"
      synonyms: ["preferred room type", "room category preference"]
      
    - name: "engagement_level"
      type: "text"
      description: "Level of social media engagement"
      synonyms: ["social activity level", "digital engagement"]
      
  measures:
    - name: "personalization_readiness_score"
      type: "average"
      description: "Score indicating readiness for personalization (0-100)"
      format: "decimal"
      
    - name: "upsell_propensity_score"
      type: "average"
      description: "Propensity to purchase upsells (0-100)"
      format: "decimal"
      
    - name: "preference_completeness"
      type: "average"
      description: "Completeness of guest preferences"
      format: "decimal"
      
  filters:
    - name: "high_personalization_ready"
      expression: "personalization_readiness_score >= 70"
      description: "Guests ready for advanced personalization"
      
    - name: "high_upsell_potential"
      expression: "upsell_propensity_score >= 70"
      description: "Guests with high upsell potential"
*/

-- =====================================================
-- REVENUE OPTIMIZATION SEMANTIC MODEL YAML
-- =====================================================

-- Revenue Optimization Model Configuration  
/*
revenue_optimization.yaml content:

semantic_model:
  name: "revenue_optimization"
  description: "Revenue optimization and business performance model"
  
  tables:
    - name: "revenue_optimization"
      base_table: "HOTEL_PERSONALIZATION.SEMANTIC.revenue_optimization"
      description: "Business metrics and revenue analytics"
      
  dimensions:
    - name: "metric_month"
      type: "date"
      description: "Month for which metrics are calculated"
      synonyms: ["month", "reporting month", "period"]
      
    - name: "hotel_name"
      type: "text"
      description: "Name of the hotel property"
      synonyms: ["property name", "hotel property"]
      
    - name: "brand_name"
      type: "text"
      description: "Hotel brand or chain"
      synonyms: ["hotel brand", "chain"]
      
  measures:
    - name: "monthly_revenue"
      type: "sum"
      description: "Total revenue for the month"
      format: "currency"
      
    - name: "revenue_per_guest"
      type: "average"
      description: "Revenue per unique guest"
      format: "currency"
      
    - name: "satisfaction_rate"
      type: "average"
      description: "Guest satisfaction rate percentage"
      format: "percentage"
      
  filters:
    - name: "recent_months"
      expression: "metric_month >= DATEADD(month, -6, CURRENT_DATE())"
      description: "Last 6 months of data"
      
    - name: "high_performing_hotels"
      expression: "satisfaction_rate >= 80 AND revenue_per_guest >= 500"
      description: "Hotels with high satisfaction and revenue"
*/

-- =====================================================
-- GUEST EXPERIENCE SEMANTIC MODEL YAML
-- =====================================================

-- Guest Experience Model Configuration
/*
guest_experience.yaml content:

semantic_model:
  name: "guest_experience"
  description: "Guest satisfaction and experience optimization model"
  
  tables:
    - name: "guest_analytics"
      base_table: "HOTEL_PERSONALIZATION.SEMANTIC.guest_analytics"
      description: "Guest analytics with satisfaction metrics"
      
  dimensions:
    - name: "satisfaction_category"
      type: "text"
      description: "Categorized satisfaction level"
      synonyms: ["satisfaction level", "experience rating"]
      
    - name: "churn_risk"
      type: "text"
      description: "Guest churn risk assessment"
      synonyms: ["retention risk", "churn probability"]
      
  measures:
    - name: "satisfaction_score"
      type: "average"
      description: "Average guest satisfaction score"
      format: "decimal"
      
    - name: "service_issue_rate"
      type: "average"
      description: "Rate of service issues per stay"
      format: "percentage"
      
  filters:
    - name: "at_risk_guests"
      expression: "churn_risk IN ('High Risk', 'Medium Risk')"
      description: "Guests at risk of churning"
      
    - name: "high_satisfaction"
      expression: "satisfaction_score >= 4.5"
      description: "Highly satisfied guests"
*/

-- =====================================================
-- VERIFICATION AND INSTRUCTIONS
-- =====================================================

SELECT 'Semantic model configurations prepared' as status;

-- Instructions for completing the setup:
SELECT '
NEXT STEPS:
1. Create the YAML files manually with the content shown in comments above
2. Upload them to the respective stages using PUT commands
3. Update the agent definitions to reference the correct stage paths
4. Test the agents with natural language queries

Example PUT commands:
PUT file://path/to/guest_analytics.yaml @GUEST_ANALYTICS_MODEL_STAGE;
PUT file://path/to/personalization.yaml @PERSONALIZATION_MODEL_STAGE;
PUT file://path/to/revenue_optimization.yaml @REVENUE_MODEL_STAGE;
PUT file://path/to/guest_experience.yaml @EXPERIENCE_MODEL_STAGE;
' as instructions;



