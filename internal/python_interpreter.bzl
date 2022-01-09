"""Repository rules for rules_py_simple"""

_OS_MAP = {
        "darwin": "@platforms//os:osx",
        "linux": "@platforms//os:linux",
        "windows": "@platforms//os:windows",
}

_ARCH_MAP = {
        "x86_64": "@platforms//cpu:x86_64",
}

def _py_download(ctx):
    """
    Downloads and builds a Python distribution.

    The Python distribution we've selected ships as a .zst, so we need zstandard to decompress the archive.
    This is annoying because ctx.download_and_extract() doesn't natively support zstd.
    We need to download the Python archive and manually decompress it using a prebuilt zstd binary.

    Although we could rely on the system installation of zstd (whatever the command "which zstd" points to), doing so is undesireable as it introduces flakiness in our build and adds an unnecessary dependency on the host.

    Args:
        ctx: Repository context.
    """
    ctx.report_progress("downloading python")
    ctx.download_and_extract(
        url = ctx.attr.urls,
        sha256 = ctx.attr.sha256,
        stripPrefix = "python",
    )
    
    ctx.report_progress("generating build file") 
    os_constraint = _OS_MAP[ctx.attr.os]
    arch_constraint = _ARCH_MAP[ctx.attr.arch]

    constraints = [os_constraint, arch_constraint]
    
    # So Starlark doesn't throw an indentation error when this gets injected.
    constraints_str = ",\n        ".join(['"%s"' % c for c in constraints])

    substitutions = {
        "{constraints}": constraints_str,
        "{interpreter_path}": ctx.attr._interpreter_path,
    }

    ctx.template(
        "BUILD.bazel",
        ctx.attr._build_tpl,
        substitutions = substitutions,
    )

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
            doc = "Expected SHA-256 sum of the archive.",
        ),
        "os": attr.string(
            mandatory = True,
            values = ["darwin", "linux", "windows"],
            doc = "Host operating system.",
        ),
        "arch": attr.string(
            mandatory = True,
            values = ["x86_64"],
            doc = "Host architecture.",
        ),
        "_interpreter_path": attr.string(
            default = "bin/python3",
            doc = "Path you'd expect the python interpreter binary to live.",
        ),
        "_build_tpl": attr.label(
            default = "@rules_py_simple//internal:BUILD.dist.bazel.tpl",
            doc = "Label denoting the BUILD file template that get's installed in the repo.",
        )
    },
)
