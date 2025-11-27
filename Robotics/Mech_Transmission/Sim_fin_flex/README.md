# Finger Gripper Simulation

## Overview
Stress analysis and multi-cup grasping simulation for flexible finger gripper.

## Features
- **Contact stress analysis** on cup surface
- **Internal finger stress** calculation (von Mises)
- **3D stress visualization** with colormap overlay
- **Deflection modeling** for different cup sizes
- **Success probability** mapping (30-90mm diameter range)
- **Force-stress relationships**

## Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Run FEA visualization (3D colormap)
python fea_visualization.py

# Run parametric simulation (charts/analysis)
python gripper_simulation.py
```

## Outputs

### FEA Visualization (fea_visualization.py)
- `stress_visualization_main.png` - High-res 3D mesh with stress colormap
- `stress_multiview.png` - 4-view analysis (iso/front/side/top)
- `stress_comparison.png` - Side-by-side cup size comparison
- `stress_distribution.csv` - Vertex-level stress data

### Parametric Analysis (gripper_simulation.py)
- `gripper_simulation_results.png` - 6-panel charts
- `gripper_analysis_report.csv` - Full parametric sweep data

## Results Include
1. Stress vs cup diameter (contact + finger internal)
2. Finger deflection profile
3. Grip success probability
4. Force-stress curves
5. Stress heatmap (force × diameter)
6. Summary metrics

## Parameters
- **Cup diameters**: 30-90mm
- **Grip forces**: 5-15N
- **Material**: Flexible TPU (E=2 GPa, yield=5 MPa)

## Key Findings
- Optimal cup size: ~60mm diameter
- Safe range: 40-80mm
- Max recommended force: 12N
- Finger stress > contact stress (1.8× factor)
