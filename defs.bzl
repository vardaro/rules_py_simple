load("@rules_py_simple//internal:python_interpreter.bzl", _py_download = "py_download")
load("@rules_py_simple//internal:py_binary.bzl", _py_binary = "py_binary")
load("@rules_py_simple//internal:py_library.bzl", _py_library = "py_library")

py_download = _py_download
py_binary = _py_binary
py_library = _py_library
