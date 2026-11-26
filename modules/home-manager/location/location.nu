# TODO: add help text

def location-path [] {
  "~/.local/state/location"
  | path expand
}

def current-location-data [] {
  open (location-path)
  | from json
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
    let location = (current-location-data)

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

def update-location-data [] {
  let script = (
    $nu.user-autoload-dirs
    | path join update-location-data.nu
  )

  if ($script | path exists) {
    nu $script
  }
}

def "location clear" [] {
  let location_path = (location-path)

  if not ($location_path | path exists) or (
    current-location-data
  | is-empty
) {
    return
  }

  rm --force (location-path)
  update-location-data
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
  let location_path = (location-path)

  if ($location_path | path exists) {
    let current_location = (current-location-data)

    if (
      [
        ($city == $current_location.city?)
        ($state == $current_location.state?)
        ($postal_code == $current_location.postal_code?)
        ($country == $current_location.country?)
      ]
      | all {$in == true}
    ) {
      return
    }
  }

  let base = "https://geocode.maps.co/search"
  let city_param = $"city=($city)"
  let state_param = $"state=($state)"

  let postal_code_param = if ($postal_code | is-not-empty) {
    $"&postalcode=($postal_code)"
  } else {
    ""
  }

  let country_param = $"country=($country)"
  let api_key = $"api_key=(geocode-maps-co-api-key)"

  let location = (
    http get $"(
      $base
    )?(
      $city_param
    )&(
      $state_param
    )(
      $postal_code_param
    )&(
      $country
    )&($api_key)"
    | first
  )

  {
    city: $city
    country: $country
    display: $location.display_name
    lat: $location.lat
    lon: $location.lon
    postal_code: $postal_code
    state: $state
  }
  | to json
  | save --force $location_path

  update-location-data
}
