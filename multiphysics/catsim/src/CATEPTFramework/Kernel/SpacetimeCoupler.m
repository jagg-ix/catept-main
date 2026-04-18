(* ::Package:: *)
(* SpacetimeCoupler.m — General-relativistic coupling to entropic rate *)
(*                                                                      *)
(* lambda_eff(t) = lambda_base(t) * a(t) * (1 + g * r(t))              *)
(*   a(t) = redshift factor = sqrt(1 - r_s/r) for Schwarzschild        *)
(*   r(t) = EFE residual norm (back-reaction)                           *)
(*   g    = EFE gain parameter                                          *)
(*                                                                      *)
(* Maps to: eq_131 (Schwarzschild), eq_113 (complex EFE)               *)

(* Loaded within CATEPT` context by Init.m *)

Begin["CATEPT`Private`"];

(* ================================================================ *)
(* Schwarzschild radius                                              *)
(* ================================================================ *)

SchwarzschildRadius[mass_?NumericQ] :=
    2 CATEPT`Private`$G * mass / CATEPT`Private`$c^2;

(* ================================================================ *)
(* Hawking temperature: T_H = hbar c^3 / (8 pi G M k_B)             *)
(* Eq 12 / eq_135: verified in Lean4 eq012, eq135                   *)
(* ================================================================ *)

HawkingTemperature[mass_?NumericQ] :=
    CATEPT`Private`$hbar * CATEPT`Private`$c^3 /
    (8 Pi CATEPT`Private`$G * mass * CATEPT`Private`$kB);

(* Symbolic *)
HawkingTemperature[mass_Symbol] :=
    HoldForm[
        \[HBar] * c^3 / (8 Pi G * mass * Subscript[k, B])
    ];

(* ================================================================ *)
(* Unruh temperature: T_U = hbar a / (2 pi c k_B)                   *)
(* Eq 49: verified in Lean4 eq049                                    *)
(* ================================================================ *)

UnruhTemperature[acceleration_?NumericQ] :=
    CATEPT`Private`$hbar * acceleration /
    (2 Pi CATEPT`Private`$c * CATEPT`Private`$kB);

(* ================================================================ *)
(* Schwarzschild redshift factor                                     *)
(* a(r) = sqrt(1 - r_s / r)                                         *)
(* ================================================================ *)

schwarzschildRedshift[mass_?NumericQ, radius_?NumericQ] :=
    Module[{rs},
        rs = SchwarzschildRadius[mass];
        If[radius <= rs, 0.0, Sqrt[1 - rs / radius]]
    ];

(* ================================================================ *)
(* ISCO radius: r_isco = 6 G M / c^2 = 3 r_s                       *)
(* ================================================================ *)

ISCORadius[mass_?NumericQ] := 3 SchwarzschildRadius[mass];

(* ================================================================ *)
(* Hawking entropy rate: dS_BH/dt                                    *)
(* ================================================================ *)

HawkingEntropyRate[mass_?NumericQ] :=
    Module[{tH},
        tH = HawkingTemperature[mass];
        (* Luminosity L = sigma_SB * A * T^4, but simplified to
           dS/dt = L/T = sigma * 4 pi r_s^2 * T^3 *)
        (* Use Stefan-Boltzmann: sigma = pi^2 k_B^4 / (60 hbar^3 c^2) *)
        Module[{sigma, rS, area},
            sigma = Pi^2 CATEPT`Private`$kB^4 /
                    (60 CATEPT`Private`$hbar^3 * CATEPT`Private`$c^2);
            rS = SchwarzschildRadius[mass];
            area = 4 Pi rS^2;
            sigma * area * tH^3
        ]
    ];

(* ================================================================ *)
(* SpacetimeCoupler constructors                                     *)
(* ================================================================ *)

(* Identity coupler: no gravitational modification *)
SpacetimeCoupler["Identity"] :=
    SpacetimeCoupler[<|
        "Type" -> "Identity",
        "RedshiftFn" -> Function[{t}, 1.0],
        "EFEResidualFn" -> Function[{t}, 0.0],
        "EFEGain" -> 0.0
    |>];

(* Schwarzschild coupler: static redshift at fixed radius *)
SpacetimeCoupler["Schwarzschild", opts___Rule] :=
    Module[{rules, mass, radius, efeGain, aR},
        rules = Association[opts];
        mass = Lookup[rules, "Mass", CATEPT`Private`$SolarMass];
        radius = Lookup[rules, "Radius", 1*^10]; (* 10^10 m default *)
        efeGain = Lookup[rules, "EFEGain", 0.0];

        aR = schwarzschildRedshift[mass, radius];

        SpacetimeCoupler[<|
            "Type" -> "Schwarzschild",
            "Mass" -> mass,
            "Radius" -> radius,
            "RedshiftFactor" -> aR,
            "RedshiftFn" -> Function[{t}, aR],
            "EFEResidualFn" -> Function[{t}, 0.0],
            "EFEGain" -> efeGain
        |>]
    ];

(* Custom coupler from explicit functions *)
SpacetimeCoupler["Custom", redshiftFn_Function, efeResidualFn_Function,
        efeGain_?NumericQ] :=
    SpacetimeCoupler[<|
        "Type" -> "Custom",
        "RedshiftFn" -> redshiftFn,
        "EFEResidualFn" -> efeResidualFn,
        "EFEGain" -> efeGain
    |>];

SpacetimeCoupler["Custom", redshiftFn_Function, efeResidualFn_Function] :=
    SpacetimeCoupler["Custom", redshiftFn, efeResidualFn, 0.0];

(* ================================================================ *)
(* Coupler evaluation                                                *)
(* lambda_eff(t) = lambda_base(t) * a(t) * (1 + g * r(t))          *)
(* ================================================================ *)

SpacetimeCouplerFactor[SpacetimeCoupler[assoc_Association], t_?NumericQ] :=
    Module[{a, r, g},
        a = assoc["RedshiftFn"][t];
        r = assoc["EFEResidualFn"][t];
        g = assoc["EFEGain"];
        a * (1 + g * r)
    ];

(* ================================================================ *)
(* Property access                                                   *)
(* ================================================================ *)

SpacetimeCoupler /: SpacetimeCoupler[assoc_Association][prop_String] :=
    Lookup[assoc, prop, Missing["Property", prop]];

SpacetimeCoupler /: SpacetimeCoupler[assoc_Association]["Factor", t_?NumericQ] :=
    SpacetimeCouplerFactor[SpacetimeCoupler[assoc], t];

(* ================================================================ *)
(* Format                                                            *)
(* ================================================================ *)

Format[SpacetimeCoupler[assoc_Association]] :=
    Interpretation[
        Row[{"SpacetimeCoupler[", Style[assoc["Type"], Bold],
             If[KeyExistsQ[assoc, "Mass"],
                Row[{", M=", ScientificForm[assoc["Mass"] / CATEPT`Private`$SolarMass, 3],
                     " M\[CircleDot]"}],
                ""
             ],
             "]"}],
        SpacetimeCoupler[assoc]
    ];

End[];
