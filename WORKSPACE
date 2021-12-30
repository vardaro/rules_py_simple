workspace(
    name = "rules_py_simple",
)

load("@rules_py_simple//internal:python_interpreter.bzl", "py_download")

py_download(
    name = "py_darwin_x86_64",
    arch = "x86_64",
    os = "darwin",
    sha256 = "fc0d184feb6db61f410871d0660d2d560e0397c36d08b086dfe115264d1963f4",
    urls = ["https://github.com/indygreg/python-build-standalone/releases/download/20211017/cpython-3.10.0-x86_64-apple-darwin-install_only-20211017T1616.tar.gz"],
)

py_download(
    name = "py_linux_x86_64",
    arch = "x86_64",
    os = "linux",
    sha256 = "eada875c9b39cc4bf4a055dd8f5188e99c0c90dd5deb05b6c213f49482fe20a6",
    urls = ["https://github.com/indygreg/python-build-standalone/releases/download/20211017/cpython-3.10.0-x86_64-unknown-linux-gnu-install_only-20211017T1616.tar.gz"],
)

py_runtime(
    name = "py_darwin_x86_64_runtime",
    files = ["@py_darwin_x86_64//:files"],
    interpreter = "@py_darwin_x86_64//:interpreter",
    python_version = "PY3",
    visibility = ["//visibility:public"],
)

py_runtime(
    name = "py_linux_x86_64_runtime",
    files = ["@py_linux_x86_64//:files"],
    interpreter = "@py_linux_x86_64//:interpreter",
    python_version = "PY3",
    visibility = ["//visibility:public"],
)

register_toolchains(
    "@py_darwin_x86_64//:toolchain",
    "@py_linux_x86_64//:toolchain",
)

