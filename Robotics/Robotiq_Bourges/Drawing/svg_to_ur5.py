"""
SVG to UR5 Script Converter
Extracts path points from an SVG file and generates a UR5 script for drawing.
A4 paper dimensions: 210mm x 297mm (0.21m x 0.297m)
"""

import xml.etree.ElementTree as ET
import re
from svg.path import parse_path
from svg.path.path import Line, CubicBezier, QuadraticBezier, Arc
import numpy as np


def parse_svg_path(svg_file):
    """
    Parse SVG file and extract all path points.
    Returns a list of path segments (each segment is a list of points).
    """
    tree = ET.parse(svg_file)
    root = tree.getroot()
    
    # Extract viewBox or width/height for scaling
    viewbox = root.get('viewBox')
    if viewbox:
        _, _, svg_width, svg_height = map(float, viewbox.split())
    else:
        svg_width = float(root.get('width', '100').replace('px', ''))
        svg_height = float(root.get('height', '100').replace('px', ''))
    
    print(f"SVG dimensions: {svg_width} x {svg_height}")
    
    # Find all path elements
    paths = []
    namespaces = {'svg': 'http://www.w3.org/2000/svg'}
    
    for path_elem in root.findall('.//svg:path', namespaces):
        d = path_elem.get('d')
        if d:
            paths.append(parse_path(d))
    
    # Also try without namespace
    for path_elem in root.findall('.//path'):
        d = path_elem.get('d')
        if d:
            paths.append(parse_path(d))
    
    return paths, svg_width, svg_height


def path_to_points(path, num_points=50):
    """
    Convert a path to a list of discrete points.
    More complex curves get more points.
    """
    if len(path) == 0:
        return []
    
    points = []
    for segment in path:
        # Adjust number of points based on segment type
        if isinstance(segment, Line):
            n = 2
        elif isinstance(segment, (CubicBezier, QuadraticBezier, Arc)):
            n = num_points
        else:
            n = 10
        
        for i in range(n):
            t = i / (n - 1) if n > 1 else 0
            point = segment.point(t)
            points.append((point.real, point.imag))
    
    return points


def scale_to_a4(points, svg_width, svg_height, a4_width=0.21, a4_height=0.297, margin=0.02):
    """
    Scale points from SVG coordinates to A4 paper size in meters.
    Maintains aspect ratio and adds margin.
    Returns scaled points in meters.
    """
    if not points:
        return []
    
    # Available drawing area (with margins)
    draw_width = a4_width - 2 * margin
    draw_height = a4_height - 2 * margin
    
    # Calculate scale factor (maintain aspect ratio)
    scale_x = draw_width / svg_width
    scale_y = draw_height / svg_height
    scale = min(scale_x, scale_y)
    
    # Calculate offsets to center the drawing
    actual_width = svg_width * scale
    actual_height = svg_height * scale
    offset_x = (draw_width - actual_width) / 2 + margin
    offset_y = (draw_height - actual_height) / 2 + margin
    
    scaled_points = []
    for x, y in points:
        # SVG Y-axis is inverted (top-left origin)
        # Convert to robot coordinates (center origin, Y pointing up)
        scaled_x = x * scale + offset_x - a4_width / 2
        scaled_y = -(y * scale) + (svg_height * scale) + offset_y - a4_height / 2
        scaled_points.append((scaled_x, scaled_y))
    
    return scaled_points


def generate_ur5_script(path_segments, svg_width, svg_height, output_file='draw_image.script'):
    """
    Generate a UR5 script file from path segments.
    """
    with open(output_file, 'w') as f:
        f.write("def draw_image():\n")
        f.write("    # Get current TCP pose as starting reference (center of A4 paper)\n")
        f.write("    pose0 = get_actual_tcp_pose()\n")
        f.write("    x_c = pose0[0]\n")
        f.write("    y_c = pose0[1]\n")
        f.write("    z_c = pose0[2]\n")
        f.write("    rx  = pose0[3]\n")
        f.write("    ry  = pose0[4]\n")
        f.write("    rz  = pose0[5]\n\n")
        
        f.write("    # Movement parameters\n")
        f.write("    a = 0.3      # acceleration\n")
        f.write("    v = 0.05     # velocity\n")
        f.write("    z_lift = 0.01  # lift height between paths\n\n")
        
        f.write("    # A4 paper dimensions: 0.21m x 0.297m\n")
        f.write(f"    # SVG dimensions: {svg_width} x {svg_height}\n\n")
        
        # Process each path segment
        for idx, points in enumerate(path_segments):
            if not points:
                continue
            
            f.write(f"    # --- Path segment {idx + 1} ---\n")
            
            # Lift pen, move to start
            x, y = points[0]
            f.write(f"    # Move to start of segment (pen up)\n")
            f.write(f"    movel(p[x_c + {x:.6f}, y_c + {y:.6f}, z_c + z_lift, rx, ry, rz], a, v)\n")
            f.write(f"    # Lower pen\n")
            f.write(f"    movel(p[x_c + {x:.6f}, y_c + {y:.6f}, z_c, rx, ry, rz], a, v)\n\n")
            
            # Draw the path
            f.write(f"    # Draw path\n")
            for x, y in points[1:]:
                f.write(f"    movel(p[x_c + {x:.6f}, y_c + {y:.6f}, z_c, rx, ry, rz], a, v)\n")
            
            f.write("\n")
        
        f.write("    # Lift pen at end\n")
        f.write("    movel(p[x_c, y_c, z_c + z_lift, rx, ry, rz], a, v)\n")
        f.write("end\n\n")
        f.write("draw_image()\n")
    
    print(f"UR5 script generated: {output_file}")


def main(svg_file, output_file='draw_image.script', points_per_curve=30):
    """
    Main function to convert SVG to UR5 script.
    
    Args:
        svg_file: Path to input SVG file
        output_file: Path to output UR5 script file
        points_per_curve: Number of points to sample per curve
    """
    print(f"Processing SVG file: {svg_file}")
    
    try:
        # Parse SVG
        paths, svg_width, svg_height = parse_svg_path(svg_file)
        print(f"Found {len(paths)} path(s)")
        
        # Convert paths to points
        all_segments = []
        for i, path in enumerate(paths):
            points = path_to_points(path, num_points=points_per_curve)
            if points:
                # Scale to A4
                scaled_points = scale_to_a4(points, svg_width, svg_height)
                all_segments.append(scaled_points)
                print(f"Path {i + 1}: {len(points)} points")
        
        if not all_segments:
            print("Warning: No valid paths found in SVG")
            return
        
        # Generate UR5 script
        generate_ur5_script(all_segments, svg_width, svg_height, output_file)
        print(f"\nSuccess! Generated script with {len(all_segments)} path segments")
        print(f"Total points: {sum(len(seg) for seg in all_segments)}")
        print(f"\nUsage: Load {output_file} into your UR5 controller")
        print("Position the robot TCP at the CENTER of your A4 paper before running.")
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python svg_to_ur5.py <svg_file> [output_script] [points_per_curve]")
        print("\nExample: python svg_to_ur5.py logo.svg draw_logo.script 50")
        print("\nThis will convert an SVG image to a UR5 script for drawing on A4 paper.")
        print("The robot should be positioned at the CENTER of the A4 paper before running.")
        sys.exit(1)
    
    svg_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else 'draw_image.script'
    points_per_curve = int(sys.argv[3]) if len(sys.argv) > 3 else 30
    
    main(svg_file, output_file, points_per_curve)
