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
        src_stem = _get_stem(src_file.basename) if ctx.attr.ext_hide else src_file.basename  # Use extension if ext is True

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

        h_file = ctx.actions.declare_file(file_path_prefix + ".h")
        cpp_file = ctx.actions.declare_file(file_path_prefix + ".cpp")

        h_files.append(h_file)
        cpp_files.append(cpp_file)

        args = ctx.actions.args()
        args.add("--input", src_file.path)
        args.add("--output_h", h_file.path)
        args.add("--output_cpp", cpp_file.path)
        args.add("--resource_name", base_name)
        
        # 添加数据类型选择
        args.add("--data_type", ctx.attr.data_type)

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
            mandatory = True,
            allow_files = True,  # Allow actual file paths
            doc = "List of input binary files.",
        ),
        "out_prefix": attr.string(
            doc = "Optional prefix for output file names (e.g., 'my_res') and C variable names. If 'ui' and input is 'icon.png', output is 'ui_icon.h/cpp' and resource name 'ui_icon'.",
        ),
        "ext_hide": attr.bool(
            default = True,
            doc = "Whether to include the extension '.bin' in the output file names.",
        ),
        "data_type": attr.string(
            values = ["char", "uchar", "uint"],
            default = "uchar",
            doc = "Data type for the array (char, uchar=unsigned char, uint=unsigned int).",
        ),
        "_tool": attr.label(
            default = Label("//tools:bin_to_cc"),
            cfg = "exec",
            executable = True,
            doc = "The binary to C/C++ conversion tool.",
        ),
    },
    doc = """
    Converts binary files into C/C++ source files.
    
    This rule takes binary files and generates corresponding C/C++ header and source files
    that contain the binary data as arrays. The generated files can be used to embed
    resources directly into C/C++ programs.
    
    Attributes:
        srcs: List of input binary files.
        out_prefix: Optional prefix for output file names and C variable names.
        ext_hide: Whether to exclude the file extension from generated names.
        data_type: Data type for the generated array (char, uchar, or uint).
    """,
)
