# rules/defs.bzl

def _get_stem(filename):
    """Gets the filename without the last extension. e.g. 'foo.bar.txt' -> 'foo.bar'"""
    parts = filename.rsplit(".", 1)
    if len(parts) > 1 and parts[0]:
        return parts[0]
    return filename

def _cc_resources_impl(ctx):
    """Implementation for the cc_resources rule."""

    h_files = []
    cpp_files = []

    # 获取工具的可执行文件对象
    tool_exec = ctx.executable._tool

    for src_file in ctx.files.srcs:
        # 计算文件名 stem
        src_stem = _get_stem(src_file.basename) if ctx.attr.ext_hide else src_file.basename

        # 计算输出文件名前缀和变量名
        if ctx.attr.out_prefix:
            base_name = ctx.attr.out_prefix + "_" + src_stem

            # 这里定义生成文件的路径前缀
            file_path_prefix = ctx.attr.out_prefix + "_" + src_stem
        else:
            base_name = src_stem
            file_path_prefix = src_stem

        # 声明输出文件
        h_file = ctx.actions.declare_file(file_path_prefix + ".h")
        cpp_file = ctx.actions.declare_file(file_path_prefix + ".cpp")

        h_files.append(h_file)
        cpp_files.append(cpp_file)

        # 构建参数
        args = ctx.actions.args()
        args.add("--input", src_file.path)
        args.add("--output_h", h_file.path)
        args.add("--output_cpp", cpp_file.path)
        args.add("--resource_name", base_name)
        args.add("--data_type", ctx.attr.data_type)

        # 执行 Action
        ctx.actions.run(
            executable = tool_exec,
            arguments = [args],
            inputs = [src_file],
            tools = [tool_exec],
            outputs = [h_file, cpp_file],
            mnemonic = "CcResourceGen",
            progress_message = "Generating C/C++ resources: %s -> %s" % (src_file.basename, base_name),
        )

    all_generated_files = h_files + cpp_files

    return [
        # DefaultInfo 允许你直接将此规则放入 cc_library 的 srcs 中
        # 例如: cc_library(name="res", srcs=[":my_resources"])
        DefaultInfo(files = depset(all_generated_files)),

        # OutputGroupInfo 允许你只提取头文件或源文件
        # 例如: filegroup(name="headers", srcs=[":my_resources"], output_group="cc_resource_headers")
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
            allow_files = True,
            doc = "List of input binary files.",
        ),
        "out_prefix": attr.string(
            doc = "Optional prefix for output file names and C variable names.",
        ),
        "ext_hide": attr.bool(
            default = True,
            doc = "Whether to include the original extension in the output name.",
        ),
        "data_type": attr.string(
            values = ["char", "uchar", "uint"],
            default = "uchar",
            doc = "Data type for the array (char, uchar, uint).",
        ),
        "_tool": attr.label(
            default = Label("//tools:bin_to_cc"),
            cfg = "exec",
            executable = True,
            doc = "The binary to C/C++ conversion tool.",
        ),
    },
    doc = "Converts binary files into C/C++ source files using a host tool.",
)
