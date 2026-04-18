(* ::Package:: *)
(* ENZMaterial.m — Drude dispersion model for epsilon-near-zero materials *)
(*                                                                        *)
(* eps(omega) = eps_inf - omega_p^2 / (omega^2 + i gamma omega)           *)
(* v_g = c / n_g,  n_g = n + omega dn/domega                             *)
(* Enhancement = c / v_g                                                  *)
(*                                                                        *)
(* Maps to: eq_188 (ENZ enhancement), verified in Lean4 eq188             *)

(* Loaded within CATEPT` context by Init.m *)

Begin["CATEPT`Private`"];

(* ================================================================ *)
(* Material database                                                 *)
(* Each entry: <| "epsInf", "omegaP", "gamma", "plasmaWavelengthNm" |> *)
(* ================================================================ *)

$MaterialDB = <|
    "ITO" -> <|
        "epsInf" -> 3.5,
        "omegaP" -> 2.5*^15,       (* rad/s *)
        "gamma" -> 1.0*^14,        (* rad/s *)
        "plasmaWavelengthNm" -> 1240.0
    |>,
    "AZO" -> <|
        "epsInf" -> 3.3,
        "omegaP" -> 2.18*^15,
        "gamma" -> 1.1*^14,
        "plasmaWavelengthNm" -> 1350.0
    |>,
    "GZO" -> <|
        "epsInf" -> 3.4,
        "omegaP" -> 2.35*^15,
        "gamma" -> 0.9*^14,
        "plasmaWavelengthNm" -> 1280.0
    |>
|>;

$ENZMaterials = Keys[$MaterialDB];

(* ================================================================ *)
(* ENZMaterial constructor                                           *)
(* ================================================================ *)

ENZMaterial[name_String] /; KeyExistsQ[$MaterialDB, name] :=
    ENZMaterial[name, $MaterialDB[name]];

ENZMaterial[name_String, params_Association] /; KeyExistsQ[params, "epsInf"] :=
    ENZMaterial[name, params["epsInf"], params["omegaP"], params["gamma"]];

(* Format *)
Format[ENZMaterial[name_String, epsInf_, omegaP_, gamma_]] :=
    Interpretation[
        Row[{"ENZMaterial[", Style[name, Bold], ", \[Lambda]_p=",
             Round[2 Pi CATEPT`Private`$c / omegaP * 1*^9, 0.1], " nm]"}],
        ENZMaterial[name, epsInf, omegaP, gamma]
    ];

(* ================================================================ *)
(* Drude permittivity: eps(omega)                                    *)
(* ================================================================ *)

ENZMaterial /: EpsilonDrude[ENZMaterial[_, epsInf_, omegaP_, gamma_], omega_] :=
    epsInf - omegaP^2 / (omega^2 + I gamma omega);

ENZMaterial /: EpsilonDrude[mat_ENZMaterial, omega_List] :=
    EpsilonDrude[mat, #] & /@ omega;

(* ================================================================ *)
(* Refractive index: n(omega) = Sqrt[eps(omega)]                     *)
(* ================================================================ *)

ENZMaterial /: RefractiveIndex[mat_ENZMaterial, omega_] :=
    Sqrt[EpsilonDrude[mat, omega]];

(* ================================================================ *)
(* Group velocity: v_g = c / n_g, n_g = n + omega dn/domega         *)
(* ================================================================ *)

ENZMaterial /: GroupVelocity[mat_ENZMaterial, omega_?NumericQ] :=
    Module[{n, dndw, ng, c = CATEPT`Private`$c, eps, deps, nVal},
        eps = EpsilonDrude[mat, omega];
        nVal = Sqrt[eps];
        (* Analytic derivative of sqrt(eps) w.r.t. omega *)
        deps = D[EpsilonDrude[mat, \[Omega]Symbol], \[Omega]Symbol] /. \[Omega]Symbol -> omega;
        dndw = deps / (2 nVal);
        ng = Re[nVal + omega * dndw];
        If[Abs[ng] < 1*^-10, c, c / ng]
    ];

(* Numeric Drude derivative (avoids symbolic overhead) *)
ENZMaterial /: GroupVelocity[ENZMaterial[_, epsInf_, omegaP_, gamma_], omega_?NumericQ] :=
    Module[{eps, nVal, deps, dndw, ng, c = CATEPT`Private`$c},
        eps = epsInf - omegaP^2 / (omega^2 + I gamma omega);
        nVal = Sqrt[eps];
        (* d(eps)/d(omega) = 2 omegaP^2 omega / (omega^2 + i gamma omega)^2
                            + i gamma omegaP^2 / (omega^2 + i gamma omega)^2 *)
        deps = omegaP^2 (2 omega + I gamma) / (omega^2 + I gamma omega)^2;
        dndw = deps / (2 nVal);
        ng = Re[nVal + omega * dndw];
        If[Abs[ng] < 1*^-10, c, c / ng]
    ];

(* ================================================================ *)
(* ENZ frequency: omega where Re[eps] = 0                            *)
(* ================================================================ *)

ENZMaterial /: ENZFrequency[ENZMaterial[_, epsInf_, omegaP_, gamma_]] :=
    Module[{wENZ},
        (* Re[eps] = epsInf - omegaP^2 omega^2/(omega^4 + gamma^2 omega^2)
                   = epsInf - omegaP^2/(omega^2 + gamma^2) = 0
           => omega^2 = omegaP^2/epsInf - gamma^2 *)
        wENZ = Sqrt[Max[omegaP^2 / epsInf - gamma^2, 0.0]];
        wENZ
    ];

ENZMaterial /: ENZWavelength[mat_ENZMaterial] :=
    2 Pi CATEPT`Private`$c / ENZFrequency[mat];

(* ================================================================ *)
(* Enhancement factor: c / v_g(omega)                                *)
(* ================================================================ *)

ENZMaterial /: EnhancementFactor[mat_ENZMaterial, omega_?NumericQ] :=
    CATEPT`Private`$c / Abs[GroupVelocity[mat, omega]];

(* ================================================================ *)
(* ENZ decoherence rate: lambda_ENZ = lambda_thermal * (c/v_g)       *)
(* Eq 188: lambda_ENZ = (k_B T / hbar) * (c / v_g)                  *)
(* ================================================================ *)

ENZMaterial /: ENZDecoherenceRate[mat_ENZMaterial, omega_?NumericQ,
        temperature_?NumericQ] :=
    Module[{lambdaThermal, enhancement},
        lambdaThermal = CATEPT`Private`$kB * temperature / CATEPT`Private`$hbar;
        enhancement = EnhancementFactor[mat, omega];
        lambdaThermal * enhancement
    ];

ENZMaterial /: ENZDecoherenceRate[mat_ENZMaterial, omega_?NumericQ] :=
    ENZDecoherenceRate[mat, omega, 300.0];

(* ================================================================ *)
(* Wavelength scan: full dispersion profile                          *)
(* ================================================================ *)

ENZMaterial /: WavelengthScan[mat_ENZMaterial,
        wavelengthRange : {_?NumericQ, _?NumericQ},
        nPoints_Integer,
        temperature_?NumericQ] :=
    Module[{lambdas, omegas, c = CATEPT`Private`$c, eps, n, vg, enh, lamENZ},
        lambdas = Subdivide[wavelengthRange[[1]], wavelengthRange[[2]], nPoints - 1] * 1*^-9;
        omegas = 2 Pi c / lambdas;
        eps = EpsilonDrude[mat, #] & /@ omegas;
        n = Sqrt /@ eps;
        vg = GroupVelocity[mat, #] & /@ omegas;
        enh = c / Abs[#] & /@ vg;
        lamENZ = ENZDecoherenceRate[mat, #, temperature] & /@ omegas;
        <|
            "WavelengthNm" -> lambdas * 1*^9,
            "OmegaRadS" -> omegas,
            "Epsilon" -> eps,
            "RefractiveIndex" -> n,
            "GroupVelocity" -> vg,
            "Enhancement" -> enh,
            "DecoherenceRate" -> lamENZ
        |>
    ];

(* Default-argument overloads for WavelengthScan *)
ENZMaterial /: WavelengthScan[mat_ENZMaterial, wavelengthRange_, nPoints_Integer] :=
    WavelengthScan[mat, wavelengthRange, nPoints, 300.0];
ENZMaterial /: WavelengthScan[mat_ENZMaterial, wavelengthRange_] :=
    WavelengthScan[mat, wavelengthRange, 500, 300.0];
ENZMaterial /: WavelengthScan[mat_ENZMaterial] :=
    WavelengthScan[mat, {800.0, 2000.0}, 500, 300.0];

End[];
