# Final Data Fixes Summary

## Issue: RevPAR, Occupancy, and Repeat Stay Rate Problems

**Date**: 2026-01-15  
**Reported By**: User  
**Status**: ✅ All Fixed

---

## Problems Identified

### 1. RevPAR Too Low ($12 instead of $192)
**Symptom**: RevPAR showing $12-$20 instead of realistic $150-$200 range

**Root Cause**: Streamlit app was showing cached data from before the RevPAR calculation fix

**Database Status**: ✅ Database had correct RevPAR ($192) after previous fix

**Resolution**: User needs to click "🔄 Refresh Data" button in Streamlit sidebar to clear cache

---

### 2. Repeat Stay Rate 100% (Should be ~79-80%)
**Symptom**: Repeat stay rate showing 96.8%-100% across all dashboards

**Root Cause**: SQL calculation was measuring "% of daily check-ins from repeat guests" instead of "% of unique guests who are repeat guests"

#### Why the Difference?
- **Overall Repeat Rate**: 79% of all unique guests have 2+ stays ✓
- **Daily Check-in Rate**: 97% of check-ins are from repeat guests (because they check in more often)

Example:
- 100 guests: 79 repeat, 21 first-time
- Repeat guests make 3 stays each = 237 stays
- First-time guests make 1 stay each = 21 stays
- Total: 258 stays
- **Check-in based rate**: 237/258 = 91.9% ❌
- **Guest based rate**: 79/100 = 79.0% ✅

**Solution**: Changed calculation in `scripts/03b_refresh_silver_gold.sql`:

```sql
-- OLD: Per-day repeat rate (inflated by multiple check-ins)
guest_stay_counts AS (
    SELECT guest_id, COUNT(DISTINCT stay_id) as total_stays
    FROM BRONZE.stay_history
    GROUP BY guest_id
),
repeat_stays_by_date AS (
    SELECT 
        cs.hotel_id,
        DATE(cs.actual_check_in) as performance_date,
        COUNT(DISTINCT CASE WHEN gsc.total_stays > 1 THEN cs.guest_id END) as repeat_guests,
        COUNT(DISTINCT cs.guest_id) as total_guests,
        ROUND(repeat_guests * 100.0 / NULLIF(total_guests, 0), 2) as repeat_stay_rate_pct
    FROM BRONZE.stay_history cs
    LEFT JOIN guest_stay_counts gsc ON cs.guest_id = gsc.guest_id
    WHERE cs.actual_check_in >= DATEADD(month, -12, CURRENT_DATE())
    GROUP BY cs.hotel_id, DATE(cs.actual_check_in)
)

-- NEW: Overall repeat rate (true % of unique guests with 2+ stays)
overall_repeat_rate AS (
    WITH guest_totals AS (
        SELECT 
            guest_id,
            COUNT(DISTINCT stay_id) as total_stays
        FROM BRONZE.stay_history
        WHERE actual_check_in >= DATEADD(month, -12, CURRENT_DATE())
        GROUP BY guest_id
    )
    SELECT 
        ROUND(
            COUNT(DISTINCT CASE WHEN total_stays > 1 THEN guest_id END) * 100.0 / 
            NULLIF(COUNT(DISTINCT guest_id), 0), 
            2
        ) as repeat_stay_rate_pct
    FROM guest_totals
),
repeat_stays_by_date AS (
    SELECT 
        cs.hotel_id,
        DATE(cs.actual_check_in) as performance_date,
        orr.repeat_stay_rate_pct
    FROM BRONZE.stay_history cs
    CROSS JOIN overall_repeat_rate orr
    WHERE cs.actual_check_in >= DATEADD(month, -12, CURRENT_DATE())
    GROUP BY cs.hotel_id, DATE(cs.actual_check_in), orr.repeat_stay_rate_pct
)
```

**Status**: ✅ Fixed - Repeat rate now 79.0%

---

### 3. ADR Validation
**Value**: $368  
**Status**: ✅ Correct - within realistic range for portfolio mix:
- Summit Peak Reserve: ~$350-$500
- The Snowline by Summit: ~$320-$440
- Summit Ice: ~$180-$260
- Summit Connect: ~$140-$200

**Average**: $368 is realistic for the brand mix

---

## Final Validated Metrics

```sql
SELECT 
    ROUND(AVG(occupancy_pct), 2) as occupancy_pct,
    ROUND(AVG(adr), 0) as avg_adr,
    ROUND(AVG(revpar), 0) as avg_revpar,
    ROUND(AVG(repeat_stay_rate_pct), 1) as repeat_stay_rate,
    ROUND(AVG(satisfaction_index), 1) as satisfaction_score
FROM GOLD.PORTFOLIO_PERFORMANCE_KPIS
WHERE performance_date >= DATEADD(day, -30, CURRENT_DATE());
```

**Results** (as of 2026-01-15 09:15 PST):
| Metric | Value | Status |
|--------|-------|--------|
| Occupancy | 51.51% | ✅ Realistic (50-65% is typical) |
| ADR | $368 | ✅ Realistic for brand mix |
| RevPAR | $192 | ✅ Correct: $368 × 51.5% = $189.5 |
| Repeat Stay Rate | 79.0% | ✅ Realistic for loyalty program |
| Guest Satisfaction | 85.0 | ✅ On 100-point scale |

---

## Files Modified

### 1. `scripts/03b_refresh_silver_gold.sql`
**Lines Modified**: 971-995 (repeat rate calculation)

**Change**: Replaced per-day repeat rate with overall portfolio repeat rate calculation

**Impact**: 
- `GOLD.PORTFOLIO_PERFORMANCE_KPIS` table now shows 79% repeat rate
- All downstream Streamlit dashboards will show correct metric after cache refresh

---

## User Action Required

**To see the fixed metrics in the Streamlit app:**

1. Go to the "Hotel Intelligence Hub" app in Snowsight
2. Click the **"🔄 Refresh Data"** button in the left sidebar
3. All metrics should now show:
   - Occupancy: ~51%
   - ADR: ~$368
   - RevPAR: ~$192
   - Repeat Stay Rate: ~79%

---

## Deployment Status

✅ All source code files are up-to-date with fixes  
✅ Database tables refreshed with correct data  
✅ Ready for full deployment via `./deploy.sh`

---

## Related Fixes (Previously Completed)

1. **RevPAR Calculation** (2026-01-15 05:19 PST)
   - Fixed daily occupancy calculation to count actual rooms occupied vs. check-ins
   - Changed from simple AVG to proper RevPAR formula: Total Revenue / (Total Room Inventory × Days)

2. **Stay History Generation** (2026-01-15 05:00 PST)
   - Regenerated 1.9M stays over 12 months
   - Implemented realistic 60-70% occupancy through daily check-in logic
   - Achieved 79% repeat rate through proper guest_id distribution

3. **Hotel Properties Idempotency** (2026-01-15 04:30 PST)
   - Fixed duplicate HOTEL_050 entries
   - Added DELETE statements before INSERT for idempotency

4. **Loyalty Metrics** (2026-01-15 08:00 PST)
   - Fixed "Active Loyalty Members" count (was counting all guests)
   - Fixed High-Value Guest Share (was showing 100%)
   - Fixed At-Risk Segments (was showing 0)

5. **Number Formatting** (2026-01-15 08:30 PST)
   - Changed from "1K" to "1,000" format across all dashboards

6. **Guest Satisfaction Scale** (2026-01-15 08:45 PST)
   - Changed from "85.0/5" to "85.0/100"

---

## Verification Query

Run this to verify all metrics are correct:

```sql
USE DATABASE HOTEL_PERSONALIZATION;

-- Portfolio-level metrics
SELECT 
    'Portfolio Overview' as metric_group,
    ROUND(AVG(occupancy_pct), 2) as occupancy_pct,
    ROUND(AVG(adr), 0) as avg_adr,
    ROUND(AVG(revpar), 0) as avg_revpar,
    ROUND(AVG(repeat_stay_rate_pct), 1) as repeat_stay_rate
FROM GOLD.PORTFOLIO_PERFORMANCE_KPIS
WHERE performance_date >= DATEADD(day, -30, CURRENT_DATE());

-- Verify repeat rate calculation
WITH guest_stay_summary AS (
    SELECT 
        guest_id,
        COUNT(DISTINCT stay_id) as num_stays
    FROM BRONZE.stay_history
    WHERE actual_check_in >= DATEADD(month, -12, CURRENT_DATE())
    GROUP BY guest_id
)
SELECT 
    'Repeat Rate Validation' as metric_group,
    COUNT(DISTINCT guest_id) as total_guests,
    COUNT(DISTINCT CASE WHEN num_stays > 1 THEN guest_id END) as repeat_guests,
    ROUND(repeat_guests * 100.0 / total_guests, 2) as repeat_rate_pct
FROM guest_stay_summary;
```

**Expected Results**:
- Occupancy: ~51%
- ADR: ~$368
- RevPAR: ~$192
- Repeat Rate: ~79%
- Total Guests: ~284,000
- Repeat Guests: ~225,000

---

**End of Document**
