#!/usr/bin/env python3
"""
Generate presentation-quality diagrams for Hotel Personalization Solution Overview.

Creates 10 professional diagrams:
1. Architecture Overview (with Consumption Layer including Streamlit)
2. Data Sources
3. Medallion Architecture (Complete: Bronze → Silver → Gold → Semantic → Consumption)
4. ML Scoring Models
5. Intelligence Agents
6. Unified Amenity Analytics
7. Intelligence Hub Architecture (Executive Intelligence Platform)
8. Portfolio Overview Dashboard
9. Loyalty Intelligence Dashboard
10. CX & Service Signals Dashboard

Requirements:
    pip install matplotlib pillow

Usage:
    python3 generate_images.py
"""

import os
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from PIL import Image, ImageDraw, ImageFont

# Create images directory
OUTPUT_DIR = "images"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Color palette
SNOWFLAKE_BLUE = '#29B5E8'
DARK_BLUE = '#1E3A8A'
LIGHT_BLUE = '#BFDBFE'
GOLD = '#FCD34D'
GREEN = '#10B981'
PURPLE = '#A78BFA'
GRAY = '#6B7280'

def create_architecture_diagram():
    """Create architecture overview diagram."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 12))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 11)
    ax.axis('off')
    
    # Title
    ax.text(5, 10.5, 'Hotel Personalization Platform - Architecture', 
            ha='center', fontsize=18, fontweight='bold')
    
    # Data Sources Layer
    sources = ['PMS', 'Booking\nSystems', 'Amenity\nSystems', 'WiFi/TV', 'Social\nMedia']
    for i, source in enumerate(sources):
        x = 1 + i * 1.8
        rect = patches.FancyBboxPatch((x - 0.3, 8.5), 0.6, 0.8,
                                       boxstyle="round,pad=0.05", 
                                       edgecolor=GRAY, facecolor=LIGHT_BLUE)
        ax.add_patch(rect)
        ax.text(x, 8.9, source, ha='center', va='center', fontsize=9)
    
    # Bronze Layer
    rect = patches.FancyBboxPatch((0.5, 6.8), 9, 1.2,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=DARK_BLUE, facecolor='#FEF3C7', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 7.7, 'BRONZE LAYER', ha='center', fontweight='bold', fontsize=12)
    ax.text(5, 7.2, '13 Raw Tables: Guests, Bookings, Amenities, Usage', 
            ha='center', fontsize=9)
    
    # Silver Layer
    rect = patches.FancyBboxPatch((0.5, 5.2), 9, 1.2,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=DARK_BLUE, facecolor='#DBEAFE', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 6.1, 'SILVER LAYER', ha='center', fontweight='bold', fontsize=12)
    ax.text(5, 5.6, '7 Enriched Tables: Cleaned, Standardized, Behavioral Analysis', 
            ha='center', fontsize=9)
    
    # Gold Layer
    rect = patches.FancyBboxPatch((0.5, 3.6), 9, 1.2,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=DARK_BLUE, facecolor='#FDE68A', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 4.5, 'GOLD LAYER', ha='center', fontweight='bold', fontsize=12)
    ax.text(5, 4.0, '3 Analytics Tables: 360° Profiles, ML Scores, Amenity Analytics', 
            ha='center', fontsize=9)
    
    # Semantic Layer
    rect = patches.FancyBboxPatch((0.5, 2.0), 9, 1.2,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=DARK_BLUE, facecolor='#E9D5FF', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 2.9, 'SEMANTIC LAYER', ha='center', fontweight='bold', fontsize=12)
    ax.text(5, 2.4, '3 Semantic Views + 5 Intelligence Agents', 
            ha='center', fontsize=9)
    
    # Consumption Layer (NEW)
    rect = patches.FancyBboxPatch((0.5, 0.3), 9, 1.3,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=DARK_BLUE, facecolor='#D1FAE5', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 1.35, 'CONSUMPTION LAYER', ha='center', fontweight='bold', fontsize=12)
    
    # Consumption components as boxes
    consumption_items = [
        ('Streamlit\nDashboard\n(5 Pages)', 1.5),
        ('Snowflake\nIntelligence\nUI', 3.5),
        ('Direct SQL\n& API\nAccess', 5.5),
        ('BI Tools\nIntegration', 7.5)
    ]
    for item, x in consumption_items:
        small_rect = patches.FancyBboxPatch((x - 0.45, 0.5), 0.9, 0.65,
                                           boxstyle="round,pad=0.03",
                                           edgecolor=GREEN, facecolor='white', linewidth=1.5)
        ax.add_patch(small_rect)
        ax.text(x, 0.82, item, ha='center', va='center', fontsize=7)
    
    # Arrows
    for y in [8.3, 6.7, 5.1, 3.5, 1.9]:
        ax.arrow(5, y, 0, -0.3, head_width=0.3, head_length=0.1, 
                fc=DARK_BLUE, ec=DARK_BLUE, linewidth=2)
    
    plt.tight_layout()
    plt.savefig(f'{OUTPUT_DIR}/architecture_overview.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"✓ Created architecture_overview.png")

def create_ml_scoring_diagram():
    """Create ML scoring models diagram."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(5, 9.5, '7 ML Scoring Models (0-100 Scale)', 
            ha='center', fontsize=16, fontweight='bold')
    
    models = [
        ('Personalization\nReadiness', SNOWFLAKE_BLUE),
        ('Upsell\nPropensity', GREEN),
        ('Spa\nUpsell', PURPLE),
        ('Dining\nUpsell', GOLD),
        ('Tech\nUpsell', SNOWFLAKE_BLUE),
        ('Pool Services\nUpsell', GREEN),
        ('Loyalty\nPropensity', PURPLE)
    ]
    
    for i, (model, color) in enumerate(models):
        row = i // 4
        col = i % 4
        x = 1.5 + col * 2.2
        y = 7 - row * 2.5
        
        circle = patches.Circle((x, y), 0.6, color=color, alpha=0.3, edgecolor=color, linewidth=3)
        ax.add_patch(circle)
        ax.text(x, y, model, ha='center', va='center', fontsize=9, fontweight='bold')
        ax.text(x, y - 1, f'Score: {50 + i * 5}', ha='center', fontsize=8)
    
    plt.tight_layout()
    plt.savefig(f'{OUTPUT_DIR}/ml_scoring_models.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"✓ Created ml_scoring_models.png")

def create_agents_diagram():
    """Create Intelligence Agents diagram."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(5, 9.5, 'Snowflake Intelligence Agents', 
            ha='center', fontsize=16, fontweight='bold')
    
    agents = [
        ('Guest\nAnalytics', 'Behavior &\nLoyalty'),
        ('Personalization\nSpecialist', 'Upsell &\nPreferences'),
        ('Amenities\nIntelligence', 'Service\nPerformance'),
        ('Experience\nOptimizer', 'Satisfaction &\nChurn'),
        ('Master\nAgent', 'Strategic\nInsights')
    ]
    
    for i, (name, desc) in enumerate(agents):
        x = 1.5 + i * 1.8
        y = 5
        
        rect = patches.FancyBboxPatch((x - 0.6, y - 0.7), 1.2, 1.4,
                                       boxstyle="round,pad=0.1",
                                       edgecolor=SNOWFLAKE_BLUE, facecolor=LIGHT_BLUE, linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y + 0.3, name, ha='center', va='center', fontsize=9, fontweight='bold')
        ax.text(x, y - 0.3, desc, ha='center', va='center', fontsize=7)
    
    # NL Query box
    rect = patches.FancyBboxPatch((1, 7), 8, 0.8,
                                   boxstyle="round,pad=0.05",
                                   edgecolor=GRAY, facecolor='white', linewidth=1)
    ax.add_patch(rect)
    ax.text(5, 7.4, 'Natural Language: "Show me top guests by revenue with high spa upsell scores"', 
            ha='center', va='center', fontsize=10, style='italic')
    
    plt.tight_layout()
    plt.savefig(f'{OUTPUT_DIR}/intelligence_agents.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"✓ Created intelligence_agents.png")

def create_amenity_analytics_diagram():
    """Create unified amenity analytics diagram."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(5, 9.5, 'Unified Amenity Analytics', 
            ha='center', fontsize=16, fontweight='bold')
    
    # Traditional Amenities
    rect = patches.FancyBboxPatch((0.5, 5.5), 4, 3,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=GREEN, facecolor='#D1FAE5', linewidth=2)
    ax.add_patch(rect)
    ax.text(2.5, 8, 'Traditional Amenities', ha='center', fontweight='bold', fontsize=11)
    ax.text(2.5, 7.5, '(Transaction-Based)', ha='center', fontsize=9)
    amenities = ['• Spa Services', '• Restaurant', '• Bar', '• Room Service']
    for i, amenity in enumerate(amenities):
        ax.text(2.5, 7 - i * 0.4, amenity, ha='center', fontsize=9)
    
    # Infrastructure Amenities
    rect = patches.FancyBboxPatch((5.5, 5.5), 4, 3,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=SNOWFLAKE_BLUE, facecolor='#DBEAFE', linewidth=2)
    ax.add_patch(rect)
    ax.text(7.5, 8, 'Infrastructure Amenities', ha='center', fontweight='bold', fontsize=11)
    ax.text(7.5, 7.5, '(Usage + Transaction)', ha='center', fontsize=9)
    infra = ['• WiFi Services', '• Smart TV', '• Pool Services']
    for i, item in enumerate(infra):
        ax.text(7.5, 7 - i * 0.4, item, ha='center', fontsize=9)
    
    # Unified Analytics
    rect = patches.FancyBboxPatch((1.5, 1.5), 7, 3,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=PURPLE, facecolor='#EDE9FE', linewidth=3)
    ax.add_patch(rect)
    ax.text(5, 4, 'UNIFIED AMENITY ANALYTICS', ha='center', fontweight='bold', fontsize=12)
    metrics = ['Revenue & Usage Tracking', 'Satisfaction Across All Categories', 'Cross-Service Bundling']
    for i, metric in enumerate(metrics):
        ax.text(5, 3.3 - i * 0.4, f'• {metric}', ha='center', fontsize=9)
    
    # Arrows
    ax.arrow(2.5, 5.3, 1, -0.5, head_width=0.2, head_length=0.1, fc=PURPLE, ec=PURPLE, linewidth=2)
    ax.arrow(7.5, 5.3, -1, -0.5, head_width=0.2, head_length=0.1, fc=PURPLE, ec=PURPLE, linewidth=2)
    
    plt.tight_layout()
    plt.savefig(f'{OUTPUT_DIR}/unified_amenity_analytics.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"✓ Created unified_amenity_analytics.png")

def create_data_sources_diagram():
    """Create data sources diagram."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    ax.text(5, 9, 'Data Sources', ha='center', fontsize=16, fontweight='bold')
    
    sources = [
        ('PMS Systems', ['Guest Profiles', 'Reservations', 'Check-ins']),
        ('Booking Platforms', ['Online Bookings', 'OTA Data', 'Direct Bookings']),
        ('Amenity Systems', ['Spa POS', 'Restaurant POS', 'Room Service']),
        ('Infrastructure', ['WiFi Usage', 'Smart TV Logs', 'Pool Access']),
        ('Guest Feedback', ['Reviews', 'Surveys', 'Social Media'])
    ]
    
    for i, (title, items) in enumerate(sources):
        x = 1 + (i % 3) * 3
        y = 6.5 - (i // 3) * 3
        
        rect = patches.FancyBboxPatch((x - 0.8, y - 0.8), 1.6, 1.6,
                                       boxstyle="round,pad=0.05",
                                       edgecolor=SNOWFLAKE_BLUE, facecolor=LIGHT_BLUE, linewidth=1.5)
        ax.add_patch(rect)
        ax.text(x, y + 0.5, title, ha='center', fontweight='bold', fontsize=9)
        for j, item in enumerate(items):
            ax.text(x, y + 0.1 - j * 0.25, f'• {item}', ha='center', fontsize=7)
    
    plt.tight_layout()
    plt.savefig(f'{OUTPUT_DIR}/data_sources.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"✓ Created data_sources.png")

def create_medallion_diagram():
    """Create medallion architecture diagram with consumption layer."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 11)
    ax.axis('off')
    
    ax.text(5, 10.3, 'Complete Data Architecture', 
            ha='center', fontsize=14, fontweight='bold')
    ax.text(5, 9.8, 'Bronze → Silver → Gold → Semantic → Consumption', 
            ha='center', fontsize=10, style='italic', color=GRAY)
    
    layers = [
        ('BRONZE', 8, '#FEF3C7', '13 Raw Tables\nNo Transformation\nSource Fidelity'),
        ('SILVER', 6, '#DBEAFE', '7 Enriched Tables\nCleaned & Standardized\nBehavioral Analysis'),
        ('GOLD', 4, '#FDE68A', '3 Analytics Tables\n360° Profiles\nML Scores'),
        ('SEMANTIC', 2, '#E9D5FF', '3 Semantic Views\n5 Intelligence Agents\nNatural Language')
    ]
    
    for name, y, color, desc in layers:
        rect = patches.FancyBboxPatch((2, y - 0.7), 6, 1.4,
                                       boxstyle="round,pad=0.1",
                                       edgecolor=DARK_BLUE, facecolor=color, linewidth=2)
        ax.add_patch(rect)
        ax.text(5, y + 0.35, name, ha='center', fontweight='bold', fontsize=11)
        ax.text(5, y - 0.25, desc, ha='center', fontsize=7.5)
        
        if y > 2:
            ax.arrow(5, y - 0.8, 0, -0.4, head_width=0.3, head_length=0.1, 
                    fc=DARK_BLUE, ec=DARK_BLUE, linewidth=2)
    
    # Consumption Layer
    rect = patches.FancyBboxPatch((1.5, 0.2), 7, 1.0,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=GREEN, facecolor='#D1FAE5', linewidth=2.5)
    ax.add_patch(rect)
    ax.text(5, 0.9, 'CONSUMPTION', ha='center', fontweight='bold', fontsize=11)
    ax.text(5, 0.5, 'Streamlit (5 Pages) • Intelligence UI • SQL Access • BI Tools', 
            ha='center', fontsize=7.5)
    
    # Arrow to consumption
    ax.arrow(5, 1.2, 0, -0.15, head_width=0.3, head_length=0.08, 
            fc=DARK_BLUE, ec=DARK_BLUE, linewidth=2)
    
    plt.tight_layout()
    plt.savefig(f'{OUTPUT_DIR}/medallion_architecture.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"✓ Created medallion_architecture.png")

def create_intelligence_hub_architecture():
    """Create Intelligence Hub architecture diagram for executive intelligence."""
    fig, ax = plt.subplots(1, 1, figsize=(16, 14))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 13)
    ax.axis('off')
    
    # Title
    ax.text(5, 12.5, 'Hotel Intelligence Hub - Executive Intelligence Platform', 
            ha='center', fontsize=18, fontweight='bold')
    ax.text(5, 12, '100 Global Properties | Portfolio Analytics | Proactive Intelligence', 
            ha='center', fontsize=11, style='italic', color=GRAY)
    
    # Data Sources (100 Properties)
    rect = patches.FancyBboxPatch((0.3, 10.3), 9.4, 1.2,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=GRAY, facecolor='#F3F4F6', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 11.2, 'DATA SOURCES (100 Global Properties)', ha='center', fontweight='bold', fontsize=11)
    sources_text = ['PMS Systems', 'Loyalty Platform', 'Service Systems', 'Revenue Systems', 'Feedback & Sentiment']
    for i, src in enumerate(sources_text):
        x = 1.2 + i * 1.8
        ax.text(x, 10.7, f'• {src}', ha='left', fontsize=8)
    
    # Bronze Layer
    rect = patches.FancyBboxPatch((0.5, 8.7), 9, 1.2,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=DARK_BLUE, facecolor='#FEF3C7', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 9.6, '🥉 BRONZE LAYER - Raw Data Ingestion', ha='center', fontweight='bold', fontsize=11)
    ax.text(5, 9.15, '100K guests • 250K bookings • 1.9M stays • 40K service cases • 100 properties', 
            ha='center', fontsize=8)
    
    # Silver Layer
    rect = patches.FancyBboxPatch((0.5, 7.1), 9, 1.2,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=DARK_BLUE, facecolor='#DBEAFE', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 8.0, '🥈 SILVER LAYER - Cleaned & Enriched', ha='center', fontweight='bold', fontsize=11)
    ax.text(5, 7.55, 'Data quality checks • Enrichment • Churn risk scoring • VIP flagging', 
            ha='center', fontsize=8)
    
    # Gold Layer (3 Executive Tables)
    rect = patches.FancyBboxPatch((0.5, 5.5), 9, 1.2,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=DARK_BLUE, facecolor='#FDE68A', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 6.4, '🏆 GOLD LAYER - Executive Analytics-Ready', ha='center', fontweight='bold', fontsize=11)
    
    # Three gold tables as boxes
    gold_tables = [
        ('Portfolio\nPerformance\nKPIs', 1.8, 'RevPAR\nOccupancy\nADR'),
        ('Loyalty Segment\nIntelligence', 5, 'Repeat Rates\nAt-Risk Segments\nSpend Mix'),
        ('CX & Service\nSignals', 8.2, 'Service Cases\nVIP Watchlist\nSentiment')
    ]
    for title, x, desc in gold_tables:
        small_rect = patches.FancyBboxPatch((x - 0.7, 5.7), 1.4, 0.55,
                                           boxstyle="round,pad=0.03",
                                           edgecolor=GOLD, facecolor='white', linewidth=1.5)
        ax.add_patch(small_rect)
        ax.text(x, 6.15, title, ha='center', va='center', fontsize=7, fontweight='bold')
        ax.text(x, 5.85, desc, ha='center', va='center', fontsize=5.5)
    
    # Semantic Layer (7 Views + Master Agent)
    rect = patches.FancyBboxPatch((0.5, 3.9), 9, 1.2,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=DARK_BLUE, facecolor='#E9D5FF', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 4.8, '🔍 SEMANTIC LAYER - Natural Language Interface', ha='center', fontweight='bold', fontsize=11)
    ax.text(5, 4.35, '7 Semantic Views + Hotel Intelligence Master Agent (40+ Sample Questions)', 
            ha='center', fontsize=8)
    
    # Consumption Layer (3 Executive Dashboards)
    rect = patches.FancyBboxPatch((0.5, 2.0), 9, 1.5,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=GREEN, facecolor='#D1FAE5', linewidth=2.5)
    ax.add_patch(rect)
    ax.text(5, 3.25, '📊 CONSUMPTION LAYER - Executive Dashboards', ha='center', fontweight='bold', fontsize=11)
    
    # Three dashboards as boxes
    dashboards = [
        ('Portfolio\nOverview', 2, '5 KPIs\nOutliers'),
        ('Loyalty\nIntelligence', 5, 'Repeat Rates\nAt-Risk'),
        ('CX & Service\nSignals', 8, 'VIP Watchlist\nIssue Tracking')
    ]
    for title, x, desc in dashboards:
        dash_rect = patches.FancyBboxPatch((x - 0.65, 2.25), 1.3, 0.7,
                                           boxstyle="round,pad=0.05",
                                           edgecolor=GREEN, facecolor='white', linewidth=1.5)
        ax.add_patch(dash_rect)
        ax.text(x, 2.75, title, ha='center', va='center', fontsize=8, fontweight='bold')
        ax.text(x, 2.45, desc, ha='center', va='center', fontsize=6)
    
    # Users Layer
    rect = patches.FancyBboxPatch((0.5, 0.5), 9, 1.1,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=PURPLE, facecolor='#FAF5FF', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 1.35, '👥 EXECUTIVE USERS', ha='center', fontweight='bold', fontsize=11)
    users = ['COO/CFO', 'Regional VPs', 'Property GMs', 'Revenue Mgrs', 'Loyalty Mgrs']
    for i, user in enumerate(users):
        x = 1.2 + i * 1.8
        ax.text(x, 0.85, f'• {user}', ha='left', fontsize=7)
    
    # Arrows connecting layers
    for y_start in [10.2, 8.6, 6.9, 5.4, 3.8, 1.9]:
        ax.arrow(5, y_start, 0, -0.3, head_width=0.3, head_length=0.1, 
                fc=DARK_BLUE, ec=DARK_BLUE, linewidth=2)
    
    plt.tight_layout()
    plt.savefig(f'{OUTPUT_DIR}/intelligence_hub_architecture.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"✓ Created intelligence_hub_architecture.png")

def create_portfolio_dashboard():
    """Create Portfolio Overview Dashboard mockup."""
    fig, ax = plt.subplots(1, 1, figsize=(16, 11))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(5, 9.7, 'Portfolio Overview - Executive Command Center', 
            ha='center', fontsize=16, fontweight='bold')
    
    # 5 KPI Cards
    kpis = [
        ('Occupancy %', '67.5%', '▼ 3%', SNOWFLAKE_BLUE),
        ('ADR', '$162', '▲ 2%', GREEN),
        ('RevPAR', '$109', '▼ 1%', GOLD),
        ('Repeat Rate', '48.2%', '▲ 5%', GREEN),
        ('Guest Sat.', '85.3/100', '▲ 2', GREEN)
    ]
    for i, (label, value, trend, color) in enumerate(kpis):
        x = 1 + i * 1.8
        y = 9
        rect = patches.FancyBboxPatch((x - 0.5, y - 0.4), 1, 0.7,
                                       boxstyle="round,pad=0.05",
                                       edgecolor=color, facecolor='white', linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y + 0.15, label, ha='center', fontsize=8, fontweight='bold')
        ax.text(x, y - 0.05, value, ha='center', fontsize=10, fontweight='bold', color=color)
        ax.text(x, y - 0.25, trend, ha='center', fontsize=7, color=color)
    
    # RevPAR by Brand Chart
    rect = patches.FancyBboxPatch((0.5, 5.8), 4.5, 2.3,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=GRAY, facecolor='white', linewidth=1.5)
    ax.add_patch(rect)
    ax.text(2.75, 7.9, 'Average RevPAR by Brand', ha='center', fontsize=9, fontweight='bold')
    
    brands = [('Peak Reserve', 195), ('Snowline', 122), ('Permafrost', 108), ('Summit Ice', 95)]
    for i, (brand, value) in enumerate(brands):
        y = 7.3 - i * 0.4
        bar_width = value / 40  # Scale for visualization
        bar = patches.Rectangle((1, y - 0.12), bar_width, 0.24, 
                                edgecolor=SNOWFLAKE_BLUE, facecolor=SNOWFLAKE_BLUE, alpha=0.7)
        ax.add_patch(bar)
        ax.text(0.9, y, brand, ha='right', va='center', fontsize=7)
        ax.text(1 + bar_width + 0.1, y, f'${value}', ha='left', va='center', fontsize=7, fontweight='bold')
    
    # RevPAR by Region Chart
    rect = patches.FancyBboxPatch((5.5, 5.8), 4, 2.3,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=GRAY, facecolor='white', linewidth=1.5)
    ax.add_patch(rect)
    ax.text(7.5, 7.9, 'Average RevPAR by Region', ha='center', fontsize=9, fontweight='bold')
    
    regions = [('AMER', 152, GREEN), ('APAC', 132, GOLD), ('EMEA', 118, SNOWFLAKE_BLUE)]
    for i, (region, value, color) in enumerate(regions):
        y = 7.1 - i * 0.5
        bar_width = value / 40
        bar = patches.Rectangle((6, y - 0.12), bar_width, 0.24, 
                                edgecolor=color, facecolor=color, alpha=0.7)
        ax.add_patch(bar)
        ax.text(5.9, y, region, ha='right', va='center', fontsize=7)
        ax.text(6 + bar_width + 0.1, y, f'${value}', ha='left', va='center', fontsize=7, fontweight='bold')
    
    # Experience Health Heatmap
    rect = patches.FancyBboxPatch((0.5, 3.2), 4.5, 2.3,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=GRAY, facecolor='white', linewidth=1.5)
    ax.add_patch(rect)
    ax.text(2.75, 5.3, 'Experience Health (Satisfaction by Brand × Region)', 
            ha='center', fontsize=8, fontweight='bold')
    
    # Simple heatmap representation
    heatmap_data = [
        ['Peak Reserve', '4.2', '3.8', '4.1'],
        ['Summit Ice', '4.0', '3.9', '3.7'],
        ['Permafrost', '3.8', '4.0', '3.8'],
        ['Snowline', '4.1', '3.2', '4.0']
    ]
    regions_header = ['', 'AMER', 'EMEA', 'APAC']
    
    for i, header in enumerate(regions_header):
        ax.text(1.2 + i * 0.9, 4.9, header, ha='center', fontsize=6, fontweight='bold')
    
    for row_idx, row_data in enumerate(heatmap_data):
        for col_idx, val in enumerate(row_data):
            y = 4.6 - row_idx * 0.3
            x = 1.2 + col_idx * 0.9
            if col_idx == 0:
                ax.text(x, y, val, ha='center', fontsize=6)
            else:
                score = float(val)
                color = GREEN if score >= 4.0 else (GOLD if score >= 3.5 else '#EF4444')
                circle = patches.Circle((x, y), 0.15, color=color, alpha=0.6)
                ax.add_patch(circle)
                ax.text(x, y, val, ha='center', va='center', fontsize=6, fontweight='bold')
    
    # Outliers & Exceptions Table
    rect = patches.FancyBboxPatch((5.5, 3.2), 4, 2.3,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=GRAY, facecolor='white', linewidth=1.5)
    ax.add_patch(rect)
    ax.text(7.5, 5.3, '⚠️ Outliers & Exceptions (Top 4)', ha='center', fontsize=8, fontweight='bold')
    
    outliers = [
        ('Summit Ice-EMEA', '🔴', '🔴', '🔴', '🟡'),
        ('Snowline-EMEA', '🟡', '🔴', '🔴', '🟢'),
        ('Peak Reserve-APAC', '🟢', '🟢', '🟢', '🟢'),
        ('Permafrost-AMER', '🟡', '🟡', '🟡', '🟡')
    ]
    headers = ['Property', 'RevPAR Δ', 'Sat. Δ', 'Cases', 'Data']
    for i, h in enumerate(headers):
        ax.text(5.8 + i * 0.85, 5.0, h, ha='center', fontsize=5, fontweight='bold')
    
    for row_idx, outlier_data in enumerate(outliers):
        y = 4.7 - row_idx * 0.25
        for col_idx, val in enumerate(outlier_data):
            x = 5.8 + col_idx * 0.85
            ax.text(x, y, val, ha='center', fontsize=5)
    
    # AI-Powered Analysis Section
    rect = patches.FancyBboxPatch((0.5, 0.5), 9, 2.3,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=PURPLE, facecolor='#FAF5FF', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 2.6, '🤖 AI-Powered Analysis', ha='center', fontsize=10, fontweight='bold')
    ax.text(5, 2.3, 'Example Questions:', ha='center', fontsize=8, style='italic')
    
    questions = [
        '• "What\'s driving RevPAR changes across brands this month?"',
        '• "Which regions improved guest satisfaction—and why?"',
        '• "Call out the top 3 operational issues impacting loyalty"'
    ]
    for i, q in enumerate(questions):
        ax.text(5, 1.95 - i * 0.25, q, ha='center', fontsize=7)
    
    # Button representation
    button_rect = patches.FancyBboxPatch((3.5, 0.7), 3, 0.4,
                                         boxstyle="round,pad=0.05",
                                         edgecolor=SNOWFLAKE_BLUE, facecolor=SNOWFLAKE_BLUE)
    ax.add_patch(button_rect)
    ax.text(5, 0.9, '🤖 Open Snowflake Intelligence', ha='center', va='center', 
            fontsize=8, fontweight='bold', color='white')
    
    plt.tight_layout()
    plt.savefig(f'{OUTPUT_DIR}/portfolio_overview_dashboard.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"✓ Created portfolio_overview_dashboard.png")

def create_loyalty_dashboard():
    """Create Loyalty Intelligence Dashboard mockup."""
    fig, ax = plt.subplots(1, 1, figsize=(16, 11))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(5, 9.7, 'Loyalty Intelligence - Member Behavior & Retention', 
            ha='center', fontsize=16, fontweight='bold')
    
    # 4 KPI Cards
    kpis = [
        ('Active Loyalty\nMembers', '50,000', 'Enrolled', PURPLE),
        ('Avg Repeat\nStay Rate', '50.2%', 'Industry: 40-50%', GREEN),
        ('High-Value\nGuest Share', '30.5%', 'Diamond + Gold', GOLD),
        ('At-Risk\nSegments', '3 segments', '2,450 members', '#EF4444')
    ]
    for i, (label, value, desc, color) in enumerate(kpis):
        x = 1.2 + i * 2.2
        y = 9
        rect = patches.FancyBboxPatch((x - 0.6, y - 0.4), 1.2, 0.7,
                                       boxstyle="round,pad=0.05",
                                       edgecolor=color, facecolor='white', linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y + 0.15, label, ha='center', fontsize=7, fontweight='bold')
        ax.text(x, y - 0.05, value, ha='center', fontsize=9, fontweight='bold', color=color)
        ax.text(x, y - 0.25, desc, ha='center', fontsize=6)
    
    # Repeat Stay Rate by Tier
    rect = patches.FancyBboxPatch((0.5, 5.5), 4.5, 2.8,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=GRAY, facecolor='white', linewidth=1.5)
    ax.add_patch(rect)
    ax.text(2.75, 8.1, 'Repeat Stay Rate by Loyalty Tier', ha='center', fontsize=9, fontweight='bold')
    
    tiers = [
        ('Diamond', 75.2, 5000, PURPLE),
        ('Gold', 60.8, 10000, GOLD),
        ('Silver', 50.5, 15000, '#9CA3AF'),
        ('Blue', 40.2, 20000, SNOWFLAKE_BLUE),
        ('Non-Member', 20.1, 50000, GRAY)
    ]
    for i, (tier, rate, members, color) in enumerate(tiers):
        y = 7.6 - i * 0.45
        bar_width = rate / 20
        bar = patches.Rectangle((1.2, y - 0.12), bar_width, 0.24, 
                                edgecolor=color, facecolor=color, alpha=0.7)
        ax.add_patch(bar)
        ax.text(1.1, y, tier, ha='right', va='center', fontsize=7)
        ax.text(1.2 + bar_width + 0.1, y, f'{rate}%  ({members:,})', 
                ha='left', va='center', fontsize=6)
    
    # Avg Spend Per Stay
    rect = patches.FancyBboxPatch((5.5, 5.5), 4, 2.8,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=GRAY, facecolor='white', linewidth=1.5)
    ax.add_patch(rect)
    ax.text(7.5, 8.1, 'Average Spend Per Stay by Tier', ha='center', fontsize=9, fontweight='bold')
    
    spend = [
        ('Diamond', 1170, PURPLE),
        ('Gold', 1078, GOLD),
        ('Silver', 990, '#9CA3AF'),
        ('Blue', 945, SNOWFLAKE_BLUE),
        ('Non-Member', 901, GRAY)
    ]
    for i, (tier, amount, color) in enumerate(spend):
        y = 7.6 - i * 0.45
        bar_width = amount / 350
        bar = patches.Rectangle((6.3, y - 0.12), bar_width, 0.24, 
                                edgecolor=color, facecolor=color, alpha=0.7)
        ax.add_patch(bar)
        ax.text(6.2, y, tier, ha='right', va='center', fontsize=7)
        ax.text(6.3 + bar_width + 0.1, y, f'${amount}', ha='left', va='center', fontsize=6, fontweight='bold')
    
    # At-Risk Segments Table
    rect = patches.FancyBboxPatch((0.5, 2.7), 9, 2.5,
                                   boxstyle="round,pad=0.1",
                                   edgecolor='#EF4444', facecolor='#FEF2F2', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 5.0, '⚠️ At-Risk Loyalty Segments (Immediate Intervention Required)', 
            ha='center', fontsize=9, fontweight='bold', color='#DC2626')
    
    # Table headers
    headers = ['Tier', 'At-Risk Members', 'Repeat Rate', 'Avg LTV', 'Revenue at Risk']
    for i, h in enumerate(headers):
        x = 1 + i * 1.8
        ax.text(x, 4.6, h, ha='center', fontsize=7, fontweight='bold')
    
    # Table data
    at_risk = [
        ('Diamond', '380 (7.6%)', '38.5%', '$8,200', '$3.1M annually'),
        ('Gold', '850 (8.5%)', '35.2%', '$5,400', '$4.6M annually'),
        ('Silver', '1,220 (8.1%)', '28.8%', '$3,600', '$4.4M annually')
    ]
    for row_idx, row_data in enumerate(at_risk):
        y = 4.2 - row_idx * 0.35
        for col_idx, val in enumerate(row_data):
            x = 1 + col_idx * 1.8
            ax.text(x, y, val, ha='center', fontsize=6)
    
    ax.text(5, 3.1, 'Recommended Actions: Diamond (Personal outreach) • Gold (Upgrade offers) • Silver (Engagement campaigns)', 
            ha='center', fontsize=6, style='italic')
    
    # AI-Powered Analysis Section
    rect = patches.FancyBboxPatch((0.5, 0.5), 9, 1.9,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=PURPLE, facecolor='#FAF5FF', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 2.2, '🤖 AI-Powered Analysis', ha='center', fontsize=10, fontweight='bold')
    
    questions = [
        '• "Which loyalty tier has the best repeat rate ROI?"',
        '• "Show me at-risk Diamond members in AMER region"',
        '• "What drives repeat stays for Silver members specifically?"'
    ]
    for i, q in enumerate(questions):
        ax.text(5, 1.8 - i * 0.25, q, ha='center', fontsize=7)
    
    button_rect = patches.FancyBboxPatch((3.5, 0.65), 3, 0.35,
                                         boxstyle="round,pad=0.05",
                                         edgecolor=SNOWFLAKE_BLUE, facecolor=SNOWFLAKE_BLUE)
    ax.add_patch(button_rect)
    ax.text(5, 0.82, '🤖 Open Snowflake Intelligence', ha='center', va='center', 
            fontsize=8, fontweight='bold', color='white')
    
    plt.tight_layout()
    plt.savefig(f'{OUTPUT_DIR}/loyalty_intelligence_dashboard.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"✓ Created loyalty_intelligence_dashboard.png")

def create_cx_service_dashboard():
    """Create CX & Service Signals Dashboard mockup."""
    fig, ax = plt.subplots(1, 1, figsize=(16, 11))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(5, 9.7, 'CX & Service Signals - Operational Excellence', 
            ha='center', fontsize=16, fontweight='bold')
    
    # 4 KPI Cards
    kpis = [
        ('Service Case\nRate', '78 per 1K', 'Benchmark: 50-100', SNOWFLAKE_BLUE),
        ('Avg Resolution\nTime', '16.5 hrs', 'Target: <24hrs', GREEN),
        ('Negative\nSentiment', '4.2%', 'Target: <5%', GREEN),
        ('Service Recovery\nSuccess', '72.5%', 'Target: >70%', GREEN)
    ]
    for i, (label, value, desc, color) in enumerate(kpis):
        x = 1.2 + i * 2.2
        y = 9
        rect = patches.FancyBboxPatch((x - 0.6, y - 0.4), 1.2, 0.7,
                                       boxstyle="round,pad=0.05",
                                       edgecolor=color, facecolor='white', linewidth=2)
        ax.add_patch(rect)
        ax.text(x, y + 0.15, label, ha='center', fontsize=7, fontweight='bold')
        ax.text(x, y - 0.05, value, ha='center', fontsize=9, fontweight='bold', color=color)
        ax.text(x, y - 0.25, desc, ha='center', fontsize=6)
    
    # Top 10 Service Issue Drivers
    rect = patches.FancyBboxPatch((0.5, 5.8), 4.5, 2.6,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=GRAY, facecolor='white', linewidth=1.5)
    ax.add_patch(rect)
    ax.text(2.75, 8.2, 'Top 5 Service Issue Drivers', ha='center', fontsize=9, fontweight='bold')
    
    issues = [
        ('Room Quality', 3240, 18, '#EF4444'),
        ('Service Delays', 2870, 16, '#F59E0B'),
        ('Amenity Issues', 2560, 14, GOLD),
        ('Billing Errors', 2220, 12, SNOWFLAKE_BLUE),
        ('Staff Behavior', 1890, 10, PURPLE)
    ]
    for i, (issue, cases, pct, color) in enumerate(issues):
        y = 7.7 - i * 0.45
        bar_width = pct / 5
        bar = patches.Rectangle((1.5, y - 0.12), bar_width, 0.24, 
                                edgecolor=color, facecolor=color, alpha=0.7)
        ax.add_patch(bar)
        ax.text(1.4, y, issue, ha='right', va='center', fontsize=7)
        ax.text(1.5 + bar_width + 0.1, y, f'{cases:,} ({pct}%)', 
                ha='left', va='center', fontsize=6)
    
    # Sentiment Distribution
    rect = patches.FancyBboxPatch((5.5, 5.8), 4, 2.6,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=GRAY, facecolor='white', linewidth=1.5)
    ax.add_patch(rect)
    ax.text(7.5, 8.2, 'Sentiment Distribution', ha='center', fontsize=9, fontweight='bold')
    
    sentiments = [
        ('😊 Positive', 78.5, GREEN),
        ('😐 Neutral', 17.3, GOLD),
        ('☹️  Negative', 4.2, '#EF4444')
    ]
    for i, (label, pct, color) in enumerate(sentiments):
        y = 7.5 - i * 0.6
        bar_width = pct / 25
        bar = patches.Rectangle((6.2, y - 0.15), bar_width, 0.3, 
                                edgecolor=color, facecolor=color, alpha=0.7)
        ax.add_patch(bar)
        ax.text(6.1, y, label, ha='right', va='center', fontsize=7)
        ax.text(6.2 + bar_width + 0.1, y, f'{pct}%', ha='left', va='center', fontsize=7, fontweight='bold')
    
    # At-Risk High-Value Guests Table
    rect = patches.FancyBboxPatch((0.5, 3.4), 4.5, 2.1,
                                   boxstyle="round,pad=0.1",
                                   edgecolor='#EF4444', facecolor='#FEF2F2', linewidth=2)
    ax.add_patch(rect)
    ax.text(2.75, 5.3, '⚠️ At-Risk High-Value Guests', ha='center', fontsize=9, fontweight='bold', color='#DC2626')
    
    # Table
    headers = ['Guest ID', 'LTV', 'Tier', 'Last Issue', 'Action']
    for i, h in enumerate(headers):
        x = 0.9 + i * 0.8
        ax.text(x, 5.0, h, ha='center', fontsize=6, fontweight='bold')
    
    guests = [
        ('G084521', '$18,200', 'Diamond', 'Room Quality', 'CEO Call'),
        ('G012489', '$14,500', 'Diamond', 'Service Delay', 'GM Visit'),
        ('G056723', '$12,800', 'Gold', 'Billing Error', 'Comp Stay')
    ]
    for row_idx, row_data in enumerate(guests):
        y = 4.65 - row_idx * 0.3
        for col_idx, val in enumerate(row_data):
            x = 0.9 + col_idx * 0.8
            ax.text(x, y, val, ha='center', fontsize=5.5)
    
    ax.text(2.75, 3.65, 'Total Revenue at Risk: $45.5K LTV | Immediate executive intervention required', 
            ha='center', fontsize=6, style='italic', color='#DC2626')
    
    # VIP Arrivals Watchlist
    rect = patches.FancyBboxPatch((5.5, 3.4), 4, 2.1,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=PURPLE, facecolor='#FAF5FF', linewidth=2)
    ax.add_patch(rect)
    ax.text(7.5, 5.3, '🎯 VIP Arrivals Watchlist (Next 7 Days)', ha='center', fontsize=9, fontweight='bold')
    
    # Table
    headers = ['Guest ID', 'Arrival', 'Property', 'Past Issues']
    for i, h in enumerate(headers):
        x = 5.9 + i * 0.9
        ax.text(x, 5.0, h, ha='center', fontsize=6, fontweight='bold')
    
    arrivals = [
        ('G024598', 'Tomorrow', 'Peak AMER #3', '🔴 2 in 6mo'),
        ('G078234', 'Day 3', 'Ice EMEA #12', '🟡 1 recent'),
        ('G091256', 'Day 5', 'Snowline #8', '🔴 3 historic')
    ]
    for row_idx, row_data in enumerate(arrivals):
        y = 4.65 - row_idx * 0.3
        for col_idx, val in enumerate(row_data):
            x = 5.9 + col_idx * 0.9
            ax.text(x, y, val, ha='center', fontsize=5.5)
    
    ax.text(7.5, 3.65, 'Action: Brief front desk • Pre-assign best rooms • GM greeting', 
            ha='center', fontsize=6, style='italic')
    
    # AI-Powered Analysis Section
    rect = patches.FancyBboxPatch((0.5, 0.5), 9, 2.6,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=PURPLE, facecolor='#FAF5FF', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 2.85, '🤖 AI-Powered Analysis', ha='center', fontsize=10, fontweight='bold')
    
    questions = [
        '• "Which properties have the highest service case escalation rates?"',
        '• "Show me VIPs arriving this week with past service issues"',
        '• "What are the top 3 drivers of negative sentiment in EMEA?"',
        '• "How effective is our service recovery for Diamond tier guests?"'
    ]
    for i, q in enumerate(questions):
        ax.text(5, 2.45 - i * 0.25, q, ha='center', fontsize=7)
    
    button_rect = patches.FancyBboxPatch((3.5, 0.65), 3, 0.35,
                                         boxstyle="round,pad=0.05",
                                         edgecolor=SNOWFLAKE_BLUE, facecolor=SNOWFLAKE_BLUE)
    ax.add_patch(button_rect)
    ax.text(5, 0.82, '🤖 Open Snowflake Intelligence', ha='center', va='center', 
            fontsize=8, fontweight='bold', color='white')
    
    plt.tight_layout()
    plt.savefig(f'{OUTPUT_DIR}/cx_service_signals_dashboard.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"✓ Created cx_service_signals_dashboard.png")

def main():
    """Generate all diagrams."""
    print("Generating solution presentation diagrams...")
    print("-" * 60)
    
    # Original diagrams
    create_architecture_diagram()
    create_ml_scoring_diagram()
    create_agents_diagram()
    create_amenity_analytics_diagram()
    create_data_sources_diagram()
    create_medallion_diagram()
    
    # New Intelligence Hub diagrams
    print("\nGenerating Intelligence Hub diagrams...")
    create_intelligence_hub_architecture()
    create_portfolio_dashboard()
    create_loyalty_dashboard()
    create_cx_service_dashboard()
    
    print("-" * 60)
    print(f"✓ All diagrams created in '{OUTPUT_DIR}/' directory")
    print("\nGenerated 10 diagrams:")
    print("  1. architecture_overview.png")
    print("  2. ml_scoring_models.png")
    print("  3. intelligence_agents.png")
    print("  4. unified_amenity_analytics.png")
    print("  5. data_sources.png")
    print("  6. medallion_architecture.png")
    print("  7. intelligence_hub_architecture.png")
    print("  8. portfolio_overview_dashboard.png")
    print("  9. loyalty_intelligence_dashboard.png")
    print(" 10. cx_service_signals_dashboard.png")
    print("\nDiagrams ready for use in solution presentations!")

if __name__ == '__main__':
    main()

