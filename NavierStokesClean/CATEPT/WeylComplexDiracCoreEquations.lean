namespace NavierStokesClean.CATEPT.WeylComplexDiracCoreEquations

/-- Source document for extracted core equations. -/
def sourceDocument : String := "/Users/macbookpro/Downloads/weyl-complex-dirac.md"

/-- Extracted A1..A7 core equations in TeX form (deduplicated by extractor). -/
def coreEquationsTex : List String := [
  "\\[
S[\\Phi] = S_R[\\Phi] + i\\,S_I[\\Phi],\\qquad S_I[\\Phi]\\ge 0
\\]",
  "\\[
\\tau_{\\mathrm{ent}}[\\Phi] := \\frac{S_I[\\Phi]}{\\hbar}
\\]",
  "\\[
\\mathcal{W}[\\Phi] := \\exp\\!\\left(\\frac{i}{\\hbar}S_R[\\Phi]-\\frac{1}{\\hbar}S_I[\\Phi]\\right)
= \\exp\\!\\left(\\frac{i}{\\hbar}S_R[\\Phi]\\right)\\exp\\!\\big(-\\tau_{\\mathrm{ent}}[\\Phi]\\big)
\\]",
  "\\[
Z := \\int \\mathcal{D}\\Phi\\;\\exp\\!\\left(\\frac{i}{\\hbar}S_R[\\Phi]-\\frac{1}{\\hbar}S_I[\\Phi]\\right)
\\]",
  "\\[
S_R[g] = \\frac{c^3}{16\\pi G}\\int d^4x\\sqrt{-g}\\,(R-2\\Lambda)
\\]",
  "\\[
S_I[g,\\Phi] := \\hbar \\int d^4x\\sqrt{-g}\\;\\ell_I(x),\\qquad 
\\ell_I(x):=\\frac{1}{2}\\lambda(x)\\,W(x),\\quad \\lambda(x)\\ge 0
\\]",
  "\\[
S_I[g] := \\hbar \\int d^4x\\sqrt{-g}\\;\\lambda(x)\\,\\mathcal{G}
\\]",
  "\\[
\\mathcal{G}=R^2-4R_{\\mu\\nu}R^{\\mu\\nu}+R_{\\mu\\nu\\rho\\sigma}R^{\\mu\\nu\\rho\\sigma}
\\]",
  "\\[
\\delta\\big(S_R + i S_I\\big)=0
\\quad\\Longrightarrow\\quad
\\frac{\\delta S_R}{\\delta g^{\\mu\\nu}} + i\\frac{\\delta S_I}{\\delta g^{\\mu\\nu}} = 0
\\]",
  "\\[
T^{(I)}_{\\mu\\nu} := \\frac{2}{\\sqrt{-g}}\\frac{\\delta S_I}{\\delta g^{\\mu\\nu}}
\\]",
  "\\[
G_{\\mu\\nu}+\\Lambda g_{\\mu\\nu} + i\\,\\frac{8\\pi G}{c^4}\\,T^{(I)}_{\\mu\\nu}=0
\\]",
  "\\[
\\lambda\\approx 0\\;\\Rightarrow\\; S_I\\approx \\text{const}\\;\\Rightarrow\\;T^{(I)}_{\\mu\\nu}\\approx 0
\\;\\Rightarrow\\;
G_{\\mu\\nu}+\\Lambda g_{\\mu\\nu}=0
\\]",
  "\\[
C(\\tau)=\\partial_{\\dot q}L\\cdot\\dot q - L = E + i\\Gamma
\\]",
  "\\[
\\frac{dC}{d\\tau_{\\mathrm{ent}}}=0
\\]",
  "\\[
\\Delta\\tau_{\\mathrm{ent},i}=\\frac{\\kappa}{\\hbar}D_\\alpha(\\rho_{i+1}\\Vert \\rho_i),
\\qquad
\\tau_{\\mathrm{ent}}=\\sum_i\\Delta\\tau_{\\mathrm{ent},i}
\\]",
]

/-- Count of extracted core equations. -/
def coreEquationCount : Nat := coreEquationsTex.length

/-- Sanity lemma: extraction produced at least one core equation. -/
theorem coreEquationCount_pos : 0 < coreEquationCount := by
  decide

end NavierStokesClean.CATEPT.WeylComplexDiracCoreEquations
