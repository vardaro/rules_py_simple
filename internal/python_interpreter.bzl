"""Repository rules for rules_py_simple"""

def _py_download(ctx):
    """
    Downloads and builds a Python distribution.

    The Python distribution we've selected ships as a .zst, so we need zstandard to decompress the archive.
    This is annoying because rctx.download_and_extract() doesn't natively support zstd.
    We need to download the Python archive and manually decompress it using a prebuilt zstd binary.

    Although we could rely on the system installation of zstd (whatever the command "which zstd" points to), doing so is undesireable as it introduces flakiness in our build and adds an unnecessary dependency on the host.
    It's preferable that we download a prebuilt zstd artifact so everyone's on the same page.
    
    No windows support (sorry)

    Args:
        ctx: Repository context.
    """
    rctx.report_progress("downloading python...")
    rctx.download_and_extract(
        url = ctx.attr.urls,
        sha256 = ctx.attr.sha256,
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
        "urls": attr.string_list(
            mandatory = True,
            doc = "String list of mirror URLs where the Python distribution can be downloaded.",
        ),
        "sha256": attr.string(
            mandatory = True,
            doc = "Exepcted SHA-256 sum of the archive.",
        ),
        "os": attr.string(
            mandatory = True,
            values = ["darwin", "linux", "windows"],
            doc = "Host operating system.",
        ),
        "arch": attr.string(
            mandatory = True,
            values = ["amd64", "x64_64"],
            doc = "Host architecture.",
        ),
        "bin_path": attr.string(
            default = "python/bin/python3",
            doc = "Path you'd expect the python interpreter binary to live."
        )
        "_build_tpl": attr.label(
            default = "@rules_py_simple//internal:BUILD.dist.bazel.tpl",
            doc = "Label denoting the BUILD file template that get's installed in the repo."
        )
    },
)
