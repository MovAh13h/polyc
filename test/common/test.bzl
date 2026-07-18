"""Reusable test macros for polyc.

Everything a `test/**/BUILD.bazel` needs to spin up a lit-style test
lives here. Concrete .mlir tests should never touch shell scripts or
sh_test directly.
"""

def polyc_roundtrip_test(name, src):
    """Runs `polyc-opt src | polyc-opt | FileCheck src`.

    Args:
      name: the test target name.
      src: a .mlir file containing input IR plus `// CHECK*` directives
        describing the expected canonical printed form.
    """
    native.sh_test(
        name = name,
        srcs = ["//test/common:run_roundtrip.sh"],
        args = [
            "$(location //tools/polyc-opt)",
            "$(location @llvm-project//llvm:FileCheck)",
            "$(location {})".format(src),
        ],
        data = [
            src,
            "//tools/polyc-opt",
            "@llvm-project//llvm:FileCheck",
        ],
    )
