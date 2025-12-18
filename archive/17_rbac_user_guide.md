# Hotel Personalization System - RBAC Security Model

## 🔐 **Role-Based Access Control Overview**

This comprehensive RBAC system ensures secure, role-appropriate access to hotel personalization data while maintaining privacy compliance and operational efficiency.

---

## 👥 **Role Hierarchy & Access Levels**

### **🏢 Executive Level**
#### **HOTEL_EXECUTIVE_ROLE**
- **Access**: Gold + Semantic layers, Executive warehouse
- **Data Scope**: All properties, strategic metrics
- **AI Agent**: Executive Intelligence Agent
- **Use Cases**: Strategic planning, investment decisions, market analysis
- **Sample Users**: CEO, CFO, COO, VP Operations

### **🏨 Management Level**
#### **HOTEL_MANAGER_ROLE**
- **Access**: Silver + Gold + Semantic layers, Operations warehouse
- **Data Scope**: Property-specific with row-level security
- **AI Agent**: Hotel Operations Agent
- **Use Cases**: Daily operations, guest satisfaction, staff management
- **Sample Users**: Hotel managers, Regional managers, Operations directors

#### **REVENUE_ANALYST_ROLE**
- **Access**: Gold + Semantic layers, Operations warehouse
- **Data Scope**: Revenue metrics, pricing analytics
- **AI Agent**: Revenue Intelligence Agent
- **Use Cases**: Pricing optimization, revenue forecasting, financial analysis
- **Sample Users**: Revenue managers, Pricing analysts, Financial analysts

### **🎯 Operational Level**
#### **GUEST_SERVICES_ROLE**
- **Access**: Semantic layer (privacy-safe views), Guest Services warehouse
- **Data Scope**: Guest preferences with PII masking
- **AI Agent**: Guest Services Agent
- **Use Cases**: Guest personalization, service optimization, upselling
- **Sample Users**: Front desk staff, Concierge, Guest relations

#### **MARKETING_ROLE**
- **Access**: Silver + Gold + Semantic layers, Operations warehouse
- **Data Scope**: Guest segments, preferences, campaign analytics
- **AI Agent**: Marketing Intelligence Agent
- **Use Cases**: Campaign targeting, guest segmentation, loyalty programs
- **Sample Users**: Marketing managers, Digital marketers, CRM specialists

### **🔧 Technical Level**
#### **DATA_ENGINEER_ROLE**
- **Access**: All layers (Bronze + Silver + Gold + Semantic)
- **Data Scope**: Full system access for development/maintenance
- **AI Agent**: All agents for testing
- **Use Cases**: System development, data pipeline management, troubleshooting
- **Sample Users**: Data engineers, Analytics engineers, System architects

#### **IT_SUPPORT_ROLE**
- **Access**: Semantic layer (limited), Compute warehouse
- **Data Scope**: System monitoring, basic troubleshooting
- **AI Agent**: None (system access only)
- **Use Cases**: User support, system monitoring, basic maintenance
- **Sample Users**: IT helpdesk, System administrators

### **📋 Compliance Level**
#### **AUDIT_ROLE**
- **Access**: Read-only access to all layers
- **Data Scope**: Full audit trail, compliance monitoring
- **AI Agent**: None (audit access only)
- **Use Cases**: Compliance auditing, data governance, security monitoring
- **Sample Users**: Internal auditors, Compliance officers, External auditors

#### **PRIVACY_OFFICER_ROLE**
- **Access**: Full read access for privacy compliance
- **Data Scope**: All data including PII for privacy management
- **AI Agent**: None (compliance access only)
- **Use Cases**: Privacy compliance, GDPR management, data protection
- **Sample Users**: Privacy officers, Legal counsel, Data protection officers

---

## 🛡️ **Security Features Implemented**

### **1. Layer-Based Access Control**
```sql
-- Bronze Layer: Raw data - Restricted access
-- Silver Layer: Cleaned data - Analyst access
-- Gold Layer: Business metrics - Management access  
-- Semantic Layer: Business views - All business users
```

### **2. Row-Level Security (RLS)**
- **Hotel managers** see only their property data
- **Guest services** access filtered by current context
- **Regional managers** see multiple properties in their region

### **3. Column-Level Security**
- **Email masking**: Progressive masking based on role
- **Phone masking**: Partial masking for operational roles
- **Name masking**: Privacy protection for analytical roles

### **4. Data Masking Policies**
```sql
-- Executive Role: john.doe@email.com → jo***@email.com
-- Guest Services: john.doe@email.com → ***@***.com
-- Phone Numbers: +1-555-1234 → +1-555-****
```

### **5. Warehouse Segregation**
- **Executive Warehouse**: High-performance for strategic analysis
- **Operations Warehouse**: Medium-performance for daily operations
- **Guest Services Warehouse**: Small-performance for front-line staff

### **6. AI Agent Access Control**
- **Role-specific agents** with appropriate data access
- **Context-aware responses** based on user permissions
- **Privacy-safe interactions** for guest-facing roles

---

## 🚀 **Implementation Guide**

### **Step 1: Deploy RBAC System**
```sql
-- Execute the RBAC security model
source 16_rbac_security_model.sql
```

### **Step 2: Assign Users to Roles**
```sql
-- Example user assignments
GRANT ROLE HOTEL_EXECUTIVE_ROLE TO USER 'ceo@hotelchain.com';
GRANT ROLE HOTEL_MANAGER_ROLE TO USER 'manager.newyork@hotelchain.com';
GRANT ROLE GUEST_SERVICES_ROLE TO USER 'frontdesk@hotelchain.com';
GRANT ROLE REVENUE_ANALYST_ROLE TO USER 'revenue.analyst@hotelchain.com';
GRANT ROLE DATA_ENGINEER_ROLE TO USER 'srsubramanian';
```

### **Step 3: Set Default Roles**
```sql
-- Set appropriate default roles for users
ALTER USER 'manager.newyork@hotelchain.com' SET DEFAULT_ROLE = HOTEL_MANAGER_ROLE;
ALTER USER 'frontdesk@hotelchain.com' SET DEFAULT_ROLE = GUEST_SERVICES_ROLE;
```

### **Step 4: Configure Context Variables**
```sql
-- Set hotel context for property-specific access
ALTER USER 'manager.newyork@hotelchain.com' SET hotel_city = 'New York';
ALTER USER 'manager.chicago@hotelchain.com' SET hotel_city = 'Chicago';
```

---

## 📊 **Access Matrix**

| Role | Bronze | Silver | Gold | Semantic | AI Agents | Warehouse |
|------|--------|--------|------|----------|-----------|-----------|
| **DATA_ENGINEER** | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ All | Executive |
| **HOTEL_EXECUTIVE** | ❌ | ❌ | ✅ Full | ✅ Full | Executive Agent | Executive |
| **HOTEL_MANAGER** | ❌ | ✅ Full | ✅ Full | ✅ Filtered | Operations Agent | Operations |
| **GUEST_SERVICES** | ❌ | ❌ | ❌ | ✅ Masked | Guest Services Agent | Guest Services |
| **REVENUE_ANALYST** | ❌ | ❌ | ✅ Revenue | ✅ Revenue | Revenue Agent | Operations |
| **MARKETING** | ❌ | ✅ Marketing | ✅ Marketing | ✅ Marketing | Marketing Agent | Operations |
| **IT_SUPPORT** | ❌ | ❌ | ❌ | ✅ Limited | ❌ | Compute |
| **AUDIT** | ✅ Read-only | ✅ Read-only | ✅ Read-only | ✅ Read-only | ❌ | Compute |
| **PRIVACY_OFFICER** | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ❌ | Compute |

---

## 🎯 **Role-Specific Use Cases**

### **Hotel Executive Questions**
- "What's our overall guest satisfaction trend across all properties?"
- "Which hotel brands generate the highest revenue per guest?"
- "What's the ROI of our personalization investments?"
- "Show me strategic opportunities for market expansion"

### **Hotel Manager Questions**
- "Which guests checking in today need special attention?"
- "What's my property's satisfaction score compared to last month?"
- "Which staff members need additional training based on guest feedback?"
- "Show me upsell opportunities for this weekend"

### **Guest Services Questions**
- "What are the preferences for the guest in room 205?"
- "Which arriving guests should receive welcome amenities?"
- "What dining recommendations should I make for guests with dietary restrictions?"
- "Show me guests celebrating special occasions today"

### **Revenue Analyst Questions**
- "What's the revenue impact of improving personalization scores?"
- "Which guest segments have the highest profit margins?"
- "How should we price rooms for next month based on demand patterns?"
- "What's the optimal upsell strategy for different guest types?"

---

## 🔍 **Monitoring & Compliance**

### **Access Monitoring**
```sql
-- Monitor user access patterns
SELECT * FROM SEMANTIC.access_monitoring 
WHERE user_name = 'specific_user@hotelchain.com'
ORDER BY execution_time DESC;
```

### **Role Usage Analytics**
```sql
-- Analyze role usage and permissions
SELECT role_name, COUNT(*) as query_count, AVG(execution_time_ms) as avg_time
FROM SEMANTIC.access_monitoring 
GROUP BY role_name
ORDER BY query_count DESC;
```

### **Data Access Audit**
```sql
-- Audit sensitive data access
SELECT user_name, query_text, execution_time
FROM SEMANTIC.access_monitoring 
WHERE query_text ILIKE '%guest_profiles%' 
   OR query_text ILIKE '%email%'
   OR query_text ILIKE '%phone%'
ORDER BY execution_time DESC;
```

---

## 🛠️ **Administration Tasks**

### **Adding New Users**
```sql
-- 1. Create user
CREATE USER 'new.manager@hotelchain.com' 
PASSWORD = 'SecurePassword123!' 
DEFAULT_ROLE = HOTEL_MANAGER_ROLE;

-- 2. Grant role
GRANT ROLE HOTEL_MANAGER_ROLE TO USER 'new.manager@hotelchain.com';

-- 3. Set context (if needed)
ALTER USER 'new.manager@hotelchain.com' SET hotel_city = 'Miami';
```

### **Modifying Permissions**
```sql
-- Grant additional role to existing user
GRANT ROLE REVENUE_ANALYST_ROLE TO USER 'manager.newyork@hotelchain.com';

-- Revoke role from user
REVOKE ROLE GUEST_SERVICES_ROLE FROM USER 'former.employee@hotelchain.com';
```

### **Emergency Access**
```sql
-- Temporarily grant elevated access for troubleshooting
GRANT ROLE DATA_ENGINEER_ROLE TO USER 'manager.newyork@hotelchain.com';

-- Remember to revoke after issue resolution
REVOKE ROLE DATA_ENGINEER_ROLE FROM USER 'manager.newyork@hotelchain.com';
```

---

## 📋 **Compliance Features**

### **GDPR Compliance**
- **Data masking** protects PII in non-essential roles
- **Access logging** tracks all data access for audit trails
- **Role segregation** ensures minimum necessary access
- **Privacy officer role** for data protection oversight

### **SOX Compliance**
- **Segregation of duties** between operational and financial roles
- **Audit trail** for all data access and modifications
- **Read-only audit role** for independent verification
- **Change management** through role-based permissions

### **Industry Standards**
- **PCI DSS**: Payment data protection through access controls
- **HIPAA-style**: Privacy protection for guest personal information
- **ISO 27001**: Information security management through RBAC

---

## 🚨 **Security Best Practices**

### **Password Management**
- Enforce strong password policies
- Require multi-factor authentication for sensitive roles
- Regular password rotation for privileged accounts

### **Access Reviews**
- Quarterly access reviews for all roles
- Annual recertification of user permissions
- Immediate access revocation for terminated employees

### **Monitoring Alerts**
- Alert on unusual access patterns
- Monitor failed authentication attempts
- Track privilege escalation requests

### **Data Classification**
- **Public**: Hotel amenities, general information
- **Internal**: Business metrics, operational data
- **Confidential**: Guest PII, financial data
- **Restricted**: Strategic plans, competitive data

---

## ✅ **Deployment Checklist**

- [ ] Execute RBAC security model SQL script
- [ ] Create user accounts for each role type
- [ ] Assign appropriate roles to users
- [ ] Set default roles and context variables
- [ ] Test access permissions for each role
- [ ] Verify data masking policies work correctly
- [ ] Configure monitoring and alerting
- [ ] Document role assignments and responsibilities
- [ ] Train users on their specific access levels
- [ ] Establish access review procedures

This comprehensive RBAC system ensures that your hotel personalization platform maintains the highest security standards while enabling role-appropriate access to drive business value!



