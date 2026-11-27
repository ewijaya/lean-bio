# Top 10 Ideas: Lean 4 for Structural Biology & Computational Drug Discovery

This document captures candidate directions for exploring whether and where **Lean 4** (formal verification and interactive theorem proving) can add real value in structural biology and computational drug discovery.

> **Guiding principle:** Lean is not meant to replace GPU molecular dynamics kernels (OpenMM, GROMACS) or PyTorch training loops. Its highest leverage is in:
> 1. **Eliminating silent correctness bugs** in tricky discrete/algebraic logic (stereochemistry, valence, space groups, graph matching).
> 2. **Verifying mathematical invariants** (symmetries, analytical gradients, conservation laws, optimization bounds).
> 3. **Proof-carrying / certificate checking** for outputs produced by fast external solvers (C++/Rust/Python).

---

## Quick Comparison

| # | Idea | Domain | Core Lean Guarantee | Dependencies | Feasibility |
|---|---|---|---|---|---|
| 1 | Verified Stereochemistry & CIP Chirality | Cheminformatics | Parity, R/S inversion, SMILES round-trip | Core Lean | High |
| 2 | Verified Valence, Tautomers & Reactions | Cheminformatics / Generative AI | Valid-by-construction graphs, mass/charge balance | Core Lean | High |
| 3 | Certified Dead-End Elimination (DEE / GMEC) | Protein Design | Pruning soundness & lower-bound certificates | Core Lean / Rationals | High–Medium |
| 4 | Verified Substructure / SMARTS Matching | Virtual Screening / IP | Sound & complete subgraph isomorphism | Core Lean | High |
| 5 | Verified FEP Graphs & Cycle Closure | Lead Optimization (FEP/RBFE) | Valid atom maps, cycle closure, variance bounds | Mathlib | High–Medium |
| 6 | Verified Crystallographic Space Groups | X-ray Crystallography | Group axioms, exact fractional ↔ Cartesian transforms | Core Lean / Mathlib | High–Medium |
| 7 | Verified $SE(3)$ Geometry & Equivariance | Structure Prediction / Docking | $\det R = +1$ chirality safety, $SE(3)$ equivariance | Mathlib | Medium |
| 8 | Verified Distance Geometry & NMR Restraints | NMR / Integrative Structural Bio | Bound-smoothing soundness, infeasibility proofs | Core Lean / Mathlib | Medium |
| 9 | Verified Force-Field Potentials & Gradients | MD & Docking Scoring | $F = -\nabla E$, Newton's 3rd law, $C^1$ cutoffs | Mathlib | Medium |
| 10 | Verified MD Integrators & Stat-Mech Identities | Molecular Simulation | Time-reversibility, symplecticity, MBAR convexity | Mathlib | Medium–Frontier |

---

## Detailed Ideas

### 1. Verified Stereochemistry & CIP (R/S, E/Z) Chirality Engine
* **Domain:** Cheminformatics / Medicinal Chemistry
* **The problem:** Silent stereochemistry bugs (inverted R/S centers, broken E/Z double bonds, mishandled *meso* compounds, or SMILES/SDF round-trip corruption) are notorious in chemoinformatics pipelines—and in drug discovery, the wrong enantiomer can turn a drug inactive or toxic.
* **What Lean proves:**
  * Cahn–Ingold–Prelog (CIP) priority assignment forms a valid ordering.
  * Tetrahedral parity flips *if and only if* an odd permutation of substituents occurs (and reflection swaps R $\leftrightarrow$ S).
  * Parsing and serializing stereochemical graphs (e.g., SMILES $\leftrightarrow$ molecular graph) preserves chirality.
* **Feasibility:** **High** (pure discrete math, finite graphs, permutations—no heavy Mathlib needed).

### 2. Verified Valence, Tautomer, and Reaction Conservation Rules
* **Domain:** Virtual Screening, Generative Chemistry, Retrosynthesis
* **The problem:** Generative drug-design models and reaction-enumeration engines (SMIRKS) routinely produce chemically invalid molecules, broken kekulization/aromaticity, or reactions that silently create/destroy atoms or charge.
* **What Lean proves:**
  * Dependent-typed molecular graphs that are **valid by construction** (valence/octet constraints, formal charge conservation).
  * Atom-balance and charge-balance theorems for every reaction template.
  * Equivalence-relation proofs (reflexive, symmetric, transitive) for tautomer canonicalization so duplicate ligands don't leak across ML train/test splits.
* **Feasibility:** **High** (natural next step beyond sequence modeling in `LeanBio/Basic.lean`).

### 3. Certified Dead-End Elimination (DEE) & Protein Design (GMEC)
* **Domain:** Computational Protein Design (side-chain packing / rotamer optimization)
* **The problem:** Provable protein-design tools (like Osprey) use Dead-End Elimination (DEE) and branch-and-bound/$A^*$ to prune astronomical rotamer spaces and claim a Global Minimum Energy Conformation (GMEC). A subtle inequality bug in a pruning rule can silently discard the true optimum.
* **What Lean proves:**
  * Soundness of Goldstein/Desmet DEE pruning criteria: *if rotamer $i_r$ satisfies the elimination inequality, it can never appear in the GMEC*.
  * A **proof-carrying checker** that verifies lower-bound / pruning certificates exported by a fast C++/Rust search engine.
* **Feasibility:** **High–Medium** (exact inequalities over rational or interval arithmetic; arguably the single cleanest "killer app" for formal verification in structural biology).

### 4. Verified Substructure / SMARTS & Pharmacophore Matching
* **Domain:** Virtual Screening, Safety Filters (PAINS / toxicity alerts), Patent Markush Search
* **The problem:** Substructure matching underpins toxicophore filtering and IP freedom-to-operate analysis, where false negatives are expensive and subtle graph-matching edge cases (aromatic rings, recursive SMARTS) are hard to test exhaustively.
* **What Lean proves:**
  * Soundness and completeness of subgraph isomorphism: a positive match carries a machine-checked graph homomorphism; a negative result guarantees no valid embedding exists.
* **Feasibility:** **High** (finite graphs and decidable predicates).

### 5. Verified FEP Perturbation Graphs & Thermodynamic Cycle Closure
* **Domain:** Free Energy Perturbation (FEP / RBFE) Lead Optimization
* **The problem:** Relative binding free energy pipelines estimate $\Delta\Delta G$ across networks of ligand pairs. Bugs in common-core atom mappings, disconnected perturbation graphs, net-charge changes, or cycle-closure error propagation silently corrupt potency rankings.
* **What Lean proves:**
  * Atom mappings are valid structure-preserving partial isomorphisms.
  * Exact cycle closure ($\sum_{\text{cycle}} \Delta\Delta G = 0$) and graph connectivity invariants.
  * Optimality / variance-bound guarantees for network estimators (e.g., MLE / DiffNet weighting on perturbation graphs).
* **Feasibility:** **High–Medium** (graph theory + linear algebra via Mathlib).

### 6. Verified Crystallographic Space Groups & Symmetry-Mate Generation
* **Domain:** X-ray Crystallography / Structural Biology (PDB / mmCIF)
* **The problem:** Reconstructing biological assemblies and crystal packing contacts relies on 230 space-group tables, `BIOMT`/`MTRIX` transforms, and fractional-to-Cartesian conversions. Table typos or misapplied operators produce wrong oligomeric states or phantom steric clashes.
* **What Lean proves:**
  * The encoded symmetry operators for each space group actually form a group modulo lattice translations.
  * Fractional $\leftrightarrow$ orthogonal coordinate transforms are exact inverses and preserve lattice distances.
  * Asymmetric unit expansion generates every symmetry mate uniquely without duplication.
* **Feasibility:** **High–Medium** (finite group actions on $\mathbb{R}^3 / \mathbb{Z}^3$).

### 7. Verified $SE(3)$ Geometry, Chirality Preservation & Equivariant Layers
* **Domain:** Protein Structure Prediction (AlphaFold-style frames), Docking, Geometric Deep Learning
* **The problem:** Structural pipelines constantly convert between internal coordinates (bond lengths, angles, $\phi/\psi/\omega$ torsions), rigid backbone frames $(R, t) \in SE(3)$, quaternions, and Cartesian coordinates. Subtle bugs—such as allowing improper reflections ($\det R = -1$, which turns L-amino acids into D-amino acids) or breaking $SE(3)$ equivariance—corrupt predictions.
* **What Lean proves:**
  * Rigid transforms stay in $SE(3)$ ($\det R = +1$), preserving L-amino acid chirality.
  * RMSD and inter-residue distance matrices are strictly invariant under $SE(3)$.
  * Idealized architectures (e.g., invariant point attention / equivariant message passing) satisfy $f(Rx + t) = R f(x) + t$.
  * Internal-coordinate (NeRF) $\leftrightarrow$ Cartesian conversion is invertible away from collinear singularities.
* **Feasibility:** **Medium** (uses Mathlib's linear algebra and `Matrix.specialOrthogonalGroup`).

### 8. Verified Distance Geometry & NMR / Cross-Link Restraint Feasibility
* **Domain:** NMR Structure Determination & Integrative Structural Biology
* **The problem:** Experimental NOE distances and cross-links define lower/upper distance bounds. Triangle- and tetrangle-inequality bound smoothing (Crippen–Havel) and SDP relaxations are used to tighten bounds or detect contradictory restraints, where bugs can over-tighten and falsely rule out valid conformations.
* **What Lean proves:**
  * Soundness of triangle-inequality (Floyd–Warshall) bound smoothing: tightened bounds never exclude any valid 3D conformation.
  * Verification of **infeasibility certificates** proving that *no* 3D structure can simultaneously satisfy a conflicting set of experimental restraints.
* **Feasibility:** **Medium** (metric spaces, triangle inequalities, interval arithmetic).

### 9. Verified Force-Field Potentials & Analytical Gradient Correctness
* **Domain:** Molecular Dynamics (MD) & Physics-Based Scoring Functions
* **The problem:** Hand-derived analytical forces ($F = -\nabla E$) for complex terms (dihedrals, improper torsions, switching functions, soft-core FEP potentials, polarizable force fields) frequently contain sign or chain-rule errors that cause subtle energy drift in MD simulations.
* **What Lean proves:**
  * The implemented force formula equals the exact symbolic negative gradient $-\nabla E(x)$.
  * Conservation laws: Newton's third law ($\sum_i F_i = 0$) and zero net torque from translational/rotational invariance of $E$.
  * Continuity / $C^1$ smoothness across non-bonded cutoff switching regions.
* **Feasibility:** **Medium** (Mathlib calculus + automated differentiation checks; high payoff for custom force fields).

### 10. Verified MD Integrators & Statistical Mechanics Identities
* **Domain:** Molecular Simulation & Enhanced Sampling
* **The problem:** Long-timescale MD and free-energy estimators rely on delicate mathematical properties: symplectic integration, time-reversibility, and convex optimization of reweighting equations (WHAM / MBAR).
* **What Lean proves:**
  * Exact time-reversibility and phase-space volume preservation ($\det J = 1$, Liouville's theorem) for splitting integrators like Velocity Verlet or BAOAB.
  * Global convexity and uniqueness of the MBAR / WHAM free-energy minimum.
  * Formal derivations of Jarzynski / Crooks fluctuation identities under stated physical assumptions.
* **Feasibility:** **Medium–Frontier** (calculus, linear algebra, and measure/probability theory in Mathlib).

---

## Recommended Starting Pilots for `lean-bio`

Because `lean-bio` currently uses **core Lean 4 with zero external dependencies**, these three pilots are the fastest way to evaluate Lean in practice:

1. **Pilot A — Mini Chemical Graph & Reaction Conservation (Idea #2):** Extend the current `Base`/`Strand` style to atoms, bonds, valence checks, and a theorem that a reaction preserves atom counts and net charge.
2. **Pilot B — Tetrahedral Chirality Parity (Idea #1):** Model a tetrahedral stereocenter with 4 distinct priorities and prove that swapping any two ligands flips R $\leftrightarrow$ S while any even permutation preserves configuration.
3. **Pilot C — Goldstein's Dead-End Elimination Theorem (Idea #3):** Write a self-contained proof over integer/rational pairwise energy tables showing that a rotamer satisfying the Goldstein DEE inequality can never belong to the global minimum energy conformation (GMEC).
