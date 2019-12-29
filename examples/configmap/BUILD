load("//build_tools/k8s:configmap.bzl", "k8s_configmap")

k8s_configmap(
    name = "config",
    srcs = [":config.py"],
)

k8s_configmap(
    name = "config_vars",
    substitutions = {
        "{FOO}": "VAR",
    },
    srcs = [":config_vars.py"],
)

k8s_configmap(
    name = "config_multi",
    substitutions = {
        "{FOO}": "VAR",
    },
    srcs = [
        ":config.py",
        ":config_vars.py",
    ],
)
