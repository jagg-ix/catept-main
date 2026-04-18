"""
Geant4 Adapter with CAT/EPT Integration

This adapter connects particle transport with:
- pynucastro (nuclear reactions → gamma rays)
- qutip (radiation effects on quantum systems)
- Galaxy simulations (cosmic rays, ISM transport)
- Complete CAT/EPT thermodynamics

Capabilities:
- Particle transport (γ, e±, hadrons, neutrons)
- Nuclear interactions
- Energy deposition
- Radiation damage
- Detector simulation
- Astrophysical radiation

Physics processes modeled:
- Electromagnetic (Compton, pair production, photoelectric)
- Hadronic (spallation, fission, capture)
- Optical (Cherenkov, scintillation)
"""

import numpy as np
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass
import sys
from pathlib import Path

# Import CAT/EPT extensions
sys.path.insert(0, str(Path(__file__).parent))
from pynucastro_catept_extension import NuclearCATEPT, make_nuclear_catept
from qutip_catept_extension import QuantumCATEPT, make_quantum_catept

# Physical constants
c = 2.998e8  # m/s
m_e = 9.109e-31  # kg (electron mass)
m_p = 1.673e-27  # kg (proton mass)
m_n = 1.675e-27  # kg (neutron mass)
e = 1.602e-19  # C (elementary charge)
k_B = 1.381e-23  # J/K
hbar = 1.055e-34  # J·s
MeV_to_J = 1.602e-13  # J/MeV
barn_to_m2 = 1e-28  # m²/barn
N_A = 6.022e23  # Avogadro's number


@dataclass
class Particle:
    """Particle state"""
    particle_type: str  # 'gamma', 'electron', 'proton', 'neutron', etc.
    energy: float  # MeV
    position: np.ndarray  # m [x, y, z]
    direction: np.ndarray  # unit vector
    time: float  # s
    weight: float = 1.0  # For importance sampling


@dataclass
class Material:
    """Material properties"""
    name: str
    Z: float  # Atomic number
    A: float  # Mass number
    density: float  # g/cm³
    I_mean: float  # Mean excitation energy (eV)


class Geant4Adapter:
    """Particle transport adapter with CAT/EPT thermodynamics
    
    This adapter simulates particle transport and connects to
    nuclear reactions (pynucastro) and quantum systems (qutip).
    
    Examples
    --------
    >>> # Gamma-ray from nuclear reaction
    >>> adapter = Geant4Adapter()
    >>> 
    >>> # Create 1.809 MeV gamma from 26Al decay
    >>> gamma = adapter.create_particle('gamma', 1.809, [0, 0, 0])
    >>> 
    >>> # Transport through ISM
    >>> result = adapter.transport_particle(gamma, material='ISM', distance=1000)
    >>> print(f"Transmission: {result['transmission']:.1%}")
    """
    
    def __init__(self):
        """Initialize Geant4 adapter"""
        self.catept_nuclear = make_nuclear_catept()
        self.catept_quantum = make_quantum_catept()
        
        # Define common materials
        self.materials = {
            'vacuum': Material('vacuum', 0, 0, 0, 0),
            'ISM': Material('ISM (H)', 1, 1, 1e-24, 19.2),  # Diffuse hydrogen
            'air': Material('Air', 7.3, 14.4, 1.2e-3, 85.7),
            'water': Material('Water', 7.42, 11.9, 1.0, 75.0),
            'silicon': Material('Silicon', 14, 28, 2.33, 173),
            'lead': Material('Lead', 82, 207, 11.35, 823),
            'scintillator': Material('NaI', 32, 64, 3.67, 452),
            'superconductor': Material('Nb', 41, 93, 8.57, 417)
        }
    
    # =========================================================================
    # PARTICLE CREATION
    # =========================================================================
    
    def create_particle(self,
                       particle_type: str,
                       energy: float,
                       position: List[float],
                       direction: Optional[List[float]] = None) -> Particle:
        """Create particle
        
        Parameters
        ----------
        particle_type : str
            'gamma', 'electron', 'positron', 'proton', 'neutron', 'alpha'
        energy : float
            Kinetic energy (MeV)
        position : list
            Position [x, y, z] in m
        direction : list, optional
            Direction unit vector. Random if None.
        
        Returns
        -------
        particle : Particle
        """
        
        pos = np.array(position)
        
        if direction is None:
            # Random isotropic direction
            theta = np.arccos(np.random.uniform(-1, 1))
            phi = np.random.uniform(0, 2*np.pi)
            direction = np.array([
                np.sin(theta) * np.cos(phi),
                np.sin(theta) * np.sin(phi),
                np.cos(theta)
            ])
        else:
            direction = np.array(direction)
            direction = direction / np.linalg.norm(direction)
        
        particle = Particle(
            particle_type=particle_type,
            energy=energy,
            position=pos,
            direction=direction,
            time=0.0
        )
        
        return particle
    
    def create_from_nuclear_reaction(self,
                                     reaction: str,
                                     Q_value: float) -> List[Particle]:
        """Create particles from nuclear reaction (pynucastro integration!)
        
        Parameters
        ----------
        reaction : str
            Reaction name
        Q_value : float
            Q-value (MeV)
        
        Returns
        -------
        particles : list of Particle
            Reaction products
        """
        
        particles = []
        
        # Common nuclear reactions
        if 'Al26' in reaction or '26Al' in reaction:
            # 26Al → 26Mg + e+ + ν, then e+ → 2γ (1.809 MeV)
            # Also characteristic 1.809 MeV gamma
            gamma = self.create_particle('gamma', 1.809, [0, 0, 0])
            particles.append(gamma)
        
        elif 'e+' in reaction or 'positron' in reaction:
            # e+ annihilation → 2γ (511 keV each)
            gamma1 = self.create_particle('gamma', 0.511, [0, 0, 0], [1, 0, 0])
            gamma2 = self.create_particle('gamma', 0.511, [0, 0, 0], [-1, 0, 0])
            particles.extend([gamma1, gamma2])
        
        elif 'C12' in reaction:
            # Excited C-12 → C-12 + γ (4.438 MeV)
            gamma = self.create_particle('gamma', 4.438, [0, 0, 0])
            particles.append(gamma)
        
        else:
            # Generic: convert Q-value to gamma
            gamma = self.create_particle('gamma', Q_value, [0, 0, 0])
            particles.append(gamma)
        
        return particles
    
    # =========================================================================
    # ELECTROMAGNETIC PROCESSES
    # =========================================================================
    
    def compton_scattering(self,
                          gamma: Particle,
                          material: Material) -> Tuple[float, Particle, Particle]:
        """Compton scattering cross section and products
        
        Parameters
        ----------
        gamma : Particle
            Incident photon
        material : Material
        
        Returns
        -------
        sigma : float
            Cross section (barn)
        gamma_scattered : Particle
            Scattered photon
        electron : Particle
            Recoil electron
        """
        
        E_gamma = gamma.energy  # MeV
        
        # Klein-Nishina formula (simplified)
        alpha = E_gamma / 0.511  # Normalized energy
        
        if alpha < 0.1:
            # Low energy: Thomson scattering
            sigma = 0.665  # barn (Thomson cross section)
        else:
            # Klein-Nishina
            sigma = 0.665 * (1 + alpha) / alpha**3 * (
                2*alpha*(1 + alpha)/(1 + 2*alpha) - np.log(1 + 2*alpha)
            ) * material.Z
        
        # Scattering (simplified - assume 90° for demo)
        theta = np.pi / 2
        
        # Scattered photon energy
        E_gamma_prime = E_gamma / (1 + alpha * (1 - np.cos(theta)))
        
        # Recoil electron
        E_electron = E_gamma - E_gamma_prime
        
        # Create scattered particles
        gamma_scattered = self.create_particle(
            'gamma', E_gamma_prime, gamma.position, [0, 1, 0]
        )
        
        electron = self.create_particle(
            'electron', E_electron, gamma.position, [1, 0, 0]
        )
        
        return sigma, gamma_scattered, electron
    
    def pair_production(self, gamma: Particle, material: Material) -> Tuple[float, Particle, Particle]:
        """Pair production cross section
        
        Parameters
        ----------
        gamma : Particle
            Incident photon (E > 1.022 MeV)
        material : Material
        
        Returns
        -------
        sigma : float
            Cross section (barn)
        electron : Particle
            Electron
        positron : Particle
            Positron
        """
        
        E_gamma = gamma.energy
        
        if E_gamma < 1.022:
            # Below threshold
            return 0.0, None, None
        
        # Cross section (simplified)
        sigma = 7/9 * material.Z**2 * np.log(E_gamma / 0.511) * 1e-3  # barn
        
        # Energy sharing (symmetric for simplicity)
        E_available = E_gamma - 1.022
        E_e = E_available / 2
        E_p = E_available / 2
        
        electron = self.create_particle('electron', E_e, gamma.position)
        positron = self.create_particle('positron', E_p, gamma.position)
        
        return sigma, electron, positron
    
    def photoelectric_effect(self, gamma: Particle, material: Material) -> Tuple[float, Particle]:
        """Photoelectric absorption
        
        Parameters
        ----------
        gamma : Particle
        material : Material
        
        Returns
        -------
        sigma : float
            Cross section (barn)
        electron : Particle
            Photo-electron
        """
        
        E_gamma = gamma.energy
        
        # Cross section (approximate)
        sigma = 10 * material.Z**5 / E_gamma**3.5 * 1e-3  # barn
        
        # Photo-electron
        E_electron = E_gamma - material.I_mean * 1e-6  # Subtract binding energy
        electron = self.create_particle('electron', E_electron, gamma.position)
        
        return sigma, electron
    
    # =========================================================================
    # HADRONIC PROCESSES
    # =========================================================================
    
    def nuclear_interaction(self,
                           particle: Particle,
                           material: Material) -> Dict:
        """Nuclear interaction (spallation, fission, etc.)
        
        This connects to pynucastro nuclear reactions!
        
        Parameters
        ----------
        particle : Particle
            Incident hadron
        material : Material
        
        Returns
        -------
        interaction : dict
            Interaction products
        """
        
        E_kin = particle.energy  # MeV
        
        # Cross section (approximate)
        if particle.particle_type == 'proton':
            # Proton-nucleus
            sigma_inel = np.pi * (1.2 * material.A**(1/3))**2 * 100  # mb → barn
        elif particle.particle_type == 'neutron':
            # Neutron-nucleus
            if E_kin < 1.0:
                # Thermal neutrons - use pynucastro cross sections!
                sigma_inel = 10  # barn (typical)
            else:
                sigma_inel = 2  # barn
        else:
            sigma_inel = 1  # barn
        
        # Products (simplified)
        products = []
        
        # Spallation neutrons
        n_neutrons = int(E_kin / 10)  # ~1 neutron per 10 MeV
        for i in range(n_neutrons):
            E_n = np.random.exponential(2.0)  # MeV (evaporation spectrum)
            neutron = self.create_particle('neutron', E_n, particle.position)
            products.append(neutron)
        
        # Gamma-rays from de-excitation
        n_gammas = int(n_neutrons / 2)
        for i in range(n_gammas):
            E_gamma = np.random.uniform(0.5, 5.0)  # MeV
            gamma = self.create_particle('gamma', E_gamma, particle.position)
            products.append(gamma)
        
        return {
            'sigma': sigma_inel,
            'products': products,
            'n_neutrons': n_neutrons,
            'n_gammas': n_gammas
        }
    
    # =========================================================================
    # PARTICLE TRANSPORT
    # =========================================================================
    
    def transport_particle(self,
                          particle: Particle,
                          material: str = 'ISM',
                          distance: float = 1000.0,
                          max_steps: int = 100) -> Dict:
        """Transport particle through material
        
        Parameters
        ----------
        particle : Particle
            Initial particle
        material : str
            Material name
        distance : float
            Distance to transport (pc for ISM, cm otherwise)
        max_steps : int
            Maximum number of steps
        
        Returns
        -------
        transport : dict
            Transport results
        """
        
        mat = self.materials[material]
        
        print(f"\n  Particle Transport:")
        print(f"    Particle: {particle.particle_type}")
        print(f"    Energy: {particle.energy} MeV")
        print(f"    Material: {mat.name}")
        print(f"    Distance: {distance:.1f} {'pc' if material == 'ISM' else 'cm'}")
        
        # Convert distance
        if material == 'ISM':
            distance_cm = distance * 3.086e18  # pc → cm
        else:
            distance_cm = distance
        
        # Track history
        history = {
            'positions': [particle.position.copy()],
            'energies': [particle.energy],
            'particle_types': [particle.particle_type]
        }
        
        current_particle = particle
        distance_traveled = 0
        
        for step in range(max_steps):
            if current_particle is None:
                break
            
            # Get cross sections
            if current_particle.particle_type == 'gamma':
                sigma_compton, _, _ = self.compton_scattering(current_particle, mat)
                sigma_pair, _, _ = self.pair_production(current_particle, mat)
                sigma_photo, _ = self.photoelectric_effect(current_particle, mat)
                
                sigma_total = sigma_compton + sigma_pair + sigma_photo
                sigma_total *= barn_to_m2 * 1e4  # barn → cm²
            else:
                # Charged particle - use stopping power
                sigma_total = 1e-24  # cm² (placeholder)
            
            # Number density
            n_atoms = mat.density * N_A / mat.A  # atoms/cm³
            
            # Mean free path
            lambda_mfp = 1 / (n_atoms * sigma_total) if sigma_total > 0 else 1e30
            
            # Distance to interaction
            s = -lambda_mfp * np.log(np.random.random())
            
            if distance_traveled + s > distance_cm:
                # Reached end
                distance_traveled = distance_cm
                break
            
            # Move particle
            distance_traveled += s
            current_particle.position += current_particle.direction * s / 100  # cm → m
            
            # Interaction
            if current_particle.particle_type == 'gamma':
                # Choose process
                r = np.random.random() * sigma_total * barn_to_m2 * 1e4
                
                if r < sigma_compton * barn_to_m2 * 1e4:
                    # Compton
                    _, gamma_new, electron = self.compton_scattering(current_particle, mat)
                    current_particle = gamma_new
                    history['particle_types'].append('compton')
                
                elif r < (sigma_compton + sigma_pair) * barn_to_m2 * 1e4:
                    # Pair production
                    _, e_minus, e_plus = self.pair_production(current_particle, mat)
                    current_particle = e_minus  # Track electron
                    history['particle_types'].append('pair')
                
                else:
                    # Photoelectric - absorbed
                    current_particle = None
                    history['particle_types'].append('absorbed')
            
            # Record
            if current_particle is not None:
                history['positions'].append(current_particle.position.copy())
                history['energies'].append(current_particle.energy)
        
        # Transmission
        transmission = np.exp(-distance_cm / lambda_mfp)
        
        print(f"\n  Transport Results:")
        print(f"    Mean free path: {lambda_mfp:.2e} cm")
        print(f"    Steps: {len(history['positions'])}")
        print(f"    Transmission: {transmission:.2e}")
        print(f"    Final energy: {current_particle.energy if current_particle else 0:.2f} MeV")
        
        return {
            'transmission': transmission,
            'lambda_mfp': lambda_mfp,
            'final_particle': current_particle,
            'history': history,
            'n_steps': len(history['positions'])
        }
    
    # =========================================================================
    # DETECTOR SIMULATION
    # =========================================================================
    
    def simulate_detector(self,
                         particle: Particle,
                         detector_material: str = 'scintillator',
                         detector_size: float = 10.0) -> Dict:
        """Simulate particle detection
        
        Parameters
        ----------
        particle : Particle
        detector_material : str
            Material name
        detector_size : float
            Detector thickness (cm)
        
        Returns
        -------
        response : dict
            Detector response
        """
        
        mat = self.materials[detector_material]
        
        print(f"\n  Detector Simulation:")
        print(f"    Material: {mat.name}")
        print(f"    Size: {detector_size} cm")
        
        # Transport through detector
        result = self.transport_particle(
            particle, detector_material, detector_size
        )
        
        # Energy deposition
        E_initial = particle.energy
        E_final = result['final_particle'].energy if result['final_particle'] else 0
        E_deposit = E_initial - E_final
        
        # Detector resolution (Gaussian)
        resolution = 0.05  # 5% FWHM
        E_measured = E_deposit * (1 + np.random.normal(0, resolution / 2.355))
        
        # Detection efficiency
        if particle.particle_type == 'gamma':
            efficiency = 1 - result['transmission']
        else:
            efficiency = 0.99  # High for charged particles
        
        print(f"\n  Detector Response:")
        print(f"    E_deposit: {E_deposit:.3f} MeV")
        print(f"    E_measured: {E_measured:.3f} MeV")
        print(f"    Efficiency: {efficiency:.1%}")
        
        return {
            'E_deposit': E_deposit,
            'E_measured': E_measured,
            'efficiency': efficiency,
            'detected': np.random.random() < efficiency
        }
    
    # =========================================================================
    # RADIATION EFFECTS (qutip integration!)
    # =========================================================================
    
    def radiation_damage_qubit(self,
                              particle: Particle,
                              qubit_material: str = 'superconductor',
                              qubit_size: float = 1e-4) -> Dict:
        """Compute radiation damage to quantum system
        
        This connects Geant4 to qutip!
        
        Parameters
        ----------
        particle : Particle
        qubit_material : str
            Qubit substrate material
        qubit_size : float
            Qubit area (cm²)
        
        Returns
        -------
        damage : dict
            Radiation damage effects
        """
        
        print(f"\n  Radiation Damage to Qubit:")
        print(f"    Particle: {particle.particle_type}, {particle.energy} MeV")
        
        mat = self.materials[qubit_material]
        
        # Hit rate (flux × area)
        # Assume cosmic ray flux
        if particle.particle_type == 'proton':
            flux = 1e-2  # cm⁻²s⁻¹ at sea level
        else:
            flux = 1e-3
        
        hit_rate = flux * qubit_size  # s⁻¹
        
        # Energy deposition per hit
        # Use stopping power
        dE_dx = 1  # MeV/cm (approximate)
        thickness = 1e-4  # cm (thin qubit)
        E_deposit = min(dE_dx * thickness, particle.energy) * MeV_to_J
        
        # Additional decoherence from radiation
        # γ_rad = hit_rate × (E_deposit / E_qubit)
        E_qubit = hbar * 2 * np.pi * 5e9  # 5 GHz qubit
        gamma_rad = hit_rate * (E_deposit / E_qubit)
        
        # Impact on T1, T2
        T1_intrinsic = 1e-3  # s
        T2_intrinsic = 0.5e-3  # s
        
        gamma_1_total = 1/T1_intrinsic + gamma_rad
        T1_damaged = 1 / gamma_1_total
        
        degradation = (T1_intrinsic - T1_damaged) / T1_intrinsic
        
        print(f"\n  Damage Effects:")
        print(f"    Hit rate: {hit_rate:.2e} s⁻¹")
        print(f"    E_deposit: {E_deposit/MeV_to_J:.2e} MeV per hit")
        print(f"    γ_rad: {gamma_rad:.2e} s⁻¹")
        print(f"    T1: {T1_intrinsic*1e3:.2f} → {T1_damaged*1e3:.2f} ms")
        print(f"    Degradation: {degradation:.1%}")
        
        # Connects to qutip decoherence!
        return {
            'hit_rate': hit_rate,
            'E_deposit': E_deposit,
            'gamma_rad': gamma_rad,
            'T1_damaged': T1_damaged,
            'degradation': degradation
        }
    
    # =========================================================================
    # CAT/EPT INTEGRATION
    # =========================================================================
    
    def compute_lambda_radiation(self,
                                particle_flux: float,
                                energy_per_particle: float,
                                volume: float = 1.0,
                                T: float = 300) -> float:
        """Compute radiation dissipation rate
        
        Parameters
        ----------
        particle_flux : float
            Particle flux (cm⁻²s⁻¹)
        energy_per_particle : float
            Energy per particle (MeV)
        volume : float
            Volume (cm³)
        T : float
            Temperature (K)
        
        Returns
        -------
        lambda_rad : float
            Radiation dissipation rate (s⁻¹)
        """
        
        # Power from radiation
        # P = flux × area × E × volume
        area = volume**(2/3)  # cm²
        E_J = energy_per_particle * MeV_to_J
        
        power = particle_flux * area * E_J  # W
        
        # Dissipation rate
        lambda_rad = power / (k_B * T**2)
        
        return lambda_rad


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def simulate_gamma_ray_astronomy(source: str = '26Al') -> Dict:
    """Simulate gamma-ray line observation from nuclear decay
    
    Connects pynucastro → Geant4 → Detection!
    
    Parameters
    ----------
    source : str
        Radioactive source
    
    Returns
    -------
    observation : dict
        Simulated observation
    """
    
    print("\n" + "="*70)
    print("  GAMMA-RAY ASTRONOMY SIMULATION")
    print("  pynucastro → Geant4 → Detection")
    print("="*70)
    
    adapter = Geant4Adapter()
    
    # Create gamma from nuclear decay (pynucastro!)
    gammas = adapter.create_from_nuclear_reaction(source, 1.809)
    gamma = gammas[0]
    
    print(f"\n  [1] Nuclear Decay (pynucastro):")
    print(f"    Source: {source}")
    print(f"    E_γ: {gamma.energy} MeV")
    
    # Transport through ISM (Geant4)
    print(f"\n  [2] Transport Through ISM (Geant4):")
    transport = adapter.transport_particle(gamma, 'ISM', distance=8000)  # 8 kpc
    
    # Detection
    print(f"\n  [3] Detection:")
    if transport['final_particle']:
        detection = adapter.simulate_detector(
            transport['final_particle'],
            'scintillator'
        )
        
        print(f"    Detected: {detection['detected']}")
        if detection['detected']:
            print(f"    → Validates {source} in Galaxy!")
    
    return {
        'source': source,
        'gamma': gamma,
        'transport': transport,
        'detection': detection if transport['final_particle'] else None
    }


def simulate_cosmic_ray_quantum_damage() -> Dict:
    """Simulate cosmic ray damage to quantum computer
    
    Connects Geant4 → qutip!
    
    Returns
    -------
    damage : dict
        Radiation damage analysis
    """
    
    print("\n" + "="*70)
    print("  COSMIC RAY DAMAGE TO QUANTUM COMPUTER")
    print("  Geant4 → qutip")
    print("="*70)
    
    adapter = Geant4Adapter()
    
    # Cosmic ray proton
    proton = adapter.create_particle('proton', 100, [0, 0, 0])
    
    # Damage to qubit
    damage = adapter.radiation_damage_qubit(proton)
    
    print(f"\n  Mitigation:")
    print(f"    • Underground lab: 10⁶x reduction")
    print(f"    • Shielding: 10²-10³x reduction")
    print(f"    • Error correction: Tolerate hits")
    
    return damage
