# 6. Glossary and resources

## Glossary

| Term | Meaning |
|---|---|
| **Lean 4** | A programming language and proof assistant. "Lean 3" is an older, incompatible version, so be careful with old tutorials. |
| **Proof assistant** | Software that checks mathematical proofs mechanically (others: Coq/Rocq, Isabelle, Agda). |
| **Formal verification** | Proving, with a machine-checked proof, that software meets a precise specification. |
| **Specification (spec)** | The precise statement of what code should do. In Lean, the statement of a theorem. |
| **elan** | Installs and selects Lean versions (reads `lean-toolchain`). |
| **lake** | Lean's build tool and package manager (reads `lakefile.toml`). |
| **Mathlib** | The huge community library of formalized mathematics. This project does **not** use it. |
| **Infoview** | The VS Code panel showing goals, hypotheses, errors, and `#eval` output. |
| **Type** | A classification of values: `Nat`, `String`, `Base`, `List Base`. In Lean, statements are types too. |
| **`inductive`** | Keyword for defining a new type by listing its constructors. |
| **Constructor** | One of the ways to build a value of an inductive type, e.g. `A`, `T`, `C`, `G` for `Base`, or `[]` and `::` for `List`. |
| **`def`** | Defines a function or value. |
| **`theorem`** | Defines a named, proven statement. |
| **`match`** | Pattern matching: branch on which constructor a value is. |
| **Pure function** | A function with no side effects. Same input, same output, always. |
| **`IO`** | The type of actions that interact with the outside world (print, read files, ...). |
| **`Option α`** | "Maybe an `α`": either `some x` or `none`. |
| **Goal** | What remains to be proven, shown after `⊢` in the Infoview. |
| **Hypothesis** | A fact you're allowed to use, shown above `⊢`. |
| **`⊢` (turnstile)** | Separates hypotheses (above) from the goal (below). |
| **Tactic** | A command (after `by`) that transforms the current goal(s). See the cheat sheet in [04](04-proofs-explained.md). |
| **`rfl`** | Proves `a = b` when both sides compute to the same value. |
| **Definitional equality** | Two expressions are "definitionally equal" if they compute to the same thing by unfolding definitions. That's what `rfl` checks. |
| **`simp`** | The simplifier. Rewrites the goal with a database of lemmas plus the ones you provide. |
| **Case analysis** | Proving something by checking every constructor (`cases`). |
| **Induction** | Proving something for all lists/numbers via a base case plus an inductive step. |
| **Induction hypothesis (`ih`)** | In the inductive step: the assumption that the statement already holds for the smaller part. |
| **Lemma** | A theorem mainly used as a stepping stone. Lean treats `lemma` and `theorem` the same (with Mathlib). Core Lean only has `theorem`. |
| **`sorry`** | A placeholder that skips a proof. Produces a warning. A finished project has none. |
| **Kernel** | The small trusted core of Lean that re-checks every proof term. |
| **Curry–Howard correspondence** | The idea that propositions are types and proofs are programs. |
| **`#eval`** | Runs an expression and shows the result (for testing and exploration). |
| **`#check`** | Shows the type of an expression, e.g. `#check complement_twice`. |
| **Termination** | Lean requires recursive functions to provably finish, so proofs can't be circular. |

## Typing special symbols in VS Code

The Lean extension converts backslash-abbreviations as you type:

| Type | Get | Meaning |
|---|---|---|
| `\ne` | `≠` | not equal |
| `\to` or `\r` | `→` | implies / function arrow |
| `\l` | `←` | rewrite backwards (in `rw`/`simp`) |
| `\forall` | `∀` | for all |
| `\exists` | `∃` | there exists |
| `\and` | `∧` | and |
| `\or` | `∨` | or |
| `\not` | `¬` | not |
| `\.` | `·` | focus bullet in proofs |
| `\alpha` | `α` | Greek letters, often used as type variables |

Hover over any symbol in a Lean file to see how to type it.

## Where to learn more

Recommended order for a beginner:

1. **[Natural Number Game](https://adam.math.hhu.de/#/g/leanprover-community/nng4)**: a browser game that teaches proofs and tactics with no install needed. The single best starting point.
2. **[Functional Programming in Lean](https://lean-lang.org/functional_programming_in_lean/)**: Lean as a *programming language*. Read it if `Main.lean` felt unfamiliar.
3. **[Theorem Proving in Lean 4](https://lean-lang.org/theorem_proving_in_lean4/)**: the official guide to the logic and proof side.
4. **[Mathematics in Lean](https://leanprover-community.github.io/mathematics_in_lean/)**: if you want to formalize math using Mathlib.
5. **[Lean documentation hub](https://lean-lang.org/documentation/)**: everything official in one place.

### Getting help

- **[Lean Zulip chat](https://leanprover.zulipchat.com/)**: very active and beginner-friendly. Use the `#new members` stream.
- In any Lean file, `#check name` and hovering are often faster than searching the web.
- Tactic `exact?` searches the library for a lemma that closes the current goal. `simp?` tells you which lemmas `simp` used. Both are useful for learning what exists.

### Beware of outdated material

Lean 3 and Lean 4 are **not compatible**, and a lot of older material online is Lean 3. Signs you're looking at Lean 3: `begin ... end` blocks around proofs, `import tactic`, or lowercase `nat`. Lean 4 uses `by`, `Nat`, and `import Mathlib`.
