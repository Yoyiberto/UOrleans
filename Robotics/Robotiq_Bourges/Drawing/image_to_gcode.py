import cv2
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from matplotlib.collections import LineCollection
import os

class ImageToGcode:
    def __init__(self, image_path, threshold_value=127, epsilon_factor=0.01):
        """
        Initialize the image to G-code converter
        
        Parameters:
        - image_path: Path to the input image
        - threshold_value: Threshold for binary conversion (0-255)
        - epsilon_factor: Contour simplification factor (smaller = more detail)
        """
        self.image_path = image_path
        self.threshold_value = threshold_value
        self.epsilon_factor = epsilon_factor
        self.original_image = None
        self.binary_image = None
        self.contours = None
        self.simplified_contours = None
        self.gcode = []
        
    def load_image(self):
        """Load and preprocess the image"""
        # Read image
        self.original_image = cv2.imread(self.image_path)
        if self.original_image is None:
            raise ValueError(f"Could not load image from {self.image_path}")
        
        # Convert to grayscale
        gray = cv2.cvtColor(self.original_image, cv2.COLOR_BGR2GRAY)
        
        # Apply binary threshold
        _, self.binary_image = cv2.threshold(gray, self.threshold_value, 255, cv2.THRESH_BINARY_INV)
        
        print(f"✓ Image loaded: {self.original_image.shape}")
        return self.binary_image
    
    def extract_contours(self):
        """Extract contours from the binary image"""
        if self.binary_image is None:
            self.load_image()
        
        # Find contours
        contours, hierarchy = cv2.findContours(
            self.binary_image, 
            cv2.RETR_TREE, 
            cv2.CHAIN_APPROX_SIMPLE
        )
        
        self.contours = contours
        print(f"✓ Found {len(contours)} contours")
        return contours
    
    def simplify_contours(self):
        """Simplify contours using Douglas-Peucker algorithm"""
        if self.contours is None:
            self.extract_contours()
        
        self.simplified_contours = []
        
        for contour in self.contours:
            # Calculate epsilon as a percentage of the contour perimeter
            epsilon = self.epsilon_factor * cv2.arcLength(contour, True)
            
            # Approximate contour
            simplified = cv2.approxPolyDP(contour, epsilon, True)
            
            # Only keep contours with at least 3 points
            if len(simplified) >= 3:
                self.simplified_contours.append(simplified)
        
        print(f"✓ Simplified to {len(self.simplified_contours)} contours")
        return self.simplified_contours
    
    def generate_gcode(self, feedrate=1000, z_draw=-1, z_safe=5, scale=1.0):
        """
        Generate G-code from simplified contours
        
        Parameters:
        - feedrate: Feed rate in mm/min
        - z_draw: Z height when drawing (negative = down)
        - z_safe: Z height when moving (positive = up)
        - scale: Scaling factor for coordinates
        """
        if self.simplified_contours is None:
            self.simplify_contours()
        
        self.gcode = []
        
        # G-code header
        self.gcode.append("; G-code generated from image")
        self.gcode.append(f"; Image: {os.path.basename(self.image_path)}")
        self.gcode.append(f"; Contours: {len(self.simplified_contours)}")
        self.gcode.append("")
        self.gcode.append("G21 ; Set units to millimeters")
        self.gcode.append("G90 ; Absolute positioning")
        self.gcode.append(f"G0 Z{z_safe} F{feedrate} ; Move to safe height")
        self.gcode.append("G0 X0 Y0 ; Move to origin")
        self.gcode.append("")
        
        # Process each contour
        for idx, contour in enumerate(self.simplified_contours):
            self.gcode.append(f"; Contour {idx + 1} ({len(contour)} points)")
            
            for i, point in enumerate(contour):
                x = point[0][0] * scale
                y = point[0][1] * scale
                
                if i == 0:
                    # Move to start position with pen up
                    self.gcode.append(f"G0 Z{z_safe} ; Pen up")
                    self.gcode.append(f"G0 X{x:.3f} Y{y:.3f} ; Move to start")
                    self.gcode.append(f"G1 Z{z_draw} F{feedrate} ; Pen down")
                else:
                    # Draw line
                    self.gcode.append(f"G1 X{x:.3f} Y{y:.3f}")
            
            # Close the contour
            first_point = contour[0][0]
            x = first_point[0] * scale
            y = first_point[1] * scale
            self.gcode.append(f"G1 X{x:.3f} Y{y:.3f} ; Close contour")
            self.gcode.append("")
        
        # G-code footer
        self.gcode.append(f"G0 Z{z_safe} ; Pen up")
        self.gcode.append("G0 X0 Y0 ; Return to origin")
        self.gcode.append("M2 ; End program")
        
        print(f"✓ Generated {len(self.gcode)} lines of G-code")
        return self.gcode
    
    def save_gcode(self, output_path):
        """Save G-code to file"""
        if not self.gcode:
            self.generate_gcode()
        
        with open(output_path, 'w') as f:
            f.write('\n'.join(self.gcode))
        
        print(f"✓ G-code saved to: {output_path}")
    
    def visualize(self, show_original=True, show_binary=True, show_contours=True, show_path=True):
        """Visualize the processing steps and final result"""
        if self.simplified_contours is None:
            self.simplify_contours()
        
        num_plots = sum([show_original, show_binary, show_contours, show_path])
        fig, axes = plt.subplots(1, num_plots, figsize=(5*num_plots, 5))
        
        if num_plots == 1:
            axes = [axes]
        
        plot_idx = 0
        
        # Original image
        if show_original:
            axes[plot_idx].imshow(cv2.cvtColor(self.original_image, cv2.COLOR_BGR2RGB))
            axes[plot_idx].set_title('Original Image')
            axes[plot_idx].axis('off')
            plot_idx += 1
        
        # Binary image
        if show_binary:
            axes[plot_idx].imshow(self.binary_image, cmap='gray')
            axes[plot_idx].set_title('Binary Image')
            axes[plot_idx].axis('off')
            plot_idx += 1
        
        # Contours on original
        if show_contours:
            img_with_contours = self.original_image.copy()
            cv2.drawContours(img_with_contours, self.simplified_contours, -1, (0, 255, 0), 2)
            axes[plot_idx].imshow(cv2.cvtColor(img_with_contours, cv2.COLOR_BGR2RGB))
            axes[plot_idx].set_title(f'Simplified Contours ({len(self.simplified_contours)})')
            axes[plot_idx].axis('off')
            plot_idx += 1
        
        # Drawing path visualization
        if show_path:
            axes[plot_idx].set_aspect('equal')
            axes[plot_idx].set_title('G-code Path Preview')
            axes[plot_idx].set_xlabel('X (pixels)')
            axes[plot_idx].set_ylabel('Y (pixels)')
            
            # Draw each contour as a path
            for idx, contour in enumerate(self.simplified_contours):
                points = contour.reshape(-1, 2)
                
                # Close the contour
                points = np.vstack([points, points[0]])
                
                # Plot the path
                axes[plot_idx].plot(points[:, 0], points[:, 1], 'b-', linewidth=1.5, alpha=0.7)
                axes[plot_idx].plot(points[0, 0], points[0, 1], 'go', markersize=8, label='Start' if idx == 0 else '')
                axes[plot_idx].plot(points[:, 0], points[:, 1], 'r.', markersize=3)
            
            # Invert Y axis to match image coordinates
            axes[plot_idx].invert_yaxis()
            axes[plot_idx].grid(True, alpha=0.3)
            if len(self.simplified_contours) > 0:
                axes[plot_idx].legend()
        
        plt.tight_layout()
        plt.savefig('preview.png', dpi=150, bbox_inches='tight')
        print("✓ Preview saved as 'preview.png'")
        plt.show()
        
        return fig


def main():
    """Example usage"""
    print("=" * 60)
    print("IMAGE TO G-CODE CONVERTER")
    print("=" * 60)
    print()
    
    # Check for example image
    image_path = input("Enter the path to your image (png/jpg/jpeg): ").strip().strip('"')
    
    if not os.path.exists(image_path):
        print(f"Error: Image not found at {image_path}")
        return
    
    print()
    print("Processing...")
    print("-" * 60)
    
    # Create converter instance
    converter = ImageToGcode(
        image_path=image_path,
        threshold_value=127,  # Adjust this (0-255) for better edge detection
        epsilon_factor=0.005  # Adjust this (0.001-0.05) for simplification
    )
    
    # Process image
    converter.load_image()
    converter.extract_contours()
    converter.simplify_contours()
    
    # Generate G-code
    converter.generate_gcode(
        feedrate=1000,
        z_draw=-1,
        z_safe=5,
        scale=0.1  # Scale down from pixels to mm
    )
    
    # Save G-code
    output_gcode = os.path.splitext(image_path)[0] + '_output.gcode'
    converter.save_gcode(output_gcode)
    
    print("-" * 60)
    print()
    print("Visualizing results...")
    
    # Visualize
    converter.visualize()
    
    print()
    print("=" * 60)
    print("DONE!")
    print(f"G-code file: {output_gcode}")
    print("=" * 60)


if __name__ == "__main__":
    main()
