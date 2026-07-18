#ifndef POLYC_DIALECT_POLY_POLYDIALECT_H
#define POLYC_DIALECT_POLY_POLYDIALECT_H

#include "mlir/IR/Builders.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"

#include "polyc/Dialect/Poly/PolyDialect.h.inc"

#define GET_OP_CLASSES
#include "polyc/Dialect/Poly/PolyOps.h.inc"

#endif  // POLYC_DIALECT_POLY_POLYDIALECT_H
