load("@io_bazel_rules_k8s//k8s:object.bzl", "k8s_object")

_TEMPLATE = "//build_tools/k8s:secret.sh.tmpl"
_K8S_TOOLCHAIN = "@io_bazel_rules_k8s//toolchains/kubectl:toolchain_type"


def _k8s_secret_impl(ctx):
    kubectl_tool_info = ctx.toolchains[_K8S_TOOLCHAIN].kubectlinfo
    kubectl_tool = kubectl_tool_info.tool_path

    secret_file_args = ""
    for src in ctx.files.srcs:
        secret_file_args += "--from-file={} ".format(src.path)

    ctx.actions.expand_template(
        template = ctx.file._template,
        output = ctx.outputs.executable,
        substitutions = {
            "{KUBECTL_PATH}": kubectl_tool,
            "{SECRET_NAME}": ctx.attr.secret_name,
            "{SECRET_FILES}": secret_file_args,
        },
    )

    ctx.actions.run(
        arguments = [ctx.outputs.created.path],
        executable = ctx.outputs.executable,
        inputs = ctx.files.srcs,
        outputs = [ctx.outputs.created],
    )

    # runfiles = ctx.runfiles(
    #     files = [ctx.outputs.executable],
    #     transitive_files = depset(ctx.files.srcs),
    #     collect_data = True
    # )

    # return struct(
    #     runfiles = runfiles
    # )


_k8s_secret = rule(
    implementation = _k8s_secret_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            allow_empty = False,
        ),
        "secret_name": attr.string(),
        "_template": attr.label(
            default = Label(_TEMPLATE),
            allow_single_file = True,
        ),
    },
    outputs = {
        "created": "%{secret_name}.created.yaml",
    },
    toolchains = [_K8S_TOOLCHAIN],
    executable = True,
)


def k8s_secret(name, srcs, cluster='', namespace='', **kwargs):
    # Create secret resource template
    _k8s_secret(
        name = "pre.%s" % name,
        secret_name = name,
        srcs = srcs,
    )

    # Create resource in k8s
    k8s_object(
        name = name,
        kind = "secret",
        template = ":%s.created.yaml" % name,
        cluster = cluster,
        namespace = namespace,
        **kwargs
    )
