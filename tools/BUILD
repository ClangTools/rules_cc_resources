# tools/BUILD
package(default_visibility = ["//visibility:public"])

py_binary(
    name = "bin_to_cc",
    srcs = ["bin_to_cc.py"],
    # main = "bin_to_cc.py", # Not strictly needed if srcs has only one .py file
    # Ensure this tool can be used by rules in other packages
    visibility = ["//rules:__pkg__"],
)
