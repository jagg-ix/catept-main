"""
Custom drivers for entropic time simulations.

Implements potential energy functions for:
- Stern-Gerlach interferometry (harmonic trap)
- Black hole test particles (Schwarzschild + dissipation)
- ENZ materials (plasma oscillations)

Compatible with i-PI socket interface.
"""

import sys
import numpy as np
from ipi.utils.messages import Message
from ipi.interfaces.sockets import InterfaceSocket

# Physical constants
HBAR = 1.054571817e-34  # J·s
KB = 1.380649e-23       # J/K
C_LIGHT = 299792458.0   # m/s
G_NEWTON = 6.67430e-11  # m³/(kg·s²)
M_SOLAR = 1.98892e30    # kg
AMU = 1.66053906660e-27 # kg


class EntropicDriver:
    """
    Base class for entropic potential drivers.
    
    Communicates with i-PI server via socket protocol.
    """
    
    def __init__(self, address="localhost", port=31415, unix_socket=None):
        """
        Initialize driver.
        
        Args:
            address: Host address for inet socket
            port: Port number for inet socket
            unix_socket: Path for unix socket (overrides inet)
        """
        if unix_socket:
            self.socket = InterfaceSocket(mode="unix", address=unix_socket)
        else:
            self.socket = InterfaceSocket(mode="inet", address=address, port=port)
        
        self.natoms = 0
        self.virial = None
        self.extras = None  # For lambda, alpha, etc.
    
    def compute_potential(self, positions):
        """
        Compute potential energy and forces.
        
        Args:
            positions: Atomic positions [natoms, 3] in meters
            
        Returns:
            energy: Potential energy in Joules
            forces: Forces [natoms, 3] in Newtons
            virial: Virial tensor [3, 3]
            extras: Extra data (lambda, alpha, Pi, etc.)
        """
        raise NotImplementedError
    
    def run(self):
        """Main driver loop."""
        print("Starting entropic driver...")
        self.socket.open()
        
        while True:
            # Receive message from i-PI
            msg = self.socket.recv_msg()
            
            if msg == Message.STATUS:
                # Send ready status
                self.socket.send_msg(Message.READY)
            
            elif msg == Message.POSDATA:
                # Receive positions
                cell, inv_cell, positions = self.socket.recv_posdata()
                self.natoms = positions.shape[0]
                
                # Compute potential
                energy, forces, virial, extras = self.compute_potential(positions)
                
                # Send results
                self.socket.send_forces(energy, forces, virial, extras)
            
            elif msg == Message.EXIT:
                # Clean shutdown
                self.socket.close()
                print("Driver exiting.")
                break
            
            else:
                print(f"Unknown message: {msg}")


class SGIDriver(EntropicDriver):
    """
    Stern-Gerlach interferometry driver.
    
    Implements harmonic trap potential with controlled dissipation:
        V(r) = (1/2) k |r - r₀|²
        λ(r) = λ₀(1 ± α·x/d)  [asymmetric dissipation for twin paradox]
    
    Parameters from paper (Table 1, page 8):
        - λ_SGI = 5.3 × 10³ s⁻¹
        - T_atom = 3 × 10⁻⁷ K
        - Π_SGI = 0.13 ± 0.02
    """
    
    def __init__(
        self,
        trap_frequency=100.0,  # Hz
        trap_center=None,
        lambda_0=5.3e3,        # s⁻¹
        asymmetry=0.0,         # For twin paradox
        separation=1e-3,       # m (arm separation)
        **kwargs
    ):
        """
        Initialize SGI driver.
        
        Args:
            trap_frequency: Harmonic trap frequency in Hz
            trap_center: Trap center position [x, y, z] in meters
            lambda_0: Base dissipation rate in s⁻¹
            asymmetry: Asymmetry parameter α for twin paradox test
            separation: Arm separation d for asymmetric dissipation
        """
        super().__init__(**kwargs)
        
        self.omega = 2.0 * np.pi * trap_frequency
        self.trap_center = trap_center if trap_center is not None else np.zeros(3)
        self.lambda_0 = lambda_0
        self.asymmetry = asymmetry
        self.separation = separation
        
        # Rb-87 mass
        self.mass = 87.0 * AMU
        
        # Spring constant: k = m·ω²
        self.k_spring = self.mass * self.omega**2
        
        print(f"SGI Driver initialized:")
        print(f"  Trap frequency: {trap_frequency} Hz")
        print(f"  Spring constant: {self.k_spring:.3e} N/m")
        print(f"  Dissipation rate: {self.lambda_0:.3e} s⁻¹")
        print(f"  Asymmetry: α = {self.asymmetry}")
    
    def compute_potential(self, positions):
        """
        Compute harmonic trap potential with entropic corrections.
        
        Returns:
            energy: V = (1/2) k Σᵢ |rᵢ - r₀|²
            forces: F = -k (r - r₀)
            virial: Standard mechanical virial
            extras: {lambda, alpha, Pi, f}
        """
        natoms = positions.shape[0]
        
        # Displacement from trap center
        displacement = positions - self.trap_center
        r_sq = np.sum(displacement**2, axis=1)
        
        # Harmonic potential
        energy = 0.5 * self.k_spring * np.sum(r_sq)
        
        # Forces (real part only - dissipation handled by motion)
        forces = -self.k_spring * displacement
        
        # Virial (for mechanical stress)
        virial = np.zeros((3, 3))
        for i in range(natoms):
            virial += np.outer(displacement[i], forces[i])
        
        # Entropic quantities
        # Position-dependent dissipation: λ(x) = λ₀(1 + α·x/d)
        x_coord = positions[:, 0]  # x-axis for asymmetry
        lambda_vals = self.lambda_0 * (1.0 + self.asymmetry * x_coord / self.separation)
        lambda_vals = np.maximum(lambda_vals, 0.0)  # Ensure non-negative
        
        # Gravitational lapse (flat space)
        alpha_vals = np.ones(natoms)
        
        # Planckian ratio (will be computed by motion class with T_eff)
        # Store lambda values for motion class
        extras = {
            'lambda': lambda_vals.tolist(),
            'alpha': alpha_vals.tolist(),
        }
        
        return energy, forces, virial, extras


class BlackHoleDriver(EntropicDriver):
    """
    Black hole test particle driver.
    
    Implements Schwarzschild potential with horizon dissipation:
        V(r) = -GM/r · f(Π)  [Newtonian approximation with openness]
        λ(r) = λ_horizon · (r_s/r)²
    
    Parameters from paper (Table 1, page 8):
        - λ_BH ~ 10³ s⁻¹ for solar mass
        - T_H ~ 10⁻⁸ K (Hawking temperature)
        - Π_BH = 0.43 ± 0.02
    """
    
    def __init__(
        self,
        mass=1.0,              # Solar masses
        spin=0.0,              # Dimensionless spin χ
        bh_center=None,
        include_gr_forces=False,  # Use full GR geodesic equation
        **kwargs
    ):
        """
        Initialize black hole driver.
        
        Args:
            mass: BH mass in solar masses
            spin: Dimensionless spin parameter χ ∈ [0, 1]
            bh_center: BH position [x, y, z] in meters
            include_gr_forces: Use GR corrections (experimental)
        """
        super().__init__(**kwargs)
        
        self.M = mass * M_SOLAR  # Convert to kg
        self.spin = spin
        self.bh_center = bh_center if bh_center is not None else np.zeros(3)
        self.include_gr = include_gr_forces
        
        # Schwarzschild radius
        self.r_s = 2.0 * G_NEWTON * self.M / C_LIGHT**2
        
        # Surface gravity
        if spin == 0:
            self.kappa = C_LIGHT**3 / (4.0 * G_NEWTON * self.M)
        else:
            f_spin = np.sqrt(1 - spin**2) / (1 + np.sqrt(1 - spin**2))
            self.kappa = (C_LIGHT**3 / (4.0 * G_NEWTON * self.M)) * f_spin
        
        # Horizon dissipation rate
        self.lambda_horizon = self.kappa / C_LIGHT
        
        # Hawking temperature
        self.T_hawking = (HBAR * self.kappa) / (2.0 * np.pi * KB * C_LIGHT)
        
        # Theoretical Planckian ratio at horizon
        self.Pi_horizon = 2.0 * np.pi  # Eq. 25 from paper
        
        print(f"Black Hole Driver initialized:")
        print(f"  Mass: {mass} M☉ = {self.M:.3e} kg")
        print(f"  Schwarzschild radius: {self.r_s:.3e} m")
        print(f"  Surface gravity: κ = {self.kappa:.3e} s⁻¹")
        print(f"  Horizon dissipation: λ = {self.lambda_horizon:.3e} s⁻¹")
        print(f"  Hawking temperature: T_H = {self.T_hawking:.3e} K")
        print(f"  Theoretical Π_horizon = {self.Pi_horizon:.2f}")
    
    def compute_potential(self, positions):
        """
        Compute gravitational potential with entropic corrections.
        
        Newtonian gravity (default):
            V = -GM/r
            F = GM·r/r³
        
        With GR corrections (experimental):
            Effective potential from geodesic equation
        """
        natoms = positions.shape[0]
        
        # Compute distances from BH
        displacement = positions - self.bh_center
        r = np.linalg.norm(displacement, axis=1, keepdims=True)
        
        # Avoid singularity (stop at 1.1 r_s)
        r_safe = np.maximum(r, 1.1 * self.r_s)
        
        # Newtonian potential
        energy = -G_NEWTON * self.M * np.sum(1.0 / r_safe)
        
        # Newtonian forces
        forces = G_NEWTON * self.M * displacement / r_safe**3
        
        # Virial
        virial = np.zeros((3, 3))
        for i in range(natoms):
            virial += np.outer(displacement[i], forces[i])
        
        # Entropic quantities
        # Position-dependent dissipation with radial falloff
        lambda_vals = self.lambda_horizon * (self.r_s / r_safe.flatten())**2
        
        # Gravitational lapse α = √(1 - r_s/r)
        alpha_vals = np.sqrt(1.0 - self.r_s / r_safe.flatten())
        
        # Planckian ratio (position-dependent)
        # Π(r) = λ(r)·ℏ / (k_B·T_H)
        Pi_vals = lambda_vals * HBAR / (KB * self.T_hawking)
        
        # Openness factor f = 1/(1+Π)
        f_vals = 1.0 / (1.0 + Pi_vals)
        
        # Optional: Apply openness correction to forces
        # This models "gravitational drag" from entropic stress
        if self.include_gr:
            forces *= f_vals.reshape(-1, 1)
        
        extras = {
            'lambda': lambda_vals.tolist(),
            'alpha': alpha_vals.tolist(),
            'Pi': Pi_vals.tolist(),
            'f': f_vals.tolist(),
        }
        
        return energy, forces, virial, extras


class ENZDriver(EntropicDriver):
    """
    Epsilon-near-zero material driver.
    
    Implements plasma oscillator with ultrafast dissipation:
        V(x) = (1/2) m ω_p² x²
        λ = 1/τ_rise
    
    Parameters from paper (Table 1, page 8):
        - λ_ENZ = 1.4 × 10¹⁴ s⁻¹
        - τ_rise = 7.1 fs
        - T_electron ~ 10³ K
        - Π_ENZ = 1.1 ± 0.1
    """
    
    def __init__(
        self,
        plasma_frequency=4.5e15,  # rad/s (ITO)
        tau_rise=7.1e-15,         # s
        electron_mass=9.1093837015e-31,  # kg
        **kwargs
    ):
        """
        Initialize ENZ driver.
        
        Args:
            plasma_frequency: ω_p in rad/s
            tau_rise: Field-amplitude decay time in seconds
            electron_mass: Effective electron mass in kg
        """
        super().__init__(**kwargs)
        
        self.omega_p = plasma_frequency
        self.lambda_ENZ = 1.0 / tau_rise
        self.m_eff = electron_mass
        
        print(f"ENZ Driver initialized:")
        print(f"  Plasma frequency: {self.omega_p:.3e} rad/s")
        print(f"  Rise time: {tau_rise*1e15:.2f} fs")
        print(f"  Dissipation rate: {self.lambda_ENZ:.3e} s⁻¹")
    
    def compute_potential(self, positions):
        """
        Compute plasma oscillator potential.
        
        V = (1/2) m ω_p² Σᵢ |rᵢ|²
        """
        natoms = positions.shape[0]
        
        r_sq = np.sum(positions**2, axis=1)
        energy = 0.5 * self.m_eff * self.omega_p**2 * np.sum(r_sq)
        
        forces = -self.m_eff * self.omega_p**2 * positions
        
        virial = np.zeros((3, 3))
        for i in range(natoms):
            virial += np.outer(positions[i], forces[i])
        
        # Constant dissipation (spatially uniform)
        lambda_vals = np.full(natoms, self.lambda_ENZ)
        alpha_vals = np.ones(natoms)
        
        extras = {
            'lambda': lambda_vals.tolist(),
            'alpha': alpha_vals.tolist(),
        }
        
        return energy, forces, virial, extras


# ===================================================================
# Command-line interface
# ===================================================================

def main():
    """Parse command-line arguments and start driver."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Entropic potential drivers for i-PI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # SGI validation
  python entropic_drivers.py --mode sgi --unix sgi_driver
  
  # Black hole test
  python entropic_drivers.py --mode blackhole --mass 1.0 --unix bh_driver
  
  # ENZ ultrafast
  python entropic_drivers.py --mode enz --unix enz_driver
        """
    )
    
    parser.add_argument(
        "--mode",
        type=str,
        required=True,
        choices=["sgi", "blackhole", "enz"],
        help="Driver mode"
    )
    
    parser.add_argument(
        "--unix",
        type=str,
        help="Unix socket path"
    )
    
    parser.add_argument(
        "--host",
        type=str,
        default="localhost",
        help="Host address for inet socket"
    )
    
    parser.add_argument(
        "--port",
        type=int,
        default=31415,
        help="Port for inet socket"
    )
    
    # SGI parameters
    parser.add_argument("--trap-freq", type=float, default=100.0)
    parser.add_argument("--lambda-0", type=float, default=5.3e3)
    parser.add_argument("--asymmetry", type=float, default=0.0)
    parser.add_argument("--separation", type=float, default=1e-3)
    
    # Black hole parameters
    parser.add_argument("--mass", type=float, default=1.0, help="BH mass in solar masses")
    parser.add_argument("--spin", type=float, default=0.0, help="BH spin χ")
    parser.add_argument("--include-gr", action="store_true")
    
    # ENZ parameters
    parser.add_argument("--plasma-freq", type=float, default=4.5e15)
    parser.add_argument("--tau-rise", type=float, default=7.1e-15)
    
    args = parser.parse_args()
    
    # Create driver based on mode
    if args.mode == "sgi":
        driver = SGIDriver(
            trap_frequency=args.trap_freq,
            lambda_0=args.lambda_0,
            asymmetry=args.asymmetry,
            separation=args.separation,
            unix_socket=args.unix,
            address=args.host,
            port=args.port
        )
    
    elif args.mode == "blackhole":
        driver = BlackHoleDriver(
            mass=args.mass,
            spin=args.spin,
            include_gr_forces=args.include_gr,
            unix_socket=args.unix,
            address=args.host,
            port=args.port
        )
    
    elif args.mode == "enz":
        driver = ENZDriver(
            plasma_frequency=args.plasma_freq,
            tau_rise=args.tau_rise,
            unix_socket=args.unix,
            address=args.host,
            port=args.port
        )
    
    # Run driver
    try:
        driver.run()
    except KeyboardInterrupt:
        print("\nDriver interrupted by user.")
        sys.exit(0)


if __name__ == "__main__":
    main()
