def _py_binary_impl(ctx):
    """
    py_binary

    Args:
        ctx: Analysis context
    """
    executable = ctx.actions.declare_file(ctx.label.name)
    runfiles = [executable]
    interpreter = ctx.toolchains["@bazel_tools//tools/python:toolchain_type"].py3_runtime.interpreter
    print(interpreter.path)

    ctx.actions.expand_template(
        template = ctx.file._bash_runner_tpl,
        output = executable,
        substitutions = {},
    )

    return [DefaultInfo(
        executable = executable,
        runfiles = ctx.runfiles(
            files = [executable, interpreter],
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
            default = "@rules_py_simple//internal:py_binary_runner.bash.tpl",
            doc = "Label denoting the bash runner template to use for the binary",
            allow_single_file = True,
        ),
    },
    executable = True,
    toolchains = ["@bazel_tools//tools/python:toolchain_type"],
    doc = "Builds a Python executable from source files and dependencies.",
)
