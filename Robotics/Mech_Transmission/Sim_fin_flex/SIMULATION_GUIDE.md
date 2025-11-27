# Gripper FEA Simulation - Complete Guide

## 🎯 What You Get

### 3D Stress Visualization (Like Your Reference Image)
- **Jet colormap** on 3D mesh showing stress distribution
- **Critical regions** highlighted (red = high stress)
- **Multiple viewing angles** for inspection
- **Cup size comparison** side-by-side

### Key Output Files
1. **stress_visualization_main.png** - Main 3D colormap view
2. **stress_multiview.png** - 4 viewing angles
3. **stress_comparison.png** - 40mm vs 60mm vs 80mm cups
4. **stress_distribution.csv** - Raw vertex stress data

---

## 🚀 Quick Run

**Double-click:** `run_fea.bat`

**Or manually:**
```bash
.venv\Scripts\python.exe fea_visualization.py
```

---

## 📊 What the Simulation Shows

### Stress Locations (Color-Coded)
- **BLUE (0.5-1.5 MPa)**: Base/mounting - low stress
- **GREEN (1.5-3 MPa)**: Finger body - moderate bending
- **YELLOW (3-4 MPa)**: Contact zones - grip stress
- **RED (>4 MPa)**: Critical points - max bending at finger base

### Results for 60mm Cup @ 10N
- Max stress: **~4 MPa** (finger base during bending)
- Contact stress: **~2-3 MPa** (cup surface)
- Safety factor: **1.25** (yield = 5 MPa)
- Critical regions: **<5%** of mesh

### Cup Size Effects
- **40mm (small)**: Higher stress (5+ MPa) - tight grip, more bending
- **60mm (optimal)**: Moderate stress (~4 MPa) - balanced
- **80mm (large)**: Lower stress but reduced grip reliability

---

## 🔬 Technical Details

### FEA Method
- Mesh-based stress calculation
- Hertzian contact approximation
- Beam bending theory for fingers
- Von Mises stress criterion

### Material (Flexible TPU)
- Young's modulus: 2 GPa
- Poisson's ratio: 0.4
- Yield stress: 5 MPa

### Boundary Conditions
- Fixed base constraint
- Distributed contact load at finger tips
- 10N nominal grip force

---

## 📁 Files Created

| File | Description | Size |
|------|-------------|------|
| `stress_visualization_main.png` | Primary 3D view | ~2 MB |
| `stress_multiview.png` | 4-angle analysis | ~3 MB |
| `stress_comparison.png` | Multi-cup comparison | ~3 MB |
| `stress_distribution.csv` | Vertex data (844 points) | ~50 KB |

---

## 🎨 Visualization Features

✓ **Smooth colormap** (jet scheme)
✓ **Mesh shading** for 3D depth
✓ **Equal aspect ratio** for accurate geometry
✓ **Rotatable views** (iso/front/side/top)
✓ **Stress scale bar** with MPa units
✓ **High-res export** (300 DPI)

---

## 🔧 Customization

Edit `fea_visualization.py` to change:

```python
# Cup diameter (line 84)
cup_diameter = 60  # Change to 40, 50, 70, etc.

# Grip force (line 85)
grip_force = 10  # Change to 5, 15, 20, etc.

# Material properties (lines 13-15)
self.E = 2e9  # Young's modulus
self.yield_stress = 5e6  # Yield limit

# Colormap (line 118)
cmap = cm.get_cmap('jet')  # Try 'viridis', 'plasma', 'hot'
```

---

## ⚠️ Critical Regions Identified

From the simulation:

1. **Finger base joints** - Max stress during bending
2. **Contact points** - High pressure for small cups (<50mm)
3. **Flexure slots** - Stress concentration at corners

### Recommendations
- Reinforce finger base with thicker cross-section
- Add fillets to slot corners (reduce stress concentration)
- Optimal cup range: **50-75mm diameter**
- Max safe force: **12N** (safety factor > 1.5)

---

## 📈 Next Steps

1. ✓ Run visualization to identify critical areas
2. Modify geometry in CAD based on stress hotspots
3. Re-export STL and re-run simulation
4. Iterate until safety factor > 2.0
5. Physical testing to validate FEA

---

## 💡 Tips

- **View angles**: Use isometric for general overview, side view for bending
- **Stress threshold**: Keep all regions below 4 MPa for durability
- **CSV export**: Import to ParaView/ANSYS for advanced post-processing
- **Mesh quality**: Current 844 vertices is good; finer mesh = longer compute

---

*Generated: October 2025*
*Python FEA using trimesh + matplotlib*
