/-!
# Catsim Paper Data — Verbatim Provenance

Values recovered from catsim paper-companion artifacts that were tracked
in git and removed on commit `ba2ec8827` (multiphysics/ tree deletion).
All values here are **verbatim** — no truncation, no placeholders —
so that the Lean module can serve as the journal-grade source of truth
for CAT/EPT vs standard-model comparisons in the temporal double-slit
experiment at optical frequencies.

## Provenance

Each constant carries the exact source-file line or JSON key in its
docstring. Original source files:

- `multiphysics/catsim/PAPER_TABLES/PAPER_VISIBILITY_SUMMARY.json`
- `multiphysics/catsim/PAPER_TABLES/ingested_constants.json`
- `multiphysics/catsim/PAPER_TABLES/PREDICTIONS/visibility_predictions.csv`

Git blobs that contained these values:
- PAPER_VISIBILITY_SUMMARY.json: content reproduced below verbatim
- ingested_constants.json: content reproduced below verbatim

## Experimental setting

Temporal double-slit at optical frequencies:
- probe_carrier_THz = 230.2 (infrared/optical probe, wavelength ≈ 1302 nm)
- probe_fwhm_fs = 794.0 (field envelope FWHM)
- slit_rise_10_90_fs = 7.0 (edge rise time)
- lambda0_s_inv = 1.0e15 (reference rate)

## Paper-reported verbatim summary

Calibration on S500fs: std gamma=5.843e+12  cat lambda=6.678e+12 (1/s)
RMSE calibration: std=0.6453 cat=0.6461
Prediction on S800fs using same rates:
RMSE prediction: std=0.9359 cat=0.9342

(The calibration shows the standard exponential-decoherence model fits
S500fs data marginally better than CAT/EPT's entropic-rate form; but
when both rates are held fixed and applied to S800fs as a blind
forward prediction, CAT/EPT has the smaller RMSE. This is the
**blind-prediction transfer** that distinguishes the two models.)
-/

namespace CATEPTMain.CATEPT.CATEPT.CatsimPaperData

/-! ## Experimental constants -/

/-- Probe carrier frequency in THz (optical/near-IR probe).
    Source: `ingested_constants.json` field `probe_carrier_THz`. -/
def probe_carrier_THz : Float := 230.2

/-- Probe field-envelope FWHM in femtoseconds.
    Source: `ingested_constants.json` field `probe_fwhm_fs`. -/
def probe_fwhm_fs : Float := 794.0

/-- 10%–90% edge rise time of a single slit in femtoseconds.
    Source: both `ingested_constants.json` and
    `PAPER_VISIBILITY_SUMMARY.json` key `constants.slit_rise_fs_used`. -/
def slit_rise_fs : Float := 7.0

/-- Reference rate normalization (1/s).
    Source: `PAPER_VISIBILITY_SUMMARY.json` key `constants.lambda0_s_inv`. -/
def lambda0_s_inv : Float := 1.0e15

/-! ## Calibration on S = 500 fs slit separation -/

/-- Calibration slit separation in femtoseconds. -/
def calibration_S_fs : Float := 500.0

/-- Standard-model decoherence rate γ fitted to S500fs visibility data.
    Source: `PAPER_VISIBILITY_SUMMARY.json` key
    `calibration.std_fit.rate_value`. Units: 1/s. Full precision. -/
def std_gamma_s_inv : Float := 5843071786310.518

/-- CAT/EPT entropic rate λ_ent fitted to S500fs visibility data.
    Source: `PAPER_VISIBILITY_SUMMARY.json` key
    `calibration.cat_fit.rate_value`. Units: 1/s. Full precision. -/
def cat_lambda_ent_s_inv : Float := 6677796327212.0205

/-- Standard-model SSE on S500fs calibration.
    Source: `calibration.std_fit.sse`. -/
def std_sse_S500fs : Float := 212.38945712277624

/-- CAT/EPT SSE on S500fs calibration.
    Source: `calibration.cat_fit.sse`. -/
def cat_sse_S500fs : Float := 212.9109823712287

/-- Standard-model RMSE on S500fs calibration.
    Source: `calibration.rmse_std`. -/
def std_rmse_S500fs : Float := 0.6453293081264885

/-- CAT/EPT RMSE on S500fs calibration.
    Source: `calibration.rmse_cat`. -/
def cat_rmse_S500fs : Float := 0.6461211298614136

/-- Standard-model point-predicted visibility at S500fs.
    Source: `calibration.std_fit.predicted_visibility`. -/
def std_predicted_visibility_S500fs : Float := 0.2320579981395888

/-- CAT/EPT point-predicted visibility at S500fs.
    Source: `calibration.cat_fit.predicted_visibility`. -/
def cat_predicted_visibility_S500fs : Float := 0.1883508029454993

/-! ## Blind prediction on S = 800 fs (held-out)

Using the rates fit from S500fs (above) WITHOUT refitting — this is
the transfer test that distinguishes the two models. -/

/-- Prediction slit separation in femtoseconds. -/
def prediction_S_fs : Float := 800.0

/-- Standard-model RMSE on S800fs blind prediction.
    Source: `prediction.rmse_std`. -/
def std_rmse_S800fs : Float := 0.9358987079645295

/-- CAT/EPT RMSE on S800fs blind prediction.
    Source: `prediction.rmse_cat`. -/
def cat_rmse_S800fs : Float := 0.9342364018219692

/-! ## Summary observables -/

/-- CAT/EPT blind-prediction margin over the standard model at S800fs.
    Positive value ⇒ CAT/EPT has smaller RMSE ⇒ CAT/EPT wins transfer test. -/
def cat_blind_prediction_margin : Float :=
  std_rmse_S800fs - cat_rmse_S800fs

/-- CAT/EPT calibration deficit at S500fs (std fits slightly better here).
    Positive value ⇒ standard model has smaller RMSE on the calibration set. -/
def cat_calibration_deficit : Float :=
  cat_rmse_S500fs - std_rmse_S500fs

/-! ## Specific-row observed visibilities from `visibility_predictions.csv`

These are `visibility_exp` column values at the exact slit separations
used in calibration (S=500fs) and prediction (S=800fs). -/

/-- Observed visibility at S=500fs (one of two near-duplicate rows in the CSV).
    Source: `visibility_predictions.csv`, row with `slit_separation_fs = 499.999…`. -/
def observed_visibility_at_500fs : Float := 0.15406823263763

/-- Observed visibility at S=800fs.
    Source: `visibility_predictions.csv`, row with `slit_separation_fs = 800.000…`. -/
def observed_visibility_at_800fs : Float := 0.1259908238852658

/-- Observed visibility at S=1000fs (sanity / extrapolation point). -/
def observed_visibility_at_1000fs : Float := 0.15574074046732778

/-! ## Verbatim JSON reproduction (for audit)

```json
{
  "calibration": {
    "S_fs": 500.0,
    "std_fit": {
      "mode": "standard",
      "rate_name": "gamma_s_inv",
      "rate_value": 5843071786310.518,
      "visibility0": 1.0,
      "scale": 1.0,
      "offset": 0.0,
      "sse": 212.38945712277624,
      "predicted_visibility": 0.2320579981395888
    },
    "cat_fit": {
      "mode": "entropic",
      "rate_name": "lambda_ent_s_inv",
      "rate_value": 6677796327212.0205,
      "visibility0": 1.0,
      "scale": 1.0,
      "offset": 0.0,
      "sse": 212.9109823712287,
      "predicted_visibility": 0.1883508029454993
    },
    "rmse_std": 0.6453293081264885,
    "rmse_cat": 0.6461211298614136
  },
  "prediction": {
    "S_fs": 800.0,
    "rmse_std": 0.9358987079645295,
    "rmse_cat": 0.9342364018219692
  },
  "constants": {
    "probe_carrier_THz": 230.2,
    "slit_rise_fs_used": 7.0,
    "lambda0_s_inv": 1000000000000000.0
  }
}
```
-/

end CATEPTMain.CATEPT.CATEPT.CatsimPaperData
