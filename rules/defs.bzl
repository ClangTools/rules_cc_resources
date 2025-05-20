# rules/defs.bzl
load("@rules_cc//cc:defs.bzl", "cc_library")

def _get_stem(filename):
    """Gets the filename without the last extension. e.g. 'foo.bar.txt' -> 'foo.bar'"""
    parts = filename.rsplit(".", 1)
    if len(parts) > 1 and parts[0]:  # Check if there's a non-empty stem
        return parts[0]
    return filename  # Return original if no extension or starts with '.'

def _cc_resources_impl(ctx):
    """Implementation for the cc_resources rule."""

    h_files = []
    cpp_files = []
    tool_runfiles = ctx.attr._tool[DefaultInfo].default_runfiles.files  # Get this once

    for src_file in ctx.files.srcs:
        src_stem = _get_stem(src_file.basename)  # e.g., "my_data" from "my_data.bin"

        if ctx.attr.out_prefix:
            # If out_prefix is "assets", and src_stem is "image", base_name becomes "assets_image"
            base_name = ctx.attr.out_prefix + "_" + src_stem

            # For files, if you want them in a directory:
            # file_path_prefix = ctx.attr.out_prefix + "/" + src_stem
            # Or for flat structure with prefix:
            file_path_prefix = ctx.attr.out_prefix + "_" + src_stem
        else:
            base_name = src_stem
            file_path_prefix = src_stem

        # Declare output files for this specific resource
        # Ensure declared paths are unique if out_prefix is not used and multiple inputs might have same stem from different dirs
        # However, ctx.actions.declare_file handles uniqueness within the rule's output directory.
        # If src_file.short_path is "path/to/data.bin", we might want "path_to_data"
        # For simplicity, let's assume basenames are unique enough or out_prefix is used.
        # A more robust way for uniqueness without out_prefix would be to incorporate parts of the path.
        # For now, file_path_prefix from above is used.

        h_file = ctx.actions.declare_file(file_path_prefix + ".h")
        cpp_file = ctx.actions.declare_file(file_path_prefix + ".cpp")

        h_files.append(h_file)
        cpp_files.append(cpp_file)

        args = ctx.actions.args()
        args.add("--input", src_file.path)
        args.add("--output_h", h_file.path)
        args.add("--output_cpp", cpp_file.path)

        # The resource_name passed to the tool should be what the C variable is named
        # This will be 'base_name' which incorporates the out_prefix if present.
        args.add("--resource_name", base_name)

        ctx.actions.run(
            executable = ctx.executable._tool,
            arguments = [args],
            inputs = depset(
                direct = [src_file],
                transitive = [tool_runfiles],
            ),
            outputs = [h_file, cpp_file],
            mnemonic = "CcResourceGen",
            progress_message = "Generating C/C++ resources for %s from %s" % (base_name, src_file.short_path),
        )

    all_generated_files = h_files + cpp_files

    return [
        DefaultInfo(files = depset(all_generated_files)),
        # It's good practice to make output group names distinct
        OutputGroupInfo(
            cc_resource_headers = depset(h_files),
            cc_resource_sources = depset(cpp_files),
        ),
    ]

cc_resources = rule(
    implementation = _cc_resources_impl,
    attrs = {
        "srcs": attr.label_list(
            # Changed from src to srcs
            mandatory = True,
            allow_files = True,  # Allow actual file paths
            doc = "List of input binary files.",
        ),
        "out_prefix": attr.string(
            doc = "Optional prefix for output file names (e.g., 'my_res') and C variable names. If 'ui' and input is 'icon.png', output is 'ui_icon.h/cpp' and resource name 'ui_icon'.",
        ),
        "_tool": attr.label(
            default = Label("//tools:bin_to_cc"),  # Make sure this path is correct
            cfg = "exec",
            executable = True,
            doc = "The binary to C/C++ conversion tool.",
        ),
    },
    doc = "Converts binary files into .cpp and .h files. Each input file results in a separate .cpp and .h pair, defining a C-compatible struct {name, size, data}.",
)
