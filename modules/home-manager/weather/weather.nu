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

def get-timestamp [value: any] {
  ^date --date $"@($value)" --rfc-3339 seconds
  | date from-human
}

# Fetch weather data for the current IP address
def weather [
  --force # Ignore cache and fetch new data
] {
  let base = "api.openweathermap.org/data/2.5/weather"
  let api_key = (openweathermap-api-key)
  let lat = (location latitude)
  let lon = (location longitude)
  let cache_file = (cache-file)

  # TODO: link time to waybar module dynamically
  if not $force and not ($cache_file | path exists) or (
    (date now) - (get-timestamp (open $cache_file | get dt)) > 15min
  ) {
    try {
      let weather = (
        http get $"($base)?appid=($api_key)&lat=($lat)&lon=($lon)&units=imperial"
      )

      $weather
      | save --force (cache-file)

      pkill -RTMIN+5 waybar

      $weather
    } catch {
      if ($cache_file | path exists) {
        open $cache_file
      }
    }
  } else {
    open $cache_file
  }
}

def "weather waybar" [] {
  let weather = (weather)

  let weather = {
    Location: $weather.name
    "Feels like": $" ($weather.main.feels_like | into int) °F"
    Temperature: $" ($weather.main.temp | into int) °F"
    High: $" ($weather.main.temp_max | into int) °F"
    Low: $" ($weather.main.temp_min | into int) °F"
    Cloudiness: $"☁ ($weather.clouds.all) %"
    Humidity: $"🌢 ($weather.main.humidity) %"
    Wind: $"💨\u{fe0e} ($weather.wind.speed | into int) mph"
  }

  {
    text: $"($weather.Temperature)"
    tooltip: ($weather | reject Temperature | to text --no-newline)
  }
  | to json
  | jq --compact-output --unbuffered
}
