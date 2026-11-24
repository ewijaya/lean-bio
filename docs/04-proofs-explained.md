# 4. Proofs explained, step by step

The best way to read this page: open `LeanBio/Basic.lean` in VS Code, and **move your cursor through each proof** while watching the Infoview. What's shown below is what the Infoview displays.

Notation reminder:

```text
b : Base                                 ← things you KNOW (hypotheses / variables)
⊢ complement (complement b) = b          ← what you must PROVE (the goal)
```

---

## Proof 1: `complement_twice`

```lean
theorem complement_twice (b : Base) : complement (complement b) = b := by
  cases b <;> rfl
```

### The idea in English

> "There are only four possible bases. Check each one directly."
>
> - A → T → A ✓
> - T → A → T ✓
> - C → G → C ✓
> - G → C → G ✓

That's a **proof by exhaustion** (case analysis). It works because `Base` has finitely many values.

### Step by step

**Start.** Cursor right after `by`:

```text
b : Base
⊢ complement (complement b) = b
```

We can't compute `complement b` yet, because we don't know which base `b` is.

**Tactic `cases b`.** This splits into one goal per constructor of `Base`:

```text
case A
⊢ complement (complement A) = A

case T
⊢ complement (complement T) = T

case C
⊢ complement (complement C) = C

case G
⊢ complement (complement G) = G
```

Now each goal is about a *specific* base, so Lean can compute.

**Combinator `<;>`.** `t1 <;> t2` means "run `t1`, then run `t2` on **every** goal `t1` produced." Without it you'd have to write `rfl` four times:

```lean
-- equivalent, longer version
theorem complement_twice' (b : Base) : complement (complement b) = b := by
  cases b
  · rfl   -- case A
  · rfl   -- case T
  · rfl   -- case C
  · rfl   -- case G
```

(The `·` bullet focuses on one goal at a time. Type it as `\.` in VS Code.)

**Tactic `rfl`.** "Reflexivity": prove `x = y` when both sides **compute to the same thing**. For case A:

```text
complement (complement A)
= complement T     -- by the definition of complement
= A                -- by the definition of complement
```

Both sides are `A`, so `rfl` succeeds. Same for T, C, G. **No goals remain. Proof complete.** ✅

### What if the code were wrong?

If `complement` had a bug like `| G => G`, then in case C we'd get `complement (complement C) = complement G = G`, which is not `C`. `rfl` fails, and Lean reports:

```text
error: Tactic `rfl` failed: The left-hand side
  badComplement (badComplement C)
is not definitionally equal to the right-hand side
  C

case C
⊢ badComplement (badComplement C) = C
```

It names the exact failing case.

---

## Proof 2: `compStrand_twice`

```lean
theorem compStrand_twice (strand : List Base) :
    complementStrand (complementStrand strand) = strand := by
  induction strand with
  | nil => rfl
  | cons b rest ih =>
    simp [complementStrand, complement_twice, ih]
```

### The problem

We can't use `cases` + check everything here. There are **infinitely many** lists. We need **induction**.

### Induction, explained like dominoes

To prove something for **every** list, prove two things:

1. **Base case (`nil`):** it's true for the empty list `[]`.
2. **Inductive step (`cons`):** *if* it's true for some list `rest`, *then* it's also true for `b :: rest` (one more base on the front).

Then it's true for all lists:

- `[]` ✓ (base case)
- `[G]` = `G :: []` ✓ (step, using `[]`)
- `[C, G]` = `C :: [G]` ✓ (step, using `[G]`)
- ...and so on, for every length.

Each domino knocks over the next. That's exactly how `List` is built (`[]` or `b :: rest`), and that's why induction fits lists so well.

### Step by step

**Start:**

```text
strand : List Base
⊢ complementStrand (complementStrand strand) = strand
```

**`induction strand with`** produces two goals, which we handle with `| nil => ...` and `| cons b rest ih => ...`.

#### Base case: `| nil => rfl`

```text
⊢ complementStrand (complementStrand []) = []
```

By definition, `complementStrand [] = []`, so the left side computes to `complementStrand [] = []`. Both sides are `[]`, and `rfl` closes it. ✅

#### Inductive step: `| cons b rest ih => simp [...]`

Here `b` is the first base, `rest` is the remainder, and **`ih`** (the *induction hypothesis*) is the "previous domino". The Infoview shows:

```text
b : Base
rest : List Base
ih : complementStrand (complementStrand rest) = rest
⊢ complementStrand (complementStrand (b :: rest)) = b :: rest
```

Read `ih` as: *"you may assume the theorem already holds for `rest`."*

Now `simp [complementStrand, complement_twice, ih]`. **`simp`** is the **simplifier**: it repeatedly rewrites the goal using the facts you give it (plus a built-in library of basic facts), until it can't simplify further or the goal becomes trivially true.

What it does here, conceptually:

```text
complementStrand (complementStrand (b :: rest))

  -- unfold complementStrand once (inner):
= complementStrand (complement b :: complementStrand rest)

  -- unfold complementStrand once (outer):
= complement (complement b) :: complementStrand (complementStrand rest)

  -- rewrite with complement_twice:   complement (complement b) = b
= b :: complementStrand (complementStrand rest)

  -- rewrite with ih:   complementStrand (complementStrand rest) = rest
= b :: rest     ✓ matches the right-hand side
```

The three hints in brackets are exactly the three facts used:

| Hint | Used for |
|---|---|
| `complementStrand` | Unfold the definition (the `b :: rest` case) |
| `complement_twice` | Our **first theorem**, reused! Fixes the head `b` |
| `ih` | The induction hypothesis. Fixes the tail `rest` |

**No goals remain. Proof complete.** ✅

💡 Notice how **theorems build on theorems**: `compStrand_twice` uses `complement_twice`. Big verified developments (like Mathlib) are thousands of small lemmas stacked this way.

---

## Tactic cheat sheet

The tactics used here, plus a few you'll want soon:

| Tactic | What it does | Example use |
|---|---|---|
| `rfl` | Closes `a = b` when both sides compute to the same thing | `complement A = T` |
| `cases x` | Split into one goal per constructor of `x` | Check all 4 bases |
| `induction x with ...` | Base case + inductive step (with hypothesis `ih`) | Prove for all lists or naturals |
| `simp [h1, h2]` | Rewrite/simplify using given facts + built-in simp lemmas | Most "obvious" algebra |
| `simp_all` | Like `simp`, but also simplifies all hypotheses | When facts are in context |
| `rw [h]` | Rewrite *once* using equation `h : a = b` (replace `a` with `b`) | More controlled than `simp` |
| `exact e` | "Here is the exact proof term `e`" | `exact complement_twice b` |
| `intro x` | For goals `∀ x, ...` or `P → Q`: introduce the variable/hypothesis | |
| `t1 <;> t2` | Run `t2` on all goals produced by `t1` | `cases b <;> rfl` |
| `·` | Focus on the next goal | Structuring multi-case proofs |
| `decide` | Settle a decidable statement by brute-force computation | Small finite facts |
| `sorry` | Give up for now (warning; **not** a real proof) | Sketching |

### How to approach a new proof

1. **State it** and write `by sorry`. Make sure the statement type-checks first.
2. **Look at the goal** in the Infoview.
3. Is the main variable from a **finite type** (like `Base`)? Try `cases x <;> rfl` or `cases x <;> simp [...]`.
4. Is it a **list or natural number**? Try `induction x with | nil => ... | cons ... ih => ...`.
5. Inside each case, try `simp [the definitions involved, earlier lemmas, ih]`.
6. If `simp` gets stuck, **look at what's left** in the Infoview. It often tells you exactly which helper lemma you're missing. Prove that lemma separately, then add it to the `simp [...]` list.

---

**Next:** [05-exercises.md](05-exercises.md): put this into practice.
