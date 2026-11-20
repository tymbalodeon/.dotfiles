def location [] {
  http get http://ip-api.com/json
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

