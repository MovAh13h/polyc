#ifndef POLYC_DIALECT_POLY_POLYDIALECT_TD
#define POLYC_DIALECT_POLY_POLYDIALECT_TD

include "mlir/IR/BuiltinTypes.td"
include "mlir/IR/OpBase.td"
include "mlir/Interfaces/SideEffectInterfaces.td"

def Poly_Dialect: Dialect {
  let name = "poly";
  let summary = "The core polynomial dialect";
  let cppNamespace = "::mlir::poly";
}

def PolyTensor : TensorRankOf<[F64], [1]>;

class Poly_Op<string mnemonic, list<Trait> traits = []> : Op<Poly_Dialect, mnemonic, traits>;

def Poly_ConstOp: Poly_Op<"const", [Pure]> {
  let summary = "Polynomial equation";
  let arguments = (ins DenseF64ArrayAttr:$coefficients);
  let results = (outs PolyTensor:$result);
  let assemblyFormat = "$coefficients attr-dict `:` type($result)";
  let hasVerifier = 1;
}

def Poly_AddOp: Poly_Op<"add", [Pure, Commutative]> {
  let arguments = (ins PolyTensor:$lhs, PolyTensor:$rhs);
  let results = (outs PolyTensor:$result);
  let assemblyFormat = "$lhs `,` $rhs attr-dict `:` functional-type(operands, results)";
}

def Poly_MulOp: Poly_Op<"mul", [Pure, Commutative]> {
  let arguments = (ins PolyTensor:$lhs, PolyTensor:$rhs);
  let results = (outs PolyTensor:$result);
  let assemblyFormat = "$lhs `,` $rhs attr-dict `:` functional-type(operands, results)";
}

def Poly_EvalOp: Poly_Op<"eval", [Pure]> {
  let summary = "Evaluate a polynomial at a point";
  let arguments = (ins PolyTensor:$poly, F64:$point);
  let results = (outs F64:$result);
  let assemblyFormat = "$poly `,` $point attr-dict `:` functional-type(operands, results)";
}

def Poly_DiffOp: Poly_Op<"diff", [Pure]> {
  let summary = "Symbolic derivative of a polynomial";
  let arguments = (ins PolyTensor:$poly);
  let results = (outs PolyTensor:$result);
  let assemblyFormat = "$poly attr-dict `:` functional-type(operands, results)";
  let hasVerifier = 1;
}

#endif  // POLYC_DIALECT_POLY_POLYDIALECT_TD
