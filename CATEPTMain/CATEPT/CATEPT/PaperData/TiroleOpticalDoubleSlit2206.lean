/-!
# Tirole et al. 2022/2023 — Optical Temporal Double-Slit Source Data

## Paper

R. Tirole, S. Vezzoli, E. Galiffi, I. Robertson, D. Maurice, B. Tilmann,
S. A. Maier, J. B. Pendry, R. Sapienza:
**"Double-slit time diffraction at optical frequencies"**
*Nature Physics* **19**, 999 (2023). arXiv:2206.04362v2.

## Source

Values below are extracted verbatim from Fig 2e of
`Fig_2_Source_data.xlsx` (Nature Source Data archive shipped with the
paper, downloaded locally). Two rows from that sheet:
- row 1: "Slit separation (fs)"
- row 2: "Spectral oscillation period (THz)"

Only the experimental curve is reproduced here (model curves live in
rows 3–6 of the same sheet). The sheet contains 17 experimental points
spanning slit separations from −1110 fs to +1190 fs.

## Relevance to CAT/EPT

The spectral oscillation period Δν is inversely proportional to the
time-slit separation S:
  Δν · S ≈ const

This `Δν · S` product is what CAT/EPT's entropic-rate framework must
reproduce. The dataset below is the ground-truth for any CAT/EPT
prediction of `Δν(S)` in this experimental regime.
-/

namespace CATEPTMain.CATEPT.CATEPT.PaperData.TiroleOpticalDoubleSlit2206

/-- Experimental (slit_separation_fs, spectral_oscillation_period_THz)
    pairs from Fig 2e of Tirole et al., Nat. Phys. 19, 999 (2023). -/
def fig2e_experimental : List (Float × Float) :=
  [ (1190.0,  0.756001303450517)
  , (1090.0,  0.938484376697204)
  , (990.0,   1.00800173793403)
  , (890.0,   1.1731054708715)
  , (790.0,   1.2969332705746)
  , (690.0,   1.47724392628263)
  , (590.0,   1.69448568014772)
  , (490.0,   2.04207248633186)
  , (390.0,   2.58083)
  , (-410.0,  2.43745)
  , (-510.0,  1.98993)
  , (-610.0,  1.69449)
  , (-710.0,  1.39904)
  , (-810.0,  1.22524)
  , (-910.0,  1.08621)
  , (-1010.0, 0.977588)
  , (-1110.0, 0.92545) ]

/-- Number of experimental data points. -/
def fig2e_count : Nat := fig2e_experimental.length

/-- ITO-film experimental parameters (Methods section of the paper). -/
def probe_carrier_THz : Float := 230.2
/-- Pump-pulse wavelength: 1300 nm. Corresponding frequency 230.2 THz. -/
def pump_wavelength_nm : Float := 1300.0
/-- Pump-pulse duration (FWHM intensity), femtoseconds. -/
def pump_duration_fs : Float := 225.0
/-- Pump intensity at sample, GW/cm². -/
def pump_intensity_GW_cm2 : Float := 124.0
/-- Probe-pulse duration (temporally broadened), femtoseconds. -/
def probe_duration_fs : Float := 794.0
/-- Incidence angle near Berreman resonance, degrees. -/
def incidence_angle_deg : Float := 60.0
/-- ITO film thickness, nm. -/
def ito_thickness_nm : Float := 40.0
/-- Gold under-layer thickness, nm. -/
def au_thickness_nm : Float := 100.0

/-- Reflectivity modulation window observed. -/
def reflectivity_min : Float := 0.08
def reflectivity_max : Float := 0.60

/-- ITO rise-time window derived from spectral oscillation envelope, fs. -/
def ito_rise_time_min_fs : Float := 1.0
def ito_rise_time_max_fs : Float := 10.0

/-- Ideal-Heaviside rise time at pump optical cycle, ≈ 4.4 fs. -/
def optical_cycle_fs : Float := 4.4

end CATEPTMain.CATEPT.CATEPT.PaperData.TiroleOpticalDoubleSlit2206
