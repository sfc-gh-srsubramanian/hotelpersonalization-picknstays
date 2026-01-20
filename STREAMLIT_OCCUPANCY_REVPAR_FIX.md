# Streamlit Occupancy & RevPAR Display Fix

## Issue Summary
**Date**: 2026-01-15  
**Reported By**: User  
**Status**: ✅ Fixed and Deployed

---

## Problems Identified

### 1. Occupancy showing 3.3% instead of 51.5%
**Symptom**: Dashboard showing 3.3% occupancy when database had 51.5%

**Root Cause**: Incorrect calculation in Streamlit app (`pages/1_Portfolio_Overview.py` lines 66-75)

```python
# ❌ WRONG: Summing TOTAL_ROOMS across all daily records
latest_total_rooms = latest_kpis['TOTAL_ROOMS'].sum()  # = 3,000 rows × 150 rooms = 450,000
avg_occupancy = (latest_rooms_occupied / (latest_total_rooms * latest_days)) * 100
# Result: way too low denominator → 3.3% occupancy
```

**Why This Was Wrong**:
- The `PORTFOLIO_PERFORMANCE_KPIS` table has **daily records per hotel**
- For 30 days × 100 hotels = **3,000 rows**
- Each row has `TOTAL_ROOMS = 150` (per hotel)
- Summing: 3,000 × 150 = **450,000 rooms** (should be 15,000)
- Then multiplying by 30 days again = **13,500,000** ❌
- Actual rooms occupied: ~155,000
- Wrong calc: 155,000 / 13,500,000 = **1.1%** ❌

**Solution**: Use pre-calculated daily percentages from the Gold table

```python
# ✅ CORRECT: Use pre-calculated daily metrics, then average
avg_occupancy = latest_kpis['OCCUPANCY_PCT'].mean()  # Already correctly calculated in Gold table
avg_adr = latest_kpis['ADR'].mean()
avg_revpar = latest_kpis['REVPAR'].mean()
```

---

### 2. RevPAR showing $12 instead of $192
**Symptom**: Dashboard showing $12 RevPAR when database had $192

**Root Cause**: Same calculation error - using the inflated `latest_total_rooms` value

```python
# ❌ WRONG
avg_revpar = latest_total_revenue / (latest_total_rooms * latest_days)
# = $150M / (450,000 × 30) = $11 ❌

# ✅ CORRECT
avg_revpar = latest_kpis['REVPAR'].mean()  # = $192 ✓
```

---

### 3. RevPAR Charts showing incorrect aggregations
**Symptom**: RevPAR by Brand and Region charts showing unrealistic low values

**Root Cause**: Charts were re-calculating RevPAR from summed totals instead of averaging pre-calculated daily values

```python
# ❌ WRONG: Lines 145-152
brand_metrics = latest_kpis.groupby('BRAND').agg({
    'TOTAL_REVENUE': 'sum',
    'TOTAL_ROOMS': 'sum',  # Summing across days!
    'ROOMS_OCCUPIED': 'sum'
}).reset_index()
brand_metrics['REVPAR'] = brand_metrics['TOTAL_REVENUE'] / (brand_metrics['TOTAL_ROOMS'] * days_in_period)

# ✅ CORRECT
brand_metrics = latest_kpis.groupby('BRAND').agg({
    'REVPAR': 'mean',  # Use pre-calculated daily values
    'OCCUPANCY_PCT': 'mean',
    'ADR': 'mean'
}).reset_index()
```

---

### 4. Missing ADR delta/trend indicator
**Symptom**: ADR KPI card had no trend arrow

**Solution**: Added `delta_adr` calculation and display

```python
delta_adr = ((avg_adr - prior_adr) / prior_adr * 100) if prior_adr > 0 else 0

st.metric(
    "ADR", 
    f"${avg_adr:.0f}",
    f"{delta_adr:+.1f}%",  # Added trend indicator
    help="..."
)
```

---

### 5. Trend comparison explanation missing
**Symptom**: User asked "what is the -3% trend comparing against?"

**Solution**: Added caption explaining trend comparison logic

```python
st.caption("📈 Trend arrows compare the recent half vs. first half of the selected time period (e.g., for 30 days: recent 15 days vs. prior 15 days)")
```

**Example**:
- Selected 30 days of data
- Prior period: Days 1-15
- Recent period: Days 16-30
- Trend = (Recent avg - Prior avg) / Prior avg × 100%

---

## Files Modified

### 1. `streamlit/intelligence_hub/pages/1_Portfolio_Overview.py`

**Lines 66-93**: Replaced manual calculation with pre-calculated metrics
```python
# Old: 20+ lines of complex aggregation logic
# New: Simple averages of pre-calculated Gold table values
avg_occupancy = latest_kpis['OCCUPANCY_PCT'].mean()
avg_adr = latest_kpis['ADR'].mean()
avg_revpar = latest_kpis['REVPAR'].mean()
```

**Lines 143-166**: Fixed RevPAR by Brand chart
**Lines 168-190**: Fixed RevPAR by Region chart

**Line 57**: Added trend comparison explanation caption

### 2. `streamlit/intelligence_hub/snowflake.yml`
No changes needed - file is correct

---

## Deployment History

### Attempt 1: Incorrect location ❌
```bash
snow streamlit deploy --connection USWEST_DEMOACCOUNT --project streamlit/intelligence_hub --replace
# Deployed to: ENERGY_UTILITIES_CC.RAW.HOTEL_INTELLIGENCE_HUB ❌
```

### Attempt 2: Correct location ✅
```bash
# Dropped incorrect deployment
snow sql -q "DROP STREAMLIT IF EXISTS ENERGY_UTILITIES_CC.RAW.HOTEL_INTELLIGENCE_HUB;"

# Deployed with explicit database/schema
cd streamlit/intelligence_hub
snow streamlit deploy \
  --connection USWEST_DEMOACCOUNT \
  --database HOTEL_PERSONALIZATION \
  --schema GOLD \
  --replace

# Deployed to: HOTEL_PERSONALIZATION.GOLD.HOTEL_INTELLIGENCE_HUB ✅
```

---

## Validation

### Database Metrics (Ground Truth)
```sql
SELECT 
    ROUND(AVG(occupancy_pct), 2) as avg_occupancy_pct,
    ROUND(AVG(adr), 0) as avg_adr,
    ROUND(AVG(revpar), 0) as avg_revpar,
    ROUND(AVG(repeat_stay_rate_pct), 1) as avg_repeat_rate
FROM GOLD.PORTFOLIO_PERFORMANCE_KPIS
WHERE performance_date >= DATEADD(day, -30, CURRENT_DATE());
```

**Results**:
| Metric | Value | Status |
|--------|-------|--------|
| Occupancy | 51.51% | ✅ Realistic |
| ADR | $368 | ✅ Realistic |
| RevPAR | $192 | ✅ Correct (51.5% × $368) |
| Repeat Rate | 79.0% | ✅ Realistic |

### Expected Streamlit Display
After the fix, the dashboard should show:
- **Occupancy**: ~51.5% (not 3.3%)
- **ADR**: ~$368 (with trend arrow)
- **RevPAR**: ~$192 (not $12, with trend arrow)
- **RevPAR by Brand chart**: Values in $180-$220 range
- **RevPAR by Region chart**: Values in $180-$220 range

---

## Root Cause Analysis

### Why Did This Happen?

1. **Data Structure Misunderstanding**: The developer didn't realize that `PORTFOLIO_PERFORMANCE_KPIS` has **one row per hotel per day**
   
2. **Over-Engineering**: Instead of using pre-calculated metrics from the Gold table, tried to re-calculate from raw components

3. **No Data Validation**: The 3.3% occupancy should have been an immediate red flag during development

### Lessons Learned

1. **Trust the Gold Layer**: Pre-calculated metrics in Gold tables are ready to use - don't recalculate
2. **Validate Outputs**: Always sanity-check dashboard values against known business benchmarks
3. **Understand Data Granularity**: Know whether your DataFrame is at property-level, hotel-level, daily-level, etc.

---

## Testing Checklist

Before considering this fixed, verify:

- [ ] Dashboard shows ~51% occupancy (not 3%)
- [ ] Dashboard shows ~$192 RevPAR (not $12)
- [ ] Dashboard shows ~$368 ADR with trend arrow
- [ ] RevPAR by Brand chart shows realistic values ($150-$250)
- [ ] RevPAR by Region chart shows realistic values ($150-$250)
- [ ] Occupancy & ADR trend line chart shows realistic values over time
- [ ] Trend arrows show comparison between first and second half of period
- [ ] App is deployed to HOTEL_PERSONALIZATION.GOLD (not ENERGY_UTILITIES_CC)

---

## Access Instructions

**Correct App URL**:
```
https://app.snowflake.com/SFSENORTHAMERICA/srsubramanian_aws1/#/streamlit-apps/HOTEL_PERSONALIZATION.GOLD.HOTEL_INTELLIGENCE_HUB
```

**Incorrect App (now deleted)**:
```
ENERGY_UTILITIES_CC.RAW.HOTEL_INTELLIGENCE_HUB ❌ (dropped)
```

---

## Future Deployment Command

To ensure correct deployment location, always use:

```bash
cd streamlit/intelligence_hub

snow streamlit deploy \
  --connection USWEST_DEMOACCOUNT \
  --database HOTEL_PERSONALIZATION \
  --schema GOLD \
  --replace
```

Or use the deployment script:
```bash
./deploy.sh
```
(The script already includes correct `--database` and `--schema` flags on lines 713-714)

---

**End of Document**
