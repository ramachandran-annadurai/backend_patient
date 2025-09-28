# Optional matplotlib import
try:
    import matplotlib.pyplot as plt
    import matplotlib.patches as patches
    MATPLOTLIB_AVAILABLE = True
except ImportError:
    print("⚠️ matplotlib not available, using fallback mode")
    MATPLOTLIB_AVAILABLE = False
    plt = None
    patches = None

from io import BytesIO
import base64
from typing import Dict
import math

class BabySizeImageGenerator:
    def __init__(self):
        self.week_sizes = {
            1: {"size": 0.1, "name": "Poppy seed"},
            2: {"size": 0.1, "name": "Poppy seed"},
            3: {"size": 0.2, "name": "Poppy seed"},
            4: {"size": 0.3, "name": "Poppy seed"},
            5: {"size": 0.5, "name": "Sesame seed"},
            6: {"size": 0.7, "name": "Sesame seed"},
            7: {"size": 1.0, "name": "Blueberry"},
            8: {"size": 1.3, "name": "Raspberry"},
            9: {"size": 1.7, "name": "Grape"},
            10: {"size": 2.1, "name": "Kumquat"},
            11: {"size": 2.5, "name": "Fig"},
            12: {"size": 3.0, "name": "Lime"},
            13: {"size": 3.5, "name": "Pea pod"},
            14: {"size": 4.0, "name": "Lemon"},
            15: {"size": 4.5, "name": "Apple"},
            16: {"size": 5.0, "name": "Avocado"},
            17: {"size": 5.5, "name": "Turnip"},
            18: {"size": 6.0, "name": "Bell pepper"},
            19: {"size": 6.5, "name": "Mango"},
            20: {"size": 7.0, "name": "Banana"},
            21: {"size": 7.5, "name": "Carrot"},
            22: {"size": 8.0, "name": "Papaya"},
            23: {"size": 8.5, "name": "Grapefruit"},
            24: {"size": 9.0, "name": "Cantaloupe"},
            25: {"size": 9.5, "name": "Cauliflower"},
            26: {"size": 10.0, "name": "Head of lettuce"},
            27: {"size": 10.5, "name": "Cabbage"},
            28: {"size": 11.0, "name": "Large eggplant"},
            29: {"size": 11.5, "name": "Butternut squash"},
            30: {"size": 12.0, "name": "Large cabbage"},
            31: {"size": 12.5, "name": "Coconut"},
            32: {"size": 13.0, "name": "Jicama"},
            33: {"size": 13.5, "name": "Pineapple"},
            34: {"size": 14.0, "name": "Cantaloupe"},
            35: {"size": 14.5, "name": "Honeydew melon"},
            36: {"size": 15.0, "name": "Romaine lettuce"},
            37: {"size": 15.5, "name": "Swiss chard"},
            38: {"size": 16.0, "name": "Leek"},
            39: {"size": 16.5, "name": "Mini watermelon"},
            40: {"size": 17.0, "name": "Small pumpkin"}
        }
    
    def generate_baby_size_image(self, week: int) -> str:
        """Generate a detailed baby size visualization image"""
        if not MATPLOTLIB_AVAILABLE or plt is None:
            return self._generate_fallback_image(week)
            
        if week < 1 or week > 40:
            week = 1
        
        # Get size data
        size_data = self.week_sizes.get(week, self.week_sizes[1])
        size_cm = size_data["size"]
        name = size_data["name"]
        
        # Create figure
        fig, ax = plt.subplots(1, 1, figsize=(10, 8))
        ax.set_xlim(0, 20)
        ax.set_ylim(0, 15)
        ax.set_aspect('equal')
        
        # Draw baby size circle
        circle = patches.Circle((10, 7.5), size_cm, 
                              facecolor='lightblue', 
                              edgecolor='darkblue', 
                              linewidth=2,
                              alpha=0.7)
        ax.add_patch(circle)
        
        # Add text
        ax.text(10, 7.5, f"👶", fontsize=min(50, size_cm * 20), 
                ha='center', va='center')
        
        # Add labels
        ax.text(10, 12, f"Week {week}", fontsize=16, fontweight='bold', ha='center')
        ax.text(10, 11, f"Size: {name}", fontsize=14, ha='center')
        ax.text(10, 10, f"Diameter: {size_cm} cm", fontsize=12, ha='center')
        
        # Add trimester info
        if week <= 12:
            trimester = 1
        elif week <= 28:
            trimester = 2
        else:
            trimester = 3
        
        ax.text(10, 9, f"Trimester {trimester}", fontsize=12, ha='center')
        
        # Add comparison objects
        self._add_comparison_objects(ax, size_cm)
        
        # Style the plot
        ax.set_xticks([])
        ax.set_yticks([])
        ax.spines['top'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['left'].set_visible(False)
        
        # Convert to base64
        buffer = BytesIO()
        plt.savefig(buffer, format='png', dpi=150, bbox_inches='tight')
        buffer.seek(0)
        image_base64 = base64.b64encode(buffer.getvalue()).decode()
        plt.close()
        
        return image_base64
    
    def generate_simple_baby_image(self, week: int) -> str:
        """Generate a simple baby size visualization"""
        if not MATPLOTLIB_AVAILABLE or plt is None:
            return self._generate_fallback_image(week)
            
        if week < 1 or week > 40:
            week = 1
        
        size_data = self.week_sizes.get(week, self.week_sizes[1])
        size_cm = size_data["size"]
        name = size_data["name"]
        
        # Create simple figure
        fig, ax = plt.subplots(1, 1, figsize=(6, 6))
        ax.set_xlim(0, 10)
        ax.set_ylim(0, 10)
        ax.set_aspect('equal')
        
        # Draw simple circle
        circle = patches.Circle((5, 5), size_cm * 2, 
                              facecolor='lightblue', 
                              edgecolor='darkblue', 
                              linewidth=2)
        ax.add_patch(circle)
        
        # Add text
        ax.text(5, 5, f"👶", fontsize=min(30, size_cm * 15), 
                ha='center', va='center')
        
        ax.text(5, 8, f"Week {week}", fontsize=14, fontweight='bold', ha='center')
        ax.text(5, 7, f"{name}", fontsize=12, ha='center')
        
        # Style
        ax.set_xticks([])
        ax.set_yticks([])
        for spine in ax.spines.values():
            spine.set_visible(False)
        
        # Convert to base64
        buffer = BytesIO()
        plt.savefig(buffer, format='png', dpi=100, bbox_inches='tight')
        buffer.seek(0)
        image_base64 = base64.b64encode(buffer.getvalue()).decode()
        plt.close()
        
        return image_base64
    
    def _add_comparison_objects(self, ax, size_cm):
        """Add comparison objects to the image"""
        # Add common objects for comparison
        objects = [
            {"name": "Coin", "size": 2.1, "y": 2, "color": "gold"},
            {"name": "Golf ball", "size": 4.3, "y": 1, "color": "white"},
            {"name": "Tennis ball", "size": 6.7, "y": 0, "color": "yellow"}
        ]
        
        for obj in objects:
            if size_cm <= obj["size"] * 1.5:  # Only show if baby is smaller
                circle = patches.Circle((3, obj["y"]), obj["size"]/2, 
                                      facecolor=obj["color"], 
                                      edgecolor='black', 
                                      linewidth=1,
                                      alpha=0.7)
                ax.add_patch(circle)
                ax.text(3, obj["y"] - 1, obj["name"], fontsize=8, ha='center')
    
    def _generate_fallback_image(self, week: int) -> str:
        """Generate fallback image when matplotlib is not available"""
        if week < 1 or week > 40:
            week = 1
        
        size_data = self.week_sizes.get(week, self.week_sizes[1])
        size_cm = size_data["size"]
        name = size_data["name"]
        
        # Create a simple text-based representation
        fallback_text = f"""
        Baby Size at Week {week}
        Size: {size_cm} cm
        Comparison: {name}
        
        [Image generation not available - matplotlib required]
        """
        
        # Return a simple base64 encoded text image
        import base64
        text_bytes = fallback_text.encode('utf-8')
        return base64.b64encode(text_bytes).decode('utf-8')

# Create global instance
baby_size_generator = BabySizeImageGenerator()
