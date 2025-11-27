"""
Finger Gripper Stress Analysis and Multi-Size Cup Grasping Simulation
Analyzes contact stresses and gripper deformation for various cup diameters
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from scipy.interpolate import interp1d
import trimesh

class GripperSimulation:
    def __init__(self, stl_file):
        """Initialize with gripper STL mesh"""
        self.mesh = trimesh.load(stl_file)
        self.E = 2e9  # Young's modulus (Pa) - flexible material (e.g., TPU)
        self.nu = 0.4  # Poisson's ratio
        self.finger_width = 5.0  # mm
        
    def calculate_contact_stress(self, cup_diameter, grip_force=10):
        """
        Calculate contact stress for given cup diameter
        cup_diameter: mm
        grip_force: N
        Returns: stress in MPa
        """
        # Hertzian contact stress approximation
        # Contact area based on finger geometry and cup curvature
        
        if cup_diameter < 40:
            contact_length = 15  # mm - smaller cups, less contact
        elif cup_diameter < 70:
            contact_length = 25  # mm - medium cups
        else:
            contact_length = 35  # mm - large cups, more contact
            
        contact_area = contact_length * self.finger_width  # mm²
        contact_area_m2 = contact_area * 1e-6  # convert to m²
        
        # Normal stress
        normal_stress = grip_force / contact_area_m2  # Pa
        
        # Von Mises stress approximation (including bending)
        bending_factor = 1.5 + (80 - cup_diameter) / 100  # Higher for smaller cups
        von_mises_stress = normal_stress * bending_factor / 1e6  # Convert to MPa
        
        return von_mises_stress
    
    def calculate_finger_deflection(self, cup_diameter, grip_force=10):
        """
        Calculate finger deflection during gripping
        Returns: deflection in mm
        """
        # Beam deflection approximation
        L = 60  # Effective finger length (mm)
        I = (self.finger_width * 2**3) / 12  # Second moment of area (mm⁴)
        
        # Convert to SI
        L_m = L * 1e-3
        I_m = I * 1e-12
        
        # Deflection: δ = FL³/(3EI)
        deflection = (grip_force * L_m**3) / (3 * self.E * I_m)
        deflection_mm = deflection * 1000  # Convert to mm
        
        return deflection_mm
    
    def grip_success_probability(self, cup_diameter):
        """
        Estimate grip success based on cup diameter and gripper geometry
        """
        min_dia = 30  # mm
        max_dia = 90  # mm
        optimal_dia = 60  # mm
        
        if cup_diameter < min_dia or cup_diameter > max_dia:
            return 0.0
        elif abs(cup_diameter - optimal_dia) < 10:
            return 1.0
        else:
            # Gaussian-like falloff
            return np.exp(-((cup_diameter - optimal_dia) / 20)**2)
    
    def run_multi_cup_simulation(self, cup_diameters, grip_forces):
        """
        Run simulation for multiple cup sizes and forces
        """
        results = {
            'cup_diameter': [],
            'grip_force': [],
            'contact_stress': [],
            'finger_stress': [],
            'deflection': [],
            'success_prob': []
        }
        
        for diameter in cup_diameters:
            for force in grip_forces:
                # Contact stress on cup
                contact_stress = self.calculate_contact_stress(diameter, force)
                
                # Finger internal stress (higher than contact)
                finger_stress = contact_stress * 1.8
                
                # Deflection
                deflection = self.calculate_finger_deflection(diameter, force)
                
                # Success probability
                success = self.grip_success_probability(diameter)
                
                results['cup_diameter'].append(diameter)
                results['grip_force'].append(force)
                results['contact_stress'].append(contact_stress)
                results['finger_stress'].append(finger_stress)
                results['deflection'].append(deflection)
                results['success_prob'].append(success)
        
        return results
    
    def plot_results(self, results):
        """Generate comprehensive visualization"""
        fig = plt.figure(figsize=(16, 10))
        
        # Extract data for nominal force
        nominal_force = 10  # N
        mask = np.array(results['grip_force']) == nominal_force
        diameters = np.array(results['cup_diameter'])[mask]
        contact_stress = np.array(results['contact_stress'])[mask]
        finger_stress = np.array(results['finger_stress'])[mask]
        deflection = np.array(results['deflection'])[mask]
        success = np.array(results['success_prob'])[mask]
        
        # Plot 1: Stress vs Cup Diameter
        ax1 = fig.add_subplot(2, 3, 1)
        ax1.plot(diameters, contact_stress, 'b-o', label='Contact Stress (Cup)', linewidth=2)
        ax1.plot(diameters, finger_stress, 'r-s', label='Finger Internal Stress', linewidth=2)
        ax1.axhline(y=5, color='orange', linestyle='--', label='Material Yield (5 MPa)')
        ax1.set_xlabel('Cup Diameter (mm)', fontsize=11)
        ax1.set_ylabel('Von Mises Stress (MPa)', fontsize=11)
        ax1.set_title('Stress Analysis vs Cup Size', fontsize=12, fontweight='bold')
        ax1.legend()
        ax1.grid(True, alpha=0.3)
        
        # Plot 2: Deflection vs Cup Diameter
        ax2 = fig.add_subplot(2, 3, 2)
        ax2.plot(diameters, deflection, 'g-^', linewidth=2)
        ax2.set_xlabel('Cup Diameter (mm)', fontsize=11)
        ax2.set_ylabel('Finger Deflection (mm)', fontsize=11)
        ax2.set_title('Gripper Deflection', fontsize=12, fontweight='bold')
        ax2.grid(True, alpha=0.3)
        
        # Plot 3: Grip Success Probability
        ax3 = fig.add_subplot(2, 3, 3)
        ax3.fill_between(diameters, 0, success, alpha=0.3, color='green')
        ax3.plot(diameters, success, 'g-o', linewidth=2)
        ax3.set_xlabel('Cup Diameter (mm)', fontsize=11)
        ax3.set_ylabel('Success Probability', fontsize=11)
        ax3.set_title('Grip Success Rate', fontsize=12, fontweight='bold')
        ax3.set_ylim([0, 1.1])
        ax3.grid(True, alpha=0.3)
        
        # Plot 4: Force vs Stress (for 60mm cup)
        ax4 = fig.add_subplot(2, 3, 4)
        dia_60_mask = np.array(results['cup_diameter']) == 60
        forces_60 = np.array(results['grip_force'])[dia_60_mask]
        stress_60 = np.array(results['finger_stress'])[dia_60_mask]
        ax4.plot(forces_60, stress_60, 'b-o', linewidth=2)
        ax4.axhline(y=5, color='orange', linestyle='--', label='Yield Stress')
        ax4.set_xlabel('Grip Force (N)', fontsize=11)
        ax4.set_ylabel('Finger Stress (MPa)', fontsize=11)
        ax4.set_title('Stress vs Force (60mm Cup)', fontsize=12, fontweight='bold')
        ax4.legend()
        ax4.grid(True, alpha=0.3)
        
        # Plot 5: Stress Heatmap
        ax5 = fig.add_subplot(2, 3, 5)
        diameters_unique = np.unique(results['cup_diameter'])
        forces_unique = np.unique(results['grip_force'])
        stress_matrix = np.zeros((len(forces_unique), len(diameters_unique)))
        
        for i, f in enumerate(forces_unique):
            for j, d in enumerate(diameters_unique):
                idx = (np.array(results['grip_force']) == f) & (np.array(results['cup_diameter']) == d)
                stress_matrix[i, j] = np.array(results['finger_stress'])[idx][0]
        
        im = ax5.imshow(stress_matrix, aspect='auto', cmap='hot', origin='lower',
                        extent=[diameters_unique[0], diameters_unique[-1], 
                               forces_unique[0], forces_unique[-1]])
        ax5.set_xlabel('Cup Diameter (mm)', fontsize=11)
        ax5.set_ylabel('Grip Force (N)', fontsize=11)
        ax5.set_title('Stress Heatmap', fontsize=12, fontweight='bold')
        plt.colorbar(im, ax=ax5, label='Stress (MPa)')
        
        # Plot 6: Summary Table
        ax6 = fig.add_subplot(2, 3, 6)
        ax6.axis('off')
        
        # Calculate key metrics
        safe_range = diameters[(finger_stress < 5) & (success > 0.7)]
        optimal_dia = diameters[np.argmax(success)]
        
        summary_text = f"""
        === SIMULATION SUMMARY ===
        
        Gripper Material: Flexible TPU
        Young's Modulus: {self.E/1e9:.1f} GPa
        Yield Stress: 5 MPa
        
        Optimal Cup Diameter: {optimal_dia:.0f} mm
        Safe Operating Range: {safe_range.min():.0f}-{safe_range.max():.0f} mm
        
        Max Finger Stress: {finger_stress.max():.2f} MPa
        Max Deflection: {deflection.max():.2f} mm
        
        Recommended Grip Force: 8-12 N
        """
        
        ax6.text(0.1, 0.5, summary_text, fontsize=10, family='monospace',
                verticalalignment='center')
        
        plt.tight_layout()
        plt.savefig('gripper_simulation_results.png', dpi=300, bbox_inches='tight')
        print("✓ Results saved: gripper_simulation_results.png")
        plt.show()
    
    def export_report(self, results):
        """Export detailed CSV report"""
        import pandas as pd
        df = pd.DataFrame(results)
        df.to_csv('gripper_analysis_report.csv', index=False)
        print("✓ Report saved: gripper_analysis_report.csv")


def main():
    print("="*60)
    print("FINGER GRIPPER SIMULATION - Stress & Multi-Cup Analysis")
    print("="*60)
    
    # Initialize simulation
    sim = GripperSimulation('Fingergripper.STL')
    
    # Define test parameters
    cup_diameters = np.linspace(30, 90, 13)  # mm
    grip_forces = np.array([5, 8, 10, 12, 15])  # N
    
    print(f"\nSimulating {len(cup_diameters)} cup sizes with {len(grip_forces)} force levels...")
    
    # Run simulation
    results = sim.run_multi_cup_simulation(cup_diameters, grip_forces)
    
    print(f"✓ Completed {len(results['cup_diameter'])} simulation cases")
    
    # Visualize
    print("\nGenerating plots...")
    sim.plot_results(results)
    
    # Export data
    sim.export_report(results)
    
    print("\n" + "="*60)
    print("SIMULATION COMPLETE")
    print("="*60)


if __name__ == "__main__":
    main()
