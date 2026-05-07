import CATEPTMain.Gravitas.Basic
import CATEPTMain.Gravitas.MetricTensor
import CATEPTMain.Gravitas.ChristoffelSymbols
import CATEPTMain.Gravitas.RiemannTensor
import CATEPTMain.Gravitas.RicciTensor
import CATEPTMain.Gravitas.EinsteinTensor
import CATEPTMain.Gravitas.WeylTensor
import CATEPTMain.Gravitas.SchoutenTensor
import CATEPTMain.Gravitas.BachTensor
import CATEPTMain.Gravitas.ElectrograviticTensor
import CATEPTMain.Gravitas.StressEnergyTensor
import CATEPTMain.Gravitas.ElectromagneticTensor
import CATEPTMain.Gravitas.AngularMomentumTensor
import CATEPTMain.Gravitas.AngularMomentumDensityTensor
import CATEPTMain.Gravitas.ADMDecomposition
import CATEPTMain.Gravitas.ExtrinsicCurvatureTensor
import CATEPTMain.Gravitas.ADMStressEnergyDecomposition
import CATEPTMain.Gravitas.DiscreteHypersurfaceDecomposition
import CATEPTMain.Gravitas.DiscreteHypersurfaceGeodesic
import CATEPTMain.Gravitas.SolveEinsteinEquations
import CATEPTMain.Gravitas.SolveVacuumEinsteinEquations
import CATEPTMain.Gravitas.SolveElectrovacuumEinsteinEquations
import CATEPTMain.Gravitas.SolveADMEquations
import CATEPTMain.Gravitas.SolveVacuumADMEquations
/-!
# CATEPTMain.Gravitas

Lean 4 port of the Gravitas general-relativity package
(originally by Jonathan Gorard, Wolfram Institute, 2020).

## Source

  (private path)/tau/Gravitas/Gravitas/Kernel/

## Module structure

| Module | WL source |
|--------|-----------|
| `Gravitas.Basic`                       | Core Expr / Mat types |
| `Gravitas.MetricTensor`                | MetricTensor.wl |
| `Gravitas.ChristoffelSymbols`          | ChristoffelSymbols.wl |
| `Gravitas.RiemannTensor`               | RiemannTensor.wl |
| `Gravitas.RicciTensor`                 | RicciTensor.wl |
| `Gravitas.EinsteinTensor`              | EinsteinTensor.wl |
| `Gravitas.WeylTensor`                  | WeylTensor.wl |
| `Gravitas.SchoutenTensor`              | SchoutenTensor.wl |
| `Gravitas.BachTensor`                  | BachTensor.wl |
| `Gravitas.ElectrograviticTensor`       | ElectrograviticTensor.wl |
| `Gravitas.StressEnergyTensor`          | StressEnergyTensor.wl |
| `Gravitas.ElectromagneticTensor`       | ElectromagneticTensor.wl |
| `Gravitas.AngularMomentumTensor`       | AngularMomentumTensor.wl |
| `Gravitas.AngularMomentumDensityTensor`| AngularMomentumDensityTensor.wl |
| `Gravitas.ADMDecomposition`            | ADMDecomposition.wl |
| `Gravitas.ExtrinsicCurvatureTensor`    | ExtrinsicCurvatureTensor.wl |
| `Gravitas.ADMStressEnergyDecomposition`| ADMStressEnergyDecomposition.wl |
| `Gravitas.DiscreteHypersurfaceDecomposition` | DiscreteHypersurfaceDecomposition.wl |
| `Gravitas.DiscreteHypersurfaceGeodesic`| DiscreteHypersurfaceGeodesic.wl |
| `Gravitas.SolveEinsteinEquations`      | SolveEinsteinEquations.wl |
| `Gravitas.SolveVacuumEinsteinEquations`| SolveVacuumEinsteinEquations.wl |
| `Gravitas.SolveElectrovacuumEinsteinEquations` | SolveElectrovacuumEinsteinEquations.wl |
| `Gravitas.SolveADMEquations`           | SolveADMEquations.wl |
| `Gravitas.SolveVacuumADMEquations`     | SolveVacuumADMEquations.wl |

## Design notes

- **Symbolic expression type**: `Gravitas.Expr` is a lightweight CAS ADT with
  full symbolic differentiation (`symDiff`) and basic simplification (`simplify`).
  It replaces Mathematica's built-in symbolic engine.

- **Matrix representation**: `Mat = Array (Array Expr)` — row-major, 0-indexed,
  matching the WL `List` convention.

- **Index convention**: `true` = covariant (lower), `false` = contravariant (upper),
  exactly matching WL's `True/False` boolean index flags.
-/
