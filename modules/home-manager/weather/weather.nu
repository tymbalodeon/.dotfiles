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

def "weather waybar" [] {
  let weather = (weather)

  let weather = {
    Cloudiness: $"☁ ($weather.clouds.all) %"
    "Feels like": $" ($weather.main.feels_like) °F"
    High: $" ($weather.main.temp_max) °F"
    Humidity: $"🌢 ($weather.main.humidity) %"
    Low: $" ($weather.main.temp_min) °F"
    Sunrise: $" (epoch-to-human $weather.sys.sunrise)"
    Sunset: $" (epoch-to-human $weather.sys.sunset)"
    Temperature: $" ($weather.main.temp) °F"
    Wind: $"༄ ($weather.wind.speed) mph"
  }

  {
    text: $"($weather.Temperature)  ($weather.Cloudiness)  ($weather.Humidity)"
    tooltip: ($weather | reject Cloudiness Humidity Temperature | to text --no-newline)
  }
  | to json
  | jq --compact-output --unbuffered
}
