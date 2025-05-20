# README.md

## cc_resources Rule

The `cc_resources` rule in Bazel is designed for converting binary files into C/C++ source files and headers. This rule generates a pair of `.cpp` and `.h` files for each input binary file. These generated files define a C-compatible struct with the name, size, and data of the resource, which can then be used in your C/C++ code.

### Usage

Here is a brief overview of how to use the `cc_resources` rule in your Bazel build files.

#### Rule Definition

You should define the `cc_resources` rule in your `BUILD.bazel` file with the required attributes:

```python
cc_resources(
    name = "my_resources",
    srcs = ["path/to/resource1.bin", "path/to/resource2.bin"],
    out_prefix = "my_res",  # Optional prefix for generated file names
    _tool = "//tools:bin_to_cc"  # Path to the conversion tool
)
```

### Attributes

- `srcs`: A mandatory list of input binary files that need to be converted. These files will be processed and transformed into C/C++ source files.

- `out_prefix`: An optional string that specifies a prefix for the output file names and the corresponding C variable names. For example, if `out_prefix` is set to `ui` and the input is `icon.png`, the outputs will be named `ui_icon.h` and `ui_icon.cpp`, and the resource name will be `ui_icon`.

- `_tool`: A label for the conversion tool that should be executed to process the binary files. By default, this is set to `//tools:bin_to_cc`, but it can be overridden to use a custom tool.

### Output

When you invoke the `cc_resources` rule, it generates:

- `.h` files containing the C-compatible struct definitions, including resource metadata.
- `.cpp` files implementing the logic to handle these resources.

### Example

Given the following `BUILD.bazel` setup:

```python
load("//rules:defs.bzl", "cc_resources")

cc_resources(
    name = "image_resources",
    srcs = ["images/logo.png", "images/background.png"],
    out_prefix = "assets"
)
```

This will produce the following files:

- `assets_logo.h`
- `assets_logo.cpp`
- `assets_background.h`
- `assets_background.cpp`

### Conclusion

The `cc_resources` rule facilitates the integration of binary resources into C/C++ projects by automating the generation of corresponding source files, thereby streamlining resource management in Bazel builds.
