def _py_library_impl(ctx):
    """
    py_library implementation

    Returns runfile tree for consumption via py_binary

    Args:
        ctx: Analysis context
    """
    files = ctx.files.srcs + ctx.files.data

    runfiles = ctx.runfiles(files = files)
    runfiles = runfiles.merge_all([
        dep[DefaultInfo].default_runfiles
        for dep in ctx.attr.deps
    ])

    return [
        DefaultInfo(
            runfiles = runfiles,
        ),
    ]

py_library = rule(
    implementation = _py_library_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            doc = "Source files to compile",
        ),
        "deps": attr.label_list(
            doc = "Direct dependencies of the library",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Data files available to the library",
        ),
    },
    doc = "Returns runfile tree for consumption via py_binary",
)
