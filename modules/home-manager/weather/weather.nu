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

def waybar-json [text: string tooltip: string = ""] {
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
    Wind: $"💨\u{fe0e} ($weather.wind.speed | into int) mph"
  }

  (
    waybar-json 
      $"($weather.Temperature)"
      ($weather | reject Temperature | to text --no-newline)
  )
}

def "weather waybar sun" [] {
  let weather = (weather)
  let sunrise_timestamp = (get-timestamp $weather.sys.sunrise)
  mut is_sunrise = true

  let timestamp = if ($sunrise_timestamp - (date now) | into int) > 0 {
    $sunrise_timestamp
  } else {
    $is_sunrise = false
    (get-timestamp $weather.sys.sunset)
  }

  let icon = if $is_sunrise {
    " at"
  } else {
    " at "
  }

  waybar-json $"($icon)($timestamp | format date "%I:%M %p")"
}

def "weather waybar sign" [] {
  let date = (date now)
  let month = ($date | format date %m | into int)
  let day = ($date | format date %d | into int)

  let sign = match $month {
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
