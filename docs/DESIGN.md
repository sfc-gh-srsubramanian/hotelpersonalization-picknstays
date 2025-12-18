# Hotel Guest Personalization System - Design Document

## Overview
This system creates a hyper-personalized experience for hotel guests by analyzing past stays, preferences, booking behavior, and social media activity to deliver tailored experiences.

## Medallion Architecture

### Bronze Layer (Raw Data)
- **guest_profiles**: Basic guest information
- **booking_history**: All booking transactions
- **stay_history**: Detailed stay records
- **room_preferences**: Guest room preferences
- **service_preferences**: Dining, spa, amenities preferences
- **social_media_activity**: Guest social media interactions
- **loyalty_program**: Loyalty tier and points data
- **feedback_reviews**: Guest reviews and ratings
- **payment_methods**: Guest payment preferences
- **special_requests**: Custom requests and accommodations

### Silver Layer (Cleaned & Standardized)
- **guests_standardized**: Cleaned guest profiles
- **bookings_enriched**: Enhanced booking data with derived fields
- **stays_processed**: Processed stay data with metrics
- **preferences_consolidated**: Unified preference profiles
- **engagement_metrics**: Social media engagement analytics
- **satisfaction_scores**: Processed feedback metrics

### Gold Layer (Analytics Ready)
- **guest_360_view**: Complete guest profile aggregation
- **personalization_scores**: ML-ready personalization metrics
- **recommendation_features**: Features for recommendation engine
- **business_metrics**: KPIs and business analytics
- **predictive_features**: Features for predictive modeling

## Use Cases
1. **Pre-Arrival Room Setup**: Auto-configure room temperature, lighting, amenities
2. **Personalized Upsells**: Targeted offers based on preferences and history
3. **Custom Recommendations**: Dining, activities, and services recommendations
4. **Dynamic Pricing**: Personalized pricing based on loyalty and behavior
5. **Proactive Service**: Anticipate needs based on past patterns

## Database Structure
- Database: `HOTEL_PERSONALIZATION`
- Schemas: `BRONZE`, `SILVER`, `GOLD`, `SEMANTIC`

