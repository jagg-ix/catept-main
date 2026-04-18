# APS Physical Review Style Guide: Figure Requirements & Improvements for CAT/EPT Paper

## Executive Summary

Based on the official APS Physical Review Style and Notation Guide, this document provides specific improvements needed for all CAT/EPT paper figures to achieve full APS compliance.

---

## 📋 **APS Figure Requirements Checklist**

### **CRITICAL REQUIREMENTS**

✅ **Resolution Standards:**
- **Raster images (photos, scans):** Minimum 300 PPI (pixels per inch)
- **Vector graphics (plots, diagrams):** Submit as native format (PDF, .ai, Excel, PowerPoint)
- **Preferred resolution for scans:** 600 DPI or higher

✅ **File Formats:**
- **Raster:** .jpg, .tif, .psd, .eps (NOT .doc or .ppt embedded images - these degrade to 72 PPI)
- **Vector:** .pdf, .ai, .eps, .xls, .ppt (native format preferred)

✅ **Font Requirements:**
- **Primary font:** Helvetica Neue 57 Condensed (or Helvetica/Arial if unavailable)
- **Variable symbols:** Helvetica italic (not bold unless highlighting)
- **Greek letters:** Regular (not italic) for coefficients
- **Minimum text size:** 9-point font for axis labels
- **Minimum capital letter/numeral height:** 2 mm when sized for journal page

✅ **Caption Format:**
```latex
\begin{figure}[t]  % Use [t] or [b], NOT [h]
  \includegraphics[width=\columnwidth]{filename.pdf}
  \caption{FIG. X. Concise description. For color online version, use (Color online) at start.}
  \label{fig:label}
\end{figure}
```

**Caption Rules:**
- Must begin with "FIG." (all capitals) + number + period
- Concise, self-contained explanation
- For color-online-only: Start with "(Color online)"
- End caption with period
- Describe line styles explicitly: "Solid line: ..., Dashed line: ..."

✅ **Color Usage:**
- **Free:** Color online only (grayscale in print)
- **Requirement:** Figures must be clear in BOTH color and grayscale
- **Best practice:** Use different line styles (solid, dashed, dotted) + colors
- **Accessible palettes:** Use colors with distinct grayscale values
- **Description:** Caption must describe curves without relying on color

✅ **Axis Labels:**
- Integer numbers preferred: 0, 5, 10 (not 1.58, 3.16, 4.75)
- Decimal points ON the line (not above)
- Consistent decimal places across axis
- Include leading zero: 0.2 (not .2)
- Use Greek symbols directly: θ (not spelled out "theta")
- Units in half-spacing: R (10³ Ω), not R×10³ Ω
- Avoid ambiguous solidus: (mb/MeV sr), not (mb/MeV/sr)

---

## 🔍 **CURRENT CAT/EPT FIGURES - COMPLIANCE ASSESSMENT**

### **Figure Quality Check**

| Figure | Type | Resolution | APS Compliant? | Issues |
|--------|------|------------|----------------|--------|
| fig1_trajectories_response.pdf | Vector | ∞ | ✅ YES | None |
| fig2_tauent_vs_tau.pdf | Vector | ∞ | ✅ YES | None |
| fig3_effective_temperature_profile.pdf | Vector | ∞ | ✅ YES | None |
| penrose_minkowski.pdf | Vector | ∞ | ✅ YES | None |
| penrose_schwarzschild.pdf | Vector | ∞ | ✅ YES | None |
| comp_isomorphism.pdf | Vector | ∞ | ✅ YES | None |
| polarization_visibility.pdf | Vector | ∞ | ✅ YES | None |
| poincare_shrink.pdf | Vector | ∞ | ✅ YES | None |
| polarization_fit.pdf | Vector | ∞ | ✅ YES | None |
| framework_summary_comprehensive.pdf | Vector | ∞ | ✅ YES | None |
| **PNG versions** | Raster | 200 DPI | ⚠️ MARGINAL | **Upgrade to 300 DPI minimum** |
| wdw_relational_time_cartoon.png | Raster | 220 DPI | ⚠️ MARGINAL | **Should be 300+ DPI** |
| history_weight_influence.png | Raster | 220 DPI | ⚠️ MARGINAL | **Should be 300+ DPI** |
| gkls_emergence_flow.png | Raster | 220 DPI | ⚠️ MARGINAL | **Should be 300+ DPI** |
| adm_slicing_cartoon.png | Raster | 220 DPI | ⚠️ MARGINAL | **Should be 300+ DPI** |

---

## 🛠️ **REQUIRED IMPROVEMENTS**

### **Priority 1: Resolution Upgrades (CRITICAL)**

**Issue:** PNG figures at 200-220 DPI below APS minimum of 300 DPI

**Fix:** Regenerate all schematic/cartoon figures at 300+ DPI

```python
# Update all figure generation scripts
fig.savefig(outdir / "figure.png", dpi=300, bbox_inches='tight')  # Was: dpi=200
```

**Affected files:**
- wdw_relational_time_cartoon.png
- history_weight_influence.png
- gkls_emergence_flow.png
- adm_slicing_cartoon.png
- All other PNG outputs

**Action:** Run regeneration script with DPI=300

---

### **Priority 2: Font Standardization**

**Issue:** Figures may not use APS-preferred fonts

**Fix:** Standardize to Helvetica/Arial

```python
import matplotlib.pyplot as plt

# Set APS-compliant fonts globally
plt.rcParams['font.family'] = 'sans-serif'
plt.rcParams['font.sans-serif'] = ['Helvetica', 'Arial']
plt.rcParams['font.size'] = 9  # Minimum for axis labels
plt.rcParams['axes.labelsize'] = 10
plt.rcParams['xtick.labelsize'] = 9
plt.rcParams['ytick.labelsize'] = 9
plt.rcParams['legend.fontsize'] = 9
plt.rcParams['figure.titlesize'] = 11
```

---

### **Priority 3: Caption Improvements**

**Current format (example):**
```latex
\caption{\textbf{Observer-dependent entropic time accumulation.} Different entropic rates...}
```

**APS-compliant format:**
```latex
\caption{Observer-dependent entropic time accumulation. Different entropic rates $\lambda(\tau)$ yield qualitatively distinct time evolution. \textbf{Blue (Hovering):} Constant $\lambda$ produces linear growth $\tau_{\mathrm{ent}} = \lambda \tau$, characteristic of stationary observers... \textbf{Orange (Free-fall):} Transient $\lambda(\tau)$ with exponential decay...}
\label{fig:tau_accumulation}
```

**Requirements:**
- ✅ Remove bold from opening phrase
- ✅ Describe line styles explicitly in caption
- ✅ End with period
- ✅ Use proper LaTeX formatting for math

---

### **Priority 4: Color-Grayscale Compatibility**

**Issue:** Some figures rely on color alone to distinguish curves

**APS Requirement:** Figures must be clear in grayscale

**Fix:** Add line styles

```python
# BEFORE (color only):
ax.plot(x, y1, color='blue', linewidth=2, label='Hovering')
ax.plot(x, y2, color='orange', linewidth=2, label='Free-fall')

# AFTER (color + line style):
ax.plot(x, y1, color='blue', linestyle='-', linewidth=2, label='Hovering')
ax.plot(x, y2, color='orange', linestyle='--', linewidth=2, label='Free-fall')
```

**Then in caption:**
```latex
\caption{... Solid line: hovering observer. Dashed line: free-fall observer.}
```

---

### **Priority 5: Axis Label Formatting**

**Check all figures for:**

❌ **Bad:**
- Decimal fractions on axes: 1.58, 3.16, 4.75
- Missing leading zero: .2, .5
- Spelled-out Greek: "theta", "lambda"
- Inconsistent decimal places: 1.2, 3.45, 5.678

✅ **Good:**
- Integer ticks: 0, 5, 10, 15, 20
- Leading zeros: 0.2, 0.5, 0.8
- Greek symbols: θ, λ, τ
- Consistent decimals: 1.0, 3.0, 5.0

**Fix in plotting code:**
```python
# Force integer ticks
ax.set_xticks([0, 5, 10, 15, 20])

# Or use MaxNLocator for automatic integers
from matplotlib.ticker import MaxNLocator
ax.xaxis.set_major_locator(MaxNLocator(integer=True))

# Greek symbols in labels
ax.set_xlabel(r'$\tau$ (proper time)', fontsize=10)
ax.set_ylabel(r'$\tau_{\mathrm{ent}}$ (entropic time)', fontsize=10)
```

---

## 📐 **FIGURE SIZE REQUIREMENTS**

### **Column Widths:**
- **Single column:** 3.375 inches (8.6 cm)
- **Double column:** 7 inches (17.8 cm)

### **Recommended figure settings:**
```python
# For single-column figures
fig, ax = plt.subplots(figsize=(3.375, 2.5))  # APS single column

# For double-column figures
fig, ax = plt.subplots(figsize=(7, 3))  # APS double column

# Text must be readable at these sizes - minimum 2mm height
```

### **Caption for LaTeX:**
```latex
% Single column
\includegraphics[width=\columnwidth]{figure.pdf}

% Double column (spanning both columns)
\begin{figure*}
  \includegraphics[width=\textwidth]{figure.pdf}
  \caption{...}
\end{figure*}
```

---

## 🎨 **COLOR PALETTE RECOMMENDATIONS**

**APS-approved accessible color schemes:**

### **For Curves/Lines:**
```python
# Colorblind-friendly palette with distinct grayscale
colors = {
    'blue': '#0173B2',      # Grayscale: Dark
    'orange': '#DE8F05',    # Grayscale: Medium
    'green': '#029E73',     # Grayscale: Medium-dark
    'red': '#CC78BC',       # Grayscale: Light
    'purple': '#CA9161',    # Grayscale: Medium-light
    'brown': '#ECE133'      # Grayscale: Very light
}
```

### **For Heatmaps:**
```python
import matplotlib.pyplot as plt

# Use perceptually uniform colormaps
plt.imshow(data, cmap='viridis')  # Good grayscale conversion
# Or: 'plasma', 'inferno', 'magma' (all colorblind-safe)

# Avoid: 'jet', 'rainbow' (poor grayscale, not accessible)
```

---

## 📄 **SPECIFIC IMPROVEMENTS FOR EACH FIGURE**

### **Figure 1: fig2_tauent_vs_tau.pdf**

**Current status:** ✅ Vector, good quality

**Improvements needed:**
1. Add line style differentiation:
   - Hovering: solid line (`-`)
   - Free-fall: dashed line (`--`)

2. Update caption:
```latex
\caption{Observer-dependent entropic time accumulation for different observer trajectories. Solid line (blue): Hovering observer with constant $\lambda$ shows linear growth $\tau_{\mathrm{ent}} = \lambda \tau$. Dashed line (orange): Free-fall observer with transient $\lambda(\tau)$ exhibits bounded saturation. This demonstrates that entropic time is not merely a reparametrization of proper time $\tau$ but an independent thermodynamic observable measuring accumulated departure from quantum equilibrium.}
```

3. Font check: Ensure axis labels use Helvetica, 9pt minimum

---

### **Figure 2: wdw_relational_time_cartoon.png**

**Current status:** ⚠️ PNG at 220 DPI (below 300 minimum)

**Improvements needed:**
1. **CRITICAL:** Regenerate at 300 DPI:
```python
fig.savefig('wdw_relational_time_cartoon.png', dpi=300, bbox_inches='tight')
```

2. Font size check: Ensure text readable at 2mm minimum height

3. Update caption:
```latex
\caption{Resolution of the Problem of Time via relational evolution. \textbf{Left:} Traditional Wheeler-DeWitt approach with Hamiltonian constraint $H_\perp \Psi = 0$ yields timeless quantum gravity. \textbf{Right:} CAT/EPT resolution: density matrix $\rho(\tau_{\mathrm{ent}})$ evolves in entropic proper time according to Lindblad generator $\mathcal{L}$. Arrow indicates constructive resolution; constraint $H_\perp\Psi = 0$ remains intact.}
```

---

### **Figure 3: framework_summary_comprehensive.pdf**

**Current status:** ✅ Vector, comprehensive

**Improvements needed:**
1. Font standardization (already Helvetica)

2. Consider splitting into two figures for journal format:
   - **Fig. 3a:** Levels 1-2 (Theory + Operations)
   - **Fig. 3b:** Levels 3-4 (Applications + Validation)

3. Alternative: Use as double-column figure:
```latex
\begin{figure*}[t]
  \includegraphics[width=\textwidth]{framework_summary_comprehensive.pdf}
  \caption{Complete CAT/EPT framework architecture organized in four hierarchical levels...}
  \label{fig:framework}
\end{figure*}
```

---

### **Figure 4-14: Schwarzschild, Penrose, Polarization**

**Current status:** ✅ All vector PDFs, good quality

**Minor improvements:**
1. Verify axis labels use integers where possible
2. Add line style descriptions to captions
3. Check font sizes when scaled to column width

---

## 🔧 **IMPLEMENTATION SCRIPT**

### **Step 1: Update Figure Generation Script**

```python
#!/usr/bin/env python3
"""
Update all CAT/EPT figures to APS compliance
"""
import matplotlib.pyplot as plt
import matplotlib as mpl
from pathlib import Path

# APS-compliant matplotlib settings
def set_aps_style():
    """Configure matplotlib for APS Physical Review style"""
    
    # Font settings
    mpl.rcParams['font.family'] = 'sans-serif'
    mpl.rcParams['font.sans-serif'] = ['Helvetica', 'Arial', 'DejaVu Sans']
    mpl.rcParams['font.size'] = 9
    mpl.rcParams['axes.labelsize'] = 10
    mpl.rcParams['axes.titlesize'] = 11
    mpl.rcParams['xtick.labelsize'] = 9
    mpl.rcParams['ytick.labelsize'] = 9
    mpl.rcParams['legend.fontsize'] = 9
    mpl.rcParams['figure.titlesize'] = 11
    
    # Line settings
    mpl.rcParams['lines.linewidth'] = 1.5
    mpl.rcParams['lines.markersize'] = 6
    
    # Figure size (APS column widths)
    mpl.rcParams['figure.figsize'] = (3.375, 2.5)  # Single column
    
    # DPI settings
    mpl.rcParams['figure.dpi'] = 100  # Display
    mpl.rcParams['savefig.dpi'] = 300  # APS minimum for raster
    
    # Use tight layout
    mpl.rcParams['figure.autolayout'] = True
    
    # Axes
    mpl.rcParams['axes.linewidth'] = 0.8
    mpl.rcParams['axes.grid'] = False
    
    # Ticks
    mpl.rcParams['xtick.major.width'] = 0.8
    mpl.rcParams['ytick.major.width'] = 0.8
    mpl.rcParams['xtick.minor.width'] = 0.6
    mpl.rcParams['ytick.minor.width'] = 0.6
    
    # Legend
    mpl.rcParams['legend.frameon'] = False
    mpl.rcParams['legend.numpoints'] = 1
    
    # Save settings
    mpl.rcParams['savefig.bbox'] = 'tight'
    mpl.rcParams['savefig.pad_inches'] = 0.05

def save_aps_figure(fig, basename, outdir):
    """Save figure in APS-compliant formats"""
    outdir = Path(outdir)
    outdir.mkdir(parents=True, exist_ok=True)
    
    # Save as PDF (vector)
    fig.savefig(outdir / f"{basename}.pdf", 
                dpi=300, bbox_inches='tight', 
                format='pdf')
    
    # Save as PNG (raster, 300 DPI minimum)
    fig.savefig(outdir / f"{basename}.png", 
                dpi=300, bbox_inches='tight',
                format='png')
    
    print(f"✓ Saved {basename} (PDF + PNG at 300 DPI)")

# Example usage
if __name__ == "__main__":
    set_aps_style()
    
    # Generate figure
    fig, ax = plt.subplots()
    
    # Use line styles + colors
    ax.plot([0, 1, 2], [0, 1, 4], 'b-', linewidth=2, label='Hovering')
    ax.plot([0, 1, 2], [0, 0.8, 1.2], 'r--', linewidth=2, label='Free-fall')
    
    # Integer ticks
    ax.set_xticks([0, 1, 2])
    ax.set_yticks([0, 1, 2, 3, 4])
    
    # Greek symbols
    ax.set_xlabel(r'$\tau$ (proper time)')
    ax.set_ylabel(r'$\tau_{\mathrm{ent}}$ (entropic time)')
    
    ax.legend()
    
    # Save
    save_aps_figure(fig, 'test_figure', './figures')
```

---

### **Step 2: Regenerate All Figures**

```bash
cd cat-ept-paper

# Update all scripts with APS style settings
python3 scripts/update_figures_aps_compliant.py

# Regenerate all figures at 300 DPI
make all-figs-aps

# Verify output
ls -lh figures/*.pdf figures/*.png
```

---

### **Step 3: Update LaTeX Captions**

**File:** `/home/claude/cat-ept-paper/latex/main.tex`

**Find and replace:** Remove bold from caption openings

```latex
% BEFORE
\caption{\textbf{Observer-dependent entropic time...} Description here.}

% AFTER
\caption{Observer-dependent entropic time accumulation. Description here with line styles: Solid line (blue): ..., Dashed line (orange): ...}
```

**Add explicit line style descriptions:**
- "Solid line: ..."
- "Dashed line: ..."
- "Dotted line: ..."
- "Dot-dashed line: ..."

---

## ✅ **FINAL COMPLIANCE CHECKLIST**

Before submission, verify:

### **Technical Requirements**
- [ ] All raster images ≥300 DPI
- [ ] Vector graphics in native format (PDF preferred)
- [ ] Fonts: Helvetica/Arial, 9pt minimum
- [ ] Minimum text height: 2mm when sized
- [ ] Integer axis ticks where possible
- [ ] Leading zeros on decimals (0.2 not .2)
- [ ] Greek symbols (not spelled out)

### **Caption Requirements**
- [ ] Begins with "FIG. X." (all caps)
- [ ] Concise, self-contained
- [ ] Line styles described explicitly
- [ ] Ends with period
- [ ] "(Color online)" if color-only online

### **Color Requirements**
- [ ] Figures clear in grayscale
- [ ] Different line styles used
- [ ] Accessible color palette
- [ ] Caption describes without color

### **Size Requirements**
- [ ] Fits in column width (3.375" or 7")
- [ ] Text readable at journal size
- [ ] No pixelation when scaled

### **LaTeX Requirements**
- [ ] Float placement: [t] or [b], not [h]
- [ ] \columnwidth or \textwidth for sizing
- [ ] Proper \label{fig:X} references
- [ ] All figures referenced in text

---

## 📊 **SUMMARY OF IMPROVEMENTS**

### **Immediate Actions (Before Submission)**

1. ✅ **Regenerate PNG figures at 300 DPI** (was 200-220 DPI)
   - wdw_relational_time_cartoon.png
   - history_weight_influence.png
   - gkls_emergence_flow.png
   - adm_slicing_cartoon.png

2. ✅ **Add line styles to all multi-curve plots**
   - fig2_tauent_vs_tau: solid vs dashed
   - fig1_trajectories: different line styles per trajectory
   - fig3_temperature: solid line with markers

3. ✅ **Update all captions:**
   - Remove bold from opening
   - Add line style descriptions
   - Ensure periods at end

4. ✅ **Verify font sizes:**
   - All axis labels ≥9pt
   - All text ≥2mm when scaled

5. ✅ **Check axis formatting:**
   - Integer ticks where possible
   - Leading zeros on decimals
   - Greek symbols used directly

### **Quality Improvements (Recommended)**

6. ✅ **Standardize fonts globally** to Helvetica/Arial
7. ✅ **Use accessible color palettes** (viridis, plasma)
8. ✅ **Test grayscale conversion** for all color figures
9. ✅ **Optimize figure sizes** for single/double column
10. ✅ **Add framework summary** as double-column figure

---

## 📚 **REFERENCES**

1. **APS Physical Review Style and Notation Guide**  
   https://journals.aps.org/files/styleguide-pr.pdf

2. **APS Style Basics**  
   https://journals.aps.org/authors/style-basics

3. **APS Figure Format Guidelines**  
   https://journals.aps.org/authors/figure-format

4. **APS Color Online Guidelines**  
   https://journals.aps.org/files/color-online-guide.pdf

---

**Version:** APS Compliance Guide v1.0  
**Date:** 2026-02-07  
**Status:** Ready for Implementation  
**Priority:** HIGH (before PRL/PRD submission)
