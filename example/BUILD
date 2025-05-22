# src/BUILD
load("@rules_cc_resources//rules:defs.bzl", "cc_resources")

# Use the rule to convert my_resource.txt
cc_resources(
    name = "app_resource",  # This name is used for output files and C variable
    srcs = [
        "assets/my_resource_next.txt",
        "my_resource.txt",
    ],
    out_prefix = "example",
)

cc_library(
    name = "lib",
    srcs = [":app_resource"],
    includes = [
        ".",
    ],
)

# Build the C++ application
cc_binary(
    name = "app",
    srcs = [
        "main.cpp",
    ],
    deps = [
        ":lib",
    ],
)
