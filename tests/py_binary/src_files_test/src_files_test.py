load("@rules_py_simple//:defs.bzl", "py_binary")

py_binary(
	name = "src_files_tests",
	srcs = ["src_files_tests.py"],
	visibility = ["//visibility:public"],
)
