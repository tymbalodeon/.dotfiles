use ($nu.default-config-dir | path join "colors.nu") *

export def get_theme [] = {
    {
        separator: $fg1 
        leading_trailing_space_bg: { attr: n } 
        header: { fg: $green attr: b }
        empty: $blue 
        bool: { || if $in { $aqua } else { $orange_bright } } 
        int: $fg1 
        filesize: $aqua 
        duration: $fg1 
        date: $purple 
        range: $fg1 
        float: $fg1 
        string: $fg1 
        nothing: $fg1 
        binary: $fg1 
        cell-path: $fg1 
        row_index: { fg: $green attr: b }
        record: $fg1 
        list: $fg1 
        block: $fg1 
        hints: $gray 
        search_result: { bg: $red fg: $fg1 }
        shape_and: { fg: $purple attr: b }
        shape_binary: { fg: $purple attr: b }
        shape_block: { fg: $blue attr: b }
        shape_bool: $aqua_bright 
        shape_closure: { fg: $green attr: b }
        shape_custom: $green 
        shape_datetime: { fg: $aqua attr: b }
        shape_directory: $aqua 
        shape_external: $aqua 
        shape_externalarg: { fg: $green attr: b }
        shape_filepath: $aqua 
        shape_flag: { fg: $blue attr: b }
        shape_float: { fg: $purple attr: b }
        shape_garbage: { fg: $fg1 bg: $red attr: b}
        shape_globpattern: {fg: $aqua attr: b }
        shape_int: { fg: $purple attr: b }
        shape_internalcall: {fg: $aqua attr: b }
        shape_keyword: { fg: $aqua attr: b }
        shape_list: { fg: $aqua attr: b }
        shape_literal: $blue 
        shape_match_pattern: $green 
        shape_matching_brackets: { attr: u }
        shape_nothing: $aqua_bright 
        shape_operator: $yellow 
        shape_or: { fg: $purple attr: b }
        shape_pipe: { fg: $purple attr: b }
        shape_range: { fg: $yellow attr: b }
        shape_record: { fg: $aqua attr: b }
        shape_redirection: { fg: $purple attr: b }
        shape_signature: { fg: $green attr: b }
        shape_string: $green 
        shape_string_interpolation: { fg: $aqua attr: b }
        shape_table: { fg: $blue attr: b }
        shape_variable: $purple 
        shape_vardecl: $purple 
    }
}

