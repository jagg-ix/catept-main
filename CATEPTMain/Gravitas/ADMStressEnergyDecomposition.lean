/-!
# Gravitas.ADMStressEnergyDecomposition

Port of `Gravitas/Kernel/ADMStressEnergyDecomposition.wl`.

3+1 decomposition of the stress-energy tensor T^{μν} into ADM quantities:
- Energy density:      ρ_ADM = T^{μν} n_μ n_ν
- Momentum density:    j^i = -γ^{iμ} T_{μν} n^ν
- Stress tensor:       S^{ij} = γ^{iμ} γ^{jν} T_{μν}

where n^μ is the unit future-pointing normal to the spatial hypersurface.

Named matter models follow the WL source (PerfectFluid, Dust, etc.).
-/

import CATEPTMain.Gravitas.Basic
import CATEPTMain.Gravitas.MetricTensor
import CATEPTMain.Gravitas.StressEnergyTensor
import CATEPTMain.Gravitas.ADMDecomposition

namespace Gravitas

-- ---------------------------------------------------------------------------
-- Structure
-- ---------------------------------------------------------------------------

/-- ADM 3+1 decomposition of a stress-energy tensor. -/
structure ADMStressEnergyDecomposition where
  adm          : ADMDecomposition
  stressEnergy : StressEnergyTensor
  /-- Energy density ρ_ADM = n^μ n^ν T_{μν}. -/
  energyDensity    : Expr
  /-- Momentum density j^i = -γ^{iμ} n^ν T_{μν} (contravariant). -/
  momentumDensity  : Array Expr
  /-- Stress tensor S^{ij} = γ^{iμ} γ^{jν} T_{μν} (contravariant). -/
  stressTensor     : Mat
  deriving Repr

namespace ADMStressEnergyDecomposition

/-- Reconstruct the 4D spacetime metric from ADM data and compute the
    normal vector n^μ = (1/α, -β^i/α). -/
private def normalVector (adm : ADMDecomposition) : Array Expr :=
  let α  := adm.lapseFunction
  let β  := adm.shiftVector
  let n3 := adm.spatialMetric.dim
  -- n^μ = (1/α, -β^i/α)
  Array.ofFn (fun μ =>
    if μ.val == 0 then .div (.lit 1) α
    else simplify (.neg (.div (β.get! (μ.val - 1)) α)))

/-- Perform the ADM decomposition of a stress-energy tensor. -/
def ofADMAndStressEnergy (adm : ADMDecomposition) (st : StressEnergyTensor)
    : ADMStressEnergyDecomposition :=
  let g4   := ADMDecomposition.spacetimeMetric adm
  let gCov := g4.covariantMatrix
  let gInv := g4.inverseMatrix
  let n4   := g4.dim  -- = n3 + 1
  let n3   := adm.spatialMetric.dim
  let γCov := adm.spatialMetric.covariantMatrix
  let γInv := adm.spatialMetric.inverseMatrix
  -- Get T_{μν} (covariant in full 4D)
  let tCov :=
    let tc := st.components
    match st.idx1, st.idx2 with
    | true, true   => tc
    | false, false =>
        matBuild n4 (fun i j =>
          sumN n4 (fun k => sumN n4 (fun l =>
            simplify (.mul (.mul (matGet gCov i k) (matGet gCov j l)) (matGet tc k l)))))
    | true, false  =>
        matBuild n4 (fun i j =>
          sumN n4 (fun k => simplify (.mul (matGet gCov k j) (matGet tc i k))))
    | false, true  =>
        matBuild n4 (fun i j =>
          sumN n4 (fun k => simplify (.mul (matGet gCov i k) (matGet tc k j))))
  let n   := normalVector adm  -- n^μ (contravariant)
  -- n_μ = g_{μν} n^ν (covariant normal)
  let nCov := Array.ofFn (fun μ =>
    sumN n4 (fun ν => simplify (.mul (matGet gCov μ.val ν) (n.get! ν))))
  -- Energy density: ρ_ADM = T^{μν} n_μ n_ν = T_{μν} n^μ n^ν
  let ρADM := sumN n4 (fun μ => sumN n4 (fun ν =>
    simplify (.mul (.mul (matGet tCov μ ν) (n.get! μ)) (n.get! ν))))
  -- Momentum density: j^i = -γ^{iμ} n^ν T_{μν}  (spatial index i in 0..n3-1)
  let jDensity := Array.ofFn (fun i =>
    -- γ^{iμ} acts on spatial indices: we use the (i+1)-th spatial component of g
    -- Approximate: j^i ≈ -Σ_μ Σ_ν γInv_{i,μ-1} n^ν T_{μν} for μ≥1
    sumN n3 (fun k => sumN n4 (fun ν =>
      simplify (.neg (.mul (.mul (matGet γInv i.val k) (n.get! ν)) (matGet tCov (k+1) ν))))))
  -- Stress tensor: S^{ij} = γ^{iμ} γ^{jν} T_{μν}  (spatial)
  let sTensor := matBuild n3 (fun i j =>
    sumN n3 (fun k => sumN n3 (fun l =>
      simplify (.mul (.mul (matGet γInv i k) (matGet γInv j l)) (matGet tCov (k+1) (l+1))))))
  { adm := adm, stressEnergy := st,
    energyDensity := ρADM, momentumDensity := jDensity, stressTensor := sTensor }

-- ---------------------------------------------------------------------------
-- Named matter models (matching WL's `ADMStressEnergyDecomposition["PerfectFluid"]` etc.)
-- ---------------------------------------------------------------------------

/-- Perfect fluid decomposition for a given ADM slicing. -/
def perfectFluid (adm : ADMDecomposition) (ρ P : Expr) (u : Array Expr)
    : ADMStressEnergyDecomposition :=
  let g4 := ADMDecomposition.spacetimeMetric adm
  let st := StressEnergyTensor.perfectFluid g4 ρ P u
  ofADMAndStressEnergy adm st

def perfectFluidSymbolic (adm : ADMDecomposition) : ADMStressEnergyDecomposition :=
  let g4 := ADMDecomposition.spacetimeMetric adm
  let n  := g4.dim
  let ρ  := .var "ρ"; let P := .var "P"
  let u  := Array.ofFn (fun i => .var s!"u{i.val}")
  perfectFluid adm ρ P u

def dust (adm : ADMDecomposition) (ρ : Expr) (u : Array Expr)
    : ADMStressEnergyDecomposition :=
  let g4 := ADMDecomposition.spacetimeMetric adm
  let st := StressEnergyTensor.dust g4 ρ u
  ofADMAndStressEnergy adm st

/-- Named dispatch. -/
def named (name : String) (adm : ADMDecomposition)
    : Option ADMStressEnergyDecomposition :=
  match name with
  | "PerfectFluid"  => some (perfectFluidSymbolic adm)
  | "Dust"          => some (dust adm (.var "ρ") (Array.ofFn (fun i => .var s!"u{i.val}")))
  | _               => none

end ADMStressEnergyDecomposition
end Gravitas
