# lean-bio

**Mathematically proven DNA tools, written in [Lean 4](https://lean-lang.org/).**

`lean-bio` is a small learning project. It uses DNA, the kind of thing a biologist works with every day, to show what *formal verification* is and why you might want it.

It contains:

1. **A tiny bioinformatics library** (`LeanBio/Basic.lean`) that models DNA bases and computes complementary strands.
2. **Machine-checked proofs** that the code is correct, e.g. *"complementing any DNA strand twice gives back the original strand, for every possible strand of every possible length."*
3. **A command-line program** (`Main.lean`) that you can run on real sequences:

```console
$ lake exe lean-bio ATGCCG
Input:      ATGCCG
Complement: TACGGC
```

> **New to Lean or formal verification?** You're the intended reader. Start with
> [docs/01-concepts.md](docs/01-concepts.md). It assumes no prior knowledge of Lean, proofs, or functional programming.

---

## Why bother proving things about code?

A normal unit test says: *"I tried `ATGC` and got the right answer."*
A Lean proof says: *"I have shown, and a computer has checked, that the answer is right for **every** input."*

| | Unit tests | Formal proof (Lean) |
|---|---|---|
| Inputs checked | The handful you thought of | **All of them**, including infinitely many |
| Who checks it | You run the tests | The Lean *kernel* checks the logic |
| If the code changes and breaks the property | Maybe a test catches it | **The project stops compiling** |
| Effort | Low | Higher, but the guarantee is much stronger |

In this repo the theorem `compStrand_twice` covers every DNA strand there is: 4 strands of length 1, 16 of length 2, ... 4¹⁰⁰⁰ of length 1000, and so on forever. No test suite can do that.

---

## Quick start

### 1. Install Lean (one-time)

Lean is installed with **elan**, a version manager similar to `rustup` or `pyenv`.

**macOS / Linux:**

```bash
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh
```

Then restart your terminal. Check that it worked:

```bash
elan --version
lake --version
```

You don't need to pick a Lean version yourself. The `lean-toolchain` file in this repo says which one to use (`v4.36.0`), and elan downloads it automatically the first time you build.

**Recommended editor:** [VS Code](https://code.visualstudio.com/) with the official **"Lean 4"** extension. See [docs/02-setup.md](docs/02-setup.md) for details.

### 2. Get the code

```bash
git clone https://github.com/ewijaya/lean-bio.git
cd lean-bio
```

### 3. Build (this also checks every proof)

```bash
lake build
```

Expected output:

```text
info: LeanBio/Basic.lean:17:0: Base.T
info: LeanBio/Basic.lean:30:0: [Base.T, Base.A, Base.C, Base.G]
Build completed successfully (11 jobs).
```

The two `info:` lines come from the `#eval` test commands in the source file. **If the build succeeds, every theorem in the project has been verified.** There's no separate "run the proofs" step.

### 4. Run the program

```bash
lake exe lean-bio ATGCCG      # valid DNA
lake exe lean-bio atgc        # lowercase is accepted
lake exe lean-bio ATXG        # invalid: prints an error
lake exe lean-bio             # no argument: prints usage
```

```text
Input:      ATGCCG
Complement: TACGGC
```

```text
Error: 'ATXG' contains invalid DNA bases (only A, T, C, G allowed).
```

---

## Project layout

```text
lean-bio/
├── LeanBio/
│   └── Basic.lean        ← The library: DNA types, functions, and THEOREMS
├── LeanBio.lean          ← Library "root": imports everything in LeanBio/
├── Main.lean             ← Command-line program (parsing, printing, main)
├── lakefile.toml         ← Build configuration (like package.json / Cargo.toml)
├── lake-manifest.json    ← Locked dependency versions (auto-generated)
├── lean-toolchain        ← Which Lean version to use (read by elan)
├── .github/workflows/
│   └── lean_action_ci.yml← GitHub Actions: rebuilds & re-checks proofs on every push
└── docs/                 ← Beginner documentation (start here!)
```

`.lake/` is the build output folder. It's git-ignored, and you can delete it any time.

---

## What's proven

| Theorem | Plain English | File |
|---|---|---|
| `complement_twice` | For any single base `b`, the complement of the complement of `b` is `b`. (A→T→A, C→G→C, ...) | `LeanBio/Basic.lean` |
| `compStrand_twice` | For any DNA strand, complementing the whole strand twice returns the original strand. | `LeanBio/Basic.lean` |

### What is *not* proven

It's worth being honest about where the guarantees stop:

- **`Main.lean` has no proofs.** The parsing (`parseDNA`) and printing (`strandToString`) are ordinary code. They are type-checked but not proven correct. Proving them is a good exercise (see [docs/05-exercises.md](docs/05-exercises.md)).
- A proof only guarantees **what the theorem states**. `compStrand_twice` does *not* say that `complement A = T`. It only says complementing twice is the identity. A function that mapped every base to itself would also satisfy it. Writing the *right* theorem is part of the skill.
- The model is simplified: only A, T, C, G. There's no `N`, no RNA `U`, and no IUPAC ambiguity codes.

---

## Documentation

Read these in order if you're new:

| # | Doc | What you'll learn |
|---|---|---|
| 1 | [Concepts](docs/01-concepts.md) | What Lean is, what "formal verification" means, types vs. proofs, why biology? |
| 2 | [Setup](docs/02-setup.md) | Installing Lean, using VS Code and the Infoview panel, essential `lake` commands |
| 3 | [Code walkthrough](docs/03-code-walkthrough.md) | Every line of `Basic.lean` and `Main.lean` explained |
| 4 | [Proofs explained](docs/04-proofs-explained.md) | How the two proofs work, step by step: `cases`, `rfl`, `induction`, `simp` |
| 5 | [Exercises](docs/05-exercises.md) | Hands-on next steps (reverse complement, GC content, ...) with checked solutions |
| 6 | [Glossary & resources](docs/06-glossary-and-resources.md) | Jargon decoder, plus where to learn more |

---

## Continuous integration

Every push and pull request runs [`leanprover/lean-action`](https://github.com/leanprover/lean-action) on GitHub Actions (`.github/workflows/lean_action_ci.yml`). It runs `lake build`, so **if anyone pushes a change that breaks a proof, CI goes red.** That's the "proofs as regression tests" idea in practice.

## Requirements

- Lean `v4.36.0` (installed automatically by elan from `lean-toolchain`)
- No external dependencies. The project uses only Lean's core library, not Mathlib.
