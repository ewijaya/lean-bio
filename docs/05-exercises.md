# 5. Exercises

The best way to learn Lean is to write proofs. These exercises build directly on `LeanBio/Basic.lean` and go from easy to harder.

## How to do them

Create a scratch file, e.g. `LeanBio/Exercises.lean`:

```lean
import LeanBio.Basic
open Base

-- your work here
```

Open it in VS Code and watch the Infoview. To include it in `lake build`, add `import LeanBio.Exercises` to `LeanBio.lean`.

Start every proof with `sorry`, check that the **statement** has no errors, then replace `sorry` with a real proof.

> ✅ All solutions below have been checked against Lean `v4.36.0` with this project.
> Try each exercise yourself first. Solutions are in collapsible blocks.

---

## Exercise 1: A base is never its own complement ⭐

Prove that complementing a base always changes it.

```lean
theorem complement_ne (b : Base) : complement b ≠ b := by
  sorry
```

(`≠` is typed `\ne` in VS Code. `x ≠ y` means `¬ (x = y)`, i.e. "`x = y` is false".)

**Hint:** Same shape as `complement_twice`: split into cases. But `rfl` proves equalities, not inequalities. Try `simp [complement]` instead. Lean knows that different constructors (like `T` and `A`) are never equal.

<details>
<summary>Solution</summary>

```lean
theorem complement_ne (b : Base) : complement b ≠ b := by
  cases b <;> simp [complement]
```

</details>

💡 Combined with `complement_twice`, this pins `complement` down more tightly. It rules out the "identity function" that would trivially satisfy `complement_twice` (see "What is not proven" in the README).

---

## Exercise 2: Complementing preserves length ⭐⭐

A complementary strand should have the same number of bases.

```lean
theorem length_complementStrand (s : List Base) :
    (complementStrand s).length = s.length := by
  sorry
```

**Hint:** Induction, just like `compStrand_twice`. In the `cons` case, `simp [complementStrand, ih]`.

<details>
<summary>Solution</summary>

```lean
theorem length_complementStrand (s : List Base) :
    (complementStrand s).length = s.length := by
  induction s with
  | nil => rfl
  | cons b rest ih => simp [complementStrand, ih]
```

</details>

---

## Exercise 3: Reverse complement ⭐⭐⭐

In real biology, the opposite strand of DNA is read in the **reverse** direction (5'→3'), so the operation you usually want is the **reverse complement**.

**3a.** Define it:

```lean
def reverseComplement (s : List Base) : List Base :=
  sorry

#eval reverseComplement [A, T, G, C, C, G]
-- expected: [Base.C, Base.G, Base.G, Base.C, Base.A, Base.T]
```

**3b.** Prove it's its own inverse:

```lean
theorem reverseComplement_twice (s : List Base) :
    reverseComplement (reverseComplement s) = s := by
  sorry
```

**Hint:** This one needs **helper lemmas**, which is a very common pattern. You'll want:

1. `complementStrand (s ++ t) = complementStrand s ++ complementStrand t` (complement distributes over concatenation `++`)
2. `complementStrand s.reverse = (complementStrand s).reverse` (complement commutes with reverse). This needs lemma 1, because `List.reverse (b :: rest)` unfolds to `rest.reverse ++ [b]`.

Then the main theorem follows from lemma 2 and `compStrand_twice`.

In `simp [← h]`, the `←` means "use `h` right-to-left".

<details>
<summary>Solution</summary>

```lean
def reverseComplement (s : List Base) : List Base :=
  (complementStrand s).reverse

theorem complementStrand_append (s t : List Base) :
    complementStrand (s ++ t) = complementStrand s ++ complementStrand t := by
  induction s with
  | nil => rfl
  | cons b rest ih => simp [complementStrand, ih]

theorem complementStrand_reverse (s : List Base) :
    complementStrand s.reverse = (complementStrand s).reverse := by
  induction s with
  | nil => rfl
  | cons b rest ih => simp [complementStrand, complementStrand_append, ih]

theorem reverseComplement_twice (s : List Base) :
    reverseComplement (reverseComplement s) = s := by
  simp [reverseComplement, ← complementStrand_reverse, compStrand_twice]
```

</details>

💡 Once this is done, you could switch `Main.lean` to print the reverse complement too, and it would carry a proof.

---

## Exercise 4: `complementStrand` is just `map` ⭐⭐

Show that our hand-written recursion is the same as the library function `List.map`:

```lean
theorem complementStrand_eq_map (s : List Base) :
    complementStrand s = s.map complement := by
  sorry
```

<details>
<summary>Solution</summary>

```lean
theorem complementStrand_eq_map (s : List Base) :
    complementStrand s = s.map complement := by
  induction s with
  | nil => rfl
  | cons b rest ih => simp [complementStrand, ih]
```

</details>

💡 Why it matters: once you know this, you can use the many existing theorems about `List.map` (e.g. `List.length_map`) for free.

---

## Exercise 5: GC content is preserved ⭐⭐⭐

GC content (the number of G and C bases) is an important property of DNA. Complementing swaps G↔C and A↔T, so the GC count should stay the same.

```lean
def isGC (b : Base) : Bool :=
  match b with
  | G | C => true
  | _ => false

def gcCount (s : List Base) : Nat := (s.filter isGC).length

#eval gcCount [A, T, G, C, C, G]   -- 4

theorem gcCount_complement (s : List Base) :
    gcCount (complementStrand s) = gcCount s := by
  sorry
```

**Hint:** Induction on `s`. In the `cons` case, also do `cases b`, because whether the base counts depends on which base it is. `simp_all` with all the relevant definitions (`gcCount`, `complementStrand`, `complement`, `isGC`, `List.filter`) can finish it.

<details>
<summary>Solution</summary>

```lean
theorem gcCount_complement (s : List Base) :
    gcCount (complementStrand s) = gcCount s := by
  induction s with
  | nil => rfl
  | cons b rest ih =>
    cases b <;> simp_all [gcCount, complementStrand, complement, isGC, List.filter]
```

A cleaner route is to first prove the single-base fact and build on it:

```lean
theorem isGC_complement (b : Base) : isGC (complement b) = isGC b := by
  cases b <;> rfl
```

</details>

---

## Open-ended challenges (no solutions provided)

These are good "real project" next steps:

1. **Prove the parser correct.** Define `baseToChar : Base → Char`, then prove that parsing the printed form gives back the strand:
   `parseDNA (strandToString s) = some s`. This would make `Main.lean` verified too.
2. **RNA.** Add an `RNABase` type (`A | U | C | G`), a `transcribe : List Base → List RNABase` function, and prove that `transcribe` preserves length.
3. **Codons and translation.** Define a `Codon` as three bases and an `AminoAcid` type, write the genetic code table, and prove facts like "every codon maps to exactly one amino acid or stop".
4. **Hamming distance.** Define the number of mismatches between two equal-length strands. Prove it's symmetric (`dist s t = dist t s`) and that `dist s s = 0`.
5. **Add `deriving DecidableEq`** to `Base`, then try proving small facts with the `decide` tactic.

---

**Next:** [06-glossary-and-resources.md](06-glossary-and-resources.md)
