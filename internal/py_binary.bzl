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

    # File targets to be included in runfile object (i.e. the default ouputs)
    files = [
        ctx.file.main,
        executable,
        interpreter,
        ctx.file._bash_runfile_helper,
    ]

    files.extend(ctx.files.srcs)
    files.extend(ctx.files.data)

    # Merge the current runfiles objects with all of the
    # transitive runfile trees (all of which would return the
    # requested DefaultInfo provider)
    runfiles = ctx.runfiles(files = files)
    runfiles = runfiles.merge_all([
        dep[DefaultInfo].default_runfiles
        for dep in ctx.attr.deps
    ])

    entrypoint_path = "{workspace_name}/{entrypoint_path}".format(
        workspace_name = ctx.workspace_name,
        entrypoint_path = ctx.file.main.short_path,
    )
    
    interpreter_path = interpreter.short_path.replace("../", "")

    substitutions = {
        "{entrypoint_path}": entrypoint_path,
        "{interpreter_path}": interpreter_path,
    }

    ctx.actions.expand_template(
        template = ctx.file._bash_runner_tpl,
        output = executable,
        substitutions = substitutions,
    )

    return [
        DefaultInfo(
            executable = executable,
            runfiles = runfiles,
        ),
    ]

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

        # This doesn't really need to be mandatory, I'm choosing to do so to keep the example simple.
        "main": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "Label denoting the entrypoint of the binary",
        ),

        # Our rule is going to register an action to expand whatever template this attribute points to.
        "_bash_runner_tpl": attr.label(
            default = "@rules_py_simple//internal:py_binary_runner.bash.tpl",
            doc = "Label denoting the bash runner template to use for the binary",
            allow_single_file = True,
        ),

        # Bazel ships with a useful bash function for querying the absolute path to runfiles at runtime.
        "_bash_runfile_helper": attr.label(
            default = "@bazel_tools//tools/bash/runfiles",
            doc = "Label pointing to bash runfile helper",
            allow_single_file = True,
        ),
    },
    executable = True,

    # You pass a toolchain_type target here.
    # In this case, we use a builtin toolchain_type that was registered in a previous
    # blog post: https://www.anthonyvardaro.com/blog/hermetic-python-toolchain-with-bazel
    toolchains = ["@bazel_tools//tools/python:toolchain_type"],
    doc = "Builds a Python executable from source files and dependencies.",
)
