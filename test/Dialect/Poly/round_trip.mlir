// CHECK-LABEL: func.func @roundtrip
func.func @roundtrip(%x: f64) -> f64 {
  // CHECK: %[[P:.*]] = poly.const {{.*}} : tensor<3xf64>
  %p = poly.const [3.0, 2.0, -1.0] : tensor<3xf64>
  // CHECK: poly.add %[[P]], %[[P]] : (tensor<3xf64>, tensor<3xf64>) -> tensor<3xf64>
  %s = poly.add %p, %p : (tensor<3xf64>, tensor<3xf64>) -> tensor<3xf64>
  // CHECK: poly.mul %[[P]], %[[P]] : (tensor<3xf64>, tensor<3xf64>) -> tensor<3xf64>
  %m = poly.mul %p, %p : (tensor<3xf64>, tensor<3xf64>) -> tensor<3xf64>
  // CHECK: poly.diff %[[P]] : (tensor<3xf64>) -> tensor<2xf64>
  %d = poly.diff %p : (tensor<3xf64>) -> tensor<2xf64>
  // CHECK: poly.eval %[[P]], %{{.*}} : (tensor<3xf64>, f64) -> f64
  %y = poly.eval %p, %x : (tensor<3xf64>, f64) -> f64
  return %y : f64
}
