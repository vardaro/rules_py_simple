def _py_library_impl(ctx):
    """
    py_library implementation

    Returns runfile tree for consumption via py_binary

    Args:
        ctx: Analysis context
    """
    runfiles = ctx.runfiles(files = ctx.files.data)
    all_targets = ctx.attr.srcs + ctx.attr.hdrs + ctx.attr.deps + ctx.attr.data
    runfiles = runfiles.merge_all([
        target[DefaultInfo].default_runfiles
        for target in all_targets
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
