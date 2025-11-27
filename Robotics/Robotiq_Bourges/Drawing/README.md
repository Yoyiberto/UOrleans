# Image to G-code Converter

Convert PNG/JPG/JPEG images to G-code for robotic drawing or CNC machining.

## Features

1. **Load Image**: Supports PNG, JPG, and JPEG formats
2. **Contour Extraction**: Automatically detects edges and shapes
3. **Simplification**: Uses Douglas-Peucker algorithm to reduce points
4. **G-code Generation**: Creates standard G-code with customizable parameters
5. **Visualization**: Shows all processing steps and final path preview

## Installation

Install the required dependencies:

```bash
pip install -r requirements.txt
```

## Quick Start

### Method 1: Interactive Mode

Run the main script and follow the prompts:

```bash
python image_to_gcode.py
```

### Method 2: Use in Your Code

```python
from image_to_gcode import ImageToGcode

# Create converter
converter = ImageToGcode('your_image.png')

# Process image
converter.load_image()
converter.extract_contours()
converter.simplify_contours()

# Generate G-code
converter.generate_gcode(
    feedrate=1000,
    z_draw=-1,
    z_safe=5,
    scale=0.1
)

# Save and visualize
converter.save_gcode('output.gcode')
converter.visualize()
```

## Parameters

### ImageToGcode Constructor

- **image_path**: Path to input image (PNG/JPG/JPEG)
- **threshold_value**: Binary threshold (0-255)
  - Lower value = more details detected
  - Default: 127
- **epsilon_factor**: Contour simplification (0.001-0.05)
  - Lower value = more detail preserved
  - Default: 0.01

### generate_gcode() Parameters

- **feedrate**: Movement speed in mm/min (default: 1000)
- **z_draw**: Z height when drawing, negative = down (default: -1)
- **z_safe**: Z height when moving, positive = up (default: 5)
- **scale**: Coordinate scaling factor (default: 1.0)
  - Use 0.1 to convert pixels to mm (recommended)

## Output

### G-code File
- Standard G-code format
- Compatible with most CNC controllers
- Includes comments for clarity
- Absolute positioning (G90)
- Millimeter units (G21)

### Visualization
Shows 4 views:
1. Original image
2. Binary (thresholded) image
3. Detected contours overlaid
4. G-code path preview with start points

## Examples

### High Detail Drawing
```python
converter = ImageToGcode('logo.png', threshold_value=100, epsilon_factor=0.002)
converter.generate_gcode(feedrate=1500, scale=0.2)
```

### Simplified Drawing
```python
converter = ImageToGcode('shape.png', threshold_value=150, epsilon_factor=0.02)
converter.generate_gcode(feedrate=800, scale=0.1)
```

## Tips

1. **Image Preparation**:
   - Use high contrast images (black and white works best)
   - Remove noise for cleaner contours
   - Adjust image size before processing

2. **Parameter Tuning**:
   - Start with default values
   - Adjust `threshold_value` if too many/few contours
   - Adjust `epsilon_factor` to balance detail vs. smoothness

3. **G-code Testing**:
   - Always test G-code in a simulator first
   - Verify safe heights (z_safe) for your machine
   - Check scale factor matches your workspace

## Workflow

```
Image → Binary → Contour Detection → Simplification → G-code → Visualization
```

1. Load image and convert to grayscale
2. Apply binary threshold to separate foreground/background
3. Find contours using OpenCV
4. Simplify contours to reduce point count
5. Convert points to G-code commands
6. Visualize the result

## Files Generated

- `[imagename]_output.gcode`: The G-code file
- `preview.png`: Visualization of all processing steps

## License

Free to use and modify.
