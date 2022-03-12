def _py_binary_impl(ctx):
    """
    py_binary

    Args:
        ctx: Analysis context
    """
    script = ctx.actions.declare_file(ctx.label.name)
    runfiles = [script]
    
    return [DefaultInfo(
        executable = script,
        runfiles = ctx.runfiles(
            files = [script, interpreter],
            transitive_files = depset(runfiles),
        ),
    )]

py_binary = rule(
    implementation = _py_binary_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            doc = "Source files to compile",
        ),
        "deps": attr.label_list(
            doc = "Direct dependencies of the binary",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Data files available to binary at runtime",
        ),
        "_bash_runner_tpl": attr.label(
            default = "@dd_source//rules/python/py_binary:py_binary_runner.bash.tpl",
            doc = "Label denoting the bash runner template to use for the binary.",
            allow_single_file = True,
        ),
    },
    executable = True,
    toolchains = ["@bazel_tools//tools/python:toolchain_type"],
    doc = "Builds a Python executable from source files and dependencies.",
)
