# 1. Concepts: Lean and formal verification from zero

This page has no code to run. It builds the mental model you'll need for the rest of the docs.

## What is Lean?

Lean is **two things in one**:

1. **A programming language.** You can write functions, compile them, and run them, just like Python or Rust. `Main.lean` in this repo is a normal command-line program.
2. **A proof assistant.** You can write *mathematical statements* about your code (or about math in general), write *proofs* of those statements, and Lean will **check every step** of the proof mechanically.

The second part is what makes Lean unusual. Lean is used by mathematicians (the [Mathlib](https://github.com/leanprover-community/mathlib4) library has formalized a huge amount of undergraduate and research math), and increasingly by engineers who want strong guarantees about software.

## What is formal verification?

**Verification** means showing that a program does what it should.
**Formal** means the argument is written in a precise logical language and checked by a computer, not just argued in prose or tested on examples.

An analogy for a biologist:

| | Biology analogy |
|---|---|
| Unit test | Running an experiment on one sample. Good evidence, but maybe that sample was special. |
| Formal proof | A derivation from first principles that covers *every* possible sample, checked line-by-line by a referee who never gets tired and never skips a step. |

## The three things you write in Lean

Everything in `LeanBio/Basic.lean` is one of these:

### 1. Types: "what kinds of things exist"

```lean
inductive Base where
  | A | T | C | G
```

This says: *a `Base` is exactly one of A, T, C, or G. Nothing else.*
A Python string `"X"` could sneak in anywhere. A Lean `Base` **cannot be anything other than these four**. The compiler enforces it, so many bugs can't even be written.

### 2. Definitions: "what the code does"

```lean
def complement (b : Base) : Base := ...
```

These are ordinary functions. They take inputs and return outputs.

### 3. Theorems: "what is guaranteed to be true"

```lean
theorem complement_twice (b : Base) : complement (complement b) = b := by
  cases b <;> rfl
```

Read this as:

> **Theorem** (named `complement_twice`): For every base `b`, `complement (complement b) = b`.
> **Proof** (everything after `by`): `cases b <;> rfl`.

The part before `:=` is the **statement** (the claim).
The part after `by` is the **proof** (the justification).

If the proof is wrong or incomplete, **Lean refuses to compile the file.** You can't "ship" a false theorem by accident.

## The key insight: statements are types, proofs are values

This is the idea that makes Lean work, and the one people find strangest at first. You don't need to fully absorb it yet.

- In ordinary programming, `5 : Nat` means "`5` is a value of type `Nat`".
- In Lean, a statement like `complement (complement b) = b` is **also a type**.
- A *proof* of that statement is a **value of that type**.

So "checking a proof" is the same operation as "type-checking a program". That's why one tool can do both. (The official name is the *Curry–Howard correspondence*, which is good to know if you want to search for it later.)

The practical consequence: **when you see a proof error in Lean, it's a type error.** The tooling for both is the same.

## Tactics: how you actually write proofs

You rarely write the proof-value by hand. Instead, after `by`, you write **tactics**: commands that build the proof for you step by step, like a dialogue:

1. Lean shows you the **goal**: what's left to prove.
2. You apply a tactic (e.g. "split into cases", "simplify", "use induction").
3. Lean shows you the new goal(s).
4. Repeat until no goals remain.

In VS Code, the **Infoview** panel shows the current goal as you move your cursor through a proof. This is the main way you'll interact with Lean. See [02-setup.md](02-setup.md).

## Who checks the proof? (The "trusted kernel")

When you write a proof with tactics, the tactics generate a proof term. That term is then checked by Lean's **kernel**, a small, carefully written core.

Why this matters: even if a tactic has a bug, it can't make Lean accept a false theorem, because the kernel re-checks everything. You only have to trust the kernel (and the logic it implements), not the thousands of lines of tactic code on top.

## `sorry`: the escape hatch

```lean
theorem something_hard : ... := by
  sorry
```

`sorry` means "trust me, I'll prove this later." Lean accepts it, but prints a **warning** (`declaration uses 'sorry'`). It's useful while sketching. A project that's really verified has **zero** `sorry`s. This repo has none.

## Why biology is a nice playground

- **Small, finite alphabets** (4 bases, 20 amino acids, 64 codons) are easy to model as types.
- **Lots of clean symmetries** to prove: complement is its own inverse, reverse complement preserves length, GC count is unchanged by complementation, and so on.
- **Real stakes:** bioinformatics pipelines silently produce wrong results surprisingly often (off-by-one errors, strand confusion, wrong reading frame). Proofs rule out whole classes of these.

## What formal verification does *not* give you

- **It proves the theorem you wrote, not the one you meant.** If your specification is wrong, the proof is still "correct" but doesn't mean what you hoped. Writing good specifications is a skill in its own right.
- **It says nothing about code you didn't prove things about.** In this repo, the parsing in `Main.lean` is unproven.
- **The model is a simplification of reality.** Our `Base` type has no `N` (unknown base) and no methylation. Proofs are about the model.

---

**Next:** [02-setup.md](02-setup.md): get Lean running and see the Infoview in action.
