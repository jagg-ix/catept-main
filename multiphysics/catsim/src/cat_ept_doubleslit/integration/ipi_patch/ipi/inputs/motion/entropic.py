"""
Input classes for entropic Langevin dynamics.

Defines XML tags and parsing for entropic motion mode.
"""

from ipi.inputs.motion.motion import InputMotion
from ipi.engine.motion.entropic_langevin import EntropicLangevinMotion
from ipi.utils.inputvalue import InputValue, InputArray
from ipi.utils.entropic_time import (
    ConstantDissipation,
    HorizonDissipation,
    GaussianDissipation,
    AsymmetricDissipation,
    ENZDissipation,
    FlatSpaceLapse,
    SchwarzschildLapse,
)

__all__ = ["InputEntropicLangevin"]


class InputEntropicLangevin(InputMotion):
    """
    Input class for entropic Langevin dynamics.
    
    XML example:
    <motion mode="entropic_langevin">
        <dissipation model="constant" rate="5.3e3" />
        <effective_temperature>3e-7</effective_temperature>
        <lapse model="flat" />
        <tracking visibility="true" complex_charge="false" />
    </motion>
    """
    
    attribs = {
        "mode": (
            InputValue(name="mode", dtype=str, default="entropic_langevin"),
            "Type of dynamics (fixed to 'entropic_langevin')",
        )
    }
    
    fields = {
        "dissipation": (
            InputValue(name="dissipation", dtype=dict),
            """Dissipation model configuration.
            
            Attributes:
                model: Type of dissipation ("constant", "horizon", "gaussian", "asymmetric", "enz")
                rate: For constant model, λ₀ in s^-1
                mass: For horizon model, BH mass in solar masses
                spin: For horizon model, dimensionless spin χ
                length_scale: For gaussian model, width L in meters
                asymmetry: For asymmetric model, parameter α
                separation: For asymmetric model, arm separation d in meters
            
            Examples:
                <dissipation model="constant" rate="5.3e3" />
                <dissipation model="horizon" mass="1.0" spin="0.69" />
                <dissipation model="gaussian" rate="1e4" length_scale="1e-6" />
            """,
        ),
        "effective_temperature": (
            InputValue(name="effective_temperature", dtype=float, default=300.0),
            """Effective temperature of dissipative channel in Kelvin.
            
            This is NOT the bath temperature, but the temperature
            entering the fluctuation-dissipation balance for the
            measured dissipation rate λ.
            
            Examples:
                - Black hole: T_Hawking ~ 10^-8 K for solar mass
                - SGI atoms: T_atom ~ 3×10^-7 K for ultracold Rb
                - ENZ electrons: T_electron ~ 10³ K under pumping
            """,
        ),
        "lapse": (
            InputValue(name="lapse", dtype=dict, default={"model": "flat"}),
            """Gravitational lapse model α(x) = √(-g_00).
            
            Attributes:
                model: Type of lapse ("flat", "schwarzschild")
                mass: For schwarzschild, BH mass in solar masses
                origin: BH center coordinates [x, y, z] in meters
            
            Examples:
                <lapse model="flat" />
                <lapse model="schwarzschild" mass="1.0" origin="[0, 0, 0]" />
            """,
        ),
        "tracking": (
            InputValue(name="tracking", dtype=dict, default={"visibility": True, "complex_charge": False}),
            """Configure tracking of derived quantities.
            
            Attributes:
                visibility: Track V(t) = exp(-τ_ent) for validation
                complex_charge: Track Q = E - iℏλ conservation
            """,
        ),
    }
    
    default_help = "Langevin dynamics with entropic time corrections"
    default_label = "ENTROPIC_LANGEVIN"
    
    def store(self, motion):
        """Store parsed input in motion object."""
        super(InputEntropicLangevin, self).store(motion)
        
        # Parse dissipation model
        diss_config = self.dissipation.fetch()
        motion.lambda_model = self._create_dissipation_model(diss_config)
        
        # Parse lapse model
        lapse_config = self.lapse.fetch()
        motion.alpha_model = self._create_lapse_model(lapse_config)
        
        # Set temperature
        motion.T_eff = self.effective_temperature.fetch()
        
        # Set tracking options
        track_config = self.tracking.fetch()
        motion.track_visibility = track_config.get("visibility", True)
        motion.track_complex_charge = track_config.get("complex_charge", False)
    
    def _create_dissipation_model(self, config):
        """Create dissipation model from config dictionary."""
        model_type = config.get("model", "constant")
        
        if model_type == "constant":
            rate = float(config.get("rate", 1e3))
            return ConstantDissipation(rate)
        
        elif model_type == "horizon":
            mass = float(config.get("mass", 1.0)) * 1.98892e30  # Solar masses to kg
            spin = float(config.get("spin", 0.0))
            origin = config.get("origin", None)
            if origin:
                origin = np.array(origin, dtype=float)
            return HorizonDissipation(mass, spin, origin)
        
        elif model_type == "gaussian":
            rate = float(config.get("rate", 1e4))
            length_scale = float(config.get("length_scale", 1e-6))
            center = config.get("center", None)
            if center:
                center = np.array(center, dtype=float)
            return GaussianDissipation(rate, length_scale, center)
        
        elif model_type == "asymmetric":
            rate = float(config.get("rate", 5.3e3))
            asymmetry = float(config.get("asymmetry", 0.1))
            separation = float(config.get("separation", 1e-3))
            axis = int(config.get("axis", 0))
            return AsymmetricDissipation(rate, asymmetry, separation, axis)
        
        elif model_type == "enz":
            tau_rise = float(config.get("tau_rise", 7.1e-15))
            return ENZDissipation(tau_rise)
        
        else:
            raise ValueError(f"Unknown dissipation model: {model_type}")
    
    def _create_lapse_model(self, config):
        """Create lapse model from config dictionary."""
        model_type = config.get("model", "flat")
        
        if model_type == "flat":
            return FlatSpaceLapse()
        
        elif model_type == "schwarzschild":
            mass = float(config.get("mass", 1.0)) * 1.98892e30  # Solar masses to kg
            origin = config.get("origin", None)
            if origin:
                origin = np.array(origin, dtype=float)
            return SchwarzschildLapse(mass, origin)
        
        else:
            raise ValueError(f"Unknown lapse model: {model_type}")
