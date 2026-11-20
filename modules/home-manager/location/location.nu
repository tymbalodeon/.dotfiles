def location [] {
  try {
    http get http://ip-api.com/json
  } catch {
    {
      lat: (location home latitude)
      lon: (location home longitude)
    }
  }
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

