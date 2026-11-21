def moon [] {
 let base = "https://api.freeastroapi.com/api/v1/moon/phase"
 let location = (location)
 let lat = $location.lat
 let lon = $location.lon
 let include_eclipse = true
 let include_forecast = true
 let include_interpretation = true
 let include_rise_set = true
 let include_special = true
 let include_traditional_moon = true
 let include_visuals = true
 let include_zodiac = true
 let api_key = (freeastroapi-api-key)

 (
  http get $"($base)?lat=($lat)&lon=($lon)&include_eclipse=($include_eclipse)&include_forecast=($include_forecast)&include_interpretation=($include_interpretation)&include_rise_set=($include_rise_set)&include_special=($include_special)&include_traditional_moon=($include_traditional_moon)&include_visuals=($include_visuals)&include_zodiac=($include_zodiac)"
  --headers {x-api-key: $api_key}
  | to json
 )
}
