def epoch-to-human [timestamp: int] {
  ^date --date $"@($timestamp)" --rfc-email
  | format date "%I:%M %p"
}

# Fetch weather data for the current IP address
def weather [
  --formatted # Whether to output human readable values
] {
  let base = "api.openweathermap.org/data/2.5/weather"
  let api_key = (openweathermap-api-key)
  let lat = (location latitude)
  let lon = (location longitude)

  let weather = (
    http get $"($base)?appid=($api_key)&lat=($lat)&lon=($lon)&units=imperial"
  )

  if $formatted {
    {
      Cloudiness: $"|☁ ($weather.clouds.all) %"
      "Feels like": $"| ($weather.main.feels_like) °F"
      High: $"| ($weather.main.temp_max) °F"
      Humidity: $"|🌢 ($weather.main.humidity) %"
      Low: $"| ($weather.main.temp_min) °F"
      Sunrise: $"| (epoch-to-human $weather.sys.sunrise)"
      Sunset: $"| (epoch-to-human $weather.sys.sunset)"
      Temperature: $"| ($weather.main.temp) °F"
      Wind: $"|༄ ($weather.wind.speed) mph"
    }
  } else {
    $weather
  }
}

def "weather waybar" [] {
  let weather = (weather --formatted)

  {
    text: $"($weather.Temperature | str replace "|" "")"
    tooltip: ($weather | to text | column --table --separator "|")
  }
  | to json
  | jq --compact-output --unbuffered
}
