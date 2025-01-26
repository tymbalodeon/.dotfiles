source ($nu.default-config-dir | path join "colors.nu")

let theme = {
    binary: $base08
    block: $base05
    bool: { || if $in { $base0d } else { $base09 } }
    cellpath: $base05
    date: $base0e
    duration: $base0e
    empty: $base0d
    filesize: $base05
    float: $base08
    header: { fg: $base0b attr: b }
    hints: $base03
    int: $base09
    leading_trailing_space_bg: $base04
    list: $base05
    nothing: $base08
    range: $base08
    record: $base05
    row_index: { fg: $base0b attr: b }
    separator: $base03
    shape_block: { fg: $base0d attr: b }
    shape_bool: $base0c
    shape_custom: { fg: $base05 attr: b }
    shape_external: $base0c
    shape_externalarg: { fg: $base0b attr: b }
    shape_filepath: $base0c
    shape_flag: { fg: $base0d attr: b }
    shape_float: { fg: $base0e attr: b }
    shape_garbage: { fg: $base07 bg: $base08 attr: b}
    shape_globpattern: {fg: $base0c attr: b }
    shape_int: { fg: $base0e attr: b }
    shape_internalcall: {fg: $base0c attr: b }
    shape_list: { fg: $base0c attr: b }
    shape_literal: $base0d
    shape_nothing: $base0c
    shape_operator: $base0a
    shape_range: { fg: $base0a attr: b }
    shape_record: { fg: $base0c attr: b }
    shape_signature: { fg: $base0b attr: b }
    shape_string: $base0b
    shape_string_interpolation: { fg: $base0c attr: b }
    shape_table: { fg: $base0d attr: b }
    shape_variable: $base0e
    string: $base05
}
