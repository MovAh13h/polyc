# Getting started

Draft — will be fleshed out as milestones land.

## Prerequisites

- Bazel ≥ 7
- A C++17 compiler (clang or gcc)
- ~30 min for the first build (LLVM/MLIR compile)

## Build

```bash
bazel build //...
bazel test  //...
```

## Use from the command line

```bash
bazel run //tools/polyc -- "3x^2 + 2x - 1" --eval 2.0
```

## Use from C++

Depend on `//include/polyc/JIT:JIT` in your `BUILD.bazel`, then:

```cpp
#include "polyc/JIT.h"

auto eval = polyc::JIT::compile({3.0, 2.0, -1.0});
double y = eval(2.0);
```
