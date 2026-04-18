(* ::Package:: *)
(* CAT/EPT Quantum Framework — Package Initialization *)
(* Complex Action Theory / Entropic Proper Time extension *)
(* for the Wolfram Quantum Framework.                     *)
(*                                                        *)
(* S[Phi] = S_R[Phi] + i S_I[Phi],   S_I >= 0            *)
(* H     = H_R      - i H_I,         H_I >= 0            *)
(* tau_ent = (1/hbar) S_I = Integrate[lambda[t'], {t',0,t}] *)

BeginPackage["CATEPT`"];

(* Soft-import QuantumFramework — package works without it for core math *)
Quiet[
    Check[Needs["Wolfram`QuantumFramework`"],
        $CATEPTQuantumFrameworkAvailable = False],
    {Get::noopen, Needs::nocont}
];
If[!ValueQ[$CATEPTQuantumFrameworkAvailable],
    $CATEPTQuantumFrameworkAvailable = True];

(* ---- Public symbols ---- *)

(* Core types *)
EntropicRate::usage =
    "EntropicRate[lambda, opts] represents an entropy production rate \
lambda(t) with optional RG running, ENZ enhancement, and spacetime coupling.";

EntropicHamiltonian::usage =
    "EntropicHamiltonian[H_R, J, lambda] represents the complex \
Hamiltonian H = H_R - i hbar lambda(t) J from the CAT/EPT framework.";

EntropicChannel::usage =
    "EntropicChannel[{L1, L2, ...}, lambda] represents a quantum channel \
with Lindblad jump operators and entropic action tracking.";

EntropicResult::usage =
    "EntropicResult[assoc] holds evolution results with entropy, \
entropic time, and path-integral weight traces.";

(* Material model *)
ENZMaterial::usage =
    "ENZMaterial[name] returns Drude dispersion parameters for an \
epsilon-near-zero material. Supported: \"ITO\", \"AZO\", \"GZO\".";

(* Spacetime coupling *)
SpacetimeCoupler::usage =
    "SpacetimeCoupler[type, opts] constructs a gravitational coupling \
that modifies the entropic rate via redshift and EFE residuals.";

(* Main solver *)
EntropicEvolve::usage =
    "EntropicEvolve[H, psi0, {t, t0, tf}] evolves a quantum state \
under complex-action dynamics, returning an EntropicResult with \
entropy S(t), entropic time tau(t), and cSF weight exp(-S_I/hbar).";

(* Thermodynamic functions *)
HawkingTemperature::usage =
    "HawkingTemperature[M] returns the Hawking temperature in Kelvin \
for a Schwarzschild black hole of mass M (kg).";

UnruhTemperature::usage =
    "UnruhTemperature[a] returns the Unruh temperature in Kelvin \
for proper acceleration a (m/s^2).";

(* RG running *)
LambdaTildeRunning::usage =
    "LambdaTildeRunning[mu, {b, c2, lambdaTilde0, mu0}] evaluates \
the one-loop RG running coupling at energy scale mu (GeV).";

(* Utility *)
EntropicTime::usage =
    "EntropicTime[tlist, lambdaValues] computes the entropic proper \
time tau_ent(t) = Integrate[lambda(t'), {t', 0, t}] via trapezoid rule.";

CSFWeight::usage =
    "CSFWeight[SI] returns the complex Schrodinger functional weight \
Exp[-SI/hbar] for imaginary action SI.";

(* Named objects *)
$ENZMaterials::usage =
    "$ENZMaterials gives the list of supported ENZ material names.";

$CATEPTVersion::usage =
    "$CATEPTVersion gives the current package version string.";

(* ENZ material functions *)
EpsilonDrude::usage =
    "EpsilonDrude[mat, omega] returns the complex Drude permittivity.";
GroupVelocity::usage =
    "GroupVelocity[mat, omega] returns the group velocity from dispersion.";
ENZFrequency::usage =
    "ENZFrequency[mat] returns the ENZ crossing frequency (rad/s).";
ENZWavelength::usage =
    "ENZWavelength[mat] returns the ENZ crossing wavelength (m).";
EnhancementFactor::usage =
    "EnhancementFactor[mat, omega] returns the c/v_g enhancement factor.";
ENZDecoherenceRate::usage =
    "ENZDecoherenceRate[mat, omega, T] returns the ENZ-enhanced decoherence rate.";
WavelengthScan::usage =
    "WavelengthScan[mat, range, n, T] returns a full dispersion profile.";
RefractiveIndex::usage =
    "RefractiveIndex[mat, omega] returns the complex refractive index.";

(* Spacetime functions *)
SchwarzschildRadius::usage =
    "SchwarzschildRadius[M] returns r_s = 2GM/c^2 (m).";
ISCORadius::usage =
    "ISCORadius[M] returns the innermost stable circular orbit radius.";
HawkingEntropyRate::usage =
    "HawkingEntropyRate[M] returns dS_BH/dt for Schwarzschild (J/K/s).";
SpacetimeCouplerFactor::usage =
    "SpacetimeCouplerFactor[coupler, t] evaluates the coupling factor at time t.";

(* Hamiltonian functions *)
ComplexMatrix::usage =
    "ComplexMatrix[ham, t] returns H_R - i*hbar*lambda(t)*J as a matrix.";
ToQuantumOperator::usage =
    "ToQuantumOperator[ham, t] converts EntropicHamiltonian to a QuantumOperator.";
DecayWidth::usage =
    "DecayWidth[ham, state, t] returns Gamma = 2*lambda*<n|H_I|n>.";
EnergyCost::usage =
    "EnergyCost[ham, state, dtau] returns DeltaE = hbar*dtau*<H_I>.";

(* Channel functions *)
ToQuantumChannel::usage =
    "ToQuantumChannel[ch] converts EntropicChannel to QuantumChannel.";
ApplyChannel::usage =
    "ApplyChannel[ch, state, dt] applies the channel and returns {newState, dSI}.";

(* Verification *)
GenerateVerificationStub::usage =
    "GenerateVerificationStub[ham, result, eqId] generates a .wl verification stub.";
VerifyEntropicResult::usage =
    "VerifyEntropicResult[result] checks all CAT/EPT physics constraints.";

(* Python backend *)
EntropicEvolvePython::usage =
    "EntropicEvolvePython[ham, psi0, tlist] runs evolution via Python/QuTiP.";
ToPythonCode::usage =
    "ToPythonCode[ham, psi0, tlist] generates Python source code.";
CATEPTExecuteCommand::usage =
    "CATEPTExecuteCommand[type, params] executes a typed qf_qutip_dsl command \
via Python and returns its result as an Association-compatible object.";

(* Extended multiphysics command wrappers (Python-native bridge) *)
ComplexEFE::usage =
    "ComplexEFE[metric, opts] executes the typed ComplexEFE pipeline via Python.";
PathIntegral::usage =
    "PathIntegral[opts] executes the typed path-integral pipeline via Python.";
SelfConsistentCoupler::usage =
    "SelfConsistentCoupler[coupler, opts] executes the typed self-consistent \
coupler pipeline via Python.";
MEEPCavity::usage =
    "MEEPCavity[opts] executes the typed MEEP cavity pipeline via Python.";
OpenFOAMFlow::usage =
    "OpenFOAMFlow[solver, opts] executes the typed OpenFOAM flow pipeline via Python.";
QEDVacuum::usage =
    "QEDVacuum[opts] executes the typed QED vacuum pipeline via Python.";
OpenFermionHamiltonian::usage =
    "OpenFermionHamiltonian[opts] executes the typed OpenFermion pipeline via Python.";
PySCFMolecular::usage =
    "PySCFMolecular[opts] executes the typed PySCF molecular pipeline via Python.";
DiracRelativistic::usage =
    "DiracRelativistic[opts] executes the typed relativistic Dirac pipeline via Python.";
CirqResource::usage =
    "CirqResource[opts] executes the typed Cirq resource-estimation pipeline via Python.";
KwantTransport::usage =
    "KwantTransport[opts] executes the typed Kwant transport pipeline via Python.";
PythTBBands::usage =
    "PythTBBands[opts] executes the typed PythTB band-structure pipeline via Python.";

(* ---- Fallback definitions when QuantumFramework is not installed ---- *)

If[!TrueQ[$CATEPTQuantumFrameworkAvailable],
    (* Predicate for QuantumOperator: wraps a matrix *)
    QuantumOperatorQ[QuantumOperator[_?MatrixQ]] := True;
    QuantumOperatorQ[_] := False;

    (* QuantumOperator property access via SubValues *)
    QuantumOperator[mat_?MatrixQ]["MatrixRepresentation"] := mat;
    QuantumOperator[mat_?MatrixQ]["OutputDimension"] := Length[mat];

    (* Predicate for QuantumState *)
    QuantumStateQ[QuantumState[_?VectorQ]] := True;
    QuantumStateQ[_] := False;

    (* QuantumState property access *)
    QuantumState[vec_?VectorQ]["StateVector"] := vec;
    QuantumState[vec_?VectorQ]["DensityMatrix"] :=
        Outer[Times, vec, Conjugate[vec]];

    (* Named states *)
    QuantumState["0"] := QuantumState[{1.0 + 0.0 I, 0.0 + 0.0 I}];
    QuantumState["1"] := QuantumState[{0.0 + 0.0 I, 1.0 + 0.0 I}];
    QuantumState["Plus"] :=
        QuantumState[{1/Sqrt[2.0] + 0.0 I, 1/Sqrt[2.0] + 0.0 I}];
    QuantumState["Minus"] :=
        QuantumState[{1/Sqrt[2.0] + 0.0 I, -1/Sqrt[2.0] + 0.0 I}];
    QuantumState["Bell"] :=
        QuantumState[{1/Sqrt[2.0] + 0.0 I, 0.0 + 0.0 I,
                      0.0 + 0.0 I, 1/Sqrt[2.0] + 0.0 I}];
];

(* ---- Load subpackages ---- *)

Begin["`Private`"];

$CATEPTVersion = "0.1.0";

(* Physical constants (SI) *)
$hbar = 1.054571817`*^-34;
$kB   = 1.380649`*^-23;
$c    = 2.99792458`*^8;
$G    = 6.67430`*^-11;
$SolarMass = 1.98892`*^30;

End[];

(* Load modules in dependency order — use file paths for direct loading *)
(* $InputFileName is set by Get[]; if loading via wolframscript -code,  *)
(* fall back to searching $Path or explicit CATEPT`$KernelDirectory.    *)

Module[{dir},
    dir = If[StringQ[$InputFileName] && $InputFileName =!= "",
        DirectoryName[$InputFileName],
        (* Fallback: check if user set the directory explicitly *)
        If[ValueQ[CATEPT`$KernelDirectory] && DirectoryQ[CATEPT`$KernelDirectory],
            CATEPT`$KernelDirectory,
            (* Last resort: search $Path *)
            Module[{found},
                found = Select[
                    FileNameJoin[{#, "CATEPTFramework", "Kernel"}] & /@ $Path,
                    DirectoryQ
                ];
                If[Length[found] > 0, First[found], Directory[]]
            ]
        ]
    ];
    Get[FileNameJoin[{dir, "ENZMaterial.m"}]];
    Get[FileNameJoin[{dir, "EntropicRate.m"}]];
    Get[FileNameJoin[{dir, "SpacetimeCoupler.m"}]];
    Get[FileNameJoin[{dir, "EntropicHamiltonian.m"}]];
    Get[FileNameJoin[{dir, "EntropicChannel.m"}]];
    Get[FileNameJoin[{dir, "EntropicResult.m"}]];
    Get[FileNameJoin[{dir, "EntropicEvolve.m"}]];
    Get[FileNameJoin[{dir, "PythonBackend.m"}]];
    Get[FileNameJoin[{dir, "VerificationBackend.m"}]];
    Get[FileNameJoin[{dir, "NamedObjects.m"}]];
];

EndPackage[];
