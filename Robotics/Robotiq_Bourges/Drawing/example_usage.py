"""
Example usage of the ImageToGcode converter
This script shows how to use the converter with custom parameters
"""

from image_to_gcode import ImageToGcode
import os

# Example 1: Simple conversion
def simple_example(image_path):
    print("\n=== SIMPLE EXAMPLE ===")
    
    converter = ImageToGcode(image_path)
    converter.load_image()
    converter.extract_contours()
    converter.simplify_contours()
    converter.generate_gcode()
    
    # Save output
    output_path = "output_simple.gcode"
    converter.save_gcode(output_path)
    
    # Visualize
    converter.visualize()


# Example 2: Custom parameters for detailed drawing
def detailed_example(image_path):
    print("\n=== DETAILED EXAMPLE ===")
    
    converter = ImageToGcode(
        image_path=image_path,
        threshold_value=100,      # Lower threshold for more details
        epsilon_factor=0.002      # Less simplification
    )
    
    converter.load_image()
    converter.extract_contours()
    converter.simplify_contours()
    
    # Generate G-code with custom parameters
    converter.generate_gcode(
        feedrate=1500,    # Faster drawing
        z_draw=-2,        # Draw deeper
        z_safe=10,        # Move higher when not drawing
        scale=0.2         # Larger scale
    )
    
    output_path = "output_detailed.gcode"
    converter.save_gcode(output_path)
    
    # Visualize only the path
    converter.visualize(show_original=False, show_binary=False)


# Example 3: Simplified drawing
def simplified_example(image_path):
    print("\n=== SIMPLIFIED EXAMPLE ===")
    
    converter = ImageToGcode(
        image_path=image_path,
        threshold_value=150,      # Higher threshold
        epsilon_factor=0.02       # More simplification
    )
    
    converter.load_image()
    converter.extract_contours()
    converter.simplify_contours()
    converter.generate_gcode(scale=0.1)
    
    output_path = "output_simplified.gcode"
    converter.save_gcode(output_path)
    
    converter.visualize()


if __name__ == "__main__":
    # Get image path from user
    image_path = input("Enter the path to your image: ").strip().strip('"')
    
    if not os.path.exists(image_path):
        print(f"Error: Image not found at {image_path}")
    else:
        # Run simple example
        simple_example(image_path)
        
        # Uncomment to run other examples
        # detailed_example(image_path)
        # simplified_example(image_path)
