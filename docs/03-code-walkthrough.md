# 3. Code walkthrough

This page goes through `LeanBio/Basic.lean` and `Main.lean` one piece at a time. Keep the files open in VS Code alongside this page.

Lean syntax notes are marked **🔤 Syntax**. Ideas are marked **💡**.

---

## Part A: `LeanBio/Basic.lean` (the verified library)

### A1. Defining the `Base` type

```lean
-- 1. Define a custom data type for DNA bases
inductive Base where
  | A | T | C | G
  deriving Repr
```

- `--` starts a comment, like `#` in Python.
- `inductive Base where` declares a **new type** called `Base`.
- `| A | T | C | G` lists its **constructors**, the only ways to make a `Base`. There are exactly four values. Nothing else can be a `Base`.
- `deriving Repr` asks Lean to auto-generate code for **printing** a `Base` (Repr = "representation"). Without it, `#eval complement A` wouldn't know how to display the result.

💡 This is like an `enum` in other languages, but much more powerful. `inductive` can also define recursive structures like lists and trees. Lean's `List` is itself defined with `inductive`.

💡 **Why not just use strings?** With `String`, a typo like `"X"` or `"a "` could flow through your whole pipeline. With `Base`, invalid bases are **impossible to represent**. Validation happens once, at the boundary (see `parseDNA` in `Main.lean`), and everything inside is guaranteed clean.

### A2. `open Base`

```lean
open Base
```

The constructors' full names are `Base.A`, `Base.T`, and so on. `open Base` lets you write just `A`, `T`, `C`, `G`. (Similar to `from Base import *` in Python.) That's why `#eval` prints `Base.T`: printing always uses the full name.

### A3. The `complement` function

```lean
def complement (b : Base) : Base :=
  match b with
  | A => T
  | T => A
  | C => G
  | G => C
```

🔤 **Syntax**, piece by piece:

| Piece | Meaning |
|---|---|
| `def complement` | Define a function named `complement` |
| `(b : Base)` | It takes one argument `b`, of type `Base` |
| `: Base` | It returns a `Base` |
| `:=` | "is defined as" |
| `match b with` | Look at which constructor `b` is... |
| `\| A => T` | ...if it's `A`, return `T` |

💡 Lean checks that the `match` is **exhaustive**. If you deleted the `| G => C` line, the file would fail to compile with an error about a missing case. Forgetting a case is a common bug in other languages. Here it can't happen.

💡 Every Lean function is **pure**: same input, same output, no hidden side effects. That's what makes it possible to reason about functions mathematically.

### A4. `#eval`: quick interactive tests

```lean
#eval complement A   -- Output: Base.T
```

`#eval` runs an expression and shows the result in the Infoview (and during `lake build`, as an `info:` line). It's like typing into a Python REPL, but saved in the file. Commands starting with `#` are **editor/debugging commands**. They don't define anything.

### A5. The first theorem

```lean
theorem complement_twice (b : Base) : complement (complement b) = b := by
  cases b <;> rfl
```

| Piece | Meaning |
|---|---|
| `theorem complement_twice` | A named theorem, which can be reused in later proofs |
| `(b : Base)` | "For any base `b`..." |
| `: complement (complement b) = b` | "...this equation holds." This is the **statement**. |
| `:= by` | "Here's the proof, written with tactics:" |
| `cases b <;> rfl` | The proof (explained in [04-proofs-explained.md](04-proofs-explained.md)) |

💡 Note the function call syntax: `complement (complement b)`, **not** `complement(complement(b))`. In Lean, function application is just a space: `f x`. Parentheses are only for grouping.

💡 A theorem is like a `def` whose "return type" is a statement and whose "body" is a proof. Recall from [01-concepts.md](01-concepts.md): statements are types.

### A6. Complementing a whole strand

```lean
def complementStrand (strand : List Base) : List Base :=
  match strand with
  | [] => []
  | b :: rest => complement b :: complementStrand rest
```

- `List Base` is a list of bases (a DNA strand).
- A Lean list is **either**:
  - `[]`, the empty list, **or**
  - `b :: rest`, a first element `b` stuck onto the front of another list `rest`. `::` is pronounced "cons".
- So `[A, T, G]` is really `A :: (T :: (G :: []))`.

The function is **recursive**:

- Empty strand → empty result.
- Otherwise → complement the first base, and stick it onto the complement of the rest.

Trace of `complementStrand [A, T, G, C]`:

```text
complementStrand [A, T, G, C]
= complement A :: complementStrand [T, G, C]
= T :: (complement T :: complementStrand [G, C])
= T :: A :: (complement G :: complementStrand [C])
= T :: A :: C :: (complement C :: complementStrand [])
= T :: A :: C :: G :: []
= [T, A, C, G]
```

💡 Lean checks that this recursion **terminates**. Here that's easy: `rest` is always shorter than `strand`. If Lean can't confirm a function terminates, it rejects it (unless you mark it `partial`). This matters because a non-terminating "proof" could prove anything.

💡 This is exactly `strand.map complement`. It's written out by hand here so the proof by induction lines up with the definition. Exercise 4 in [05-exercises.md](05-exercises.md) proves the two are equal.

### A7. The main theorem

```lean
theorem compStrand_twice (strand : List Base) :
    complementStrand (complementStrand strand) = strand := by
  induction strand with
  | nil => rfl
  | cons b rest ih =>
    simp [complementStrand, complement_twice, ih]
```

Statement: *for **any** strand, complementing it twice gives the original strand.*

The proof uses **induction**, the standard way to prove things about every list. It's covered step by step in [04-proofs-explained.md](04-proofs-explained.md).

---

## Part B: `Main.lean` (the command-line program)

This file has **no theorems**. It's the "untrusted shell" around the verified core: it reads text from the outside world, validates it, calls the verified `complementStrand`, and prints the result.

### B1. Importing the library

```lean
import LeanBio

open Base
```

`import LeanBio` loads `LeanBio.lean`, which in turn imports `LeanBio/Basic.lean`. Imports must be at the very top of a file.

### B2. Parsing one character

```lean
def parseChar (c : Char) : Option Base :=
  match c with
  | 'A' | 'a' => some A
  | 'T' | 't' => some T
  | 'C' | 'c' => some C
  | 'G' | 'g' => some G
  | _         => none
```

- `Char` is a single character. Character literals use single quotes: `'A'`.
- `Option Base` means **"maybe a `Base`, maybe nothing"**. It has two forms:
  - `some A`: success, here's the base
  - `none`: failure, no base
- `| 'A' | 'a' => ...` matches either uppercase or lowercase.
- `_` is the **wildcard**: "anything else".

💡 `Option` is Lean's alternative to `null`/`None`/exceptions. The type *forces* callers to handle the failure case. You can't accidentally use a `none` as if it were a base.

### B3. Parsing a whole string

```lean
def parseDNA (s : String) : Option (List Base) :=
  List.mapM parseChar s.toList
```

- `s.toList` turns the string into a `List Char`.
- `List.mapM parseChar` applies `parseChar` to every character. The `M` means it works with `Option`: if **all** characters succeed, you get `some [bases...]`. If **any** fails, the whole result is `none`.

So `parseDNA "ATG"` = `some [A, T, G]`, and `parseDNA "ATXG"` = `none`.

### B4. Back to text

```lean
def baseToString (b : Base) : String :=
  match b with
  | A => "A"
  | T => "T"
  | C => "C"
  | G => "G"

def strandToString (strand : List Base) : String :=
  String.join (strand.map baseToString)
```

- `strand.map baseToString` turns `[T, A, C]` into `["T", "A", "C"]`.
- `String.join` concatenates them: `"TAC"`.
- `strand.map f` is shorthand for `List.map f strand`. This "dot notation" works because `strand` has type `List ...`.

### B5. `main`: the program entry point

```lean
def main (args : List String) : IO Unit := do
  match args with
  | [seq] =>
    match parseDNA seq with
    | some strand =>
      let comp := complementStrand strand
      IO.println s!"Input:      {strandToString strand}"
      IO.println s!"Complement: {strandToString comp}"
    | none =>
      IO.eprintln s!"Error: '{seq}' contains invalid DNA bases (only A, T, C, G allowed)."
  | _ =>
    IO.println "Usage: lean-bio <DNA_SEQUENCE>"
    IO.println "Example: lean-bio ATGCCG"
```

| Piece | Meaning |
|---|---|
| `args : List String` | The command-line arguments |
| `IO Unit` | "An action that does input/output and returns nothing useful." `Unit` is like `void` or `None`. |
| `do` | Begins a block of steps run in order, like ordinary imperative code |
| `\| [seq] =>` | Matches a list with **exactly one** argument, and names it `seq` |
| `let comp := ...` | A local variable |
| `s!"...{x}..."` | String interpolation, like Python's `f"...{x}..."` |
| `IO.println` / `IO.eprintln` | Print to stdout / stderr |
| `\| _ =>` | Zero arguments, or two or more: print usage |

💡 **The pure/IO split.** In Lean, functions that touch the outside world (printing, files, network) must have an `IO` type. Pure functions like `complement` can't secretly print or read files. That's part of why we can prove things about them.

💡 **Architecture lesson:** keep the verified logic pure and small (`Basic.lean`), and keep the messy I/O in a thin outer layer (`Main.lean`). This pattern, sometimes called "functional core, imperative shell", is how verified software is usually structured.

---

**Next:** [04-proofs-explained.md](04-proofs-explained.md): how the proofs actually work.
