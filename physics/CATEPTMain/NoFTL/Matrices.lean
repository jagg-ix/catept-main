import CATEPTMain.NoFTL.Vectors

/-!
# Matrices — 4×4 Spacetime Matrices

Defines 4×4 matrices, their application to points, column/row extraction,
transpose, and matrix multiplication.

Isabelle: `class Matrices = Vectors`.
-/

set_option autoImplicit false

namespace NoFTL.Matrices

open NoFTL.Points NoFTL.Vectors

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q]

/-- A 4×4 matrix, stored as four row vectors. -/
structure Matrix (Q : Type*) where
  trow : Point Q
  xrow : Point Q
  yrow : Point Q
  zrow : Point Q

/-- Apply a matrix to a point (matrix-vector product). -/
def applyMatrix (m : Matrix Q) (p : Point Q) : Point Q :=
  ⟨dot (m.trow) p, dot (m.xrow) p, dot (m.yrow) p, dot (m.zrow) p⟩

/-- Extract the t-column of a matrix. -/
def tcol (m : Matrix Q) : Point Q :=
  ⟨m.trow.tval, m.xrow.tval, m.yrow.tval, m.zrow.tval⟩

/-- Extract the x-column of a matrix. -/
def xcol (m : Matrix Q) : Point Q :=
  ⟨m.trow.xval, m.xrow.xval, m.yrow.xval, m.zrow.xval⟩

/-- Extract the y-column of a matrix. -/
def ycol (m : Matrix Q) : Point Q :=
  ⟨m.trow.yval, m.xrow.yval, m.yrow.yval, m.zrow.yval⟩

/-- Extract the z-column of a matrix. -/
def zcol (m : Matrix Q) : Point Q :=
  ⟨m.trow.zval, m.xrow.zval, m.yrow.zval, m.zrow.zval⟩

/-- Matrix transpose. -/
def transpose (m : Matrix Q) : Matrix Q :=
  ⟨tcol m, xcol m, ycol m, zcol m⟩

/-- Matrix multiplication. -/
def mprod (m₁ m₂ : Matrix Q) : Matrix Q :=
  transpose ⟨applyMatrix m₁ (tcol m₂), applyMatrix m₁ (xcol m₂),
             applyMatrix m₁ (ycol m₂), applyMatrix m₁ (zcol m₂)⟩

end NoFTL.Matrices
