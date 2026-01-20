# Loyalty & Regional Data Realism Fixes

## Issues Fixed

### 1. ❌ **Unrealistic 100% Repeat Rates for Loyalty Tiers**
**Problem:** Diamond, Gold, and Silver members showed 100% repeat rates with 0% at-risk guests.

**Root Cause:** Probabilistic guest assignment logic couldn't guarantee specific repeat rates. With 1.9M stays and 100K guests (~19 stays/guest average), even "one-timer" guest IDs were randomly selected multiple times, making them repeaters.

**Solution:** Implemented **DETERMINISTIC** repeat rate logic in `scripts/03_data_generation.sql`:

```sql
-- NEW APPROACH: Split each tier's stays into TWO pools
-- Pool A: First X% of stays → UNIQUE one-time guests (each gets exactly 1 stay)
-- Pool B: Remaining stays → Repeater guests (cycle through smaller pool)

tier_assignment AS (
    -- Assign tier based on stay distribution
    SELECT *, 
        CASE 
            WHEN UNIFORM(0, 100, RANDOM()) < 18 THEN 'Diamond'
            WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 'Gold'
            ...
        END as tier
),
tier_stay_sequence AS (
    -- Number stays sequentially WITHIN each tier
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY tier ORDER BY global_stay_num) as tier_stay_num,
        COUNT(*) OVER (PARTITION BY tier) as tier_total_stays
),
stay_with_guest AS (
    -- Deterministically assign guest_id based on position within tier
    CASE 
        WHEN tier = 'Diamond' THEN
            CASE 
                -- First 25% of Diamond stays → 1250 unique one-timers
                WHEN tier_stay_num <= ROUND(tier_total_stays * 0.25)
                THEN 'GUEST_' || LPAD((0 + tier_stay_num - 1)::VARCHAR, 6, '0')
                -- Remaining 75% → Cycle through 3750 repeaters
                ELSE 'GUEST_' || LPAD((1250 + ((tier_stay_num - ...) % 3750))::VARCHAR, 6, '0')
            END
        ...
    END
)
```

**Results:**
| Tier | Target Repeat Rate | At-Risk Rate |
|------|-------------------|--------------|
| Diamond | 75% | 25% |
| Gold | 60% | 40% |
| Silver | 50% | 50% |
| Blue | 40% | 60% |
| Non-Member | 20% | 80% |

**Industry Benchmarks:**
- Overall Repeat Rate: 40-60% (industry average)
- Luxury Hotels: 25-30% repeat bookings
- Major Chains with Strong Loyalty: Up to 60%
- Business Hotels: 40-50%

---

### 2. ❌ **Identical RevPAR Across All Regions**
**Problem:** AMER, EMEA, and APAC all showed identical $266 RevPAR, which is unrealistic.

**Solution:** Implemented **REGIONAL PRICING MULTIPLIERS** in `stay_history` generation:

```sql
-- Regional pricing multipliers (applied to room charges)
CASE 
    WHEN region = 'AMER' THEN base_rate * 1.25  -- 25% higher (NYC, SF markets)
    WHEN region = 'EMEA' THEN base_rate * 1.00  -- Baseline (London, Paris)
    WHEN region = 'APAC' THEN base_rate * 0.80  -- 20% lower (Bangkok, Manila)
END
```

**Expected Results:**
- AMER: ~$332 RevPAR (higher cost markets)
- EMEA: ~$266 RevPAR (baseline)
- APAC: ~$213 RevPAR (lower cost markets)

---

### 3. ❌ **Non-Members Spending More Than Loyalty Members**
**Problem:** Average spend per stay was inverted - non-members spending more than Diamond.

**Solution:** Implemented **LOYALTY TIER REVENUE MULTIPLIERS** (applied AFTER regional):

```sql
-- Loyalty tier pricing (reflects suite upgrades, premium amenities)
CASE 
    WHEN guest_id BETWEEN 'GUEST_000000' AND 'GUEST_004999' THEN 1.30  -- Diamond: 30% premium
    WHEN guest_id BETWEEN 'GUEST_005000' AND 'GUEST_014999' THEN 1.20  -- Gold: 20% premium
    WHEN guest_id BETWEEN 'GUEST_015000' AND 'GUEST_029999' THEN 1.10  -- Silver: 10% premium
    WHEN guest_id BETWEEN 'GUEST_030000' AND 'GUEST_049999' THEN 1.05  -- Blue: 5% premium
    ELSE 1.00  -- Non-members: base rate
END
```

**Expected Hierarchy:**
- Diamond: Highest avg spend (suite upgrades, premium services)
- Gold: High spend
- Silver: Medium-high spend
- Blue: Medium spend
- Non-Member: Lowest avg spend (standard rooms)

---

### 4. ❌ **Blank "Experience Drivers of Repeat Stays" Chart**
**Problem:** Chart showed no data despite having amenity_usage records.

**Root Cause:** Only 15K amenity records for 1.9M stays (~0.8% coverage) - insufficient for meaningful analysis.

**Solution:** Expanded `amenity_usage` generation to **~5M records**:

```sql
-- OLD: 15K records (WiFi only, 0.8% coverage)
-- NEW: 5M records with realistic category coverage:
-- - WiFi: 80% of stays (1.5M records)
-- - TV/Streaming: 70% of stays (1.3M records)
-- - Dining (Restaurant/Room Service): 60% of stays (1.1M records)
-- - Pool/Fitness: 40% of stays (760K records)
-- - Spa: 25% of stays (475K records)
-- - Bar: 30% of stays (570K records)
```

**Expected Result:** Chart will now show meaningful correlations between amenity usage and repeat stays.

---

## Files Modified

### Source Scripts (Permanent Fixes)
✅ **scripts/03_data_generation.sql**
- Lines 730-836: Deterministic repeat rate logic
- Lines 864-883: Regional + loyalty tier pricing multipliers
- Lines 920-1050: Expanded amenity usage generation (5M records)

### Deployment Scripts
✅ **deploy.sh**
- Ensures correct execution order: `01b_expand_to_100_properties.sql` → `03_data_generation.sql`
- Added `USE SCHEMA BRONZE;` before stay_history generation

### Data Refresh Scripts
✅ **scripts/03b_refresh_silver_gold.sql**
- Automatically rebuilds Silver/Gold after Bronze changes

---

## Deployment

```bash
# Full clean + redeploy with fixed logic
./clean.sh --connection USWEST_DEMOACCOUNT
./deploy.sh --connection USWEST_DEMOACCOUNT
```

**Expected Timeline:**
- Phase 1 (Setup): ~2 min
- Phase 2 (Bronze - 100K guests, 1.9M stays, 5M amenities): ~15 min
- Phase 3 (Silver/Gold refresh): ~3 min
- Phase 4 (Semantic Views + Agents): ~1 min
- **Total: ~21 minutes**

---

## Validation Queries

### Check Repeat Rates by Tier
```sql
WITH guest_stays AS (
    SELECT 
        guest_id,
        COUNT(*) as stay_count,
        CASE 
            WHEN guest_id < 'GUEST_005000' THEN 'Diamond'
            WHEN guest_id < 'GUEST_015000' THEN 'Gold'
            WHEN guest_id < 'GUEST_030000' THEN 'Silver'
            WHEN guest_id < 'GUEST_050000' THEN 'Blue'
            ELSE 'Non-Member'
        END as tier
    FROM HOTEL_PERSONALIZATION.BRONZE.stay_history
    GROUP BY guest_id
)
SELECT 
    tier,
    COUNT(*) as total_guests,
    SUM(CASE WHEN stay_count > 1 THEN 1 ELSE 0 END) as repeat_guests,
    SUM(CASE WHEN stay_count = 1 THEN 1 ELSE 0 END) as at_risk_guests,
    ROUND(repeat_guests * 100.0 / total_guests, 1) as repeat_rate_pct,
    ROUND(at_risk_guests * 100.0 / total_guests, 1) as at_risk_rate_pct
FROM guest_stays
GROUP BY tier;
```

**Expected:**
- Diamond: ~75% repeat, ~25% at-risk
- Gold: ~60% repeat, ~40% at-risk
- Silver: ~50% repeat, ~50% at-risk
- Blue: ~40% repeat, ~60% at-risk
- Non-Member: ~20% repeat, ~80% at-risk

### Check Regional RevPAR Variance
```sql
SELECT 
    region,
    COUNT(DISTINCT hotel_id) as hotels,
    COUNT(*) as total_stays,
    ROUND(AVG(total_charges / num_nights), 2) as avg_adr,
    ROUND(AVG(total_charges), 2) as avg_stay_value
FROM HOTEL_PERSONALIZATION.BRONZE.stay_history sh
JOIN HOTEL_PERSONALIZATION.BRONZE.hotel_properties hp ON sh.hotel_id = hp.hotel_id
GROUP BY region
ORDER BY avg_adr DESC;
```

**Expected:**
- AMER: Highest ADR (~$332)
- EMEA: Medium ADR (~$266)
- APAC: Lowest ADR (~$213)

### Check Loyalty Tier Spend Hierarchy
```sql
SELECT 
    CASE 
        WHEN sh.guest_id < 'GUEST_005000' THEN 'Diamond'
        WHEN sh.guest_id < 'GUEST_015000' THEN 'Gold'
        WHEN sh.guest_id < 'GUEST_030000' THEN 'Silver'
        WHEN sh.guest_id < 'GUEST_050000' THEN 'Blue'
        ELSE 'Non-Member'
    END as tier,
    COUNT(*) as total_stays,
    ROUND(AVG(total_charges), 2) as avg_spend_per_stay
FROM HOTEL_PERSONALIZATION.BRONZE.stay_history sh
GROUP BY tier
ORDER BY 
    CASE tier
        WHEN 'Diamond' THEN 1
        WHEN 'Gold' THEN 2
        WHEN 'Silver' THEN 3
        WHEN 'Blue' THEN 4
        ELSE 5
    END;
```

**Expected:**
- Diamond: Highest spend
- Gold > Silver > Blue > Non-Member (decreasing hierarchy)

---

## Status: ✅ FIXED IN SOURCE CODE

All fixes are now permanent in source scripts. Future deployments will automatically include these realistic distributions.
