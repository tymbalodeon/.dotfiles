def cache-file [] {
  let base = try {
    $env.XDG_CACHE_HOME
  } catch {
    $env.HOME
    | path join ".cache"
  }

  $base
  | path join "weather/weather.json"
}

# Fetch weather data for the current IP address
def weather [] {
  let base = "api.openweathermap.org/data/2.5/weather"
  let api_key = (openweathermap-api-key)
  let lat = (location latitude)
  let lon = (location longitude)
  let cache_file = (cache-file)

  # TODO: link time to waybar module dynamically
  if not ($cache_file | path exists) or (
    ((date now) - 15min) > (ls $cache_file | first).modified
  ) {
    let weather = (
      http get $"($base)?appid=($api_key)&lat=($lat)&lon=($lon)&units=imperial"
    )

    $weather
    | save --force (cache-file)

    $weather
  } else {
    open $cache_file
  }
}

def epoch-to-human [timestamp: int] {
  ^date --date $"@($timestamp)" --rfc-email
  | format date "%I:%M %p"
}

def waybar-json [text: string tooltip: string] {
  {
    text: ($text | str trim)
    tooltip: ($tooltip | str trim)
  }
  | to json
  | jq --compact-output --unbuffered
}

def "weather waybar" [] {
  let weather = (weather)

  let weather = {
    "Feels like": $" ($weather.main.feels_like | into int) °F"
    Temperature: $" ($weather.main.temp | into int) °F"
    High: $" ($weather.main.temp_max | into int) °F"
    Low: $" ($weather.main.temp_min | into int) °F"
    Cloudiness: $"☁ ($weather.clouds.all) %"
    Humidity: $"🌢 ($weather.main.humidity) %"
    Wind: $"💨\u{fe0e} ($weather.wind.speed | math round --precision 1) mph"
    # Sunrise: $" (epoch-to-human $weather.sys.sunrise)"
    # Sunset: $" (epoch-to-human $weather.sys.sunset)"
  }

  (
    waybar-json 
      $"($weather."Feels like")"
      ($weather | reject "Feels like" | values | to text --no-newline)
  )
}

def "weather sun" [] {
  let weather = (weather)
  
  let weather = {
    Sunrise: $" (epoch-to-human $weather.sys.sunrise)"
    Sunset: $" (epoch-to-human $weather.sys.sunset)"
  }

  let text = if ($weather.sys.sunrise) {
    $weather.Sunrise
  } else {
    $weather.Sunset
  }

  let tooltip = if ($weather.sys.sunrise) {
    $weather.Sunrise
  } else {
    $weather.Sunset
  }

  (
    waybar-json 
      $text
      $tooltip
  )
}
