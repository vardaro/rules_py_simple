workspace(
    name = "rules_py_simple",
)

load("@rules_py_simple//internal:python_interpreter.bzl", "py_build_hermetic_interpreter")

py_build_hermetic_interpreter(
    name = "python_interpreter",
)

register_toolchains("@rules_py_simple//:py_toolchain")

