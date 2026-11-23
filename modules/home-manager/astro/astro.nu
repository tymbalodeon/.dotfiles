def cache-file [] {
  let base = try {
    $env.XDG_CACHE_HOME
  } catch {
    $env.HOME
    | path join ".cache"
  }

  $base
  | path join "astro/astro.json"
}

def icon [phase: string] {
  let icon = {
    "New Moon": 🌕
    "Waxing Crescent": 🌖
    "First Quarter": 🌗
    "Waxing Gibbous": 🌘
    "Full Moon": 🌑
    "Waning Gibbous": 🌒
    "Last Quarter": 🌓
    "Waning Crescent": 🌔
  } | get $phase

  $"($icon)\u{fe0e}"
}

# FIXME: types
def event-time [event: any] {
  $event
  | format date "%I:%M %p"
}

def days-until [days: float type: string] {
  let days = ($days | into int)

  let pluralized = if $days > 1 {
    "days"
  } else {
    "day"
  }

  let icon = {
    Full: (icon "Full Moon")
    New: (icon "New Moon")
  } | get $type

  $"($icon) in ($days) ($pluralized)"
}

def waybar-json [text: string tooltip: string = ""] {
  {
   text: ($text | str trim)
   tooltip: ($tooltip | str trim)
  }
  | to json
  | jq --compact-output --unbuffered
}

def get-data [at: datetime] {
  let base = "https://www.cyclecalcs.com/v2"
  let lat = (location latitude)
  let lon = (location longitude)
  let at = ($at | format date %Y-%m-%d)

  http get $"($base)/today?&at=($at)&lat=($lat)&lon=($lon)&tz=US/Eastern&include=sun,moon,events,night"
}

# Get current astro-(nomical/logical) data
def astro [
  --force # Ignore cache and fetch new data
] {
  let cache_file = (cache-file)

  if $force or not ($cache_file | path exists) or (
    try {
      (date now) - (
        open $cache_file
        | get timestamp
        | into datetime
      # TODO: link time to waybar module dynamically
      ) > 6hr
    } catch { true }
  ) {
    let current_date = (date now)
    let today = (get-data ($current_date))
    let tomorrow = (get-data ($current_date + 1day))

    let data = {
      timestamp: $current_date
      today: $today.data
      tomorrow: $tomorrow.data
    }

    $data
    | save --force (cache-file)

    pkill -RTMIN+4 waybar

    $data
  } else {
    open $cache_file
  }
}

# Get info about the current moon phase
def "astro moon phase" [
  --format # Display formatted version of the data
] {
  let moon_phase = (astro | get today.moon.phase)
  let name = $moon_phase.name
  let icon = (icon $name)

  if $format {
    $"($icon) ($name) \((
      $moon_phase.illumination_percent
      | math round
    ) %\)"
  } else {
    {
      name: $name
      icon: $icon
      illumination: $moon_phase.illumination_percent
    }
  }
}

def is-past [event: datetime] {
  ((date now) - $event | into int) > 0
}

# FIXME: types
def get-future-event [type: string today: any tomorrow: any] {
  let today = ($today | get $type | first | into datetime)
  let tomorrow = ($tomorrow | get $type | first | into datetime)

  if (is-past $today) {
    $tomorrow
  } else {
    $today
  }
}

def get-rise-set [type: string format: bool] {
  let today = (astro | get today | get $type | get rise_set)
  let tomorrow = (astro | get tomorrow | get $type | get rise_set)
  let rise = (get-future-event rise $today $tomorrow)
  let set = (get-future-event set $today $tomorrow)

  if $format {
    let rise_set = [
      {name: rise timestamp: $rise}
      {name: set timestamp: $set}
    ]
    | sort-by timestamp

    let icon = match $type {
      "moon" => ""
      "sun" => ""
    }

    $rise_set
    | each {
        |item|

        if $item.name == rise {
          $"($icon)↑ (event-time $item.timestamp)"
        } else {
          $"($icon)↓ (event-time $item.timestamp)"
        }
    }
    | to text --no-newline
  } else {
    {
      rise: $rise
      set: $set
    }
  }
}

# Get times for the next Moonrise and Moonset
def "astro moon rise-set" [
  --format # Display formatted version of the data
] {
  get-rise-set "moon" $format
}

def days-from-now [event: datetime] {
  $"(($event - (date now)) | format duration day)s"
}

# Get times for the next New and Full Moons
def "astro moon next" [
  --format # Display formatted version of the data
] {
  let new = (astro | get today.moon.next_new_moon | into datetime)
  let full = (astro | get today.moon.next_full_moon | into datetime)

  if $format {
    let next = [
      {name: new timestamp: $new}
      {name: full timestamp: $full}
    ]
    | sort-by timestamp

    $next
    | each {
        |item|

        if $item.name == full {
          $"(icon "Full Moon") (days-from-now $item.timestamp)"
        } else {
          $"(icon "New Moon") ((days-from-now $item.timestamp))"
        }
    }
    | to text --no-newline
  } else {
    {
      new: $new
      full: $full
    }
  }
}

def "astro moon waybar" [] {
  let text = (astro moon phase --format)

  let tooltip = (
    [
      (astro moon rise-set --format)
      (astro moon next --format)
    ]
    | to text --no-newline
  )

  waybar-json $text $tooltip
}

# Add special moon and eclipse info from freeastroapi

# TODO: calculate the month number (starting from the first new moon after the
# winter solstice) and add symbol:
# let major_arcana = {
#   1: 🃯
#   2: 🃱
#   3: 🃲
#   4: 🃤
#   5: 🃥
#   6: 🃦
#   7: 🃧
#   8: 🃨
#   9: 🃩
#   10: 🃫
#   11: 🃭
#   12: 🃮
#   13: 🃠
# } | get $month

# Get current data about the sun
def "astro sun rise-set" [
  --format # Display formatted version of the data
] {
  get-rise-set "sun" $format
}

def "astro sun waybar" [] {
  let rise_set = (astro sun rise-set --format)

  waybar-json ($rise_set | first) ($rise_set | last)
}

# Get the current sun sign
def "astro sun sign" [] {
  let date = (date now)
  let month = ($date | format date %m | into int)
  let day = ($date | format date %d | into int)

  match $month {
    1 => (if $day <= 19 { "♑︎" } else { "♒︎" })
    2 => (if $day <= 18 { "♒︎" } else { "♓︎" })
    3 => (if $day <= 20 { "♓︎" } else { "♈︎" })
    4 => (if $day <= 19 { "♈︎" } else { "♉︎" })
    5 => (if $day <= 20 { "♉︎" } else { "♊︎" })
    6 => (if $day <= 21 { "♊︎" } else { "♋︎" })
    7 => (if $day <= 22 { "♋︎" } else { "♌︎" })
    8 => (if $day <= 22 { "♌︎" } else { "♍︎" })
    9 => (if $day <= 22 { "♍︎" } else { "♎︎" })
    10 => (if $day <= 23 { "♎︎" } else { "♏︎" })
    11 => (if $day <= 21 { "♏︎" } else { "♐︎" })
    12 => (if $day <= 21 { "♐︎" } else { "♑︎" })
  }
}

def "astro sun sign waybar" [] {
  let sign = (astro sun sign)

  let name = {
    ♑︎: Capricorn
    ♒︎: Aquarius
    ♓︎: Pisces
    ♈︎: Aries
    ♉︎: Taurus
    ♊︎: Gemini
    ♋︎: Cancer
    ♌︎: Leo
    ♍︎: Virgo
    ♎︎: Libra
    ♏︎: Scorpio
    ♐︎: Sagittarius
  } | get $sign

  waybar-json $sign $name
}
