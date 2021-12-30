filegroup(
    name = "files",
    srcs = glob(["install/**"], exclude = ["**/* *"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "interpreter",
    srcs = ["python/{interpreter_path}"],
    visibility = ["//visibility:public"],
)

py_runtime(
    name = "py_runtime",
    files = [":files"],
    interpreter = ":interpreter",
    python_version = "PY3",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "toolchain",
    exec_compatible_with = [
	{exec_constraints},
    ],
    target_compatible_with = [
	{target_constraints},
    ],
    toolchain = ":py_runtime",
    toolchain_type = "@rules_py_simple//:python_toolchain_type",
)
