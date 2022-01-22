def _py_binary_impl(ctx):
    """
    Implements py_binary.

    Produces an executable artifact in the form of a Python launcher script.
    The launcher script creates a subprocess of the hermetic runtime within the runfile tree, where the users code runs.

    Args:
        ctx: Analysis context.

    Returns:
        DefaultInfo provider containing the executable and corresponding runfiles.
    """
    executable = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(executable, "Hello", is_executable = True)

    # Query the Python runtime
    py_toolchain = ctx.toolchains["@bazel_tools//tools/python:toolchain_type"]

    return [
        DefaultInfo(
            files = depset([executable]),
            runfiles = ctx.runfiles(collect_data = True),
            executable = executable,
        ),
    ]

py_binary = rule(
    _py_binary_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".py"],
            doc = "Source files to compile.",
        ),
        "deps": attr.label_list(
            doc = "Direct dependencies of the binary.",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Data files available to this binary at runtime.",
        ),
    },
    doc = "Builds an executable program from Python source code",
    executable = True,

    # All toolchains of this alias propagate to this rule.
    # This is how Bazel knows to include our hermetic runtime in the analysis context.
    toolchains = ["@bazel_tools//tools/python:toolchain_type"],
)
