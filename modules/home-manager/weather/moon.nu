def cache-file [] {
  let base = try {
    $env.XDG_CACHE_HOME
  } catch {
    $env.HOME
    | path join ".cache"
  }

  $base
  | path join "weather/moon.json"
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

def moon [
  --force # Ignore cache and fetch new data
] {
  let base = "https://api.freeastroapi.com/api/v1/moon/phase"
  let location = (location)
  let lat = $location.lat
  let lon = $location.lon
  let include_eclipse = true
  let include_forecast = true
  let include_interpretation = true
  let include_rise_set = true
  let include_special = true
  let include_traditional_moon = true
  let include_zodiac = true
  let api_key = (freeastroapi-api-key)
  let cache_file = (cache-file)

  if not $force and not ($cache_file | path exists) or (
    (date now) - (
      open $cache_file
      | get timestamp
      | into datetime
    # TODO: link time to waybar module dynamically
    ) > 6hr
  ) {
   let data = (
    http get $"($base)?lat=($lat)&lon=($lon)&include_eclipse=($include_eclipse)&include_forecast=($include_forecast)&include_interpretation=($include_interpretation)&include_rise_set=($include_rise_set)&include_special=($include_special)&include_traditional_moon=($include_traditional_moon)&include_zodiac=($include_zodiac)"
    --headers {x-api-key: $api_key}
   )

    $data
    | save --force (cache-file)

    pkill -RTMIN+4 waybar

    $data
  } else {
    open $cache_file
  }
}

def event-time [event: string] {
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

def "moon waybar" [] {
  let moon = (moon)
  let phase = $moon.phase.name
  let illumination = $"(($moon.phase.illumination * 100) | into int) %"
  let rise = $"↑ (event-time $moon.rise_set.rise_local)"
  let set = $"↓ (event-time $moon.rise_set.set_local)"

 let eclipse = if $moon.eclipse.is_blood_moon {
    "Blood Moon "
  } else if $moon.eclipse.is_eclipse {
    "Eclipse "
  } else {
    ""
  }

  let special_moon = if $moon.special_moon.is_supermoon {
    " Super Moon "
  } else if $moon.special_moon.is_micromoon {
    " Micro Moon "
  } else if $moon.special_moon.is_blue_moon {
    " Blue Moon "
  } else if $moon.special_moon.is_black_moon {
    " Black Moon "
  } else if $moon.special_moon.is_harvest_moon {
    " Harvest Moon "
  } else if $moon.special_moon.is_hunter_moon {
    " Hunter Moon "
  } else {
    ""
  }

  let name = if $moon.traditional_moon.is_current_full_moon {
    $moon.traditional_moon.name
  } else {
    $phase
  }

  # TODO: add next specials and elipses
  let moon = {
    Rise: $rise
    Set: $set
    next_new_moon: $"(days-until $moon.forecast.days_until_new_moon "New")"
    next_full_moon: $"(days-until $moon.forecast.days_until_full_moon "Full")"
    Phase: $phase
    Illumination: $illumination
  }

  {
    text: $"($eclipse)($special_moon)(icon $phase) ($name) \(($illumination)\)"
    tooltip: ($moon | reject Phase Illumination | values | to text --no-newline)
  }
  | to json
  | jq --compact-output --unbuffered
}
