load("@io_bazel_rules_k8s//k8s:object.bzl", "k8s_object")

_TEMPLATE = "//build_tools/k8s:configmap.sh.tmpl"
_K8S_TOOLCHAIN = "@io_bazel_rules_k8s//toolchains/kubectl:toolchain_type"


def _k8s_configmap_impl(ctx):
    kubectl_tool_info = ctx.toolchains[_K8S_TOOLCHAIN].kubectlinfo
    kubectl_tool = kubectl_tool_info.tool_path

    config_files = ""
    for src in ctx.files.srcs:
        config_files += "--from-file={} ".format(src.path)

    ctx.actions.expand_template(
        template = ctx.file._template,
        output = ctx.outputs.executable,
        substitutions = {
            "{KUBECTL_PATH}": kubectl_tool,
            "{CONFIG_NAME}": ctx.attr.config_name,
            "{CONFIG_FILES}": config_files,
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


_k8s_configmap = rule(
    implementation = _k8s_configmap_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            allow_empty = False,
        ),
        "config_name": attr.string(),
        "_template": attr.label(
            default = Label(_TEMPLATE),
            allow_single_file = True,
        ),
    },
    outputs = {
        "created": "%{config_name}.created.yaml",
    },
    toolchains = [_K8S_TOOLCHAIN],
    executable = True,
)


def k8s_configmap(name, srcs, cluster='', namespace='', **kwargs):
    # Create configmap resource template
    _k8s_configmap(
        name = "pre.%s" % name,
        config_name = name,
        srcs = srcs,
    )

    # Create resource in k8s
    k8s_object(
        name = name,
        kind = "configmap",
        template = ":%s.created.yaml" % name,
        cluster = cluster,
        namespace = namespace,
        **kwargs
    )
