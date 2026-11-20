def location [] {
  # TODO: use a better method than this! Or use it if available and check the
  # internet if not?
  
  let sunsetr_config = (open ~/.config/sunsetr/sunsetr.toml)

  $"($sunsetr_config.latitude),($sunsetr_config.longitude)"
}

def fahrenheit [degrees: number] {
  ($degrees * (9 / 5)) + 32
}

def main [] {
  let weather = (
    wego --backend openmeteo --days 1 --frontend json
    | from json
  )

  {
    text: $" (fahrenheit $weather.Current.TempC)°F"
    tooltip: $"Feels like: (fahrenheit $weather.Current.FeelsLikeC)°F"
  }
  | to json
  | jq --compact-output --unbuffered
}
