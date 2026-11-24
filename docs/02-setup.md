# 2. Setup: installing Lean and the everyday workflow

## The toolchain in one picture

```text
elan  ──installs/selects──▶  lean  (the compiler + proof checker)
                             lake  (the build tool / package manager)
```

| Tool | Analogy | What it does |
|---|---|---|
| **elan** | `rustup`, `pyenv`, `nvm` | Installs Lean versions and picks the right one per project (from `lean-toolchain`) |
| **lean** | `python`, `rustc` | Compiles code and **checks proofs** |
| **lake** | `cargo`, `npm`, `pip` | Builds the project, runs executables, manages dependencies |

You mostly type `lake` commands. You rarely call `lean` directly.

## Installing

### macOS / Linux

```bash
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh
```

Accept the defaults. Then **restart your terminal** (or run `source ~/.elan/env`) and check:

```bash
elan --version
lake --version
```

### Windows

Follow the official guide: <https://lean-lang.org/install/>

### The first build downloads Lean

This project pins Lean `v4.36.0` in the `lean-toolchain` file. The first time you run `lake build` inside the folder, elan downloads that version (a few hundred MB). After that it's cached.

## Editor: VS Code + Lean 4 extension (strongly recommended)

You *can* write Lean in any editor, but the interactive experience is most of what makes Lean usable for beginners.

1. Install [VS Code](https://code.visualstudio.com/).
2. Open the Extensions panel (`Cmd+Shift+X` / `Ctrl+Shift+X`), search **"Lean 4"**, and install the official extension (publisher: *leanprover*).
3. Open the **project folder** (`File → Open Folder… → lean-bio`). Open the folder, not just a single file, so the extension finds `lakefile.toml`.
4. Open `LeanBio/Basic.lean`.

### The Infoview: your most important window

When a `.lean` file is open, the extension shows an **Infoview** panel (usually on the right). If you don't see it, press `Cmd+Shift+Enter` / `Ctrl+Shift+Enter`, or run **"Lean 4: Infoview: Toggle Infoview"** from the command palette.

Try these:

| Put your cursor on... | Infoview shows |
|---|---|
| `#eval complement A` (line 17) | `Base.T`, the result of running the code |
| `#eval complementStrand [A, T, G, C]` | `[Base.T, Base.A, Base.C, Base.G]` |
| The word `by` in `complement_twice` | The **goal**: `⊢ complement (complement b) = b` |
| After `cases b` (before `<;>`) | **Four goals**, one per base (`case A`, `case T`, ...) |
| The end of the proof | `No goals`, meaning the proof is complete |
| Inside `compStrand_twice`, on `simp [...]` | The induction step's goal, with `ih` listed as a hypothesis above `⊢` |

The `⊢` symbol (read "turnstile") separates **what you know** (above) from **what you need to prove** (below).

### Hover and go-to-definition

- **Hover** over any name (e.g. `List.mapM`) to see its type and documentation.
- **Cmd/Ctrl+click** a name to jump to its definition, including definitions inside Lean's own standard library.

### Red and yellow squiggles

- **Red** = error. A proof that doesn't work, a type mismatch, a typo.
- **Yellow/blue** = warning or info. `#eval` output, or `declaration uses 'sorry'`.

Lean re-checks the file **as you type**, so you get feedback immediately without running a build.

## Essential `lake` commands

Run these from the project root (the folder containing `lakefile.toml`).

| Command | What it does |
|---|---|
| `lake build` | Compile everything **and check every proof**. The main command. |
| `lake exe lean-bio ATGC` | Build if needed, then run the `lean-bio` program with argument `ATGC` |
| `lake clean` | Delete build outputs in `.lake/build`. Use it if things get weird. |
| `lake env lean SomeFile.lean` | Check a single standalone file that imports this project |
| `elan show` | Show which Lean version is active for this folder |

### What a successful build looks like

```text
info: LeanBio/Basic.lean:17:0: Base.T
info: LeanBio/Basic.lean:30:0: [Base.T, Base.A, Base.C, Base.G]
Build completed successfully (11 jobs).
```

The `info:` lines are the `#eval` outputs. They're informational, not errors.

### What a broken proof looks like

Suppose someone introduced a bug and made `G` map to `G` instead of `C`. The proof `cases b <;> rfl` would fail with:

```text
error: Tactic `rfl` failed: The left-hand side
  badComplement (badComplement C)
is not definitionally equal to the right-hand side
  C

case C
⊢ badComplement (badComplement C) = C
```

Lean tells you **exactly which case fails** (`case C`): complementing C twice doesn't give back C. This is the payoff. The proof caught a bug that a test on `[A, T]` would have missed.

## Project configuration files

### `lakefile.toml`

```toml
name = "lean-bio"
version = "0.1.0"
defaultTargets = ["lean-bio"]

[[lean_lib]]          # a library...
name = "LeanBio"      # ...whose root file is LeanBio.lean

[[lean_exe]]          # an executable...
name = "lean-bio"     # ...run with `lake exe lean-bio`
root = "Main"         # ...whose entry point is Main.lean
```

### `lean-toolchain`

```text
leanprover/lean4:v4.36.0
```

A single line that tells elan which Lean version to use. To upgrade Lean later, change this line, then run `lake build`. Newer versions occasionally rename things, so expect small fixes.

### `LeanBio.lean`

```lean
import LeanBio.Basic
```

The library's "table of contents". If you add a new file like `LeanBio/RNA.lean`, add `import LeanBio.RNA` here so it gets built.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `lake: command not found` | Restart the terminal, or `source ~/.elan/env` |
| VS Code shows "Imports are out of date" | Click **"Restart File"** in the Infoview, or run `lake build` in a terminal |
| Everything is red after pulling changes | Run `lake build` once from the terminal, then restart the Lean server (Command palette → "Lean 4: Restart Server") |
| Infoview is blank | Make sure you opened the **folder**, not a lone file. Check the bottom-right status bar for Lean errors. |
| Weird stale errors | `lake clean && lake build` |

---

**Next:** [03-code-walkthrough.md](03-code-walkthrough.md): what every line of the code means.
