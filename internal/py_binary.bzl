def _py_binary_impl(ctx):
    """
    py_binary implementation
    
    Produces a bash script for launching a Python binary using the toolchain
    registered in "@bazel_tools//tools/python:toolchain_type".

    Args:
        ctx: Analysis context
    """
    executable = ctx.actions.declare_file(ctx.label.name)
    interpreter = ctx.toolchains["@bazel_tools//tools/python:toolchain_type"].py3_runtime.interpreter

    dep_targets = ctx.attr.deps + ctx.attr.data + ctx.attr.srcs
    dep_files = [ctx.file.main, executable, interpreter, ctx.file._bash_runfile_helper]

    # Append the output of this rule, the toolchain, and direct
    # dependencies of this target to the accumulating runfile tree
    runfiles = ctx.runfiles(files = dep_files)
    runfiles = runfiles.merge_all([
        target[DefaultInfo].default_runfiles
        for target in dep_targets
    ])

    # Chop off the "../" bit from the short_path of the toolchain
    # so "rlocation" can parse the path to the python3 executable properly
    interpreter_path = interpreter.short_path.replace("../", "")
    py_binary_entry = "{workspace_name}/{entrypoint_path}".format(
        workspace_name = ctx.workspace_name,
        entrypoint_path = ctx.file.main.short_path,
    )

    substitutions = {
        "{interpreter_path}": interpreter_path,
        "{py_binary_entry}": py_binary_entry,
    }

    ctx.actions.expand_template(
        template = ctx.file._bash_runner_tpl,
        output = executable,
        substitutions = substitutions,
    )

    return [DefaultInfo(
        executable = executable,
        runfiles = runfiles,
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
        "main": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "Label denoting the entrypoint of the binary",
        ),
        "_bash_runner_tpl": attr.label(
            default = "@rules_py_simple//internal:py_binary_runner.bash.tpl",
            doc = "Label denoting the bash runner template to use for the binary",
            allow_single_file = True,
        ),
        "_bash_runfile_helper": attr.label(
            default = "@bazel_tools//tools/bash/runfiles",
            doc = "Label pointing to bash runfile helper",
            allow_single_file = True,
        ),
    },
    executable = True,
    toolchains = ["@bazel_tools//tools/python:toolchain_type"],
    doc = "Builds a Python executable from source files and dependencies.",
)
