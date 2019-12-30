load("//build_tools/k8s:configmap.bzl", "k8s_configmap")
load("//build_tools/k8s:job.bzl", "k8s_job")
load("@io_bazel_rules_k8s//k8s:objects.bzl", "k8s_objects")

k8s_objects(
    name = "k8s-job",
    objects = [
        ":config",
        ":job-with-cm",
    ],
)

k8s_job(
    name = "job-with-cm",
    template = ":job.yaml",
    substitutions = {
        "{MOUNT_PATH}": "/mnt/configs",
        "{CONFIG_FILE}": "config.py",
    }
)

k8s_configmap(
    name = "config",
    srcs = [":config.py"],
)
