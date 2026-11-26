# TODO: add help text

def location-path [] {
  "~/.local/state/location"
  | path expand
}

def "location home" [] {
  {
    lat: (location home latitude)
    lon: (location home longitude)
  }
}

def location [] {
  let location_path = (location-path)

  if ($location_path | path type) == file {
    let location = (open $location_path | from json)

    try {
      let columns = ($location | columns)

      if "lat" not-in $columns or "lon" not-in $columns {
        location home
      } else {
        $location
      }
    } catch {
      location home
    }
  } else {
    try {
      http get http://ip-api.com/json
    } catch {
      location home
    }
  }
}

def "location clear" [] {
  rm --force (location-path)
}

def "location coordinates" [] {
  let location = (location)

  $"($location.lat),($location.lon)"
}

def "location latitude" [] {
  location
  | get lat
}

def "location longitude" [] {
  location
  | get lon
}

def "location set" [
  city: string
  state: string
  postal_code?: string
  country = "US"
] {
  let base = "https://geocode.maps.co/search"
  let city = $"city=($city)"
  let state = $"state=($state)"

  let postal_code = if ($postal_code | is-not-empty) {
    $"&postalcode=($postal_code)"
  } else {
    ""
  }

  let country = $"country=($country)"
  let api_key = $"api_key=(geocode-maps-co-api-key)"

  let location = (
    http get $"($base)?($city)&($state)($postal_code)&($country)&($api_key)"
    | first
  )

  {
    lat: $location.lat
    lon: $location.lon
  }
  | to json
  | save --force (location-path)
}
