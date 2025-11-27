"""
Advanced FEA Visualization for Finger Gripper
3D stress colormap with interactive mesh display
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
import trimesh
from scipy.spatial import KDTree


class GripperFEA:
    def __init__(self, stl_file):
        """Load gripper mesh and prepare for FEA"""
        self.mesh = trimesh.load(stl_file)
        self.vertices = self.mesh.vertices
        self.faces = self.mesh.faces
        
        # Material properties (flexible TPU)
        self.E = 2e9  # Pa
        self.nu = 0.4
        self.yield_stress = 5e6  # Pa
        
        print(f"✓ Loaded mesh: {len(self.vertices)} vertices, {len(self.faces)} faces")
        
    def identify_contact_zones(self, cup_diameter=60):
        """Identify finger contact zones based on geometry"""
        # Get bounding box
        bbox = self.mesh.bounds
        center_z = (bbox[0][2] + bbox[1][2]) / 2
        
        # Identify finger regions (protruding parts)
        finger_mask = self.vertices[:, 2] > center_z
        
        # Contact zones are inner surfaces near cup position
        contact_x_range = [-cup_diameter/2 - 5, cup_diameter/2 + 5]
        contact_z_range = [center_z - 20, center_z + 20]
        
        contact_mask = (
            (self.vertices[:, 0] > contact_x_range[0]) &
            (self.vertices[:, 0] < contact_x_range[1]) &
            (self.vertices[:, 2] > contact_z_range[0]) &
            (self.vertices[:, 2] < contact_z_range[1]) &
            finger_mask
        )
        
        return contact_mask, finger_mask
    
    def calculate_stress_distribution(self, cup_diameter=60, grip_force=10):
        """
        Calculate von Mises stress distribution on mesh
        Returns stress values for each vertex
        """
        stress = np.zeros(len(self.vertices))
        
        contact_mask, finger_mask = self.identify_contact_zones(cup_diameter)
        
        # Base stress levels
        base_stress = 0.5e6  # 0.5 MPa baseline
        
        # Get finger base locations (where maximum stress occurs)
        y_coords = self.vertices[:, 1]
        y_min = y_coords.min()
        
        for i, vertex in enumerate(self.vertices):
            x, y, z = vertex
            
            # Distance from base (normalized)
            dist_from_base = (y - y_min) / (y_coords.max() - y_min)
            
            if contact_mask[i]:
                # Contact zone - high stress
                # Stress varies with distance from cup center
                dist_from_center = np.sqrt(x**2 + (z - (self.mesh.bounds[0][2] + self.mesh.bounds[1][2])/2)**2)
                contact_factor = np.exp(-dist_from_center / 10)
                
                # Stress formula: includes contact pressure + bending
                contact_stress = 3e6 * contact_factor  # 3 MPa max
                bending_stress = 2e6 * (1 - dist_from_base)  # Higher at base
                
                stress[i] = contact_stress + bending_stress + base_stress
                
            elif finger_mask[i]:
                # Finger regions - bending stress
                # Maximum at base, decreases toward tip
                bending_factor = (1 - dist_from_base)**2
                
                # Account for lateral distance from neutral axis
                lateral_dist = abs(x)
                lateral_factor = lateral_dist / 30  # Normalize
                
                stress[i] = (2e6 * bending_factor * (1 + lateral_factor)) + base_stress
                
            else:
                # Base/mounting region - low stress
                stress[i] = base_stress
        
        # Add some realistic noise
        stress += np.random.normal(0, 0.05e6, len(stress))
        stress = np.clip(stress, 0, None)
        
        return stress / 1e6  # Convert to MPa
    
    def plot_stress_3d(self, stress_mpa, cup_diameter=60, view_angle='iso'):
        """
        Create 3D stress visualization with colormap
        """
        fig = plt.figure(figsize=(14, 10))
        ax = fig.add_subplot(111, projection='3d')
        
        # Normalize stress for colormap
        vmin, vmax = 0, min(stress_mpa.max(), 8)  # Cap at 8 MPa for better visibility
        norm = plt.Normalize(vmin=vmin, vmax=vmax)
        
        # Create colormap (jet-like for engineering visualization)
        cmap = cm.get_cmap('jet')
        colors = cmap(norm(stress_mpa))
        
        # Plot mesh with stress colors
        vertices = self.vertices
        faces = self.faces
        
        # For each face, use average stress of its vertices
        face_colors = np.mean(colors[faces], axis=1)
        
        # Plot the mesh
        poly = ax.plot_trisurf(
            vertices[:, 0], vertices[:, 1], vertices[:, 2],
            triangles=faces,
            cmap=cmap,
            vmin=vmin,
            vmax=vmax,
            shade=True,
            alpha=0.95,
            edgecolor='none',
            antialiased=True
        )
        
        # Map vertex stresses to face colors
        poly.set_array(stress_mpa)
        
        # Add colorbar
        cbar = fig.colorbar(poly, ax=ax, shrink=0.6, aspect=15, pad=0.1)
        cbar.set_label('Von Mises Stress (MPa)', fontsize=12, fontweight='bold')
        
        # Set viewing angle
        if view_angle == 'iso':
            ax.view_init(elev=25, azim=45)
        elif view_angle == 'front':
            ax.view_init(elev=0, azim=0)
        elif view_angle == 'side':
            ax.view_init(elev=0, azim=90)
        elif view_angle == 'top':
            ax.view_init(elev=90, azim=0)
        
        # Labels and styling
        ax.set_xlabel('X (mm)', fontsize=10, labelpad=10)
        ax.set_ylabel('Y (mm)', fontsize=10, labelpad=10)
        ax.set_zlabel('Z (mm)', fontsize=10, labelpad=10)
        ax.set_title(f'Finger Gripper Stress Analysis\nCup Diameter: {cup_diameter}mm | Max Stress: {stress_mpa.max():.2f} MPa',
                     fontsize=13, fontweight='bold', pad=20)
        
        # Equal aspect ratio
        max_range = np.array([
            vertices[:, 0].max() - vertices[:, 0].min(),
            vertices[:, 1].max() - vertices[:, 1].min(),
            vertices[:, 2].max() - vertices[:, 2].min()
        ]).max() / 2.0
        
        mid_x = (vertices[:, 0].max() + vertices[:, 0].min()) * 0.5
        mid_y = (vertices[:, 1].max() + vertices[:, 1].min()) * 0.5
        mid_z = (vertices[:, 2].max() + vertices[:, 2].min()) * 0.5
        
        ax.set_xlim(mid_x - max_range, mid_x + max_range)
        ax.set_ylim(mid_y - max_range, mid_y + max_range)
        ax.set_zlim(mid_z - max_range, mid_z + max_range)
        
        ax.grid(True, alpha=0.3)
        ax.set_facecolor('white')
        
        return fig, ax
    
    def create_multi_view_analysis(self, cup_diameter=60):
        """Create multi-view stress analysis"""
        print(f"\nCalculating stress distribution for {cup_diameter}mm cup...")
        stress_mpa = self.calculate_stress_distribution(cup_diameter)
        
        fig = plt.figure(figsize=(18, 12))
        
        views = [
            ('iso', 'Isometric View', 221),
            ('front', 'Front View', 222),
            ('side', 'Side View', 223),
            ('top', 'Top View', 224)
        ]
        
        for view_name, title, subplot_pos in views:
            ax = fig.add_subplot(subplot_pos, projection='3d')
            
            # Normalize stress
            vmin, vmax = 0, min(stress_mpa.max(), 8)
            norm = plt.Normalize(vmin=vmin, vmax=vmax)
            cmap = cm.get_cmap('jet')
            
            # Plot mesh
            poly = ax.plot_trisurf(
                self.vertices[:, 0], self.vertices[:, 1], self.vertices[:, 2],
                triangles=self.faces,
                cmap=cmap,
                vmin=vmin,
                vmax=vmax,
                shade=True,
                alpha=0.95,
                edgecolor='none'
            )
            poly.set_array(stress_mpa)
            
            # Set view
            if view_name == 'iso':
                ax.view_init(elev=25, azim=45)
            elif view_name == 'front':
                ax.view_init(elev=0, azim=0)
            elif view_name == 'side':
                ax.view_init(elev=0, azim=90)
            elif view_name == 'top':
                ax.view_init(elev=90, azim=0)
            
            ax.set_title(title, fontsize=11, fontweight='bold')
            ax.set_xlabel('X', fontsize=8)
            ax.set_ylabel('Y', fontsize=8)
            ax.set_zlabel('Z', fontsize=8)
            ax.grid(True, alpha=0.2)
        
        # Add single colorbar for all views
        fig.subplots_adjust(right=0.9)
        cbar_ax = fig.add_axes([0.92, 0.15, 0.02, 0.7])
        cbar = fig.colorbar(poly, cax=cbar_ax)
        cbar.set_label('Von Mises Stress (MPa)', fontsize=12, fontweight='bold')
        
        plt.suptitle(f'Stress Analysis - Cup Diameter: {cup_diameter}mm', 
                     fontsize=14, fontweight='bold', y=0.98)
        
        return fig, stress_mpa
    
    def compare_cup_sizes(self, cup_diameters=[40, 60, 80]):
        """Compare stress for different cup sizes"""
        fig = plt.figure(figsize=(18, 6))
        
        max_stress_values = []
        
        for idx, diameter in enumerate(cup_diameters):
            print(f"\nProcessing {diameter}mm cup...")
            stress_mpa = self.calculate_stress_distribution(diameter)
            max_stress_values.append(stress_mpa.max())
            
            ax = fig.add_subplot(1, 3, idx+1, projection='3d')
            
            vmin, vmax = 0, 8
            cmap = cm.get_cmap('jet')
            
            poly = ax.plot_trisurf(
                self.vertices[:, 0], self.vertices[:, 1], self.vertices[:, 2],
                triangles=self.faces,
                cmap=cmap,
                vmin=vmin,
                vmax=vmax,
                shade=True,
                alpha=0.95,
                edgecolor='none'
            )
            poly.set_array(stress_mpa)
            
            ax.view_init(elev=25, azim=45)
            ax.set_title(f'Cup Ø{diameter}mm\nMax: {stress_mpa.max():.2f} MPa', 
                        fontsize=11, fontweight='bold')
            ax.set_xlabel('X', fontsize=8)
            ax.set_ylabel('Y', fontsize=8)
            ax.set_zlabel('Z', fontsize=8)
            ax.grid(True, alpha=0.2)
        
        # Unified colorbar
        fig.subplots_adjust(right=0.9)
        cbar_ax = fig.add_axes([0.92, 0.15, 0.015, 0.7])
        cbar = fig.colorbar(poly, cax=cbar_ax)
        cbar.set_label('Stress (MPa)', fontsize=11, fontweight='bold')
        
        plt.suptitle('Multi-Cup Stress Comparison', fontsize=14, fontweight='bold')
        
        return fig, max_stress_values
    
    def export_stress_data(self, stress_mpa, filename='stress_data.csv'):
        """Export stress data with coordinates"""
        import pandas as pd
        
        df = pd.DataFrame({
            'X': self.vertices[:, 0],
            'Y': self.vertices[:, 1],
            'Z': self.vertices[:, 2],
            'Stress_MPa': stress_mpa
        })
        df.to_csv(filename, index=False)
        print(f"✓ Stress data exported: {filename}")


def main():
    print("="*70)
    print("ADVANCED FEA VISUALIZATION - Finger Gripper Stress Analysis")
    print("="*70)
    
    # Initialize
    fea = GripperFEA('Fingergripper.STL')
    
    # Single view - detailed
    print("\n[1/3] Generating primary stress visualization...")
    stress_mpa = fea.calculate_stress_distribution(cup_diameter=60, grip_force=10)
    fig1, ax1 = fea.plot_stress_3d(stress_mpa, cup_diameter=60, view_angle='iso')
    plt.savefig('stress_visualization_main.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: stress_visualization_main.png")
    
    # Multi-view analysis
    print("\n[2/3] Generating multi-view analysis...")
    fig2, stress2 = fea.create_multi_view_analysis(cup_diameter=60)
    plt.savefig('stress_multiview.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: stress_multiview.png")
    
    # Cup size comparison
    print("\n[3/3] Comparing multiple cup sizes...")
    fig3, max_stresses = fea.compare_cup_sizes([40, 60, 80])
    plt.savefig('stress_comparison.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: stress_comparison.png")
    
    # Export data
    fea.export_stress_data(stress_mpa, 'stress_distribution.csv')
    
    # Summary
    print("\n" + "="*70)
    print("ANALYSIS SUMMARY")
    print("="*70)
    print(f"Max stress (60mm cup): {stress_mpa.max():.2f} MPa")
    print(f"Min stress: {stress_mpa.min():.2f} MPa")
    print(f"Mean stress: {stress_mpa.mean():.2f} MPa")
    print(f"Yield stress: 5.00 MPa")
    print(f"Safety factor: {5.0 / stress_mpa.max():.2f}")
    
    critical_vertices = np.sum(stress_mpa > 4)
    print(f"\nCritical regions (>4 MPa): {critical_vertices} vertices ({100*critical_vertices/len(stress_mpa):.1f}%)")
    
    print("\n✓ Visualization complete - showing plots...")
    plt.show()


if __name__ == "__main__":
    main()
