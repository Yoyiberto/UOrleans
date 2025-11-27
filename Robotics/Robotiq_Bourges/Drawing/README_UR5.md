# UR5 Drawing Scripts for A4 Paper

This toolkit converts SVG images or generates geometric shapes into UR5 robot scripts for drawing on A4 paper with a whiteboard marker.

## Features

- **SVG to UR5 Conversion**: Convert any SVG file to robot movements
- **Hardcoded Shapes**: Generate scripts for circles, stars, rectangles, spirals, and hearts
- **A4 Paper Scaling**: Automatically scales drawings to fit A4 paper (210mm × 297mm)
- **Center-based Positioning**: Robot starts from the center of the paper
- **Pen Lift Control**: Automatically lifts pen between disconnected paths

## Files

- `svg_to_ur5.py` - Main converter for SVG files
- `simple_shapes_example.py` - Generate scripts for basic geometric shapes
- `requirements_ur5.txt` - Python dependencies

## Installation

```bash
pip install -r requirements_ur5.txt
```

## Usage

### Option 1: Convert SVG File

```bash
python svg_to_ur5.py your_image.svg output_script.script 30
```

Parameters:
- `your_image.svg` - Input SVG file
- `output_script.script` - Output UR5 script (default: draw_image.script)
- `30` - Points per curve (default: 30, higher = smoother curves)

### Option 2: Generate Simple Shapes

**Single shape (centered):**
```bash
python simple_shapes_example.py circle draw_circle.script
python simple_shapes_example.py star draw_star.script
python simple_shapes_example.py heart draw_heart.script
```

**Grid of shapes:**
```bash
python simple_shapes_example.py grid draw_grid.script
```

Available shapes: `circle`, `star`, `rectangle`, `spiral`, `heart`

## Robot Setup

### Before Running:

1. **Position the robot**: Move the TCP (Tool Center Point) to the **CENTER** of your A4 paper
2. **Set Z-height**: Adjust the TCP so the marker just touches the paper at the current Z position
3. **Verify orientation**: Ensure the robot can move ±10.5cm in X and ±14.85cm in Y without obstacles
4. **Test marker**: Ensure the whiteboard marker is securely attached and writes properly

### A4 Paper Coordinate System:

```
        Y+ (Up)
         ↑
         |
    _____|_____
   |     |     |
   |  +--+--+  |  0.297m
   |  |  o  |  |  (height)
   |  +-----+  |
   |___________|
         |
    ←----+----→  X+ (Right)
      0.21m
     (width)
```

- Origin (0, 0) = Center of A4 paper
- X-axis: Left (-) to Right (+)
- Y-axis: Down (-) to Up (+)
- Z-axis: Away from paper (+) to touching paper (0)

### Script Parameters (adjustable in generated scripts):

```
a = 0.3      # Acceleration (m/s²)
v = 0.05     # Velocity (m/s) - adjust for marker quality
z_lift = 0.01  # Pen lift height (m) - adjust if marker drags
```

## Example: Custom Shape

Based on your Eiffel Tower example, here's the structure:

```
def draw_custom():
    # Get current position (center of paper)
    pose0 = get_actual_tcp_pose()
    x_c = pose0[0]
    y_c = pose0[1]
    z_c = pose0[2]
    rx  = pose0[3]
    ry  = pose0[4]
    rz  = pose0[5]

    a = 0.3
    v = 0.05
    z_lift = 0.01

    # Draw your custom points
    # All coordinates are relative to (x_c, y_c)
    movel(p[x_c + 0.05, y_c + 0.05, z_c, rx, ry, rz], a, v)
    movel(p[x_c - 0.05, y_c + 0.05, z_c, rx, ry, rz], a, v)
    # ... more points
end

draw_custom()
```

## Tips

1. **Start Small**: Test with simple shapes first before complex SVG files
2. **Adjust Speed**: Lower velocity (v) for better marker coverage
3. **Marker Pressure**: Adjust z_c if marker doesn't write or presses too hard
4. **SVG Preparation**: Simplify complex SVGs in Inkscape before conversion
5. **Path Direction**: Some markers write better in certain directions

## Scaling Reference

- Full A4 width: 0.21m (±0.105m from center)
- Full A4 height: 0.297m (±0.1485m from center)
- Recommended drawing area: ~0.17m × 0.25m (with 2cm margins)

## Troubleshooting

**Marker doesn't write:**
- Check z_c position (marker should touch paper)
- Increase marker pressure by lowering z_c by 0.001m increments
- Check marker ink

**Robot moves outside paper:**
- SVG might be too large for A4
- Check scaling in svg_to_ur5.py
- Verify robot position at paper center

**Choppy lines:**
- Increase points_per_curve in svg_to_ur5.py
- Reduce velocity (v) for smoother marker flow

**Marker drags between shapes:**
- Increase z_lift value
- Check that pen lifts properly between paths

## Safety

⚠️ **Always:**
- Test movements in simulation first
- Use slow speeds (v < 0.1 m/s) during initial tests
- Keep emergency stop accessible
- Ensure workspace is clear of obstacles
- Monitor first run closely

## License

Free to use and modify for educational and research purposes.
