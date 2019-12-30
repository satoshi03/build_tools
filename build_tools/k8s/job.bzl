load("@io_bazel_rules_k8s//k8s:object.bzl", "k8s_object")


def _k8s_job_impl(ctx):
    ctx.actions.expand_template(
        template = ctx.file.template,
        output = ctx.outputs.substituted,
        substitutions = {
            key: ctx.expand_make_variables(key, value, {})
            for (key, value) in ctx.attr.substitutions.items()
        },
    )


_k8s_job = rule(
    implementation = _k8s_job_impl,
    attrs = {
        "configmaps": attr.label_list(),
        "secrets": attr.label_list(),
        "template": attr.label(
            allow_single_file = True,
        ),
        "substitutions": attr.string_dict(),
        "template_name": attr.string(),
    },
    outputs = {
        "substituted": "%{template_name}.created.yaml",
    },
)

def k8s_job(name, template, configmaps=[], secrets=[], substitutions={}, cluster='', namespace='', **kwargs):
    # Create job resource template
    _k8s_job(
        name = "pre.%s" % name,
        template_name = name,
        template = template,
        configmaps = configmaps,
        secrets = secrets,
        substitutions = substitutions,
    )

    # Create resource in k8s
    k8s_object(
        name = name,
        kind = "job",
        template = ":%s.created.yaml" % name,
        cluster = cluster,
        namespace = namespace,
        substitutions = substitutions,
        **kwargs
    )
