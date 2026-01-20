"""
Shared Visualization Components for Hotel Personalization Dashboards
"""
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st
import pandas as pd

def create_kpi_card(label, value, delta=None, delta_color="normal"):
    """Create a KPI metric card"""
    if delta:
        st.metric(label=label, value=value, delta=delta, delta_color=delta_color)
    else:
        st.metric(label=label, value=value)

def format_currency(value):
    """Format value as currency with K/M/B suffixes"""
    if pd.isna(value) or value == 0:
        return "$0"
    
    if abs(value) >= 1_000_000_000:
        return f"${value/1_000_000_000:.2f}B"
    elif abs(value) >= 1_000_000:
        return f"${value/1_000_000:.2f}M"
    elif abs(value) >= 10_000:  # Changed from 1_000 to 10_000 for better readability
        return f"${value/1_000:.1f}K"
    else:
        return f"${value:,.0f}"

def format_number(value):
    """Format value as number with K/M/B suffixes"""
    if pd.isna(value) or value == 0:
        return "0"
    
    if abs(value) >= 1_000_000_000:
        return f"{value/1_000_000_000:.2f}B"
    elif abs(value) >= 1_000_000:
        return f"{value/1_000_000:.2f}M"
    elif abs(value) >= 10_000:  # Changed from 1_000 to 10_000 for better readability
        return f"{value/1_000:.1f}K"
    else:
        return f"{value:,.0f}"

def format_percentage(value):
    """Format value as percentage"""
    if pd.isna(value):
        return "0%"
    return f"{value:.1f}%"

def create_gauge_chart(value, title, max_value=100):
    """Create a gauge chart for scores"""
    fig = go.Figure(go.Indicator(
        mode = "gauge+number",
        value = value,
        domain = {'x': [0, 1], 'y': [0, 1]},
        title = {'text': title},
        gauge = {
            'axis': {'range': [None, max_value]},
            'bar': {'color': "darkblue"},
            'steps' : [
                {'range': [0, max_value*0.33], 'color': "lightgray"},
                {'range': [max_value*0.33, max_value*0.66], 'color': "gray"},
                {'range': [max_value*0.66, max_value], 'color': "lightgreen"}],
            'threshold' : {
                'line': {'color': "red", 'width': 4},
                'thickness': 0.75,
                'value': max_value*0.9}}))
    
    fig.update_layout(height=300)
    return fig

def create_pie_chart(df, values, names, title):
    """Create a pie chart"""
    fig = px.pie(df, values=values, names=names, title=title)
    fig.update_traces(textposition='inside', textinfo='percent+label')
    return fig

def create_bar_chart(df, x, y, title, color=None):
    """Create a bar chart"""
    fig = px.bar(df, x=x, y=y, title=title, color=color)
    fig.update_layout(xaxis_title=x, yaxis_title=y)
    return fig

def create_line_chart(df, x, y, title, color=None):
    """Create a line chart"""
    fig = px.line(df, x=x, y=y, title=title, color=color)
    fig.update_layout(xaxis_title=x, yaxis_title=y)
    return fig

def create_scatter_plot(df, x, y, size=None, color=None, hover_data=None, title=""):
    """Create a scatter plot"""
    fig = px.scatter(df, x=x, y=y, size=size, color=color, 
                     hover_data=hover_data, title=title)
    return fig

def create_heatmap(df, x, y, z, title):
    """Create a heatmap"""
    fig = px.density_heatmap(df, x=x, y=y, z=z, title=title)
    return fig

def create_treemap(df, path, values, title):
    """Create a treemap"""
    fig = px.treemap(df, path=path, values=values, title=title)
    return fig

def display_risk_badge(risk_level):
    """Display a colored risk badge"""
    if risk_level == 'High':
        st.markdown("""
            <span style='background-color: #ff4444; color: white; padding: 5px 10px; 
            border-radius: 5px; font-weight: bold;'>🔴 High Risk</span>
        """, unsafe_allow_html=True)
    elif risk_level == 'Medium':
        st.markdown("""
            <span style='background-color: #ffaa00; color: white; padding: 5px 10px; 
            border-radius: 5px; font-weight: bold;'>🟡 Medium Risk</span>
        """, unsafe_allow_html=True)
    else:
        st.markdown("""
            <span style='background-color: #44ff44; color: white; padding: 5px 10px; 
            border-radius: 5px; font-weight: bold;'>🟢 Low Risk</span>
        """, unsafe_allow_html=True)

def display_loyalty_badge(tier):
    """Display a loyalty tier badge"""
    badge_colors = {
        'Diamond': '#E5E4E2',
        'Gold': '#FFD700',
        'Silver': '#C0C0C0',
        'Bronze': '#CD7F32',
        'Member': '#4A90E2'
    }
    color = badge_colors.get(tier, '#4A90E2')
    st.markdown(f"""
        <span style='background-color: {color}; color: black; padding: 5px 10px; 
        border-radius: 5px; font-weight: bold;'>⭐ {tier}</span>
    """, unsafe_allow_html=True)

def apply_custom_css():
    """Apply custom CSS styling"""
    st.markdown("""
        <style>
        .stApp {
            max-width: 1400px;
            margin: 0 auto;
        }
        .metric-card {
            background-color: #f0f2f6;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .section-header {
            font-size: 24px;
            font-weight: bold;
            margin-top: 30px;
            margin-bottom: 15px;
            color: #1f77b4;
        }
        </style>
    """, unsafe_allow_html=True)
