# polyc roadmap

Progressive, small-step goals for building polyc v0.1. Work top to
bottom. Each milestone lists:

- **Goal** — what you're building and why.
- **Steps** — the small moves inside the milestone.
- **Done when** — the acceptance criteria. If these hold, move on.
- **Refs** — which tutorial stage(s) to peek at when stuck.

Keep milestones committed independently — one commit (or a small
handful) per milestone makes the history readable.

---

## M0 — Project skeleton ✅

**Goal.** Empty repo with Bazel wiring, directory layout, README, and
LICENSE. Nothing to build yet.

**Done when.** `ls polyc/` shows the layout and `git status` is clean.

---

## M1 — Empty `poly` dialect + `polyc-opt`

**Goal.** Register a dialect named `poly` with zero ops. Wire up a
custom `mlir-opt`-style driver (`polyc-opt`) that loads it. This proves
tablegen + Bazel are wired correctly before you add any real code.

**Steps.**
1. `lib/Dialect/Poly/PolyDialect.td` — ODS `Dialect` definition (name
   = "poly", cppNamespace = "polyc::poly").
2. `include/polyc/Dialect/Poly/PolyDialect.h` — declares the dialect
   class + `#include` the tablegen'd decls.
3. `lib/Dialect/Poly/PolyDialect.cpp` — `initialize()` (empty for
   now), tablegen'd defs.
4. `lib/Dialect/Poly/BUILD.bazel` — `gentbl_cc_library` for the .td,
   `cc_library` for the dialect.
5. `tools/polyc-opt/polyc_opt.cpp` — a `main()` that registers the
   `poly` dialect + all upstream dialects and calls
   `mlir::MlirOptMain`.
6. `tools/polyc-opt/BUILD.bazel` — `cc_binary` depending on the
   dialect and `@llvm-project//mlir:MlirOptLib`.

**Done when.**
- `bazel build //tools/polyc-opt` succeeds.
- `bazel run //tools/polyc-opt -- --help | grep poly` shows `poly` in
  the registered dialects list.

**Refs.** Tutorial stage 01 (`stage01-empty-dialect/`).

---

## M2 — Core ops with round-trip

**Goal.** Add the five ops: `poly.const`, `poly.add`, `poly.mul`,
`poly.eval`, `poly.diff`. `polyc-opt` should parse and re-print a
hand-written `.mlir` file unchanged.

**Design notes.**
- Represent a polynomial value by a plain `tensor<Nxf64>` for v0.1 — no
  custom type needed yet (custom type is a M-later polish). Coefficients
  are **descending order of degree**: `[3.0, 2.0, -1.0]` means
  `3x² + 2x − 1`.
- `poly.const` takes a `DenseF64ArrayAttr` and returns a tensor.
- `poly.add`, `poly.mul` are binary, `Pure`, `Commutative`,
  `SameOperandsAndResultType` (both tensors, degrees may differ →
  result is the larger; verify in M3).
- `poly.eval` : `(tensor<Nxf64>, f64) -> f64`.
- `poly.diff` : `(tensor<Nxf64>) -> tensor<(N-1)xf64>`.

**Steps.**
1. `lib/Dialect/Poly/PolyOps.td` — one `Poly_Op` base, then the five
   ops with `arguments`, `results`, `assemblyFormat`, traits.
2. Wire ops into `PolyDialect.cpp` (`addOperations<...>()` in
   `initialize`).
3. `test/Dialect/Poly/round_trip.mlir` — one `func.func` exercising
   each op, plus a `RUN: polyc-opt %s | polyc-opt | FileCheck %s`
   line.
4. Extend `test/BUILD.bazel` with a `run_filecheck`-style rule (borrow
   from `common/test.bzl` in the tutorial).

**Done when.**
- Every op parses and prints cleanly.
- Round-trip test passes.

**Refs.** Tutorial stages 02, 03.

---

## M3 — Verifiers

**Goal.** Reject malformed IR at parse time with good error messages.

**Steps.**
1. `poly.add` / `poly.mul`: operand and result tensor element type
   must be `f64`. Trait `SameOperandsAndResultElementType` covers
   this — no custom verifier needed.
2. `poly.eval` : result type == operand-1 element type (both `f64`).
   Assembly format usually enforces this.
3. `poly.diff` : result tensor length == operand tensor length − 1
   (unless operand is length 0 or 1, then result is length 0 or a
   single `0.0`). This one needs `hasVerifier = 1` and a custom
   `verify()` in `PolyDialect.cpp`.
4. `test/Dialect/Poly/verify.mlir` — cases that must fail, using
   `--verify-diagnostics` and `// expected-error @+1 {{...}}`.

**Done when.**
- All positive tests still pass.
- Each malformed case fails with the expected error.

**Refs.** Tutorial stage 05.

---

## M4 — Canonicalization + folders

**Goal.** Trivial algebraic simplifications happen automatically under
`--canonicalize`. This is the "wow" milestone — you type IR and it
gets smaller.

**Steps.**
1. `lib/Dialect/Poly/PolyPatterns.td` — DRR patterns:
   - `poly.add(p, const[0.0]) → p`
   - `poly.mul(p, const[1.0]) → p`
   - `poly.mul(p, const[0.0]) → const[0.0]`
2. `getCanonicalizationPatterns` hooks on the ops (or `hasCanonicalizer`).
3. Folders (in `PolyDialect.cpp`):
   - `poly.add(const, const) → const` (add coefficient vectors).
   - `poly.mul(const, const) → const` (polynomial multiply — nested
     loop, O(n·m)).
   - `poly.diff(const) → const` (differentiate coefficients).
   - `poly.eval(const, const-scalar) → const-scalar` (Horner in the folder).
4. Tests: `test/Dialect/Poly/canonicalize.mlir`, `fold.mlir`.

**Done when.**
- `polyc-opt --canonicalize` on `add(x, const[0.0])` yields `x`.
- `polyc-opt --canonicalize` on `add(const[1,2], const[3,4])` yields
  `const[4,6]`.

**Refs.** Tutorial stages 06, 07.

---

## M5 — Symbolic differentiation pass

**Goal.** A named pass `--poly-differentiate` that eagerly evaluates
every `poly.diff` in the module by folding it into a `poly.const`
(via the M4 folder), even when the operand isn't a literal — as long
as it can be *made* constant by canonicalization first.

This one is small if M4 is solid: run canonicalize until fixed point,
then any remaining `poly.diff` on a non-const operand is a genuine
symbolic op we leave alone.

**Steps.**
1. `lib/Transforms/PolyPasses.td` — ODS pass declaration
   (`Poly_DifferentiatePass`).
2. `lib/Transforms/Differentiate.cpp` — runs
   `applyPatternsAndFoldGreedily` on a bundled pattern set (the
   canonicalizers plus the diff-of-const folder).
3. Register the pass in `polyc-opt`.
4. Test: `test/Transforms/differentiate.mlir`.

**Done when.** `polyc-opt --poly-differentiate` on a module built
from constants collapses all `poly.diff` ops to `poly.const`.

**Refs.** Tutorial stage 08.

---

## M6 — Lowering `poly.eval` to `arith` (Horner)

**Goal.** Convert `poly.eval` into an explicit chain of
`arith.mulf` + `arith.addf` implementing Horner's scheme. This is
what makes JIT-compiled evaluation fast — no loops, no loads, fully
inlined.

For a polynomial `[a_n, ..., a_1, a_0]` and point `x`, Horner is:

```
acc = a_n
acc = acc*x + a_{n-1}
acc = acc*x + a_{n-2}
...
acc = acc*x + a_0
```

**Steps.**
1. `lib/Conversion/PolyToArith.cpp` — `OpConversionPattern` for
   `poly.eval` on a `poly.const` producer: unroll Horner directly.
   (Requires the operand chain to have been canonicalized first —
   document that.)
2. Pass `--convert-poly-to-arith` with a `ConversionTarget` that
   marks `poly` as illegal, `arith` as legal.
3. Tests: `test/Conversion/poly_to_arith.mlir`,
   `full_pipeline.mlir` (canonicalize → differentiate →
   convert-to-arith).

**Done when.** `polyc-opt --canonicalize --poly-differentiate
--convert-poly-to-arith` on any `poly.eval` of a literal polynomial
produces pure `arith` output with the Horner shape.

**Refs.** Tutorial stage 09.

---

## M7 — JIT + C++ header API

**Goal.** `polyc::JIT::compile({3.0, 2.0, -1.0})` returns a
`std::function<double(double)>` that runs the JIT-compiled evaluator.
This is the user-facing library API.

**Steps.**
1. `include/polyc/JIT.h` — declares
   ```cpp
   namespace polyc {
   class JIT {
   public:
     static std::function<double(double)> compile(
         std::vector<double> descending_coefficients);
   };
   }
   ```
2. `lib/JIT/JIT.cpp` — internally:
   - Build an `MLIRModule` containing a `func.func @poly_eval(f64) ->
     f64` whose body is `poly.const` + `poly.eval` on the argument.
   - Run the pipeline from M6, then `--convert-arith-to-llvm`,
     `--convert-func-to-llvm`, `--reconcile-unrealized-casts`.
   - Hand off to `mlir::ExecutionEngine::create` and look up
     `poly_eval`.
   - Wrap the raw function pointer in a `std::function`.
3. `examples/eval.cpp` — the README's C++ snippet, actually running.
4. `test/JIT/end_to_end.cpp` — GTest checking a few coefficient
   vectors evaluate correctly.

**Done when.** `bazel run //examples:eval` prints `15.0` for
`3x² + 2x − 1` at `x = 2.0`.

**Refs.** Tutorial stages 10, 11.

---

## M8 — Expression parser + `polyc` CLI

**Goal.** Take a string like `"3x^2 + 2x - 1"` on the command line and
plumb it end-to-end.

**Steps.**
1. `lib/Parse/PolyParser.cpp` — recursive-descent parser over a small
   grammar (`term = coefficient? "x" ("^" integer)?`, terms joined by
   `+`/`-`). Return `std::vector<double>` in descending order.
2. `tools/polyc/polyc.cpp` — CLI with flags:
   - `polyc "<expr>"` (default: print MLIR)
   - `--eval <x>` — JIT and evaluate.
   - `--diff` — apply `--poly-differentiate` and print the resulting
     polynomial in human form.
   - `--emit=mlir|llvm` — dump IR at a chosen pipeline stage.
3. `test/tools/polyc/` — golden-output tests using `FileCheck`.

**Done when.** Every command in the README's "Quickstart" block
produces the shown output.

---

## M9 — Docs, examples, benchmark

**Goal.** Ship-ready polish. Someone landing on the GitHub repo should
be running `polyc` in under 5 minutes.

**Steps.**
1. Fill in `docs/getting-started.md` with real command output.
2. Fill in `docs/dialect.md` with the finalised op signatures.
3. `examples/` — one file per feature (eval, diff, print-mlir).
4. `bench/eval_bench.cpp` — compare polyc JIT vs a naive C++
   `std::pow` loop vs a hand-Horner C++ loop on `1e7` evaluations of
   a degree-10 polynomial.
5. Tag `v0.1.0`.

**Done when.** README quickstart works from a fresh clone on a
different machine.

---

## Post-v0.1 ideas (do not build now)

- Parametric coefficient type: `!poly.poly<f32>`, `!poly.poly<i64>`.
- Multivariate polynomials (`poly.mvpoly` or generalise the type).
- Numerical root-finding (`poly.roots` — Durand-Kerner).
- Python bindings via pybind11 → `pip install polyc`.
- SIMD/vectorization pass for batch evaluation of many x's.
