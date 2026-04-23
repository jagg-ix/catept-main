#!/usr/bin/env python3
"""
Build a SQLite catalog of the NavierStokes Route 6 formalization.

Parses all .lean source files to extract:
- Files and their import dependencies
- Axioms with type signatures, line numbers, classifications
- Theorems with type signatures, line numbers, proof status
- Structures and definitions
- Route 6 critical path annotations
- Cross-references to Wolfram equation stubs

Usage:
    python3 catalog.py                    # builds catalog.db in current dir
    python3 catalog.py --output my.db     # custom output path
    python3 catalog.py --query            # build + run sample queries
"""

import sqlite3
import re
import os
import sys
import argparse
from pathlib import Path

# ---------------------------------------------------------------------------
# Schema
# ---------------------------------------------------------------------------

SCHEMA = """
-- Files in the formalization
CREATE TABLE IF NOT EXISTS files (
    id          INTEGER PRIMARY KEY,
    filename    TEXT UNIQUE NOT NULL,        -- e.g. 'PDEInterfaces.lean'
    filepath    TEXT NOT NULL,               -- relative path from lean4/
    line_count  INTEGER,
    description TEXT                         -- from module docstring
);

-- Import dependencies between files
CREATE TABLE IF NOT EXISTS imports (
    id          INTEGER PRIMARY KEY,
    importer_id INTEGER NOT NULL REFERENCES files(id),
    imported_id INTEGER NOT NULL REFERENCES files(id),
    UNIQUE(importer_id, imported_id)
);

-- Axioms
CREATE TABLE IF NOT EXISTS axioms (
    id              INTEGER PRIMARY KEY,
    name            TEXT UNIQUE NOT NULL,
    file_id         INTEGER NOT NULL REFERENCES files(id),
    line_number     INTEGER NOT NULL,
    type_signature  TEXT,                    -- full type after ':'
    classification  TEXT,                    -- TYPE, POS, STD-PDE, STD-MATH, PUBLISHED, PHYS-ID, WOLFRAM, OPEN, SUPERSEDED, STRUCTURAL
    reference       TEXT,                    -- published source
    description     TEXT,                    -- from docstring or comment
    route6_critical INTEGER DEFAULT 0       -- 1 if on Route 6 critical path
);

-- Theorems
CREATE TABLE IF NOT EXISTS theorems (
    id              INTEGER PRIMARY KEY,
    name            TEXT UNIQUE NOT NULL,
    file_id         INTEGER NOT NULL REFERENCES files(id),
    line_number     INTEGER NOT NULL,
    type_signature  TEXT,
    proof_method    TEXT,                    -- 'tactic', 'term', 'by'
    description     TEXT,
    route6_critical INTEGER DEFAULT 0
);

-- Structures
CREATE TABLE IF NOT EXISTS structures (
    id          INTEGER PRIMARY KEY,
    name        TEXT UNIQUE NOT NULL,
    file_id     INTEGER NOT NULL REFERENCES files(id),
    line_number INTEGER NOT NULL,
    fields      TEXT,                        -- JSON or semicolon-separated
    description TEXT
);

-- Definitions (def, noncomputable def)
CREATE TABLE IF NOT EXISTS definitions (
    id          INTEGER PRIMARY KEY,
    name        TEXT NOT NULL,
    file_id     INTEGER NOT NULL REFERENCES files(id),
    line_number INTEGER NOT NULL,
    type_signature TEXT,
    description TEXT
);

-- Wolfram equation stubs cross-referenced to Lean
CREATE TABLE IF NOT EXISTS equations (
    id              INTEGER PRIMARY KEY,
    equation_id     TEXT UNIQUE NOT NULL,    -- e.g. 'eq_238'
    title           TEXT,
    wolfram_file    TEXT,                    -- e.g. 'eq_238_trace_cameron_competition.wl'
    lean_theorem    TEXT,                    -- primary Lean theorem name
    lean_file       TEXT,                    -- Lean file containing theorem
    description     TEXT,
    status          TEXT                     -- 'verified', 'partial', 'open'
);

-- Route 6 critical path (ordered steps)
CREATE TABLE IF NOT EXISTS route6_path (
    step_order  INTEGER PRIMARY KEY,
    item_type   TEXT NOT NULL,               -- 'axiom' or 'theorem'
    item_name   TEXT NOT NULL,
    file        TEXT NOT NULL,
    description TEXT,
    reference   TEXT
);

-- Epistemic summary view
CREATE VIEW IF NOT EXISTS axiom_summary AS
SELECT
    classification,
    COUNT(*) as count,
    SUM(route6_critical) as route6_count
FROM axioms
GROUP BY classification
ORDER BY count DESC;

-- File statistics view
CREATE VIEW IF NOT EXISTS file_stats AS
SELECT
    f.filename,
    (SELECT COUNT(*) FROM axioms a WHERE a.file_id = f.id) as axiom_count,
    (SELECT COUNT(*) FROM theorems t WHERE t.file_id = f.id) as theorem_count,
    (SELECT COUNT(*) FROM structures s WHERE s.file_id = f.id) as structure_count,
    (SELECT COUNT(*) FROM definitions d WHERE d.file_id = f.id) as def_count
FROM files f
ORDER BY axiom_count + theorem_count DESC;
"""

# ---------------------------------------------------------------------------
# Lean parser
# ---------------------------------------------------------------------------

def find_lean_dir():
    """Find the lean4 source directory."""
    candidates = [
        Path(__file__).parent / "lean4",
        Path(__file__).parent.parent / "lean4_formal_verification" / "NavierStokes",
    ]
    for c in candidates:
        if (c / "NavierStokes.lean").exists():
            return c
    # fallback: relative to cwd
    for c in [Path("lean4"), Path(".")]:
        if (c / "NavierStokes.lean").exists():
            return c
    raise FileNotFoundError("Cannot find lean4 source directory. Run from submission dir.")


def parse_module_docstring(content: str) -> str:
    """Extract the first /-! ... -/ docstring."""
    m = re.search(r'/\-!\s*\n(.*?)\-/', content, re.DOTALL)
    if m:
        lines = m.group(1).strip().split('\n')
        # Take first non-empty line as description
        for line in lines:
            stripped = line.strip().lstrip('#').strip()
            if stripped:
                return stripped[:500]
    return ""


def parse_imports(content: str) -> list:
    """Extract import statements."""
    imports = []
    for m in re.finditer(r'^import\s+NavierStokes\.(\w+)', content, re.MULTILINE):
        imports.append(m.group(1) + ".lean")
    return imports


def parse_axioms(content: str) -> list:
    """Extract axiom declarations with line numbers and type signatures."""
    axioms = []
    lines = content.split('\n')
    i = 0
    while i < len(lines):
        line = lines[i]
        m = re.match(r'^axiom\s+(\w+)', line)
        if m:
            name = m.group(1)
            # Collect full type signature (may span multiple lines)
            sig_line = line[len("axiom " + name):].strip()
            if sig_line.startswith(':'):
                sig_line = sig_line[1:].strip()
            elif sig_line.startswith('(') or sig_line.startswith('{'):
                # has parameters before ':'
                full = sig_line
                j = i + 1
                while j < len(lines) and not re.match(r'^(axiom|theorem|def|structure|namespace|end|section|/-)', lines[j]):
                    full += ' ' + lines[j].strip()
                    j += 1
                sig_line = full

            # Look for preceding comment/docstring
            desc = ""
            if i > 0:
                prev = lines[i-1].strip()
                if prev.startswith('--'):
                    desc = prev.lstrip('-').strip()
                elif prev.endswith('-/'):
                    # scan backward for /--
                    for k in range(i-1, max(i-20, -1), -1):
                        if '/--' in lines[k] or '/-' in lines[k]:
                            desc = ' '.join(l.strip().lstrip('/-!*').rstrip('-/').strip()
                                          for l in lines[k:i] if l.strip())[:500]
                            break

            axioms.append({
                'name': name,
                'line': i + 1,
                'type_sig': sig_line[:1000],
                'description': desc[:500]
            })
        i += 1
    return axioms


def parse_theorems(content: str) -> list:
    """Extract theorem declarations."""
    theorems = []
    lines = content.split('\n')
    i = 0
    while i < len(lines):
        line = lines[i]
        m = re.match(r'^theorem\s+(\w+)', line)
        if m:
            name = m.group(1)
            sig_line = line[len("theorem " + name):].strip()
            if sig_line.startswith(':'):
                sig_line = sig_line[1:].strip()

            # Determine proof method
            proof_method = "unknown"
            full_block = line
            j = i + 1
            depth = 0
            while j < len(lines) and j < i + 50:
                full_block += '\n' + lines[j]
                if ':= by' in full_block or ':=\n  by' in full_block.replace('\n', '\n'):
                    proof_method = "tactic"
                    break
                if ':=' in lines[j] and 'by' not in lines[j]:
                    proof_method = "term"
                    break
                j += 1
            if ':= by' in line:
                proof_method = "tactic"
            elif ':=' in line and 'by' not in line:
                proof_method = "term"

            desc = ""
            if i > 0:
                prev = lines[i-1].strip()
                if prev.startswith('--'):
                    desc = prev.lstrip('-').strip()

            theorems.append({
                'name': name,
                'line': i + 1,
                'type_sig': sig_line[:1000],
                'proof_method': proof_method,
                'description': desc[:500]
            })
        i += 1
    return theorems


def parse_structures(content: str) -> list:
    """Extract structure declarations."""
    structs = []
    lines = content.split('\n')
    for i, line in enumerate(lines):
        m = re.match(r'^structure\s+(\w+)', line)
        if m:
            name = m.group(1)
            # Collect fields
            fields = []
            j = i + 1
            while j < len(lines):
                fl = lines[j].strip()
                if fl.startswith('/--') or fl.startswith('--'):
                    j += 1
                    continue
                fm = re.match(r'(\w+)\s*:', fl)
                if fm:
                    fields.append(fm.group(1))
                if fl == '' or (fl and not fl.startswith('/') and not fl.startswith('-') and ':' not in fl and fl != 'where'):
                    break
                j += 1
            structs.append({
                'name': name,
                'line': i + 1,
                'fields': '; '.join(fields)
            })
    return structs


def parse_definitions(content: str) -> list:
    """Extract def/noncomputable def declarations."""
    defs = []
    lines = content.split('\n')
    for i, line in enumerate(lines):
        m = re.match(r'^(?:noncomputable\s+)?def\s+(\w+)', line)
        if m:
            name = m.group(1)
            sig = line[line.index(name)+len(name):].strip()
            if sig.startswith(':'):
                sig = sig[1:].strip()
            defs.append({
                'name': name,
                'line': i + 1,
                'type_sig': sig[:500]
            })
    return defs


# ---------------------------------------------------------------------------
# Axiom classification
# ---------------------------------------------------------------------------

# Axioms that declare types/functions (no mathematical claim)
TYPE_AXIOMS = {
    'NSField', 'NSField_nonempty', 'nsZero', 'nsAdd', 'nsSmul', 'nsGrad',
    'nsDiv', 'nsLaplace', 'nsConvection', 'nsDdt', 'nsVelocityMem',
    'nsPressureMem', 'nsDivFree', 'nsNu', 'kineticEnergy', 'enstrophy',
    'vorticityLinfty', 'nsEnergyRate', 'nsPressureEnergyContribution',
    'nsViscousEnergyContribution', 'nsIntegratedEnergyRate',
    'volumeEmbeddingConstant', 'bkmVorticityIntegral', 'entropicProperTime',
    'BKMIntegralConverges', 'fwRateFunctional', 'gradientNormSquared',
    'enstrophyDivergenceCorrection', 'integratedEnstrophy', 'hbar',
    'concentrationRatio', 'cameronWeight', 'entropicRatioIntegral',
    'palinstrophy', 'superPalinstrophy', 'stokesFirstEigenvalue',
    'integratedPalinstrophyRatioEntropic', 'integralRSquaredEntropic',
    'agmonEmbeddingConstant', 'TraceCameronSumConverges',
    'cameronWeightedPerturbationNorm', 'galerkinPerturbationNorm',
    'galerkinNormEquivConstant', 'enstrophyRate', 'vortexStretchingIntegral',
    'enstrophyDiffusionContribution', 'enstrophyTransportContribution',
    'ladyzhenskayaConstant', 'integratedNormalizedStretching',
    'integratedEnstrophyCube', 'integratedPalinstrophy',
    'integratedPalSqRatioEntropic', 'youngsInequalityAbsorptionConstant',
    'StretchingODEBoundHolds', 'ODEBoundContent', 'L1BoundContent',
    'VelocitySupBounded', 'IsBlowupRescalingOf', 'IsZeroVelocity',
    'CLMSHardyContent', 'CameronConcentrationContent', 'StrainDegeneracyContent',
    'MorseInvertibilityContent', 'FeffermanSteinContent', 'JohnNirenbergContent',
    'CameronComplementContent', 'GradientL65Content',
    'inverseJacobianNorm', 'stochasticActionFunctional',
    'helicity', 'helicityRateFunction',
    'sobolevEmbeddingConstant', 'poincareConstant', 'biotSavartNorm',
}

# Positivity/nonnegativity axioms
POS_AXIOMS = {
    'nsNu_pos', 'hbar_pos', 'kineticEnergy_nonneg', 'enstrophy_nonneg',
    'volumeEmbeddingConstant_pos', 'palinstrophy_nonneg',
    'superPalinstrophy_nonneg', 'stokesFirstEigenvalue_pos',
    'agmonEmbeddingConstant_pos', 'integralRSquaredEntropic_nonneg',
    'fwRateFunctional_nonneg', 'concentrationRatio_nonneg',
    'cameronWeightedPerturbationNorm_nonneg', 'galerkinPerturbationNorm_nonneg',
    'galerkinNormEquivConstant_pos', 'vortexStretchingIntegral_nonneg',
    'ladyzhenskayaConstant_pos', 'sobolevEmbeddingConstant_pos',
    'youngsInequalityAbsorptionConstant_pos', 'vorticity_bound_formula_pos',
    'inverseJacobianNorm_nonneg',
}

# Published results (specific papers)
PUBLISHED_AXIOMS = {
    'popkov_zeno_bound': 'Popkov-Barontini-Presilla, arXiv:1806.10422, 2018',
    'ml_stabilization_implies_precise_gap': 'Temam, Navier-Stokes Equations, North-Holland, 1984',
    'weyl_law_stokes_eigenvalues': 'Metivier, J. Math. Pures Appl. 56:325-346, 1977',
    'constantinFeffermanAlignment': 'Constantin-Fefferman, Indiana Univ. Math. J. 42:775-789, 1993',
    'ancient_solutions_are_kms': 'KMS structure (Connes-Rovelli framework)',
    'blowup_rescaling_produces_ancient': 'Seregin-Sverak rescaling theory',
    'clms_div_curl_hardy': 'Coifman-Lions-Meyer-Semmes, J. Math. Pures Appl. 72:247-286, 1993',
    'fefferman_stein_h1_bmo_duality': 'Fefferman-Stein, Acta Math. 129:137-193, 1972',
    'john_nirenberg_bmo_to_lp': 'John-Nirenberg, Commun. Pure Appl. Math. 14:415-426, 1961',
    's2_sector_implies_sphere_orlicz': 'Sphere Orlicz embedding (standard)',
    'angular_stretching_bounded_by_cf': 'Constantin-Fefferman 1993',
    'nsBKMBootstrap': 'Beale-Kato-Majda, Commun. Math. Phys. 94:61-66, 1984',
}

# Physical identification
PHYS_ID_AXIOMS = {
    'constantinIyer_identification': 'Constantin-Iyer, Commun. Pure Appl. Math. 61(3):330-345, 2008',
}

# Wolfram-verified
WOLFRAM_AXIOMS = {
    'unit_torus_ci_certificate': 'Wolfram 50-digit: S_inf(7.60) ≈ 0.00051 < 39.48 ≈ lambda_1',
}

# Open content (not on Route 6 path)
OPEN_AXIOMS = {
    'spatial_gradient_uniform_bkm', 'universal_spectral_to_precise_gap',
    'common_gap_uniform_bkm', 'cameron_trace_sum_below_spectral_gap',
}

# Superseded
SUPERSEDED_AXIOMS = {
    'sobolev_constant_potential_independent': 'SUPERSEDED: H1->Linfty false in 3D',
}

# Counterexamples
COUNTEREXAMPLE_AXIOMS = {
    'millennium_D_periodic_breakdown_counterexample',
    'millennium_B_whole_space_breakdown_counterexample',
}

# Route 6 critical path axioms
ROUTE6_CRITICAL = {
    'constantinIyer_identification', 'unit_torus_ci_certificate',
    'unit_torus_ci_certificate_domain', 'unit_torus_ci_certificate_rate',
    'unit_torus_data', 'unit_torus_sideLength', 'unit_torus_eigenvalue_matches',
    'weyl_law_stokes_eigenvalues', 'cameron_suppression_from_entropic_time',
    'trace_cameron_sum_converges', 'cameron_sum_implies_partial_bound',
    'popkov_zeno_bound', 'ml_stabilization_implies_precise_gap',
    'integral_upper_bound_formula',
}

ROUTE6_CRITICAL_THEOREMS = {
    'unit_torus_route6_closed', 'quantitative_route6_pipeline',
    'certificate_implies_gap', 'unit_torus_gap_closed',
    'trace_cameron_implies_gap_condition', 'cameron_gap_holds_at_all_levels',
    'popkov_implies_ml_stabilization', 'maxExponent_is_half',
}


def classify_axiom(name: str) -> tuple:
    """Return (classification, reference) for an axiom."""
    if name in TYPE_AXIOMS:
        return ('TYPE', '')
    if name in POS_AXIOMS:
        return ('POS', '')
    if name in PHYS_ID_AXIOMS:
        return ('PHYS-ID', PHYS_ID_AXIOMS[name])
    if name in WOLFRAM_AXIOMS:
        return ('WOLFRAM', WOLFRAM_AXIOMS[name])
    if name in PUBLISHED_AXIOMS:
        return ('PUBLISHED', PUBLISHED_AXIOMS[name])
    if name in SUPERSEDED_AXIOMS:
        return ('SUPERSEDED', SUPERSEDED_AXIOMS[name])
    if name in COUNTEREXAMPLE_AXIOMS:
        return ('COUNTEREXAMPLE', '')
    if name in OPEN_AXIOMS:
        return ('OPEN', '')
    # Default: standard PDE/math
    return ('STD-PDE', '')


# ---------------------------------------------------------------------------
# Wolfram equation cross-references
# ---------------------------------------------------------------------------

EQUATION_MAP = [
    ('eq_230', 'Laplace asymptotics O2b bridge', 'refinedO2b_implies_alignment', 'LaplaceO2bBridge.lean', 'verified'),
    ('eq_231', 'Information-geometric O2b reformulation', None, 'InformationGeometricO2b.lean', 'partial'),
    ('eq_232', 'Dual-sphere Fisher decomposition', 'three_sector_composition', 'DualSphereFisherDecomposition.lean', 'verified'),
    ('eq_233', 'Concentration ratio evolution', 'gronwall_route_to_precise_gap', 'ConcentrationRatioEvolution.lean', 'verified'),
    ('eq_234', 'Agmon interpolation bridge', 'spectral_route_to_precise_gap', 'AgmonInterpolationBridge.lean', 'verified'),
    ('eq_235', 'Enstrophy evolution balance', 'budget_route_to_precise_gap', 'EnstrophyEvolutionBalance.lean', 'verified'),
    ('eq_236', 'Galerkin descent tower', 'galerkin_ml_route_to_precise_gap', 'GalerkinDescentTower.lean', 'verified'),
    ('eq_237', 'Popkov Zeno bridge', 'six_routes_to_precise_gap', 'PopkovZenoBridge.lean', 'verified'),
    ('eq_238', 'Trace-Cameron competition', 'quantitative_route6_pipeline', 'TraceCameronCompetition.lean', 'verified'),
    ('eq_239', 'Domain parameter bridge (CI identification)', 'maxExponent_is_half', 'DomainParameterBridge.lean', 'verified'),
    ('eq_240', 'Numerical bound certificate', 'unit_torus_route6_closed', 'NumericalBoundCertificate.lean', 'verified'),
]

# Route 6 critical path (ordered)
ROUTE6_PATH = [
    (1, 'axiom', 'constantinIyer_identification', 'DomainParameterBridge.lean',
     'hbar = 2*nu (Constantin-Iyer 2008)', 'Constantin-Iyer, CPAM 61(3):330-345, 2008'),
    (2, 'theorem', 'maxExponent_is_half', 'DomainParameterBridge.lean',
     'hbar/(4*nu) = 1/2 under CI', 'PROVED from CI axiom'),
    (3, 'axiom', 'unit_torus_data', 'DomainParameterBridge.lean',
     'Domain data for T^3(L=1)', 'Standard'),
    (4, 'axiom', 'unit_torus_eigenvalue_matches', 'DomainParameterBridge.lean',
     'lambda_1 = 4*pi^2 for unit torus', 'Standard'),
    (5, 'axiom', 'weyl_law_stokes_eigenvalues', 'TraceCameronCompetition.lean',
     'Weyl law: eigenvalue density ~ k^{1/3} in 3D', 'Metivier 1977'),
    (6, 'axiom', 'cameron_suppression_from_entropic_time', 'TraceCameronCompetition.lean',
     'Cameron weight = exp(-c\'*k^{2/3})', 'Algebraic identity'),
    (7, 'axiom', 'trace_cameron_sum_converges', 'TraceCameronCompetition.lean',
     'Exponential beats polynomial (comparison test)', 'Standard analysis'),
    (8, 'axiom', 'unit_torus_ci_certificate', 'NumericalBoundCertificate.lean',
     'Wolfram-verified: S_inf ≈ 0.00051 < 39.48 ≈ lambda_1', 'eq_238 Wolfram script'),
    (9, 'theorem', 'unit_torus_gap_closed', 'NumericalBoundCertificate.lean',
     'Certificate closes the trace-Cameron gap', 'PROVED'),
    (10, 'theorem', 'trace_cameron_implies_gap_condition', 'TraceCameronCompetition.lean',
     'Sub-axioms -> cameron_weighted_gap_condition_uniform', 'PROVED'),
    (11, 'theorem', 'cameron_gap_holds_at_all_levels', 'PopkovZenoBridge.lean',
     'Cameron weighting -> subcritical perturbation at all N', 'PROVED'),
    (12, 'axiom', 'popkov_zeno_bound', 'PopkovZenoBridge.lean',
     'Zeno spectral gap preserved under perturbation', 'Popkov et al. 2018'),
    (13, 'axiom', 'ml_stabilization_implies_precise_gap', 'GalerkinDescentTower.lean',
     'Uniform Galerkin bounds -> BKM bound', 'Temam 1984'),
    (14, 'theorem', 'unit_torus_route6_closed', 'NumericalBoundCertificate.lean',
     'PreciseGapStatement for T^3(L=1) via Route 6', 'PROVED (= quantitative_route6_pipeline)'),
]

# Backward-compatible symbol aliases across Route 6 evolutions.
# If a legacy metadata name is missing, any listed replacement name is accepted.
ROUTE6_SYMBOL_ALIASES = {
    # Legacy external-certificate names now represented by native Lean bounds.
    'unit_torus_ci_certificate': ['lean_native_sum_bound'],
    'unit_torus_ci_certificate_domain': ['unit_torus_eigenvalue_matches'],
    'unit_torus_ci_certificate_rate': ['unit_torus_cameron_rate', 'cameron_suppression_from_entropic_time'],
    'integral_upper_bound_formula': ['lean_native_sum_bound', 'cameron_trace_sum_below_spectral_gap'],
}


def validate_route6_configuration(lean_dir: Path) -> list[str]:
    """Static integrity checks for Route 6 metadata tables."""
    errors = []

    step_orders = [step[0] for step in ROUTE6_PATH]
    expected_orders = list(range(1, len(ROUTE6_PATH) + 1))
    if sorted(step_orders) != expected_orders:
        errors.append(
            f"ROUTE6_PATH step_order mismatch: expected {expected_orders}, got {sorted(step_orders)}")

    path_axioms = {item_name for _, item_type, item_name, _, _, _ in ROUTE6_PATH if item_type == 'axiom'}
    path_theorems = {item_name for _, item_type, item_name, _, _, _ in ROUTE6_PATH if item_type == 'theorem'}

    missing_axiom_flags = sorted(path_axioms - ROUTE6_CRITICAL)
    if missing_axiom_flags:
        errors.append(
            "Route 6 path axioms missing from ROUTE6_CRITICAL: " + ", ".join(missing_axiom_flags))

    missing_theorem_flags = sorted(path_theorems - ROUTE6_CRITICAL_THEOREMS)
    if missing_theorem_flags:
        errors.append(
            "Route 6 path theorems missing from ROUTE6_CRITICAL_THEOREMS: " +
            ", ".join(missing_theorem_flags))

    src_dir = lean_dir / "NavierStokes"
    known_files = {p.name for p in src_dir.glob("*.lean")}
    missing_path_files = sorted({step[3] for step in ROUTE6_PATH} - known_files)
    if missing_path_files:
        errors.append("Route 6 path references missing Lean file(s): " + ", ".join(missing_path_files))

    eq_theorems = {lean_theorem for _, _, lean_theorem, _, _ in EQUATION_MAP if lean_theorem}
    required_equation_links = {
        'maxExponent_is_half',
        'quantitative_route6_pipeline',
        'unit_torus_route6_closed',
    }
    missing_equation_links = sorted(required_equation_links - eq_theorems)
    if missing_equation_links:
        errors.append(
            "EQUATION_MAP missing required Route 6 theorem link(s): " +
            ", ".join(missing_equation_links))

    return errors


def validate_route6_entries_present(conn: sqlite3.Connection) -> list[str]:
    """Database-level checks that critical Route 6 entries were actually parsed."""
    errors = []

    def _exists(name: str) -> bool:
        for table in ('axioms', 'theorems', 'definitions'):
            row = conn.execute(f"SELECT 1 FROM {table} WHERE name = ?", (name,)).fetchone()
            if row is not None:
                return True
        return False

    def _exists_with_alias(name: str) -> bool:
        if _exists(name):
            return True
        for alias in ROUTE6_SYMBOL_ALIASES.get(name, []):
            if _exists(alias):
                return True
        return False

    for name in sorted(ROUTE6_CRITICAL):
        if not _exists_with_alias(name):
            errors.append(f"Missing critical Route 6 axiom in catalog: {name}")

    for name in sorted(ROUTE6_CRITICAL_THEOREMS):
        if not _exists_with_alias(name):
            errors.append(f"Missing critical Route 6 theorem in catalog: {name}")

    return errors


# ---------------------------------------------------------------------------
# Database builder
# ---------------------------------------------------------------------------

def build_database(db_path: str, lean_dir: Path):
    """Build the SQLite catalog from Lean sources."""
    conn = sqlite3.connect(db_path)
    conn.executescript(SCHEMA)

    # --- Parse files ---
    root_file = lean_dir / "NavierStokes.lean"
    src_dir = lean_dir / "NavierStokes"

    file_ids = {}

    # Root file
    root_content = root_file.read_text()
    root_lines = len(root_content.split('\n'))
    conn.execute("INSERT INTO files (filename, filepath, line_count, description) VALUES (?,?,?,?)",
                 ("NavierStokes.lean", "lean4/NavierStokes.lean", root_lines, "Root import file"))
    file_ids["NavierStokes.lean"] = conn.execute("SELECT last_insert_rowid()").fetchone()[0]

    # Source files
    for lean_file in sorted(src_dir.glob("*.lean")):
        content = lean_file.read_text()
        fname = lean_file.name
        line_count = len(content.split('\n'))
        desc = parse_module_docstring(content)

        conn.execute("INSERT INTO files (filename, filepath, line_count, description) VALUES (?,?,?,?)",
                     (fname, f"lean4/NavierStokes/{fname}", line_count, desc))
        fid = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
        file_ids[fname] = fid

        # Parse imports
        for imp in parse_imports(content):
            if imp in file_ids:
                conn.execute("INSERT OR IGNORE INTO imports (importer_id, imported_id) VALUES (?,?)",
                             (fid, file_ids[imp]))

        # Parse axioms
        for ax in parse_axioms(content):
            cls, ref = classify_axiom(ax['name'])
            r6 = 1 if ax['name'] in ROUTE6_CRITICAL else 0
            conn.execute(
                "INSERT OR IGNORE INTO axioms (name, file_id, line_number, type_signature, classification, reference, description, route6_critical) VALUES (?,?,?,?,?,?,?,?)",
                (ax['name'], fid, ax['line'], ax['type_sig'], cls, ref, ax['description'], r6))

        # Parse theorems
        for th in parse_theorems(content):
            r6 = 1 if th['name'] in ROUTE6_CRITICAL_THEOREMS else 0
            conn.execute(
                "INSERT OR IGNORE INTO theorems (name, file_id, line_number, type_signature, proof_method, description, route6_critical) VALUES (?,?,?,?,?,?,?)",
                (th['name'], fid, th['line'], th['type_sig'], th['proof_method'], th['description'], r6))

        # Parse structures
        for st in parse_structures(content):
            conn.execute(
                "INSERT OR IGNORE INTO structures (name, file_id, line_number, fields, description) VALUES (?,?,?,?,?)",
                (st['name'], fid, st['line'], st['fields'], ''))

        # Parse definitions
        for df in parse_definitions(content):
            conn.execute(
                "INSERT INTO definitions (name, file_id, line_number, type_signature, description) VALUES (?,?,?,?,?)",
                (df['name'], fid, df['line'], df['type_sig'], ''))

    # Root file imports
    for imp in parse_imports(root_content):
        if imp in file_ids:
            conn.execute("INSERT OR IGNORE INTO imports (importer_id, imported_id) VALUES (?,?)",
                         (file_ids["NavierStokes.lean"], file_ids[imp]))

    # --- Equation cross-references ---
    for eq_id, title, lean_thm, lean_file, status in EQUATION_MAP:
        wl_file = f"{eq_id}_trace_cameron_competition.wl" if eq_id == "eq_238" else None
        conn.execute(
            "INSERT OR IGNORE INTO equations (equation_id, title, wolfram_file, lean_theorem, lean_file, status) VALUES (?,?,?,?,?,?)",
            (eq_id, title, wl_file, lean_thm, lean_file, status))

    # --- Route 6 critical path ---
    for step in ROUTE6_PATH:
        conn.execute(
            "INSERT OR REPLACE INTO route6_path (step_order, item_type, item_name, file, description, reference) VALUES (?,?,?,?,?,?)",
            step)

    conn.commit()
    return conn


# ---------------------------------------------------------------------------
# Sample queries
# ---------------------------------------------------------------------------

def run_sample_queries(conn):
    """Print sample queries demonstrating the catalog."""
    print("=" * 70)
    print("NAVIER-STOKES ROUTE 6 FORMALIZATION CATALOG")
    print("=" * 70)

    print("\n--- Axiom Classification Summary ---")
    for row in conn.execute("SELECT * FROM axiom_summary"):
        print(f"  {row[0]:20s}  {row[1]:4d} total  ({row[2]:2d} on Route 6)")

    print(f"\n--- Totals ---")
    ax_count = conn.execute("SELECT COUNT(*) FROM axioms").fetchone()[0]
    th_count = conn.execute("SELECT COUNT(*) FROM theorems").fetchone()[0]
    st_count = conn.execute("SELECT COUNT(*) FROM structures").fetchone()[0]
    fi_count = conn.execute("SELECT COUNT(*) FROM files").fetchone()[0]
    print(f"  Files:      {fi_count}")
    print(f"  Axioms:     {ax_count}")
    print(f"  Theorems:   {th_count}")
    print(f"  Structures: {st_count}")

    print("\n--- File Statistics (top 10 by content) ---")
    for row in conn.execute("SELECT * FROM file_stats LIMIT 10"):
        print(f"  {row[0]:45s}  ax={row[1]:3d}  th={row[2]:3d}  st={row[3]:2d}  def={row[4]:2d}")

    print("\n--- Route 6 Critical Path (14 steps) ---")
    for row in conn.execute("SELECT step_order, item_type, item_name, description FROM route6_path ORDER BY step_order"):
        marker = "AXIOM  " if row[1] == 'axiom' else "THEOREM"
        print(f"  [{row[0]:2d}] {marker}  {row[2]:45s}  {row[3]}")

    print("\n--- Route 6 Critical Axioms (what a reviewer must check) ---")
    for row in conn.execute("SELECT name, classification, reference FROM axioms WHERE route6_critical = 1 ORDER BY classification, name"):
        print(f"  [{row[1]:12s}]  {row[0]:45s}  {row[2]}")

    print("\n--- Equation Cross-References ---")
    for row in conn.execute("SELECT equation_id, title, lean_theorem, status FROM equations ORDER BY equation_id"):
        print(f"  {row[0]:8s}  {row[1]:50s}  {row[2] or '(none)':40s}  {row[3]}")

    print("\n--- Published Axioms (checkable references) ---")
    for row in conn.execute("SELECT name, reference FROM axioms WHERE classification = 'PUBLISHED' ORDER BY name"):
        print(f"  {row[0]:45s}  {row[1]}")

    print("\n--- Open Content (genuinely unresolved) ---")
    for row in conn.execute("SELECT name, a.description FROM axioms a WHERE classification = 'OPEN' ORDER BY name"):
        print(f"  {row[0]:45s}  {row[1][:60]}")

    print("\n--- Import Dependency Chain ---")
    for row in conn.execute("""
        SELECT f1.filename AS importer, f2.filename AS imported
        FROM imports i
        JOIN files f1 ON i.importer_id = f1.id
        JOIN files f2 ON i.imported_id = f2.id
        WHERE f1.filename != 'NavierStokes.lean'
        ORDER BY f1.filename, f2.filename
    """):
        print(f"  {row[0]:45s} -> {row[1]}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Build NavierStokes Route 6 catalog")
    parser.add_argument("--output", "-o", default="catalog.db", help="Output database path")
    parser.add_argument("--query", "-q", action="store_true", help="Run sample queries after building")
    parser.add_argument(
        "--strict-route6",
        action="store_true",
        help="Fail if Route 6 metadata integrity checks report issues",
    )
    args = parser.parse_args()

    lean_dir = find_lean_dir()
    print(f"Lean source directory: {lean_dir}")

    preflight_errors = validate_route6_configuration(lean_dir)
    if preflight_errors:
        print("\nRoute 6 metadata preflight:")
        for err in preflight_errors:
            print(f"  [warn] {err}")
        if args.strict_route6:
            print("\nAborting due to --strict-route6 preflight failure.")
            sys.exit(2)

    db_path = args.output
    if os.path.exists(db_path):
        os.remove(db_path)

    conn = build_database(db_path, lean_dir)
    print(f"Catalog built: {db_path}")

    ax_count = conn.execute("SELECT COUNT(*) FROM axioms").fetchone()[0]
    th_count = conn.execute("SELECT COUNT(*) FROM theorems").fetchone()[0]
    fi_count = conn.execute("SELECT COUNT(*) FROM files").fetchone()[0]
    print(f"  {fi_count} files, {ax_count} axioms, {th_count} theorems")

    db_errors = validate_route6_entries_present(conn)
    if db_errors:
        print("\nRoute 6 catalog integrity:")
        for err in db_errors:
            print(f"  [warn] {err}")
        if args.strict_route6:
            conn.close()
            print("\nAborting due to --strict-route6 catalog integrity failure.")
            sys.exit(2)

    if args.query:
        run_sample_queries(conn)

    conn.close()
    print(f"\nDone. Open with: sqlite3 {db_path}")


if __name__ == "__main__":
    main()
