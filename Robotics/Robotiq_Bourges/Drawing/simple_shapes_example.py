"""
Simple example: Generate UR5 scripts for basic shapes without SVG input.
Creates hardcoded points for common shapes scaled to A4 paper.
"""

import numpy as np


def generate_circle(center_x=0, center_y=0, radius=0.05, num_points=36):
    """Generate points for a circle."""
    points = []
    for i in range(num_points + 1):
        angle = 2 * np.pi * i / num_points
        x = center_x + radius * np.cos(angle)
        y = center_y + radius * np.sin(angle)
        points.append((x, y))
    return points


def generate_star(center_x=0, center_y=0, outer_radius=0.06, inner_radius=0.025, num_points=5):
    """Generate points for a star."""
    points = []
    for i in range(num_points * 2 + 1):
        angle = -np.pi / 2 + (2 * np.pi * i) / (num_points * 2)
        radius = outer_radius if i % 2 == 0 else inner_radius
        x = center_x + radius * np.cos(angle)
        y = center_y + radius * np.sin(angle)
        points.append((x, y))
    return points


def generate_rectangle(center_x=0, center_y=0, width=0.08, height=0.06):
    """Generate points for a rectangle."""
    w2, h2 = width / 2, height / 2
    return [
        (center_x - w2, center_y - h2),
        (center_x + w2, center_y - h2),
        (center_x + w2, center_y + h2),
        (center_x - w2, center_y + h2),
        (center_x - w2, center_y - h2)
    ]


def generate_spiral(center_x=0, center_y=0, max_radius=0.07, num_turns=3, points_per_turn=20):
    """Generate points for a spiral."""
    points = []
    total_points = num_turns * points_per_turn
    for i in range(total_points + 1):
        t = i / points_per_turn
        angle = 2 * np.pi * t
        radius = max_radius * (t / num_turns)
        x = center_x + radius * np.cos(angle)
        y = center_y + radius * np.sin(angle)
        points.append((x, y))
    return points


def generate_heart(center_x=0, center_y=0, size=0.05, num_points=100):
    """Generate points for a heart shape."""
    points = []
    for i in range(num_points + 1):
        t = 2 * np.pi * i / num_points
        x = size * 16 * np.sin(t)**3
        y = size * (13 * np.cos(t) - 5 * np.cos(2*t) - 2 * np.cos(3*t) - np.cos(4*t))
        points.append((center_x + x/16, center_y + y/16))
    return points


def write_ur5_script(shapes, output_file='draw_shapes.script'):
    """
    Write a UR5 script with multiple shapes.
    
    Args:
        shapes: List of (name, points_list) tuples
        output_file: Output script filename
    """
    with open(output_file, 'w') as f:
        f.write("def draw_shapes():\n")
        f.write("    # Get current TCP pose as starting reference (center of A4 paper)\n")
        f.write("    pose0 = get_actual_tcp_pose()\n")
        f.write("    x_c = pose0[0]\n")
        f.write("    y_c = pose0[1]\n")
        f.write("    z_c = pose0[2]\n")
        f.write("    rx  = pose0[3]\n")
        f.write("    ry  = pose0[4]\n")
        f.write("    rz  = pose0[5]\n\n")
        
        f.write("    # Movement parameters\n")
        f.write("    a = 0.3      # acceleration (m/s²)\n")
        f.write("    v = 0.05     # velocity (m/s)\n")
        f.write("    z_lift = 0.01  # lift height between shapes (m)\n\n")
        
        f.write("    # All coordinates are relative to center of A4 paper\n")
        f.write("    # A4 dimensions: 0.21m (width) x 0.297m (height)\n\n")
        
        for shape_name, points in shapes:
            if not points:
                continue
            
            f.write(f"    # --- {shape_name} ---\n")
            
            # Move to start with pen up
            x, y = points[0]
            f.write(f"    # Move to start (pen up)\n")
            f.write(f"    movel(p[x_c + {x:.6f}, y_c + {y:.6f}, z_c + z_lift, rx, ry, rz], a, v)\n")
            f.write(f"    # Lower pen\n")
            f.write(f"    movel(p[x_c + {x:.6f}, y_c + {y:.6f}, z_c, rx, ry, rz], a, v)\n\n")
            
            # Draw the shape
            f.write(f"    # Draw {shape_name}\n")
            for x, y in points[1:]:
                f.write(f"    movel(p[x_c + {x:.6f}, y_c + {y:.6f}, z_c, rx, ry, rz], a, v)\n")
            
            f.write(f"    # Lift pen\n")
            f.write(f"    movel(p[x_c + {x:.6f}, y_c + {y:.6f}, z_c + z_lift, rx, ry, rz], a, v)\n\n")
        
        f.write("    # Return to center\n")
        f.write("    movel(p[x_c, y_c, z_c + z_lift, rx, ry, rz], a, v)\n")
        f.write("end\n\n")
        f.write("draw_shapes()\n")
    
    print(f"UR5 script generated: {output_file}")


def create_grid_of_shapes(output_file='draw_grid.script'):
    """Create a grid of different shapes on A4 paper."""
    # Position shapes in a grid (3x2)
    # A4 paper: 0.21m x 0.297m, centered at (0, 0)
    positions = [
        (-0.06, 0.08),   # top-left
        (0.0, 0.08),     # top-center
        (0.06, 0.08),    # top-right
        (-0.06, -0.02),  # bottom-left
        (0.0, -0.02),    # bottom-center
        (0.06, -0.02)    # bottom-right
    ]
    
    shapes = [
        ("Circle", generate_circle(positions[0][0], positions[0][1], 0.025)),
        ("Star", generate_star(positions[1][0], positions[1][1], 0.03, 0.012)),
        ("Rectangle", generate_rectangle(positions[2][0], positions[2][1], 0.04, 0.03)),
        ("Spiral", generate_spiral(positions[3][0], positions[3][1], 0.03, 2)),
        ("Heart", generate_heart(positions[4][0], positions[4][1], 0.03)),
        ("Small Circle", generate_circle(positions[5][0], positions[5][1], 0.015))
    ]
    
    write_ur5_script(shapes, output_file)
    
    print(f"\nGenerated grid of shapes:")
    for name, points in shapes:
        print(f"  - {name}: {len(points)} points")
    print(f"\nPosition the robot TCP at the CENTER of your A4 paper before running.")


def create_single_shape(shape_type='circle', output_file='draw_shape.script'):
    """Create a single centered shape."""
    shape_generators = {
        'circle': lambda: generate_circle(0, 0, 0.08),
        'star': lambda: generate_star(0, 0, 0.09, 0.036),
        'rectangle': lambda: generate_rectangle(0, 0, 0.12, 0.09),
        'spiral': lambda: generate_spiral(0, 0, 0.09, 4),
        'heart': lambda: generate_heart(0, 0, 0.08)
    }
    
    if shape_type not in shape_generators:
        print(f"Unknown shape type: {shape_type}")
        print(f"Available shapes: {', '.join(shape_generators.keys())}")
        return
    
    points = shape_generators[shape_type]()
    shapes = [(shape_type.capitalize(), points)]
    
    write_ur5_script(shapes, output_file)
    print(f"\nGenerated {shape_type}: {len(points)} points")
    print(f"Position the robot TCP at the CENTER of your A4 paper before running.")


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python simple_shapes_example.py grid [output_file]")
        print("  python simple_shapes_example.py <shape_type> [output_file]")
        print("\nShape types: circle, star, rectangle, spiral, heart")
        print("\nExamples:")
        print("  python simple_shapes_example.py grid")
        print("  python simple_shapes_example.py circle draw_circle.script")
        print("  python simple_shapes_example.py star")
        sys.exit(1)
    
    command = sys.argv[1].lower()
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    if command == 'grid':
        output_file = output_file or 'draw_grid.script'
        create_grid_of_shapes(output_file)
    else:
        output_file = output_file or f'draw_{command}.script'
        create_single_shape(command, output_file)
