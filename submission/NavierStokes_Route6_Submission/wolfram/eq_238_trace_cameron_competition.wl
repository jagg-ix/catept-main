(* ============================================================================
   Trace-Cameron Competition: Numerical Evaluation of the Irreducible Inequality

   Equation ID: 238
   Lean4 theorem: trace_cameron_implies_gap_condition (TraceCameronCompetition.lean)

   THE MILLENNIUM PROBLEM (Route 6) reduces to:

       S_inf = Sum_{k=1}^inf  k^{1/3} * exp(-c' * k^{2/3})  <  lambda_1

   where:
     lambda_1 = first Stokes eigenvalue on T^3 = (2*Pi/L)^2
     c' = (hbar/(4*nu)) * C_W  (Cameron suppression rate)
     C_W = (6*Pi^2 / L^3)^{2/3}  (Weyl constant for T^3)

   This script evaluates S_inf numerically and compares to lambda_1
   across a range of physical parameters.

   References:
   - Metivier, J. Math. Pures Appl. 56 (1977): Weyl law for Stokes eigenvalues
   - Popkov-Barontini-Presilla, arXiv:1806.10422: Zeno spectral gap theorem
   ============================================================================ *)

(* ---------- Section 1: Core Definitions ---------- *)

(* Weyl constant for Stokes operator on T^3 with side length L *)
weylConstant[L_] := (6 Pi^2 / L^3)^(2/3)

(* First Stokes eigenvalue on T^3 *)
stokesLambda1[L_] := (2 Pi / L)^2

(* Cameron suppression rate: c' = (hbar / (4 nu)) * C_W *)
cameronRate[hbar_, nu_, L_] := (hbar / (4 nu)) * weylConstant[L]

(* The trace-Cameron sum: S_inf = Sum_{k=1}^inf k^{1/3} exp(-c' k^{2/3}) *)
(* Numerical evaluation with truncation at kMax *)
traceCameronSum[cPrime_, kMax_: 10000] :=
  NSum[k^(1/3) * Exp[-cPrime * k^(2/3)], {k, 1, kMax},
    WorkingPrecision -> 50, Method -> "AlternatingSigns"]

(* Exact partial sum for verification *)
traceCameronPartialSum[cPrime_, N_] :=
  Sum[k^(1/3) * Exp[-cPrime * k^(2/3)], {k, 1, N}]

(* ---------- Section 2: Integral Approximation ---------- *)

(* The integral test gives:
   S_inf ~ Integral_1^inf x^{1/3} exp(-c' x^{2/3}) dx
   Substitution u = x^{2/3}: x = u^{3/2}, dx = (3/2) u^{1/2} du
   Integral = (3/2) Integral_{1}^inf u^{1/2} * u^{1/2} * exp(-c' u) du
            = (3/2) Integral_1^inf u * exp(-c' u) du
            = (3/2) * (1 + c') * exp(-c') / c'^2
*)
traceCameronIntegralApprox[cPrime_] :=
  (3/2) * (1 + cPrime) * Exp[-cPrime] / cPrime^2

(* More precise: include the full integral from 1 *)
traceCameronIntegralExact[cPrime_] :=
  NIntegrate[x^(1/3) * Exp[-cPrime * x^(2/3)], {x, 1, Infinity},
    WorkingPrecision -> 30]


(* ---------- Section 3: Parameter Survey ---------- *)

(* Physical parameter ranges:
   L = domain side length (meters), typically 1 for unit torus
   nu = kinematic viscosity (m^2/s), water ~ 1e-6, air ~ 1.5e-5
   hbar = entropic Planck constant (action units)

   The ratio hbar/nu controls everything:
   - Large hbar/nu => strong Cameron suppression => S_inf << lambda_1
   - Small hbar/nu => weak suppression => inequality may fail
*)

VerifyEquation[] := Module[
  {results, L, nu, hbar, cPrime, sInf, lam1, ratio, ok,
   paramSets, tableData, criticalRatio},

  (* === Test 1: Unit torus, varying hbar/nu ratio === *)
  L = 1;
  lam1 = stokesLambda1[L] // N;

  Print["============================================"];
  Print["Trace-Cameron Competition (eq_238)"];
  Print["============================================"];
  Print["Domain: T^3 with L = ", L];
  Print["lambda_1 = (2*Pi/L)^2 = ", lam1];
  Print["Weyl constant C_W = ", weylConstant[L] // N];
  Print[""];

  (* Scan hbar/nu ratio *)
  paramSets = {0.01, 0.05, 0.1, 0.5, 1, 2, 5, 10, 20, 50, 100};

  Print["hbar/nu ratio scan (L=1):"];
  Print[StringForm["  `1`  `2`  `3`  `4`  `5`",
    PaddedForm["hbar/nu", {8, 0}],
    PaddedForm["c'", {12, 0}],
    PaddedForm["S_inf", {15, 0}],
    PaddedForm["lambda_1", {12, 0}],
    PaddedForm["S_inf < lam1?", {12, 0}]]];
  Print["  ", StringJoin[Table["-", 75]]];

  tableData = Table[
    Module[{r = paramSets[[i]], cp, s, pass},
      cp = (r / 4) * weylConstant[L] // N;
      s = If[cp > 0.01,
        traceCameronSum[cp, 10000],
        traceCameronSum[cp, 100000]
      ];
      pass = s < lam1;
      Print[StringForm["  `1`  `2`  `3`  `4`  `5`",
        PaddedForm[r, {8, 2}],
        PaddedForm[cp, {12, 6}],
        PaddedForm[s, {15, 10}],
        PaddedForm[lam1, {12, 6}],
        If[pass, "  YES", "  NO"]]];
      {r, cp, s, lam1, pass}
    ],
    {i, Length[paramSets]}
  ];

  Print[""];

  (* === Test 2: Find critical hbar/nu ratio where S_inf = lambda_1 === *)
  Print["--- Critical ratio search ---"];

  (* Binary search for the critical ratio *)
  Module[{lo = 0.001, hi = 100, mid, cp, s, tol = 1*^-8},
    Do[
      mid = (lo + hi) / 2;
      cp = (mid / 4) * weylConstant[L] // N;
      s = traceCameronSum[cp, 50000];
      If[s < lam1, hi = mid, lo = mid],
      {50}
    ];
    criticalRatio = (lo + hi) / 2;
    Print["Critical hbar/nu ratio (S_inf = lambda_1): ", criticalRatio // N];
    Print["For hbar/nu > ", criticalRatio // N, ", the inequality S_inf < lambda_1 HOLDS."];
    Print[""];
  ];

  (* === Test 3: Convergence rate demonstration === *)
  Print["--- Convergence of partial sums (hbar/nu = 1, L = 1) ---"];
  Module[{cp, partials},
    cp = (1/4) * weylConstant[L] // N;
    Print["c' = ", cp];
    partials = Table[
      {n, traceCameronPartialSum[cp, n] // N},
      {n, {1, 5, 10, 50, 100, 500, 1000, 5000}}
    ];
    Print["  N        S_N"];
    Print["  ", StringJoin[Table["-", 35]]];
    Do[
      Print[StringForm["  `1`    `2`",
        PaddedForm[partials[[i, 1]], {6, 0}],
        PaddedForm[partials[[i, 2]], {18, 12}]]],
      {i, Length[partials]}
    ];
    Print["  lambda_1 = ", lam1];
    Print[""];
  ];

  (* === Test 4: Integral approximation vs exact sum === *)
  Print["--- Integral approximation accuracy ---"];
  Module[{cp, sExact, sIntegral, sApprox},
    Do[
      cp = (r / 4) * weylConstant[L] // N;
      If[cp > 0.01,
        sExact = traceCameronSum[cp, 10000];
        sIntegral = traceCameronIntegralExact[cp];
        sApprox = traceCameronIntegralApprox[cp] // N;
        Print[StringForm["  hbar/nu=`1`: sum=`2`, integral=`3`, closed-form=`4`",
          PaddedForm[r, {5, 1}],
          PaddedForm[sExact, {12, 8}],
          PaddedForm[sIntegral, {12, 8}],
          PaddedForm[sApprox, {12, 8}]]],
        (* skip very small c' *)
        Null
      ],
      {r, {0.1, 0.5, 1, 5, 10, 50}}
    ];
    Print[""];
  ];

  (* === Test 5: Domain size dependence === *)
  Print["--- Domain size dependence (hbar/nu = 1) ---"];
  Print["  L      lambda_1      c'            S_inf         S_inf/lambda_1"];
  Print["  ", StringJoin[Table["-", 75]]];
  Do[
    Module[{cp, s, l1},
      l1 = stokesLambda1[LL] // N;
      cp = (1/4) * weylConstant[LL] // N;
      s = traceCameronSum[cp, 10000];
      Print[StringForm["  `1`  `2`  `3`  `4`  `5`",
        PaddedForm[LL, {5, 2}],
        PaddedForm[l1, {12, 6}],
        PaddedForm[cp, {12, 6}],
        PaddedForm[s, {12, 8}],
        PaddedForm[s/l1, {12, 8}]]];
    ],
    {LL, {0.1, 0.5, 1, 2, 5, 10}}
  ];
  Print[""];

  (* === Test 6: Exponent dominance verification === *)
  Print["--- Exponent dominance: 2/3 > 1/3 ---"];
  Print["Trace growth exponent alpha = 1/3"];
  Print["Cameron suppression exponent beta = 2/3"];
  Print["beta > alpha: ", 2/3 > 1/3];
  Print["Ratio beta/alpha = ", (2/3)/(1/3), " (quadratic margin)"];
  Print[""];

  (* === Summary === *)
  ok = AllTrue[tableData[[5;;]], #[[5]] &]; (* All hbar/nu >= 1 should pass *)

  Print["============================================"];
  Print["SUMMARY"];
  Print["============================================"];
  Print["The trace-Cameron sum S_inf = Sum_k k^{1/3} exp(-c' k^{2/3})"];
  Print["converges for all c' > 0 (exponential beats polynomial)."];
  Print[""];
  Print["For T^3 with L=1:"];
  Print["  lambda_1 = ", lam1];
  Print["  Critical hbar/nu ~ ", criticalRatio // N];
  Print["  For hbar/nu > critical: S_inf < lambda_1 (inequality HOLDS)"];
  Print[""];
  Print["Physical interpretation:"];
  Print["  hbar/nu measures entropic time strength vs viscous dissipation."];
  Print["  When entropic time dominates (hbar/nu >> 1), Cameron suppression"];
  Print["  exponentially kills high-mode contributions, making S_inf << lambda_1."];
  Print[""];

  <|
    "equation_id" -> "238",
    "label" -> "eq:trace_cameron_competition",
    "ok" -> ok,
    "critical_ratio" -> criticalRatio // N,
    "notes" -> StringForm[
      "S_inf < lambda_1 holds for hbar/nu > `1` on T^3(L=1). " <>
      "Inequality is concrete and computable.",
      criticalRatio // N]
  |>
];

(* Run if not in notebook frontend *)
If[$FrontEnd === Null, Print[VerifyEquation[]]];


(* ============================================================================
   INTERACTIVE EXPLORATION (for Mathematica notebook use)
   Uncomment and run in a notebook for plots and interactive exploration.
   ============================================================================ *)

(*
(* Plot 1: S_inf vs c' *)
Plot[traceCameronIntegralApprox[cp], {cp, 0.01, 10},
  PlotLabel -> "Trace-Cameron Sum vs Suppression Rate",
  AxesLabel -> {"c' (Cameron rate)", "S_inf"},
  PlotRange -> {0, 50},
  Epilog -> {Red, Dashed, Line[{{0, 4 Pi^2}, {10, 4 Pi^2}}]},
  PlotLegends -> {"S_inf (integral approx)", "lambda_1 (L=1)"}]

(* Plot 2: Mode contributions *)
With[{cp = 1.0},
  ListLogPlot[
    Table[{k, k^(1/3) * Exp[-cp * k^(2/3)]}, {k, 1, 100}],
    PlotLabel -> StringForm["Mode contributions (c' = `1`)", cp],
    AxesLabel -> {"mode k", "k^{1/3} exp(-c' k^{2/3})"},
    Joined -> True, PlotMarkers -> Automatic]]

(* Plot 3: Ratio S_inf / lambda_1 vs hbar/nu *)
With[{L = 1},
  LogLogPlot[
    Module[{cp = (r/4) * weylConstant[L]},
      traceCameronIntegralApprox[cp] / stokesLambda1[L]],
    {r, 0.01, 100},
    PlotLabel -> "S_inf / lambda_1 vs hbar/nu",
    AxesLabel -> {"hbar/nu", "S_inf / lambda_1"},
    Epilog -> {Red, Dashed, Line[{{0.01, 1}, {100, 1}}]},
    PlotLegends -> {"S_inf/lambda_1", "Critical threshold"}]]

(* Plot 4: Partial sum convergence *)
With[{cp = 1.0},
  ListLogPlot[
    Table[{N, Abs[traceCameronPartialSum[cp, N] - traceCameronSum[cp, 10000]]},
      {N, 1, 200}],
    PlotLabel -> "Convergence of partial sums",
    AxesLabel -> {"N (truncation)", "|S_N - S_inf|"},
    Joined -> True]]
*)
