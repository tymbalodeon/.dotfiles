const bg = "#282828"
const red = "#cc241d" 
const green = "#98971a"
const yellow = "#d79921"
const blue = "#458588"
const purple = "#b16286"
const aqua = "#689d6a"
const gray = "#a89984"
const gray_bright = "#928374"
const red_bright = "#fb4934"
const green_bright = "#b8bb26"
const yellow_bright = "#fabd2f"
const blue_bright = "#83a598"
const purple_bright = "#d3869b"
const aqua_bright = "#8ec07c"
const fg = "ebdbb2"
const bg0_h = "#1d2021"
const bg0 = $bg
const bg1 = "#3c3836"
const bg2 = "#504945"
const bg3 = "#665c54"
const bg4 = "#7c6f64"
const orange = "#d65d0e"
const bg0_s = "#32302f"
const fg4 = "#a89984" 
const fg3 = "#bdae93"
const fg2 = "#d5c4a1"
const fg1 = $fg
const fg0 = "#fbf1c7"
const orange_bright = "#fe8019"

const red_bold = (ansi --escape { fg: $red attr: b})
const blue_bold = (ansi --escape { fg: $blue attr: b})
const light_red_bold = (ansi --escape { fg: $red_bright attr: b})
const light_blue_bold = (ansi --escape { fg: $blue_bright attr: b})
const green_bold = (ansi --escape { fg: $green attr: b})
const branch_color = (ansi --escape { fg: $gray })
const prompt_insert_color = (ansi --escape { fg: $green })
const prompt_normal_color = (ansi --escape { fg: $yellow })
const prompt_multiline_color = (ansi --escape { fg: $gray })
