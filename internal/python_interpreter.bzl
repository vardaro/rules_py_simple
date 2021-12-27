"""Repository rules for rules_py_simple"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

OSX_OS_NAME = "mac os x"
LINUX_OS_NAME = "linux"

def _py_build_hermetic_interpreter(rctx):
    """
    Downloads a Python distribution.

    Args:
        rtcx: Repository context struct.
    """
    os_name = rctx.os.name.lower()

    if os_name == OSX_OS_NAME:
        url = "https://github.com/indygreg/python-build-standalone/releases/download/20210228/cpython-3.8.8-x86_64-apple-darwin-pgo+lto-20210228T1503.tar.zst"
        integrity_shasum = "4c859311dfd677e4a67a2c590ff39040e76b97b8be43ef236e3c924bff4c67d2"
    elif os_name == LINUX_OS_NAME:
        url = "https://github.com/indygreg/python-build-standalone/releases/download/20210228/cpython-3.8.8-x86_64-unknown-linux-gnu-pgo+lto-20210228T1503.tar.zst"
        integrity_shasum = "74c9067b363758e501434a02af87047de46085148e673547214526da6e2b2155"
    else:
        fail("OS '{}' is not supported.".format(os_name))
    
    rctx.report_progress("downloading standalone python")
    rctx.download(
        url = [url],
        sha256 = integrity_shasum,
        output = "python.tar.zst",
    )
    
    rctx.report_progress("extracting compressed python")
    unzstd_bin_path = rctx.which("unzstd")
    if unzstd_bin_path == None:
        fail("On OSX and Linux this Python toolchain requires that the zstd and unzstd exes are available on the $PATH, but it was not found.")

    res = rctx.execute([unzstd_bin_path, "python.tar.zst"])
    if res.return_code:
        fail("Error decompressing with zstd" + res.stdout + res.stderr)

    rctx.extract(archive = "python.tar")
    rctx.delete("python.tar")
    rctx.delete("python.tar.zst")

    # NOTE: 'json' library is only available in Bazel 4.*.
    python_build_data = json.decode(rctx.read("python/PYTHON.json"))

    rctx.report_progress("generating BUILD.bazel file")
    BUILD_FILE_CONTENT = """
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
""".format(interpreter_path = python_build_data["python_exe"])

    rctx.file("BUILD.bazel", BUILD_FILE_CONTENT)

    return None

py_build_hermetic_interpreter = repository_rule(
    implementation = _py_build_hermetic_interpreter,
    attrs = {},
)
