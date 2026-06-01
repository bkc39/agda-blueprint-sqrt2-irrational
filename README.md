# √2 is irrational

A small, fully formalized Agda proof that **√2 is irrational**, presented as an
interactive [agdablueprint](https://github.com/bkc39/agdablueprint) dependency
graph with clickable links into the proof source.

**Live site:** https://bkc39.github.io/agda-blueprint-sqrt2-irrational/

## What it proves

`src/Sqrt2.agda` (checked with `--safe`, so no postulates or holes):

```agda
sqrt2-irrational : (r : Rational) → ¬ (Rational* r r r= 2)
```

i.e. no rational number squares to 2.

The heavy lifting is Shinji Kono's general theorem that **no rational squares to
a prime** (`root2.root-prime-irrational1` in
[`automaton-in-agda`](https://github.com/shinji-kono/automaton-in-agda)). This
repo adds only the specialization to `p = 2`: a proof that `2` is prime
(`prime2`), and the one-line instantiation

```agda
sqrt2-irrational = root-prime-irrational1 2 prime2
```

`automaton-in-agda` is pulled in via Nix as an Agda library; we depend on it, we
don't vendor it.

## Build it locally

Everything runs in the Nix dev shell (provides agda + standard-library +
automaton-in-agda, graphviz, kpsewhich, and the agdablueprint CLI):

```sh
nix develop
agdablueprint web         # build blueprint/web/ (the dependency graph)
agdablueprint checkdecls  # verify every \agda{…} resolves in the Agda code
agda --html --html-dir=blueprint/web/agda src/Sqrt2.agda   # clickable source
agdablueprint serve       # preview at http://localhost:8000/
```

CI (`.github/workflows/blueprint.yml`) runs the same steps and deploys
`blueprint/web/` to GitHub Pages on every push to `main`.

> **First-time setup:** in the repo's *Settings → Pages*, set the source to
> **"GitHub Actions"** so the deploy workflow can publish.

## Credits

The irrationality proof is from
[`automaton-in-agda`](https://github.com/shinji-kono/automaton-in-agda) by
Shinji Kono (MIT). The blueprint tooling is
[`agdablueprint`](https://github.com/bkc39/agdablueprint). This repository is
MIT-licensed.
