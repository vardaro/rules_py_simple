workspace(
    name = "rules_py_simple",
)

load("@rules_py_simple//internal:python_interpreter.bzl", "py_build_hermetic_interpreter")

py_build_hermetic_interpreter(
    name = "python_interpreter",
)

register_toolchains("@rules_py_simple//:py_toolchain")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Fun http_archive hack to register zstd as a Bazel rule (so build targets can depend on it).
http_archive(
    name = "com_github_facebook_zstd",
    urls = [
        "https://github.com/facebook/zstd/releases/download/v1.5.1/zstd-1.5.1.tar.gz"
    ],
    sha256 = "e28b2f2ed5710ea0d3a1ecac3f6a947a016b972b9dd30242369010e5f53d7002",
    # Hoist everything up one level.
    strip_prefix = "zstd-1.5.1",
    patch_cmds = [
        # Build zstd.
        "make",
    ],
    # zstd is the name of binary produced from running "make"
    # therefore we export it so the pre-compiled binary can be dependency for a build target.
    build_file_content = """
exports_files(["zstd"])

filegroup(
    name = "files",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"],
)

""",
)
