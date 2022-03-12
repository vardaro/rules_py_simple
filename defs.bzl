load("@rules_py_simple//internal:python_interpreter", _py_download = "py_download")
load("@rules_py_simple//internal:py_binary", _py_binary = "py_binary")

py_download = _py_download
py_binary = _py_binary
