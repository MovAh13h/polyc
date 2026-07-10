# The `poly` dialect

Draft — filled in as ops land. See `include/polyc/Dialect/Poly/PolyOps.td`
for the source of truth.

## Types

- `!poly.poly` — a univariate polynomial with `f64` coefficients,
  stored in descending order of degree. (v0.1: shape is inferred from
  the constant attribute; a parametric `!poly.poly<T, degree>` may
  arrive later.)

## Ops

| Op | Signature | Notes |
|---|---|---|
| `poly.const` | `() -> !poly.poly` | Literal polynomial via a `DenseF64ArrayAttr`. |
| `poly.add` | `(!poly.poly, !poly.poly) -> !poly.poly` | Commutative. |
| `poly.mul` | `(!poly.poly, !poly.poly) -> !poly.poly` | Commutative. |
| `poly.eval` | `(!poly.poly, f64) -> f64` | Evaluate at a point (Horner). |
| `poly.diff` | `(!poly.poly) -> !poly.poly` | Symbolic derivative. |

## Passes

- `--canonicalize` — DRR: `add(p, 0) = p`, `mul(p, 1) = p`, `mul(p, 0) = 0`.
- Folders — constant-folds `add`/`mul`/`diff` when all operands are `poly.const`.
- `--poly-differentiate` — eagerly materialises `poly.diff` into a `poly.const`.
- `--convert-poly-to-arith` — lowers `poly.eval` to a Horner-scheme chain of `arith` ops.
