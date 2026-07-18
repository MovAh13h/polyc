#include "polyc/Dialect/Poly/PolyDialect.h"

using namespace mlir;
using namespace mlir::poly;

#include "polyc/Dialect/Poly/PolyDialect.cc.inc"

void PolyDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "polyc/Dialect/Poly/PolyOps.cc.inc"
      >();
}

#define GET_OP_CLASSES
#include "polyc/Dialect/Poly/PolyOps.cc.inc"
