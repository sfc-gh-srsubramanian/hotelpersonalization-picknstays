"""
Visualization components for Hotel Intelligence Hub
Reusable chart and KPI card components with tooltips
"""

import streamlit as st
import plotly.express as px
import plotly.graph_objects as go
from .formatters import format_currency, format_percent, format_number, format_delta
from .kpi_definitions import get_kpi_help

def create_kpi_card(title, value, delta=None, kpi_key=None, is_positive_good=True, prefix="", suffix=""):
    """
    Create a KPI card with optional tooltip and delta
    
    Args:
        title: KPI title
        value: KPI value
        delta: Optional delta value (percentage)
        kpi_key: Key for KPI definition lookup
        is_positive_good: Whether positive delta is good
        prefix: Prefix for value (e.g., "$")
        suffix: Suffix for value (e.g., "%")
    """
    # Get help text if kpi_key provided
    help_text = get_kpi_help(kpi_key) if kpi_key else None
    
    # Display title with help icon if help text available
    if help_text:
        st.markdown(f"**{title}** :gray[ℹ️]")
        with st.expander("ℹ️ Definition", expanded=False):
            st.caption(help_text)
    else:
        st.markdown(f"**{title}**")
    
    # Format and display metric
    if isinstance(value, (int, float)):
        formatted_value = f"{prefix}{value:,.1f}{suffix}"
    else:
        formatted_value = f"{prefix}{value}{suffix}"
    
    # Display with delta if provided
    if delta is not None:
        delta_formatted, delta_color = format_delta(delta, is_positive_good)
        st.metric(label="", value=formatted_value, delta=delta_formatted)
    else:
        st.metric(label="", value=formatted_value)

def create_bar_chart(df, x, y, title, color=None, orientation='v'):
    """
    Create a Plotly bar chart
    
    Args:
        df: DataFrame
        x: X-axis column
        y: Y-axis column
        title: Chart title
        color: Optional color column
        orientation: 'v' for vertical, 'h' for horizontal
    """
    fig = px.bar(
        df,
        x=x if orientation == 'v' else y,
        y=y if orientation == 'v' else x,
        title=title,
        color=color,
        orientation=orientation,
        template='plotly_white'
    )
    fig.update_layout(
        height=400,
        showlegend=True if color else False
    )
    return fig

def create_line_chart(df, x, y, title, color=None, y2=None):
    """
    Create a Plotly line chart with optional dual axis
    
    Args:
        df: DataFrame
        x: X-axis column
        y: Y-axis column(s) - can be list
        title: Chart title
        color: Optional color column
        y2: Optional second Y-axis column
    """
    if isinstance(y, list):
        fig = go.Figure()
        for y_col in y:
            fig.add_trace(go.Scatter(x=df[x], y=df[y_col], mode='lines+markers', name=y_col))
    else:
        fig = px.line(df, x=x, y=y, title=title, color=color, template='plotly_white')
    
    # Add second y-axis if specified
    if y2:
        fig.add_trace(go.Scatter(
            x=df[x], y=df[y2], mode='lines+markers', name=y2, yaxis='y2'
        ))
        fig.update_layout(
            yaxis2=dict(title=y2, overlaying='y', side='right')
        )
    
    fig.update_layout(
        height=400,
        xaxis_title=x,
        yaxis_title=y if not isinstance(y, list) else None
    )
    return fig

def create_heatmap(df, x, y, z, title, colorscale='RdYlGn'):
    """
    Create a Plotly heatmap
    
    Args:
        df: DataFrame (should be pivoted)
        x: X-axis column
        y: Y-axis column
        z: Value column
        title: Chart title
        colorscale: Plotly colorscale name
    """
    # Pivot data if needed
    if not df.index.name:
        pivot_df = df.pivot(index=y, columns=x, values=z)
    else:
        pivot_df = df
    
    fig = go.Figure(data=go.Heatmap(
        z=pivot_df.values,
        x=pivot_df.columns,
        y=pivot_df.index,
        colorscale=colorscale,
        hoverongaps=False
    ))
    
    fig.update_layout(
        title=title,
        height=400,
        template='plotly_white'
    )
    return fig

def create_scatter_plot(df, x, y, title, color=None, size=None):
    """
    Create a Plotly scatter plot
    
    Args:
        df: DataFrame
        x: X-axis column
        y: Y-axis column
        title: Chart title
        color: Optional color column
        size: Optional size column
    """
    fig = px.scatter(
        df,
        x=x,
        y=y,
        title=title,
        color=color,
        size=size,
        template='plotly_white'
    )
    fig.update_layout(height=400)
    return fig

def create_grouped_bar_chart(df, x, y, color, title):
    """
    Create a grouped bar chart
    
    Args:
        df: DataFrame
        x: X-axis column
        y: Y-axis column
        color: Grouping column
        title: Chart title
    """
    fig = px.bar(
        df,
        x=x,
        y=y,
        color=color,
        title=title,
        barmode='group',
        template='plotly_white'
    )
    fig.update_layout(height=400)
    return fig

def style_dataframe(df, highlight_cols=None):
    """
    Apply styling to dataframe for display
    
    Args:
        df: DataFrame to style
        highlight_cols: List of columns to apply conditional formatting
    
    Returns:
        Styled DataFrame
    """
    # Apply basic styling
    styled = df.style.format(precision=2, thousands=',')
    
    # Apply conditional formatting to highlight columns
    if highlight_cols:
        for col in highlight_cols:
            if col in df.columns:
                styled = styled.background_gradient(
                    subset=[col],
                    cmap='RdYlGn',
                    vmin=df[col].min(),
                    vmax=df[col].max()
                )
    
    return styled

def create_metric_row(metrics_data, columns=5):
    """
    Create a row of KPI metrics
    
    Args:
        metrics_data: List of tuples (title, value, delta, kpi_key)
        columns: Number of columns to display
    """
    cols = st.columns(columns)
    for idx, (title, value, delta, kpi_key) in enumerate(metrics_data):
        with cols[idx % columns]:
            create_kpi_card(title, value, delta=delta, kpi_key=kpi_key)
