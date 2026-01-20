"""
KPI Definitions for Hotel Intelligence Hub
Provides tooltip text and help documentation for all metrics
"""

KPI_DEFINITIONS = {
    # =========================================================================
    # Portfolio Overview KPIs
    # =========================================================================
    "occupancy": "Percentage of available rooms occupied. Calculated as: (Total Occupied Rooms / Total Available Rooms) × 100. Industry benchmark: 65-75%",
    
    "adr": "Average Daily Rate - Average revenue per occupied room per day. Calculated as: Total Room Revenue / Number of Rooms Sold. Higher ADR indicates premium positioning.",
    
    "revpar": "Revenue Per Available Room - Key performance metric combining occupancy and pricing. Calculated as: ADR × Occupancy Rate OR Total Room Revenue / Total Available Rooms. Primary metric for hotel performance.",
    
    "repeat_stay_rate": "Percentage of guests who have stayed more than once. Calculated as: (Guests with >1 Stay / Total Guests) × 100. Higher rates indicate strong loyalty.",
    
    "satisfaction_index": "Average guest satisfaction score across all stays (1-5 scale). Based on post-stay surveys and feedback. Target: 4.0+",
    
    "personalization_coverage": "Percentage of stays where we have guest preference or behavior data. Calculated as: (Stays with Known Preferences / Total Stays) × 100. Higher coverage enables better personalization.",
    
    "service_case_rate": "Number of service incidents per 1,000 stays. Calculated as: (Total Service Cases / Total Stays) × 1,000. Lower is better. Industry benchmark: 50-100 cases per 1,000 stays.",
    
    "net_sentiment_score": "Average sentiment from reviews and feedback (-100 to +100 scale). Positive scores indicate favorable sentiment. Target: >40",
    
    # =========================================================================
    # Loyalty Intelligence KPIs
    # =========================================================================
    "active_loyalty_members": "Number of loyalty members with at least one stay in the period. Measures program engagement.",
    
    "repeat_rate_by_tier": "Percentage of guests in each loyalty tier who returned for additional stays. Key retention metric by tier.",
    
    "loyalty_redemption_rate": "Percentage of bookings where loyalty points were redeemed. Calculated as: (Redemption Bookings / Total Bookings) × 100. Measures program value perception.",
    
    "high_value_guest_share": "Percentage of total revenue from guests with $10K+ lifetime value. Shows concentration of revenue among top guests. Typical range: 20-40%",
    
    "churn_risk_guests": "Count of guests flagged as at-risk based on declining activity, sentiment, or recency of stays. Requires proactive retention efforts.",
    
    # =========================================================================
    # CX Service Signals KPIs
    # =========================================================================
    "avg_resolution_time": "Average time (in hours) to resolve service cases. Lower is better. Target varies by severity: Critical <4h, High <2h, Medium <1h, Low <30min.",
    
    "negative_sentiment_rate": "Percentage of feedback with negative sentiment (score < -20). Calculated as: (Negative Feedback / Total Feedback) × 100. Target: <5%",
    
    "service_recovery_success": "Percentage of service recovery attempts accepted by guests. Measures effectiveness of recovery efforts. Target: >70% for VIPs, >60% overall.",
    
    "at_risk_high_value_guests": "Count of high-value guests ($10K+ LTV) with recent negative sentiment or service issues. Priority for retention efforts.",
    
    "vip_watchlist_count": "Number of Diamond/Platinum guests with 2+ service cases in last 90 days. Requires immediate attention.",
    
    # =========================================================================
    # Segment & Table Column Metrics
    # =========================================================================
    "avg_spend_per_stay": "Average total spend per stay including room, amenities, and services. Indicates guest value and upsell effectiveness.",
    
    "top_friction_driver": "Most common service issue category for this segment (billing, room readiness, noise, etc.). Focus area for operational improvement.",
    
    "recommended_focus": "Strategic recommendation based on segment behavior: Retention (low repeat rate), Upsell (low spend), or Engagement (optimization).",
    
    "experience_affinity": "Primary amenity/service preference for this segment based on usage patterns (Dining, Wellness, Convenience, etc.).",
    
    "underutilized_opportunity": "Service or amenity with high appeal but low current penetration in this segment. Revenue growth opportunity.",
    
    "revenue_mix": "Breakdown of revenue sources: Room (base charges), F&B (dining), Spa (wellness), Other (parking, business services).",
    
    "churn_risk_score": "Predictive score (0-100) indicating likelihood of guest not returning. Based on recency, frequency, sentiment, and service history.",
    
    "preference_coverage": "Extent of known guest preferences (Low/Medium/High). More data enables better personalization.",
    
    "at_risk_arrivals": "Number of future check-ins (next 7 days) for guests with past service issues or negative sentiment. Enables proactive service.",
    
    "issue_impact": "Average impact on guest satisfaction (1-5 scale) for this issue category. Higher scores require urgent attention.",
    
    "recurring_issue_flag": "Indicates if this issue has occurred multiple times. Suggests systemic problem requiring root cause analysis.",
    
    "recovery_value": "Monetary value of recovery action (points credit, room upgrade, discount, etc.). Shows investment in retention.",
    
    "satisfaction_delta": "Change in satisfaction before and after service recovery. Positive delta shows recovery effectiveness.",
}

def get_kpi_help(kpi_key: str) -> str:
    """
    Get help text for a KPI by key
    
    Args:
        kpi_key: The key for the KPI (e.g., 'occupancy', 'adr')
    
    Returns:
        Help text string, or a default message if key not found
    """
    return KPI_DEFINITIONS.get(kpi_key, "No definition available for this metric.")

def get_all_kpis() -> dict:
    """Return all KPI definitions"""
    return KPI_DEFINITIONS.copy()
