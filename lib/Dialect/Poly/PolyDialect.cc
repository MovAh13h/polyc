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

LogicalResult DiffOp::verify() {
  auto operandLen = cast<RankedTensorType>(getPoly().getType()).getDimSize(0);
  auto resultLen = cast<RankedTensorType>(getResult().getType()).getDimSize(0);

  if (ShapedType::isDynamic(operandLen) || ShapedType::isDynamic(resultLen))
    return success();

  if (operandLen == 0)
    return emitOpError("cannot differentiate an empty polynomial");

  int64_t expected = operandLen == 1 ? 1 : operandLen - 1;
  if (resultLen != expected)
    return emitOpError("expected result length ")
           << expected << ", got " << resultLen;

  return success();
}

LogicalResult ConstOp::verify() {
    auto attrLen = getCoefficients().size();
    auto resultLen = cast<RankedTensorType>(getResult().getType()).getDimSize(0);

    if (ShapedType::isDynamic(resultLen))
        return success();

    if ((int64_t) attrLen != resultLen) {
        return emitOpError("coefficient count") << attrLen << " does not match result " << resultLen;
    }

    return success();
}
