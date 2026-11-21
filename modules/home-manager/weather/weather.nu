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
    ((date now) - 5min) > (ls $cache_file | first).modified
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
    Cloudiness: $"☁ ($weather.clouds.all) %"
    Humidity: $"🌢 ($weather.main.humidity) %"
    Sunrise: $" (epoch-to-human $weather.sys.sunrise)"
    Sunset: $" (epoch-to-human $weather.sys.sunset)"
    Wind: $"💨\u{fe0e} ($weather.wind.speed | math round --precision 1) mph"
  }

  (
    waybar-json 
      $"($weather.Cloudiness) ($weather.Humidity) ($weather.Wind)"
      ($weather | select Sunrise Sunset | values | to text --no-newline)
  )
}

def "weather waybar temperature" [] {
  let weather = (weather)

  let weather = {
    "Feels like": $" ($weather.main.feels_like | into int) °F"
    Divider: "-------"
    High: $" ($weather.main.temp_max | into int) °F"
    Low: $" ($weather.main.temp_min | into int) °F"
    Temperature: $" ($weather.main.temp | into int) °F"
  }

  (
    waybar-json
      $"($weather.Temperature)"
      ($weather | reject Temperature | values | to text --no-newline)
  )
}
