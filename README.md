# polyc — an MLIR-based polynomial compiler

## Roadmap

Progressive milestones with per-step goals and acceptance criteria
live in [`ROADMAP.md`](ROADMAP.md). Summary:

| # | Milestone | Status |
|---|---|---|
| M0 | Project skeleton | ✅ done |
| M1 | Empty `poly` dialect registered | ✅ done |
| M2 | Core ops (`const`, `add`, `mul`, `eval`, `diff`) + round-trip | pending |
| M3 | Verifiers | pending |
| M4 | Canonicalization + folders | pending |
| M5 | Symbolic differentiation pass | pending |
| M6 | Lowering to `arith` (Horner) | pending |
| M7 | JIT + C++ header API | pending |
| M8 | Expression parser + `polyc` CLI | pending |
| M9 | Docs, examples, benchmark | pending |


## License

MIT.
