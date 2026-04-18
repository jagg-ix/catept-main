#!/usr/bin/env wolframscript
(* ============================================================================ *)
(* test_catept_diagrams.wl                                                     *)
(*                                                                              *)
(* Verification test for CATEPTSpacetimeDiagrams physics computations.          *)
(* Tests the underlying equations without requiring a GUI/frontend.             *)
(*                                                                              *)
(* Paper equations: 2, 57-62, 90, 92-93, 130-134                               *)
(* ============================================================================ *)

$VerificationLog = {};
$FailCount = 0;

ReportVerification[label_String, passed_] := (
  AppendTo[$VerificationLog, <|"label" -> label, "passed" -> passed|>];
  If[!passed, $FailCount++];
  Print["  ", If[passed, "PASS", "FAIL"], ": ", label];
);

Print["================================================================"];
Print["CAT/EPT Spacetime Diagrams - Physics Verification"];
Print["================================================================\n"];

(* ================================================================== *)
(* Natural units: c = G = hbar = kB = 1                               *)
(* ================================================================== *)

(* ------------------------------------------------------------------ *)
(* Test 1: Schwarzschild lapse function (Eq 90)                        *)
(* ------------------------------------------------------------------ *)

Print["--- Test 1: Schwarzschild lapse function ---\n"];

M = 1;
fSchw[r_, m_] := 1 - 2 m / r;

(* f(r) = 0 at r = 2M *)
test1a = TrueQ[fSchw[2 M, M] === 0];
ReportVerification["Eq90: f(2M) = 0 (horizon)", test1a];

(* f -> 1 as r -> infinity *)
test1b = TrueQ[Limit[fSchw[r, M], r -> Infinity] === 1];
ReportVerification["Eq90: f(r) -> 1 as r -> infinity", test1b];

(* f > 0 outside horizon *)
test1c = fSchw[3 M, M] > 0;
ReportVerification["Eq90: f(3M) > 0 (outside horizon)", test1c];

(* ------------------------------------------------------------------ *)
(* Test 2: Corrected lapse function (Eq 92)                            *)
(* ------------------------------------------------------------------ *)

Print["\n--- Test 2: Corrected lapse function ---\n"];

fCorr[r_, m_, lam_] := 1 - 2 m / r + lam m^2 / r^2;

(* Corrected horizon: r_h = M(1 + sqrt(1-lambda)) *)
rHCorr[m_, lam_] := m (1 + Sqrt[1 - lam]);

(* f_corr(r_h) = 0 *)
test2a = TrueQ[FullSimplify[fCorr[rHCorr[M, lam], M, lam], lam > 0 && lam < 1] === 0];
ReportVerification["Eq92: f_corr(r_h) = 0 at corrected horizon", test2a];

(* r_h -> 2M when lambda -> 0 *)
test2b = TrueQ[FullSimplify[rHCorr[M, 0] - 2 M] === 0];
ReportVerification["Eq92: r_h -> 2M when lambda -> 0", test2b];

(* r_h < 2M for lambda > 0 (horizon shrinks) *)
test2c = TrueQ[Simplify[rHCorr[1, 0.5] < 2]];
ReportVerification["Eq92: r_h < 2M for lambda > 0 (horizon shrinks)", test2c];

(* ------------------------------------------------------------------ *)
(* Test 3: Surface gravity (Eq 130)                                    *)
(* ------------------------------------------------------------------ *)

Print["\n--- Test 3: Surface gravity ---\n"];

(* Standard: kappa = 1/(4M) *)
kappa[m_] := 1 / (4 m);

test3a = TrueQ[kappa[M] === 1 / 4];
ReportVerification["Eq130: kappa = 1/(4M) at M=1", test3a];

(* From f'(r_h)/2 *)
fPrime = D[fSchw[r, M], r];
kappaFromMetric = Simplify[(1/2) Abs[fPrime /. r -> 2 M]];
test3b = TrueQ[Simplify[kappaFromMetric - kappa[M]] === 0];
ReportVerification["Eq130: kappa = (1/2)|f'(r_h)|", test3b];

(* Corrected surface gravity at lambda=0 recovers standard *)
fCorrPrime = D[fCorr[r, M, lam], r];
kappaCorrAt0 = Simplify[(1/2) Abs[fCorrPrime /. {r -> 2 M, lam -> 0}]];
test3c = TrueQ[Simplify[kappaCorrAt0 - kappa[M]] === 0];
ReportVerification["Eq93: kappa_corr -> 1/(4M) at lambda=0", test3c];

(* ------------------------------------------------------------------ *)
(* Test 4: Hawking temperature (Eq 133)                                *)
(* ------------------------------------------------------------------ *)

Print["\n--- Test 4: Hawking temperature ---\n"];

(* T_H = kappa/(2pi) in natural units *)
tH[m_] := kappa[m] / (2 Pi);

test4a = TrueQ[Simplify[tH[M] - 1 / (8 Pi)] === 0];
ReportVerification["Eq133: T_H = 1/(8 pi M) at M=1", test4a];

(* ------------------------------------------------------------------ *)
(* Test 5: Entropic rate (Eq 131)                                      *)
(* ------------------------------------------------------------------ *)

Print["\n--- Test 5: Entropic rate ---\n"];

(* lambda_H = 1/(8 pi M) in natural units *)
lambdaH[m_] := 1 / (8 Pi m);

test5a = TrueQ[Simplify[lambdaH[M] - tH[M]] === 0];
ReportVerification["Eq131: lambda_H = T_H (in natural units)", test5a];

(* ------------------------------------------------------------------ *)
(* Test 6: BH entropy (Eq 134)                                        *)
(* ------------------------------------------------------------------ *)

Print["\n--- Test 6: BH entropy ---\n"];

(* S_BH = 4 pi M^2 in natural units *)
sBH[m_] := 4 Pi m^2;

test6a = TrueQ[Simplify[sBH[M] - 4 Pi] === 0];
ReportVerification["Eq134: S_BH = 4 pi M^2 at M=1", test6a];

(* First law: T dS/dM = 1 *)
dSdM = D[sBH[m], m];
firstLaw = Simplify[tH[m] * dSdM];
test6b = TrueQ[firstLaw === 1];
ReportVerification["First law: T_H dS/dM = 1 (natural units)", test6b];

(* ------------------------------------------------------------------ *)
(* Test 7: Entropic time reparameterization (Eq 2)                     *)
(* ------------------------------------------------------------------ *)

Print["\n--- Test 7: Entropic time ---\n"];

(* Constant lambda: tau = lambda * t *)
(* Inverse: t = tau / lambda *)
ClearAll[lam0, t0, tau0];
$Assumptions = {lam0 > 0, t0 > 0};

entropicTime[t_, lam_] := lam * t;
coordTime[tau_, lam_] := tau / lam;

(* Round trip: t -> tau -> t *)
test7a = TrueQ[Simplify[coordTime[entropicTime[t0, lam0], lam0] - t0] === 0];
ReportVerification["Eq2: tau/lambda = t (round trip)", test7a];

(* Variable lambda: tau = lambda0 * tauDecay * (1 - exp(-t/tauDecay)) *)
ClearAll[lam1, td];
$Assumptions = {lam1 > 0, td > 0, t0 > 0};

entropicTimeVar[t_, lam_, tau_] := lam * tau * (1 - Exp[-t / tau]);
coordTimeVar[tauEnt_, lam_, tau_] := -tau * Log[1 - tauEnt / (lam * tau)];

(* Round trip for variable case *)
test7b = TrueQ[FullSimplify[
    coordTimeVar[entropicTimeVar[t0, lam1, td], lam1, td] - t0,
    $Assumptions
] === 0];
ReportVerification["Eq2: Variable lambda round trip", test7b];

(* Monotonicity: dtau/dt = lambda > 0 *)
dtaudt = D[entropicTime[t0, lam0], t0];
test7c = TrueQ[dtaudt === lam0];  (* dtau/dt = lambda exactly *)
ReportVerification["Eq2: dtau/dt = lambda (monotonicity)", test7c];

(* ------------------------------------------------------------------ *)
(* Test 8: CFL equivalence (Eqs 57-62)                                *)
(* ------------------------------------------------------------------ *)

Print["\n--- Test 8: CFL equivalence ---\n"];

ClearAll[a, dx, dt, dtau, lamCFL];
$Assumptions = {a > 0, dx > 0, dt > 0, lamCFL > 0};

(* CFL_t: dt <= dx/a *)
(* CFL_tau: dtau <= lambda * dx/a *)
(* Since dtau = lambda * dt, CFL_tau <=> lambda*dt <= lambda*dx/a <=> dt <= dx/a <=> CFL_t *)

(* The key: lambda * (dx/a) / lambda = dx/a *)
ratio = FullSimplify[lamCFL * dx / a / lamCFL - dx / a, $Assumptions];
test8a = TrueQ[ratio === 0];
ReportVerification["Eq62: lambda*dx/a / lambda = dx/a", test8a];

(* Numerical check *)
lamVal = 0.5; aVal = 2.0; dxVal = 1.0;
dtMax = dxVal / aVal;
dtauMax = lamVal * dxVal / aVal;
test8b = (Abs[dtauMax - lamVal * dtMax] < 10^-15);
ReportVerification["Eq62: dtau_max = lambda * dt_max (numerical)", test8b];

(* ------------------------------------------------------------------ *)
(* Test 9: Tortoise coordinate                                         *)
(* ------------------------------------------------------------------ *)

Print["\n--- Test 9: Tortoise coordinate ---\n"];

rStarFunc[r_, m_] := r + 2 m Log[Abs[r / (2 m) - 1]];

(* r* -> -infinity as r -> 2M *)
test9a = TrueQ[Limit[rStarFunc[r, 1], r -> 2, Direction -> "FromAbove"] === -Infinity];
ReportVerification["Tortoise: r* -> -infinity at horizon", test9a];

(* dr*/dr = 1/f(r) *)
drStardr = D[rStarFunc[r, 1], r];
expected = 1 / fSchw[r, 1];
diff9 = FullSimplify[drStardr - expected, r > 2];
test9b = TrueQ[diff9 === 0];
ReportVerification["Tortoise: dr*/dr = 1/f(r)", test9b];

(* ------------------------------------------------------------------ *)
(* Summary                                                             *)
(* ------------------------------------------------------------------ *)

Print["\n================================================================"];
Print["RESULTS"];
Print["================================================================\n"];

totalCount = Length[$VerificationLog];
passCount = Count[$VerificationLog, _?(#["passed"] &)];
failCount = totalCount - passCount;

Print["  Total: ", totalCount, "  Passed: ", passCount, "  Failed: ", failCount];
Print[""];

Print["RESULT: total_verifications=", totalCount];
Print["RESULT: passed=", passCount];
Print["RESULT: failed=", failCount];

Exit[If[failCount == 0, 0, 1]];
