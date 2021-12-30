"""Repository rules for rules_py_simple"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

OSX_OS_NAME = "mac os x"
LINUX_OS_NAME = "linux"

def _py_download(rctx):
    """
    Downloads and builds a Python distribution.

    The Python distribution we've selected ships as a .zst, so we need zstandard to decompress the archive.
    This is annoying because rctx.download_and_extract() doesn't natively support zstd.
    We need to download the Python archive and manually decompress it using a prebuilt zstd binary.

    Although we could rely on the system installation of zstd (whatever the command "which zstd" points to), doing so is undesireable as it introduces flakiness in our build and adds an unnecessary dependency on the host.
    It's preferable that we download a prebuilt zstd artifact so everyone's on the same page.
    
    No windows support (sorry)

    Args:
        rtcx: Repository context.
    """
    os_name = rctx.os.name.lower()
    if os_name == OSX_OS_NAME:
        url = "https://github.com/indygreg/python-build-standalone/releases/download/20211017/cpython-3.10.0-x86_64-apple-darwin-install_only-20211017T1616.tar.gz"
        integrity_shasum = "fc0d184feb6db61f410871d0660d2d560e0397c36d08b086dfe115264d1963f4"

    elif os_name == LINUX_OS_NAME:
        url = "https://github.com/indygreg/python-build-standalone/releases/download/20210228/cpython-3.8.8-x86_64-unknown-linux-gnu-pgo+lto-20210228T1503.tar.zst"
        integrity_shasum = "74c9067b363758e501434a02af87047de46085148e673547214526da6e2b2155"

    else:
        fail("OS '{}' is not supported.".format(os_name))

    rctx.report_progress("downloading python...")
    rctx.download_and_extract(
        url = [url],
        sha256 = integrity_shasum,
    )
    
    # Our Python distribution generates a PYTHON.json file that contains useful fun facts about our build.
    # We can use this to extract the path to our python executable.
    # python_build_data = json.decode(rctx.read("python/PYTHON.json"))

    # Generate build targets for Python. This gets dropped in the WORKSPACE level BUILD.bazel for our new repo.
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

sh_binary(
    name = "python_interpreter",
    srcs = ["python/{interpreter_path}"],
    visibility = ["//visibility:public"],
)
""".format(interpreter_path = "bin/python3.10")
    rctx.file("BUILD.bazel", BUILD_FILE_CONTENT)

    return None

py_download = repository_rule(
    implementation = _py_download,
    attrs = {
        "_zstd_bin": attr.label(
            default = "@com_github_facebook_zstd//:zstd",
            doc = "Label type denoting an executable file target to a pre-built zstd binary.",
        ),
    },
)
