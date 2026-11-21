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
    "New moon": 🌑
    "Waxing Crescent": 🌒
    "First Quarter": 🌓
    "Waxing Gibbous": 🌔
    "Full Moon": 🌕
    "Waning Gibbous": 🌖
    "Last Quarter": 🌗
    "Waning Crescent": 🌘
  } | get $phase

  $"($icon)\u{fe0e}"
}

def moon [] {
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

  # TODO: link time to waybar module dynamically
  if not ($cache_file | path exists) or (
    ((date now) - 1day) > (ls $cache_file | first).modified
  ) {
   let data = (
    http get $"($base)?lat=($lat)&lon=($lon)&include_eclipse=($include_eclipse)&include_forecast=($include_forecast)&include_interpretation=($include_interpretation)&include_rise_set=($include_rise_set)&include_special=($include_special)&include_traditional_moon=($include_traditional_moon)&include_zodiac=($include_zodiac)"
    --headers {x-api-key: $api_key}
   )

    $data
    | save --force (cache-file)

    $data
  } else {
    open $cache_file
  }
}

def "moon waybar" [] {
  let moon = (moon)

  let phase = $moon.phase.name
  let illumination = $"(($moon.phase.illumination * 100) | into int) %"
  let age = $"($moon.phase.age_days) days old"

  let rise = (
    $moon.rise_set.rise_local
    | format date "%I:%M %p"
  )

  let set = (
    $moon.rise_set.set_local
    | format date "%I:%M %p"
  )

  let interpretation = $moon.interpretation.body

  let moon = {
    Phase: $phase
    Illumination: $illumination
    Age: $"($moon.phase.age_days) days old"
    Rise: $rise
    Set: $set
  }

  $moon
  | to text --no-newline

  {
    text: (icon $phase)
    tooltip: $"($phase) \(($illumination)\) - ($age)"
  }
  | to json
  | jq --compact-output --unbuffered
}
