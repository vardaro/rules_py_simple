"""Repository rules for rules_py_simple"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

OSX_OS_NAME = "mac os x"
LINUX_OS_NAME = "linux"

def _py_build_hermetic_interpreter(rctx):
    """
    Downloads and builds a Python distribution.

    Because the Python we're building ships in the .zst format, we need to download and build zstd from source.
    Otherwise, there's a dependency on the host machine (which may not have zstd installed).

    No windows support (sorry)

    Args:
        rtcx: Repository context.
    """

    # Downlaod python
    os_name = rctx.os.name.lower()

    if os_name == OSX_OS_NAME:
        url = "https://github.com/indygreg/python-build-standalone/releases/download/20210228/cpython-3.8.8-x86_64-apple-darwin-pgo+lto-20210228T1503.tar.zst"
        integrity_shasum = "4c859311dfd677e4a67a2c590ff39040e76b97b8be43ef236e3c924bff4c67d2"

    elif os_name == LINUX_OS_NAME:
        url = "https://github.com/indygreg/python-build-standalone/releases/download/20210228/cpython-3.8.8-x86_64-unknown-linux-gnu-pgo+lto-20210228T1503.tar.zst"
        integrity_shasum = "74c9067b363758e501434a02af87047de46085148e673547214526da6e2b2155"

    else:
        fail("OS '{}' is not supported.".format(os_name))

    rctx.report_progress("downloading python...")
    rctx.download(
        url = [url],
        sha256 = integrity_shasum,
        output = "python.tar.zst",
    )

    # Download zstd, build it, and collect the path to the zstd binary.
    rctx.download_and_extract(
        url = ["https://github.com/facebook/zstd/releases/download/v1.5.1/zstd-1.5.1.tar.gz"],
        sha256 = "e28b2f2ed5710ea0d3a1ecac3f6a947a016b972b9dd30242369010e5f53d7002",
    )

    rctx.report_progress("building zstd...")
    res = rctx.execute(
        [
            "make",
        ],
        working_directory = "zstd-1.5.1",
    )

    if res.return_code:
        fail("Error building zstd from source: " + res.stdout + res.stderr)

    zstd_bin_path = "zstd-1.5.1/zstd"

    rctx.report_progress("decompressing python... ")
    res = rctx.execute([
        zstd_bin_path,
        "-d",
        "python.tar.zst",
    ])

    if res.return_code:
        fail("Error decompressing with zstd: " + res.stdout + res.stderr)

    rctx.extract(archive = "python.tar")
    rctx.delete("python.tar")
    rctx.delete("python.tar.zst")
    rctx.delete("zstd-1.5.1")

    python_build_data = json.decode(rctx.read("python/PYTHON.json"))

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
