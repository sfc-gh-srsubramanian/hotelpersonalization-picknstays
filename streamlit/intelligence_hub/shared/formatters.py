"""
Formatting utilities for Hotel Intelligence Hub
Provides consistent number, currency, and percentage formatting
"""

def format_currency(value, decimals=0):
    """
    Format value as currency with appropriate scale
    
    Examples:
        1234.56 -> "$1.2K"
        1234567.89 -> "$1.2M"
        45.50 -> "$46"
    """
    if value is None or value == 0:
        return "$0"
    
    # Check for NaN (using the fact that NaN != NaN)
    if value != value:
        return "$—"
    
    abs_value = abs(value)
    sign = "-" if value < 0 else ""
    
    if abs_value >= 1_000_000:
        return f"{sign}${abs_value / 1_000_000:.{decimals}f}M"
    elif abs_value >= 1_000:
        return f"{sign}${abs_value / 1_000:.{decimals}f}K"
    else:
        return f"{sign}${abs_value:.{decimals}f}"

def format_percent(value, decimals=1):
    """
    Format value as percentage
    
    Examples:
        0.153 -> "15.3%"
        15.3 -> "15.3%" (handles both decimal and percentage input)
    """
    if value is None:
        return "0.0%"
    
    # Check for NaN (using the fact that NaN != NaN)
    if value != value:
        return "—%"
    
    # If value is already in percentage form (>1), use as-is
    if abs(value) > 1:
        return f"{value:.{decimals}f}%"
    else:
        return f"{value * 100:.{decimals}f}%"

def format_number(value, decimals=1):
    """
    Format number with K/M abbreviations
    
    Examples:
        1234 -> "1.2K"
        1234567 -> "1.2M"
        45 -> "45"
    """
    if value is None or value == 0:
        return "0"
    
    # Check for NaN (using the fact that NaN != NaN)
    if value != value:
        return "—"
    
    abs_value = abs(value)
    sign = "-" if value < 0 else ""
    
    if abs_value >= 1_000_000:
        return f"{sign}{abs_value / 1_000_000:.{decimals}f}M"
    elif abs_value >= 1_000:
        return f"{sign}{abs_value / 1_000:.{decimals}f}K"
    else:
        return f"{sign}{abs_value:.{decimals}f}"

def format_delta(value, is_positive_good=True, decimals=1):
    """
    Format delta value with up/down arrow and color indication
    
    Args:
        value: The delta value
        is_positive_good: Whether positive change is good (True) or bad (False)
        decimals: Number of decimal places
    
    Returns:
        Tuple of (formatted_string, color)
    
    Examples:
        (12.5, True) -> ("↑ 12.5%", "green")
        (-5.2, True) -> ("↓ 5.2%", "red")
    """
    if value is None or value == 0:
        return ("—", "gray")
    
    abs_value = abs(value)
    
    # Determine arrow and color
    if value > 0:
        arrow = "↑"
        color = "green" if is_positive_good else "red"
    else:
        arrow = "↓"
        color = "red" if is_positive_good else "green"
    
    formatted = f"{arrow} {abs_value:.{decimals}f}%"
    return (formatted, color)

def format_rating(value, max_rating=5, decimals=1):
    """
    Format rating value with max scale
    
    Examples:
        4.5 -> "4.5/5.0"
        85 -> "85/100"
    """
    if value is None:
        return f"—/{max_rating}"
    
    # Check for NaN (using the fact that NaN != NaN)
    if value != value:
        return f"—/{max_rating}"
    
    return f"{value:.{decimals}f}/{max_rating:.{decimals}f}"

def format_large_number(value, decimals=0):
    """
    Format large numbers with commas
    
    Examples:
        1234567 -> "1,234,567"
        1234.56 -> "1,235"
    """
    if value is None:
        return "0"
    
    # Check for NaN (using the fact that NaN != NaN)
    if value != value:
        return "—"
    
    return f"{value:,.{decimals}f}"

def format_duration(hours):
    """
    Format duration in hours to human-readable format
    
    Examples:
        0.5 -> "30 min"
        1.5 -> "1h 30min"
        24 -> "1 day"
    """
    # Handle None, NaN, and zero values
    if hours is None or hours == 0:
        return "0 min"
    
    # Check for NaN (using the fact that NaN != NaN)
    if hours != hours:  # NaN check
        return "—"
    
    # Convert to float if it's a pandas/numpy type
    try:
        hours = float(hours)
    except (ValueError, TypeError):
        return "—"
    
    if hours < 1:
        minutes = int(hours * 60)
        return f"{minutes} min"
    elif hours < 24:
        h = int(hours)
        m = int((hours - h) * 60)
        if m > 0:
            return f"{h}h {m}min"
        else:
            return f"{h}h"
    else:
        days = int(hours / 24)
        remaining_hours = int(hours % 24)
        if remaining_hours > 0:
            return f"{days}d {remaining_hours}h"
        else:
            return f"{days} day" if days == 1 else f"{days} days"
