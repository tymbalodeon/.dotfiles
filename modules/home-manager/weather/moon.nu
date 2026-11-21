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
 let include_visuals = true
 let include_zodiac = true
 let api_key = (freeastroapi-api-key)
  let cache_file = (cache-file)

  # TODO: link time to waybar module dynamically
  if not ($cache_file | path exists) or (
    ((date now) - 1day) > (ls $cache_file | first).modified
  ) {
   let data = (
    http get $"($base)?lat=($lat)&lon=($lon)&include_eclipse=($include_eclipse)&include_forecast=($include_forecast)&include_interpretation=($include_interpretation)&include_rise_set=($include_rise_set)&include_special=($include_special)&include_traditional_moon=($include_traditional_moon)&include_visuals=($include_visuals)&include_zodiac=($include_zodiac)"
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

  {
    text: ""
    tooltip: ""
  }
  | to json
  | jq --compact-output --unbuffered
}
