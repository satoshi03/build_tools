load("//build_tools/k8s:secret.bzl", "k8s_secret")

k8s_secret(
    name = "secret",
    srcs = [":secret.py"],
)

k8s_secret(
    name = "secret_multi",
    srcs = [
        ":secret.py",
        ":secret_sub.py",
    ],
)
