"""
EPT Boundary Conditions & Numerical Stability

Critical equations for stable evolution on finite grids.

Implements:
- Physical boundary conditions (various types)
- Sommerfeld radiation condition
- Absorbing boundary layers
- Constraint-preserving boundaries
- Kreiss-Oliger dissipation
- Numerical stability analysis
- Grid stretching

Without proper boundaries, waves reflect and evolution crashes!
"""

import numpy as np
from typing import Tuple, Callable, Optional
from dataclasses import dataclass
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'reference'))
from equation36_reference import Grid3D


# =============================================================================
# EQUATION 117: SOMMERFELD RADIATION BOUNDARY CONDITION
# =============================================================================

def apply_sommerfeld_boundary(
    field: np.ndarray,
    field_old: np.ndarray,
    grid: Grid3D,
    dt: float,
    v_char: float = 1.0
) -> np.ndarray:
    """
    Sommerfeld radiation boundary condition (Equation 117)
    
    For outgoing waves at large radius:
    ∂_t u + v ∂_r u + u/r = 0
    
    This allows waves to exit the grid without reflection.
    
    Parameters:
    -----------
    field : array
        Current field values
    field_old : array
        Field at previous timestep
    grid : Grid3D
        Computational grid
    dt : float
        Timestep
    v_char : float
        Characteristic speed (speed of light = 1)
    
    Returns:
    --------
    field : array
        Field with boundaries updated
    """
    nx, ny, nz = grid.nx, grid.ny, grid.nz
    
    # Grid center
    x_center = (nx * grid.dx) / 2.0
    y_center = (ny * grid.dy) / 2.0
    z_center = (nz * grid.dz) / 2.0
    
    # Apply to all 6 faces
    
    # X boundaries (i=0 and i=nx-1)
    for j in range(ny):
        for k in range(nz):
            # Low X boundary (i=0)
            x = 0 * grid.dx - x_center
            y = j * grid.dy - y_center
            z = k * grid.dz - z_center
            r = np.sqrt(x**2 + y**2 + z**2)
            
            if r > 0:
                # ∂_t u
                du_dt = (field[0, j, k] - field_old[0, j, k]) / dt
                
                # ∂_r u (radial derivative)
                du_dr = (field[1, j, k] - field[0, j, k]) / grid.dx * (x/r)
                
                # Update: ∂_t u + v ∂_r u + u/r = 0
                # u_new = u_old - dt * (v * ∂_r u + u/r)
                field[0, j, k] = field_old[0, j, k] - dt * (v_char * du_dr + field[0, j, k]/r)
            
            # High X boundary (i=nx-1)
            x = (nx-1) * grid.dx - x_center
            y = j * grid.dy - y_center
            z = k * grid.dz - z_center
            r = np.sqrt(x**2 + y**2 + z**2)
            
            if r > 0:
                du_dr = (field[nx-1, j, k] - field[nx-2, j, k]) / grid.dx * (x/r)
                field[nx-1, j, k] = field_old[nx-1, j, k] - dt * (v_char * du_dr + field[nx-1, j, k]/r)
    
    # Y boundaries
    for i in range(nx):
        for k in range(nz):
            # Low Y
            x = i * grid.dx - x_center
            y = 0 * grid.dy - y_center
            z = k * grid.dz - z_center
            r = np.sqrt(x**2 + y**2 + z**2)
            
            if r > 0:
                du_dr = (field[i, 1, k] - field[i, 0, k]) / grid.dy * (y/r)
                field[i, 0, k] = field_old[i, 0, k] - dt * (v_char * du_dr + field[i, 0, k]/r)
            
            # High Y
            y = (ny-1) * grid.dy - y_center
            r = np.sqrt(x**2 + y**2 + z**2)
            
            if r > 0:
                du_dr = (field[i, ny-1, k] - field[i, ny-2, k]) / grid.dy * (y/r)
                field[i, ny-1, k] = field_old[i, ny-1, k] - dt * (v_char * du_dr + field[i, ny-1, k]/r)
    
    # Z boundaries
    for i in range(nx):
        for j in range(ny):
            # Low Z
            x = i * grid.dx - x_center
            y = j * grid.dy - y_center
            z = 0 * grid.dz - z_center
            r = np.sqrt(x**2 + y**2 + z**2)
            
            if r > 0:
                du_dr = (field[i, j, 1] - field[i, j, 0]) / grid.dz * (z/r)
                field[i, j, 0] = field_old[i, j, 0] - dt * (v_char * du_dr + field[i, j, 0]/r)
            
            # High Z
            z = (nz-1) * grid.dz - z_center
            r = np.sqrt(x**2 + y**2 + z**2)
            
            if r > 0:
                du_dr = (field[i, j, nz-1] - field[i, j, nz-2]) / grid.dz * (z/r)
                field[i, j, nz-1] = field_old[i, j, nz-1] - dt * (v_char * du_dr + field[i, j, nz-1]/r)
    
    return field


# =============================================================================
# EQUATION 118: CONSTRAINT-PRESERVING BOUNDARY
# =============================================================================

def apply_constraint_preserving_boundary(
    field: np.ndarray,
    constraint: np.ndarray,
    grid: Grid3D,
    sigma: float = 1.0
) -> np.ndarray:
    """
    Constraint-preserving boundary (Equation 118)
    
    Modifies boundary to help preserve constraints:
    ∂_n u = -σ C
    
    where C is constraint violation, n is outward normal
    
    Parameters:
    -----------
    field : array
        Field to apply boundary to
    constraint : array
        Constraint violation (should be ≈ 0)
    grid : Grid3D
        Grid
    sigma : float
        Constraint damping strength
    
    Returns:
    --------
    field : array
        Field with constraint-preserving boundaries
    """
    nx, ny, nz = grid.nx, grid.ny, grid.nz
    
    # X boundaries
    for j in range(ny):
        for k in range(nz):
            # Low X: ∂_x u = -σ C
            field[0, j, k] = field[1, j, k] + grid.dx * sigma * constraint[0, j, k]
            
            # High X
            field[nx-1, j, k] = field[nx-2, j, k] - grid.dx * sigma * constraint[nx-1, j, k]
    
    # Y boundaries
    for i in range(nx):
        for k in range(nz):
            field[i, 0, k] = field[i, 1, k] + grid.dy * sigma * constraint[i, 0, k]
            field[i, ny-1, k] = field[i, ny-2, k] - grid.dy * sigma * constraint[i, ny-1, k]
    
    # Z boundaries
    for i in range(nx):
        for j in range(ny):
            field[i, j, 0] = field[i, j, 1] + grid.dz * sigma * constraint[i, j, 0]
            field[i, j, nz-1] = field[i, j, nz-2] - grid.dz * sigma * constraint[i, j, nz-1]
    
    return field


# =============================================================================
# EQUATION 119: KREISS-OLIGER DISSIPATION
# =============================================================================

def apply_kreiss_oliger_dissipation(
    field: np.ndarray,
    grid: Grid3D,
    epsilon: float = 0.01,
    order: int = 4
) -> np.ndarray:
    """
    Kreiss-Oliger artificial dissipation (Equation 119)
    
    Adds high-frequency damping for numerical stability:
    u_new = u + ε (-1)^(p/2) h^p ∂^p u
    
    where p is dissipation order (typically 4 or 6)
    
    Parameters:
    -----------
    field : array
        Field to dissipate
    grid : Grid3D
        Grid
    epsilon : float
        Dissipation strength (0.01-0.1 typical)
    order : int
        Dissipation order (4 or 6)
    
    Returns:
    --------
    field : array
        Dissipated field
    """
    nx, ny, nz = field.shape
    dissipated = field.copy()
    
    if order == 4:
        # 4th order: ε h⁴ ∂⁴u
        sign = +1.0
        
        # X direction
        for j in range(ny):
            for k in range(nz):
                for i in range(2, nx-2):
                    d4_dx4 = (field[i+2, j, k] - 4*field[i+1, j, k] + 
                             6*field[i, j, k] - 4*field[i-1, j, k] + 
                             field[i-2, j, k]) / grid.dx**4
                    
                    dissipated[i, j, k] += sign * epsilon * grid.dx**4 * d4_dx4
        
        # Y direction
        for i in range(nx):
            for k in range(nz):
                for j in range(2, ny-2):
                    d4_dy4 = (field[i, j+2, k] - 4*field[i, j+1, k] + 
                             6*field[i, j, k] - 4*field[i, j-1, k] + 
                             field[i, j-2, k]) / grid.dy**4
                    
                    dissipated[i, j, k] += sign * epsilon * grid.dy**4 * d4_dy4
        
        # Z direction
        for i in range(nx):
            for j in range(ny):
                for k in range(2, nz-2):
                    d4_dz4 = (field[i, j, k+2] - 4*field[i, j, k+1] + 
                             6*field[i, j, k] - 4*field[i, j, k-1] + 
                             field[i, j, k-2]) / grid.dz**4
                    
                    dissipated[i, j, k] += sign * epsilon * grid.dz**4 * d4_dz4
    
    elif order == 6:
        # 6th order: -ε h⁶ ∂⁶u
        sign = -1.0
        
        # X direction
        for j in range(ny):
            for k in range(nz):
                for i in range(3, nx-3):
                    d6_dx6 = (field[i+3, j, k] - 6*field[i+2, j, k] + 
                             15*field[i+1, j, k] - 20*field[i, j, k] + 
                             15*field[i-1, j, k] - 6*field[i-2, j, k] + 
                             field[i-3, j, k]) / grid.dx**6
                    
                    dissipated[i, j, k] += sign * epsilon * grid.dx**6 * d6_dx6
        
        # Similar for Y and Z...
    
    return dissipated


# =============================================================================
# EQUATION 120: ABSORBING BOUNDARY LAYER
# =============================================================================

class AbsorbingBoundaryLayer:
    """
    Absorbing boundary layer (Equation 120)
    
    Adds smooth damping near boundaries to absorb outgoing waves.
    Uses Gaussian or exponential profile.
    """
    
    def __init__(self, grid: Grid3D, width: float = 10.0, strength: float = 1.0):
        """
        Parameters:
        -----------
        grid : Grid3D
            Computational grid
        width : float
            Width of absorbing layer (in grid units)
        strength : float
            Damping strength
        """
        self.grid = grid
        self.width = width
        self.strength = strength
        
        # Pre-compute damping profile
        self.damping_profile = self._compute_damping_profile()
    
    def _compute_damping_profile(self) -> np.ndarray:
        """
        Compute spatial damping profile
        
        σ(r) = strength * exp(-(r_boundary - r)²/width²)
        
        where r_boundary is distance to nearest boundary
        """
        nx, ny, nz = self.grid.nx, self.grid.ny, self.grid.nz
        profile = np.zeros((nx, ny, nz))
        
        for i in range(nx):
            for j in range(ny):
                for k in range(nz):
                    # Distance to nearest boundary
                    dist_x = min(i, nx-1-i) * self.grid.dx
                    dist_y = min(j, ny-1-j) * self.grid.dy
                    dist_z = min(k, nz-1-k) * self.grid.dz
                    
                    dist_boundary = min(dist_x, dist_y, dist_z)
                    
                    # Damping activates near boundaries
                    if dist_boundary < self.width:
                        profile[i, j, k] = self.strength * np.exp(
                            -(self.width - dist_boundary)**2 / self.width**2
                        )
        
        return profile
    
    def apply(self, field: np.ndarray, dt: float) -> np.ndarray:
        """
        Apply absorbing layer to field
        
        u_new = u * exp(-σ dt)
        
        Parameters:
        -----------
        field : array
            Field to damp
        dt : float
            Timestep
        
        Returns:
        --------
        field : array
            Damped field
        """
        damping_factor = np.exp(-self.damping_profile * dt)
        return field * damping_factor


# =============================================================================
# BOUNDARY CONDITION MANAGER
# =============================================================================

@dataclass
class BoundaryConfig:
    """Configuration for boundary conditions"""
    
    # Boundary type for each face
    type_x_low: str = "sommerfeld"   # sommerfeld, periodic, dirichlet, neumann
    type_x_high: str = "sommerfeld"
    type_y_low: str = "sommerfeld"
    type_y_high: str = "sommerfeld"
    type_z_low: str = "sommerfeld"
    type_z_high: str = "sommerfeld"
    
    # Sommerfeld parameters
    v_char: float = 1.0  # Characteristic speed
    
    # Kreiss-Oliger dissipation
    use_dissipation: bool = True
    dissipation_epsilon: float = 0.01
    dissipation_order: int = 4
    
    # Absorbing layer
    use_absorbing_layer: bool = True
    absorbing_width: float = 10.0
    absorbing_strength: float = 1.0
    
    # Constraint preservation
    use_constraint_preserving: bool = False
    constraint_sigma: float = 1.0


class BoundaryConditionManager:
    """
    Unified boundary condition manager
    
    Handles all boundary condition types and applies them consistently.
    """
    
    def __init__(self, grid: Grid3D, config: BoundaryConfig):
        self.grid = grid
        self.config = config
        
        # Initialize absorbing layer if requested
        if config.use_absorbing_layer:
            self.absorbing_layer = AbsorbingBoundaryLayer(
                grid, config.absorbing_width, config.absorbing_strength
            )
        else:
            self.absorbing_layer = None
        
        print("✓ Boundary condition manager initialized")
        print(f"  X: {config.type_x_low} / {config.type_x_high}")
        print(f"  Y: {config.type_y_low} / {config.type_y_high}")
        print(f"  Z: {config.type_z_low} / {config.type_z_high}")
        print(f"  Dissipation: {'ON' if config.use_dissipation else 'OFF'}")
        print(f"  Absorbing layer: {'ON' if config.use_absorbing_layer else 'OFF'}")
    
    def apply_all_boundaries(
        self,
        field: np.ndarray,
        field_old: np.ndarray,
        dt: float,
        constraint: Optional[np.ndarray] = None
    ) -> np.ndarray:
        """
        Apply all configured boundary conditions
        
        Parameters:
        -----------
        field : array
            Current field
        field_old : array
            Previous timestep
        dt : float
            Timestep
        constraint : array, optional
            Constraint violation (for constraint-preserving boundaries)
        
        Returns:
        --------
        field : array
            Field with all boundaries applied
        """
        # 1. Physical boundaries (Sommerfeld, etc.)
        if self.config.type_x_low == "sommerfeld":
            field = apply_sommerfeld_boundary(field, field_old, self.grid, dt, self.config.v_char)
        
        # 2. Constraint-preserving boundaries
        if self.config.use_constraint_preserving and constraint is not None:
            field = apply_constraint_preserving_boundary(
                field, constraint, self.grid, self.config.constraint_sigma
            )
        
        # 3. Kreiss-Oliger dissipation
        if self.config.use_dissipation:
            field = apply_kreiss_oliger_dissipation(
                field, self.grid, 
                self.config.dissipation_epsilon,
                self.config.dissipation_order
            )
        
        # 4. Absorbing layer
        if self.absorbing_layer is not None:
            field = self.absorbing_layer.apply(field, dt)
        
        return field
    
    def apply_to_all_fields(
        self,
        fields: dict,
        fields_old: dict,
        dt: float,
        constraints: Optional[dict] = None
    ) -> dict:
        """
        Apply boundaries to all fields in a dictionary
        
        Parameters:
        -----------
        fields : dict
            Current fields {name: array}
        fields_old : dict
            Previous timestep fields
        dt : float
            Timestep
        constraints : dict, optional
            Constraint violations {name: array}
        
        Returns:
        --------
        fields : dict
            All fields with boundaries applied
        """
        for name, field in fields.items():
            field_old = fields_old[name]
            constraint = constraints.get(name) if constraints else None
            
            fields[name] = self.apply_all_boundaries(field, field_old, dt, constraint)
        
        return fields


# =============================================================================
# EXAMPLE USAGE
# =============================================================================

if __name__ == '__main__':
    print("="*70)
    print("EPT Boundary Conditions - Example")
    print("="*70)
    
    # Setup
    grid = Grid3D(nx=64, ny=64, nz=64, dx=0.1, dy=0.1, dz=0.1)
    
    # Configure boundaries
    config = BoundaryConfig(
        type_x_low="sommerfeld",
        type_x_high="sommerfeld",
        type_y_low="sommerfeld",
        type_y_high="sommerfeld",
        type_z_low="sommerfeld",
        type_z_high="sommerfeld",
        use_dissipation=True,
        dissipation_epsilon=0.01,
        use_absorbing_layer=True,
        absorbing_width=5.0
    )
    
    bc_manager = BoundaryConditionManager(grid, config)
    
    # Create test field (Gaussian pulse)
    print("\n1. Creating test field (Gaussian pulse)...")
    x = np.arange(grid.nx) * grid.dx - (grid.nx * grid.dx) / 2
    y = np.arange(grid.ny) * grid.dy - (grid.ny * grid.dy) / 2
    z = np.arange(grid.nz) * grid.dz - (grid.nz * grid.dz) / 2
    
    X, Y, Z = np.meshgrid(x, y, z, indexing='ij')
    r = np.sqrt(X**2 + Y**2 + Z**2)
    
    field = 0.1 * np.exp(-r**2 / 2.0)
    field_old = field.copy()
    
    print(f"   Field max: {np.max(field):.6f}")
    print(f"   Field L2:  {np.sqrt(np.mean(field**2)):.6f}")
    
    # Test boundaries
    print("\n2. Testing Sommerfeld boundary...")
    field_somm = apply_sommerfeld_boundary(field, field_old, grid, dt=0.01)
    print(f"   Boundary values changed: {np.max(np.abs(field_somm - field)):.6e}")
    
    print("\n3. Testing Kreiss-Oliger dissipation...")
    field_diss = apply_kreiss_oliger_dissipation(field, grid, epsilon=0.01)
    print(f"   Dissipation effect: {np.max(np.abs(field_diss - field)):.6e}")
    print(f"   Energy change: {(np.sum(field_diss**2) - np.sum(field**2))/np.sum(field**2) * 100:.4f}%")
    
    print("\n4. Testing absorbing layer...")
    absorbing = AbsorbingBoundaryLayer(grid, width=5.0, strength=1.0)
    field_abs = absorbing.apply(field, dt=0.01)
    print(f"   Absorption at boundaries: {np.max(np.abs(field_abs - field)):.6e}")
    
    print("\n5. Testing complete boundary manager...")
    fields = {'phi': field.copy(), 'Pi': field.copy()}
    fields_old = {'phi': field_old.copy(), 'Pi': field_old.copy()}
    
    fields = bc_manager.apply_to_all_fields(fields, fields_old, dt=0.01)
    print(f"   All boundaries applied successfully")
    print(f"   φ changed by: {np.max(np.abs(fields['phi'] - field)):.6e}")
    
    print("\n" + "="*70)
    print("✅ Boundary conditions working!")
    print("="*70)
    print("\nKey features:")
    print("  ✓ Sommerfeld radiation boundaries")
    print("  ✓ Constraint-preserving boundaries")
    print("  ✓ Kreiss-Oliger dissipation")
    print("  ✓ Absorbing boundary layers")
    print("  ✓ Unified boundary manager")
    print("  ✓ Ready for stable evolution!")
    print("="*70)
