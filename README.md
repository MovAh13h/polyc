# polyc — an MLIR-based polynomial compiler

`polyc` compiles univariate polynomials into fast native code via MLIR
and LLVM. Hand it a polynomial once; get back a JIT-compiled evaluator
that's competitive with hand-written C. It also does symbolic
differentiation and algebraic simplification as MLIR passes.

> **Status:** early. v0.1 is under construction — see the roadmap
> below. Not yet released.

## Quickstart (target UX)

**CLI:**

```bash
# Evaluate at a point.
polyc "3x^2 + 2x - 1" --eval 2.0
# 15.0

# Differentiate symbolically.
polyc "3x^2 + 2x - 1" --diff
# 6x + 2

# Inspect the MLIR at any stage of the pipeline.
polyc "3x^2 + 2x - 1" --emit=mlir
polyc "3x^2 + 2x - 1" --emit=llvm
```

**C++ library:**

```cpp
#include "polyc/JIT.h"

int main() {
  // Coefficients in descending order: 3x^2 + 2x - 1
  auto eval = polyc::JIT::compile({3.0, 2.0, -1.0});
  double y = eval(2.0);   // 15.0
}
```

## Why?

- **Fast evaluation.** MLIR lowers `poly.eval` to Horner's method in
  the `arith` dialect, then LLVM autovectorises and inlines. The
  compiled code is specialised to *your* coefficients — no dispatch,
  no coefficient loads.
- **Symbolic passes for free.** Because polynomials live in a proper
  IR, canonicalization, folding, and differentiation are just rewrite
  patterns and passes.

## Roadmap

Progressive milestones with per-step goals and acceptance criteria
live in [`ROADMAP.md`](ROADMAP.md). Summary:

| # | Milestone | Status |
|---|---|---|
| M0 | Project skeleton | ✅ done |
| M1 | Empty `poly` dialect registered | pending |
| M2 | Core ops (`const`, `add`, `mul`, `eval`, `diff`) + round-trip | pending |
| M3 | Verifiers | pending |
| M4 | Canonicalization + folders | pending |
| M5 | Symbolic differentiation pass | pending |
| M6 | Lowering to `arith` (Horner) | pending |
| M7 | JIT + C++ header API | pending |
| M8 | Expression parser + `polyc` CLI | pending |
| M9 | Docs, examples, benchmark | pending |

Beyond v0.1: parametric coefficient types, multivariate polynomials,
rational-root finding, Python bindings.

## Layout

```
polyc/
├── include/polyc/         public headers — this is what you #include
├── lib/                   implementation
│   ├── Dialect/Poly/      the poly dialect
│   ├── Transforms/        canonicalization, differentiation passes
│   ├── Conversion/        lowering to arith / LLVM
│   └── JIT/               ExecutionEngine wrapper
├── tools/
│   ├── polyc/             the CLI
│   └── polyc-opt/         mlir-opt-style driver, for tests
├── examples/              small runnable C++ programs
├── test/                  lit tests, mirrors lib/ structure
└── docs/                  dialect reference, tutorial
```

## License

MIT.
