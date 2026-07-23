// Negative: diff on length-3 must produce length-2, not length-3.
func.func @diff_wrong_length(%p: tensor<3xf64>) {
  // expected-error @+1 {{expected result length 2, got 3}}
  %d = poly.diff %p : (tensor<3xf64>) -> tensor<3xf64>
  return
}

// -----

// Negative: diff on length-1 (constant) must produce length-1 ([0.0]).
func.func @diff_constant_wrong_length(%p: tensor<1xf64>) {
  // expected-error @+1 {{expected result length 1, got 0}}
  %d = poly.diff %p : (tensor<1xf64>) -> tensor<0xf64>
  return
}

// -----

// Positive: diff on constant polynomial → length-1 result is legal.
func.func @diff_constant_ok(%p: tensor<1xf64>) {
  %d = poly.diff %p : (tensor<1xf64>) -> tensor<1xf64>
  return
}

// -----

// Positive: standard diff shrinks length by one.
func.func @diff_ok(%p: tensor<4xf64>) {
  %d = poly.diff %p : (tensor<4xf64>) -> tensor<3xf64>
  return
}

// -----

// Positive: dynamic shapes bypass the static length check.
func.func @diff_dynamic(%p: tensor<?xf64>) {
  %d = poly.diff %p : (tensor<?xf64>) -> tensor<?xf64>
  return
}

// -----

// Negative: coefficient count must match declared tensor length.
func.func @const_length_mismatch() {
  // expected-error @+1 {{coefficient count 2 does not match result tensor length 3}}
  %p = poly.const [1.0, 2.0] : tensor<3xf64>
  return
}

// -----

// Positive: matching lengths are accepted.
func.func @const_ok() {
  %p = poly.const [3.0, 2.0, -1.0] : tensor<3xf64>
  return
}
