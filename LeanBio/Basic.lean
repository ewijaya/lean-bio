-- 1. Define a custom data type for DNA bases
inductive Base where
  | A | T | C | G
  deriving Repr

open Base

-- 2. Write a normal function to find the complementary base
def complement (b : Base) : Base :=
  match b with
  | A => T
  | T => A
  | C => G
  | G => C

-- Test it interactively (hover or click this line to see output in Infoview)
#eval complement A   -- Output: Base.T

-- 3. PROVE a theorem: taking the complement twice returns the original base!
theorem complement_twice (b : Base) : complement (complement b) = b := by
  cases b <;> rfl

-- 4. Scale up to a full DNA strand (a list of bases)
def complementStrand (strand : List Base) : List Base :=
  match strand with
  | [] => []
  | b :: rest => complement b :: complementStrand rest

-- Test it on a short sequence
#eval complementStrand [A, T, G, C]  -- Output: [Base.T, Base.A, Base.C, Base.G]

-- 5. PROVE that for ANY DNA strand of ANY length, complementing twice gives it back!
theorem compStrand_twice (strand : List Base) :
    complementStrand (complementStrand strand) = strand := by
  induction strand with
  | nil => rfl
  | cons b rest ih =>
    simp [complementStrand, complement_twice, ih]

-- 6. Example of `sorry` (an unproven placeholder)
-- Lean still compiles the file, emits a warning, and marks the theorem with `sorryAx`.
theorem complementStrand_length (strand : List Base) :
    (complementStrand strand).length = strand.length := by
  sorry

-- Compare axioms: a real proof vs. a `sorry` proof
#print axioms compStrand_twice
#print axioms complementStrand_length
