#ifndef POLYC_DIALECT_POLY_POLYDIALECT_TD
#define POLYC_DIALECT_POLY_POLYDIALECT_TD

include "mlir/IR/OpBase.td"

def PolyDialect: Dialect {
  let name = "poly";
  let summary = "The core polynomial dialect";
  let cppNamespace = "::mlir::poly";
}

#endif  // POLYC_DIALECT_POLY_POLYDIALECT_TD
