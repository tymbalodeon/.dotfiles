def create_left_prompt [] {
    let home =  $nu.home-path

    let dir = (
        if (
            $env.PWD
            | path split
            | zip ($home | path split)
            | all { $in.0 == $in.1 }
        ) {
            ($env.PWD | str replace $home "~")
        } else {
            $env.PWD
        }
    )

    let path_color = (ansi --escape { fg: $base0d attr: b})
    let separator_color = (ansi --escape { fg: $base0b attr: b})

    let prompt = (
        $"($path_color)($dir)"
        | str replace --all
            (char path_sep)
            $"($separator_color)(char path_sep)($path_color)"
    )

    let green_bold = (ansi --escape { fg: $base0b attr: b})

    if (
        do --ignore-errors { git rev-parse --abbrev-ref HEAD err> /dev/null }
        | is-empty
    ) == false {
        mut branch_info = (
            git branch --list
                | lines
                | filter {|branch| $branch | str contains "*" }
                | each {|branch| $branch | str replace "* " ""}
        )

        $branch_info = if not ($branch_info | is-empty) {
            $branch_info | get 0
        } else {
            ""
        }

        (
            $"($prompt) (ansi --escape { fg: $base04 })($branch_info)"
            + $"\n"
            + $"($green_bold)"
        )
     } else {
        $prompt + $"\n" + $"($green_bold)"
    }
}

let prompt_insert_color = ansi --escape { fg: $base0b }
let prompt_multiline_color = ansi --escape { fg: $base04 }
let prompt_normal_color = ansi --escape { fg: $base0a }

$env.PROMPT_COMMAND = {|| create_left_prompt}
$env.PROMPT_COMMAND_RIGHT = {|| null}
$env.PROMPT_INDICATOR_VI_INSERT = {|| $"($prompt_insert_color)> "}

$env.PROMPT_INDICATOR_VI_NORMAL = {||
  $"($prompt_normal_color)>>($prompt_insert_color) "
}

$env.PROMPT_MULTILINE_INDICATOR = {||
  $"($prompt_multiline_color):::($prompt_insert_color) "
}
