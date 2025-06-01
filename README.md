# README.md

## cc_resources Rule

The `cc_resources` rule in Bazel is designed for converting binary files into C/C++ source files and headers. This rule generates a pair of `.cpp` and `.h` files for each input binary file. These generated files define a C-compatible struct with the name, size, and data of the resource, which can then be used in your C/C++ code.

### Usage

Here is a brief overview of how to use the `cc_resources` rule in your Bazel build files.

```bazel
bazel_dep(name = "rules_cc_resources", version = "0.1.0")
# load("@rules_cc_resources//rules:defs.bzl", "cc_resources")
```

#### Rule Definition

You should define the `cc_resources` rule in your `BUILD.bazel` file with the required attributes:

```python
cc_resources(
    name = "my_resources",
    srcs = ["path/to/resource1.bin", "path/to/resource2.bin"],
    out_prefix = "my_res",  # Optional prefix for generated file names
    data_type = "uchar",    # Optional data type for the array (default: "uchar")
)
```

### Attributes

- `srcs`: A mandatory list of input binary files that need to be converted. These files will be processed and transformed into C/C++ source files.

- `out_prefix`: An optional string that specifies a prefix for the output file names and the corresponding C variable names. For example, if `out_prefix` is set to `ui` and the input is `icon.png`, the outputs will be named `ui_icon.h` and `ui_icon.cpp`, and the resource name will be `ui_icon`.

- `data_type`: An optional string that specifies the data type for the generated array. Available options are:
  - `"char"`: Signed char array, suitable for text data
  - `"uchar"`: Unsigned char array (default), suitable for binary data
  - `"uint"`: Unsigned int array, reduces generated source file size by combining 4 bytes into one integer

### Output

When you invoke the `cc_resources` rule, it generates:

- `.h` files containing the C-compatible struct definitions, including resource metadata.
- `.cpp` files implementing the logic to handle these resources.

### Examples

Basic usage with default settings:
```python
load("@rules_cc_resources//rules:defs.bzl", "cc_resources")

cc_resources(
    name = "image_resources",
    srcs = ["images/logo.png", "images/background.png"],
    out_prefix = "assets"
)
```

Using unsigned int type to reduce generated file size:
```python
cc_resources(
    name = "large_resources",
    srcs = ["data/large_file.bin"],
    out_prefix = "data",
    data_type = "uint"  # Combines 4 bytes into one unsigned int
)
```

Text data handling:
```python
cc_resources(
    name = "text_resources",
    srcs = ["text/strings.txt"],
    out_prefix = "text",
    data_type = "char"  # Uses signed char for text data
)
```

This will produce the following files:
- `assets_logo.h` and `assets_logo.cpp`
- `assets_background.h` and `assets_background.cpp`
- `data_large_file.h` and `data_large_file.cpp`
- `text_strings.h` and `text_strings.cpp`

### Data Type Selection Guide

- Use `"uchar"` (default) when:
  - Working with general binary data
  - Maximum compatibility is needed
  - Individual byte access is important

- Use `"uint"` when:
  - You have large binary files
  - You want to reduce the generated source file size
  - Memory alignment is not a concern

- Use `"char"` when:
  - Working primarily with text data
  - Sign information is important
  - You need to handle ASCII/text data

### Conclusion

The `cc_resources` rule facilitates the integration of binary resources into C/C++ projects by automating the generation of corresponding source files, thereby streamlining resource management in Bazel builds. With the flexible data type options, you can optimize the generated code size and choose the most appropriate representation for your data.
