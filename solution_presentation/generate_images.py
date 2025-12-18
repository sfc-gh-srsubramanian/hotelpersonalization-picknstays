#!/usr/bin/env python3
"""
Generate presentation-quality diagrams for Hotel Personalization Solution Overview.

Creates 8 professional diagrams:
1. Architecture Overview
2. Data Sources
3. Medallion Architecture
4. ML Scoring Models
5. Intelligence Agents
6. Unified Amenity Analytics
7. Data Flow
8. Use Case Workflow

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
    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(5, 9.5, 'Hotel Personalization Platform - Architecture', 
            ha='center', fontsize=18, fontweight='bold')
    
    # Data Sources Layer
    sources = ['PMS', 'Booking\nSystems', 'Amenity\nSystems', 'WiFi/TV', 'Social\nMedia']
    for i, source in enumerate(sources):
        x = 1 + i * 1.8
        rect = patches.FancyBboxPatch((x - 0.3, 7.5), 0.6, 0.8,
                                       boxstyle="round,pad=0.05", 
                                       edgecolor=GRAY, facecolor=LIGHT_BLUE)
        ax.add_patch(rect)
        ax.text(x, 7.9, source, ha='center', va='center', fontsize=9)
    
    # Bronze Layer
    rect = patches.FancyBboxPatch((0.5, 5.8), 9, 1.2,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=DARK_BLUE, facecolor='#FEF3C7', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 6.7, 'BRONZE LAYER', ha='center', fontweight='bold', fontsize=12)
    ax.text(5, 6.2, '13 Raw Tables: Guests, Bookings, Amenities, Usage', 
            ha='center', fontsize=9)
    
    # Silver Layer
    rect = patches.FancyBboxPatch((0.5, 4.2), 9, 1.2,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=DARK_BLUE, facecolor='#DBEAFE', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 5.1, 'SILVER LAYER', ha='center', fontweight='bold', fontsize=12)
    ax.text(5, 4.6, '7 Enriched Tables: Cleaned, Standardized, Behavioral Analysis', 
            ha='center', fontsize=9)
    
    # Gold Layer
    rect = patches.FancyBboxPatch((0.5, 2.6), 9, 1.2,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=DARK_BLUE, facecolor='#FDE68A', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 3.5, 'GOLD LAYER', ha='center', fontweight='bold', fontsize=12)
    ax.text(5, 3.0, '3 Analytics Tables: 360° Profiles, ML Scores, Amenity Analytics', 
            ha='center', fontsize=9)
    
    # Semantic Layer
    rect = patches.FancyBboxPatch((0.5, 1.0), 9, 1.2,
                                   boxstyle="round,pad=0.1",
                                   edgecolor=DARK_BLUE, facecolor='#E9D5FF', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 1.9, 'SEMANTIC LAYER', ha='center', fontweight='bold', fontsize=12)
    ax.text(5, 1.4, '3 Semantic Views + 5 Intelligence Agents', 
            ha='center', fontsize=9)
    
    # Arrows
    for y in [7.3, 5.7, 4.1, 2.5]:
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
    """Create medallion architecture diagram."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    ax.text(5, 9.5, 'Medallion Architecture: Bronze → Silver → Gold', 
            ha='center', fontsize=14, fontweight='bold')
    
    layers = [
        ('BRONZE', 7, '#FEF3C7', '13 Raw Tables\nNo Transformation\nSource Fidelity'),
        ('SILVER', 4.5, '#DBEAFE', '7 Enriched Tables\nCleaned & Standardized\nBehavioral Analysis'),
        ('GOLD', 2, '#FDE68A', '3 Analytics Tables\n360° Profiles\nML Scores')
    ]
    
    for name, y, color, desc in layers:
        rect = patches.FancyBboxPatch((2, y - 0.8), 6, 1.6,
                                       boxstyle="round,pad=0.1",
                                       edgecolor=DARK_BLUE, facecolor=color, linewidth=2)
        ax.add_patch(rect)
        ax.text(5, y + 0.4, name, ha='center', fontweight='bold', fontsize=12)
        ax.text(5, y - 0.3, desc, ha='center', fontsize=8)
        
        if y > 2:
            ax.arrow(5, y - 0.9, 0, -0.5, head_width=0.3, head_length=0.1, 
                    fc=DARK_BLUE, ec=DARK_BLUE, linewidth=2)
    
    plt.tight_layout()
    plt.savefig(f'{OUTPUT_DIR}/medallion_architecture.png', dpi=300, bbox_inches='tight')
    plt.close()
    print(f"✓ Created medallion_architecture.png")

def main():
    """Generate all diagrams."""
    print("Generating solution presentation diagrams...")
    print("-" * 60)
    
    create_architecture_diagram()
    create_ml_scoring_diagram()
    create_agents_diagram()
    create_amenity_analytics_diagram()
    create_data_sources_diagram()
    create_medallion_diagram()
    
    print("-" * 60)
    print(f"✓ All diagrams created in '{OUTPUT_DIR}/' directory")
    print("\nDiagrams ready for use in solution presentations!")

if __name__ == '__main__':
    main()

