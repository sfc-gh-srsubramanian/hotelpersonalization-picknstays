# NaN Formatter Fix Summary

## Issue
Streamlit Intelligence Hub app was crashing with:
```
ValueError: cannot convert float NaN to integer
```

**Error Location**: `shared/formatters.py`, line 148, in `format_duration` function
**Affected Page**: CX & Service Signals dashboard

## Root Cause
The `format_duration()` function (and other formatter functions) did not handle NaN (Not a Number) values properly. When encountering a NaN value from the database, the function tried to convert it to an integer, causing a crash.

## Solution
Added NaN checks to all formatter functions in `streamlit/intelligence_hub/shared/formatters.py`:

### Functions Fixed:
1. ✅ `format_currency()` - Returns `"$—"` for NaN
2. ✅ `format_percent()` - Returns `"—%"` for NaN
3. ✅ `format_number()` - Returns `"—"` for NaN
4. ✅ `format_rating()` - Returns `"—/{max_rating}"` for NaN
5. ✅ `format_large_number()` - Returns `"—"` for NaN
6. ✅ `format_duration()` - Returns `"—"` for NaN

### NaN Detection Method:
Used the mathematical property that `NaN != NaN`:
```python
# Check for NaN (using the fact that NaN != NaN)
if value != value:
    return "—"
```

This approach is more reliable than importing additional libraries and works with pandas/numpy NaN values.

## Deployment
```bash
# Redeployed Intelligence Hub Streamlit app
cd streamlit/intelligence_hub
snow streamlit deploy \
  --connection USWEST_DEMOACCOUNT \
  --database HOTEL_PERSONALIZATION \
  --schema GOLD \
  --replace
```

## Results
- ✅ Streamlit app no longer crashes on NaN values
- ✅ NaN values display as "—" (em dash) for better UX
- ✅ All dashboards (Portfolio, Loyalty, CX & Service) display correctly
- ✅ Duration formatting handles edge cases gracefully

## Files Modified
- `streamlit/intelligence_hub/shared/formatters.py` - Added NaN checks to all 6 formatter functions

## Testing
Tested with:
- Empty/missing data fields
- NaN values from SQL queries
- Various data types (float, int, pandas Series)

---
**Fixed**: 2026-01-15
**Applied**: USWEST_DEMOACCOUNT
