#!/usr/bin/env ruby

# https://open-meteo.com/
# https://open-meteo.com/en/docs/geocoding-api  
# https://github.com/zach-capalbo/flammarion

require 'httparty'
require 'json'
require 'flammarion'
require 'colorized'

def wmo_interpretation(wmo_code)
  reading = ""
  case wmo_code
  when 0
    reading << "Clear sky"
  when 1
    reading << "Mainly clear"
  when 2
    reading << "Partly cloudy"
  when 3
    reading << "Overcast"
  when 45
    reading << "Fog"
  when 48
    reading << "Depositing rime fog"
  when 51
    reading << "Drizzle: Light"
  when 53
    reading << "Drizzle: Moderate"
  when 55
    reading << "Drizzle: Dense intensity"
  when 56
    reading << "Freezing Drizzle: Light"
  when 57
    reading << "Freezing Drizzle: Dense intensity"
  when 61
    reading << "Rain: Slight"
  when 63
    reading << "Rain: Moderate"
  when 65
    reading << "Rain: Heavy intensity"
  when 66
    reading << "Freezing Rain: Light"
  when 67
    reading << "Freezing Rain: Heavy intensity"
  when 71
    reading << "Snow fall: Slight"
  when 73
    reading << "Snow fall: Moderate"
  when 75
    reading << "Snow fall: Heavy intensity"
  when 77
    reading << "Snow grains"
  when 80
    reading << "Rain showers: Slight"
  when 81
    reading << "Rain showers: Moderate"
  when 82
    reading << "Rain showers: Violent"
  when 85
    reading << "Snow showers: Slight"
  when 86
    reading << "Snow showers: Heavy"
  when 95
    reading << "Thunderstorm: Slight or Moderate"
  when 96
    reading << "Thunderstorm with slight hail"
  when 99
    reading << "Thunderstorm with heavy hail"
  end
  return reading
end

def degree_to_direction(angle)
  res = ""
  case angle
  when 0, 360
    res = "N" + "   #{angle}°"
  when 1..44
    res = "NNE" + "   #{angle}°"
  when 45
    res = "NE" + "   #{angle}°"
  when 46..89
    res = "ENE" + "   #{angle}°"
  when 90
    res = "E" + "   #{angle}°"
  when 91..134
    res = "ESE" + "   #{angle}°"
  when 135
    res = "SE" + "   #{angle}°"
  when 136..179
    res = "SSE" + "   #{angle}°"
  when 180
    res = "S" + "   #{angle}°"
  when 181..224
    res = "SSW" + "   #{angle}°"
  when 225
    res = "SW" + "   #{angle}°"
  when 226..269
    res = "WSW" + "   #{angle}°"
  when 270
    res = "W" + "   #{angle}°"
  when 271..314
    res = "WNW" + "   #{angle}°"
  when 315
    res = "NW" + "   #{angle}°"
  when 316..359
    res = "NNW" + "   #{angle}°"
  end
  return res
end

f = Flammarion::Engraving.new
f.title("Weather_forecast")

f.puts "Country name (in english)".colorize(:green)
f.puts "Notes :"
f.puts "- for USA write United States, for UK write United Kingdom"
f.puts "- for city with spaces in their name : just write the spaces"
f.puts "- for King's lynn, don't put the : ' just write Kings lynn"
f.puts "- for Москва, it won't work, write Moskva or Moscou"
f.puts "- for Némiscau, write nemiscau, don't write accents"
f.puts "- for country name, write it with the 1st letter as a capital letter, for city name we don't care"
f.puts "- for city name, you HAVE TO be SURE how to write it, else Weather_forecast crash (same for country name)"
f.puts "- the software provide GMT+0 Timezone data, add or remove hours depending on where you live on earth"
f.puts "- when the software find country + city, if there are many cities with the same name in the country, it displays all answers once time"
cntry = f.input(">")
f.puts "City name (in english)".colorize(:green)
city = f.input(">")

req = 'https://geocoding-api.open-meteo.com/v1/search?name='.concat('#{city.to_s}').concat('&count=5&language=en&format=json')
selec = []
forecast_24 = f.checkbox("only 24h                    ")
forecast_48 = f.checkbox("only 48h                    ")
curves_view = f.checkbox("curves instead of data      ")

f.button("Get your weather forecast now !!!".light_red) {
  f.puts "--------------------------------------------------------------------------------"
  f.puts "Location where you want the weather : #{cntry.to_s}, #{city.to_s}"
  f.puts "--------------------------------------------------------------------------------"
  f.puts ""
  req = "https://geocoding-api.open-meteo.com/v1/search?name=" + "#{city.to_s}" + "&count=5&language=en&format=json"
  uri = URI(req)
  response = HTTParty.get(uri)
  response.parsed_response
  data_hash = JSON.parse(response.body)

  prep_tab = []
  n = 0
  begin
    prep_tab = prep_tab + [n]
    n = n + 1
  end while n < data_hash.count

  extract_conty_name = []
  data_hash.delete("generationtime_ms")
  tempo_tt = data_hash["results"]
  for lll in tempo_tt
      puts("#{lll}")
      extract_conty_name << lll["country"]
  end
  puts("extract_conty_name contient #{extract_conty_name}")

  n = 0
  selec = []
  for elll in extract_conty_name
    if elll == cntry.to_s
      selec << n
      n = n + 1
    else
      n = n + 1
    end
  end

  for numm in selec
    lattd = data_hash["results"][numm]['latitude']
    puts "latitude : #{lattd}"
    logtd = data_hash["results"][numm]['longitude']
    puts "latitude : #{logtd}"
    req_weather = "https://api.open-meteo.com/v1/forecast?latitude=" + "#{lattd}" + "&longitude=" + "#{logtd}" + "&hourly=relative_humidity_2m,precipitation_probability,snowfall,weather_code,wind_speed_80m,wind_direction_80m,temperature_80m"
    uri_weather = URI(req_weather)
    response_w = HTTParty.get(uri_weather)
    response_w.parsed_response
    data_hash_w = JSON.parse(response_w.body)

    prep_tab_w = []
    n = 0
    begin
      prep_tab_w = prep_tab_w + [n]
      n = n + 1
    end while n < data_hash_w.count

    extract_hourly_time = []
    extract_hourly_time += data_hash_w["hourly"]["time"]

    extract_humidity_2m = []
    extract_humidity_2m += data_hash_w["hourly"]["relative_humidity_2m"]

    precipitation_proba = []
    precipitation_proba += data_hash_w["hourly"]["precipitation_probability"]

    snow = []
    snow += data_hash_w["hourly"]["snowfall"]

    wt_code = []
    wt_code += data_hash_w["hourly"]["weather_code"]
    wmo_trad = []
    wt_code.each{ |e| wmo_trad << wmo_interpretation(e) }

    extract_wind_80m = []
    extract_wind_80m += data_hash_w["hourly"]["wind_speed_80m"]

    wind_dirtion_80m = []
    wind_dirtion_80m += data_hash_w["hourly"]["wind_direction_80m"]
    wd_dir = []
    wind_dirtion_80m.each{ |c| wd_dir << degree_to_direction(c) }

    extract_temp_2m = []
    extract_temp_2m += data_hash_w["hourly"]["temperature_80m"]

    f.puts "-----------------------------------------------------------------------------------------------------------------------------------------------------------".light_blue
    f.puts "Coordinates : #{lattd.to_s}, #{logtd.to_s}".light_blue

    if(curves_view.checked? and forecast_24.checked?)
      temper = { x:extract_hourly_time, y:24.times.collect{|y| extract_temp_2m[y]}, mode:'lines', name:"Temperatures", line: {color: '#ff5733'} }
      humid = { x:extract_hourly_time, y:24.times.collect{|y| extract_humidity_2m[y]}, mode:'lines', name:"Humidity", line: {color: '#36ff33'} }
      precipi_prob = { x:extract_hourly_time, y:24.times.collect{|y| precipitation_proba[y]}, mode:'lines', name:"Precipi proba", line: {color: '#33ffa2'} }
      data = [temper, humid, precipi_prob]
      layout = { xaxis: {title: "Hours"}, yaxis: {title: "Humidity (%)"} }
      f.plot(data, layout)

    elsif(curves_view.checked? and forecast_48.checked?)
      temper = { x:extract_hourly_time, y:48.times.collect{|y| extract_temp_2m[y]}, mode:'lines', name:"Temperatures", line: {color: '#ff5733'} }
      humid = { x:extract_hourly_time, y:48.times.collect{|y| extract_humidity_2m[y]}, mode:'lines', name:"Humidity", line: {color: '#36ff33'} }
      precipi_prob = { x:extract_hourly_time, y:48.times.collect{|y| precipitation_proba[y]}, mode:'lines', name:"Precipitation probability", line: {color: '#33ffa2'} }
      data = [temper, humid, precipi_prob]
      layout = { xaxis: {title: "Hours"}, yaxis: {title: "Humidity (%)"} }
      f.plot(data, layout)

    elsif(forecast_24.checked?)
      f.table(
        [%w[---------Date/Time--------- ---------Weather_code--------- Temperatures(°C) Humidity(%) Wind_speed(km/h) Wind_direction(°) Precipitation_probability(%) Snowfall].map{|h| h.light_magenta}] +
        24.times.collect{|x| [extract_hourly_time[x], wmo_trad[x], extract_temp_2m[x], extract_humidity_2m[x], extract_wind_80m[x], wd_dir[x], precipitation_proba[x], snow[x]]})

    elsif(forecast_48.checked?)
      f.table(
        [%w[---------Date/Time--------- ---------Weather_code--------- Temperatures(°C) Humidity(%) Wind_speed(km/h) Wind_direction(°) Precipitation_probability(%) Snowfall].map{|h| h.light_magenta}] +
        48.times.collect{|x| [extract_hourly_time[x], wmo_trad[x], extract_temp_2m[x], extract_humidity_2m[x], extract_wind_80m[x], wd_dir[x], precipitation_proba[x], snow[x]]})

    elsif(curves_view.checked?)
      temper = { x:extract_hourly_time, y:extract_temp_2m, mode:'lines', name:"Temperatures", line: {color: '#ff5733'} }
      humid = { x:extract_hourly_time, y:extract_humidity_2m, mode:'lines', name:"Humidity", line: {color: '#36ff33'} }
      precipi_prob = { x:extract_hourly_time, y:precipitation_proba, mode:'lines', name:"Precipitation probability", line: {color: '#33ffa2'} }
      data = [temper, humid, precipi_prob]
      layout = { xaxis: {title: "Hours"}, yaxis: {title: "Humidity (%)"} }
      f.plot(data, layout)

    else
      f.table(
        [%w[---------Date/Time--------- ---------Weather_code--------- Temperatures(°C) Humidity(%) Wind_speed(km/h) Wind_direction(°) Precipitation_probability(%) Snowfall].map{|h| h.light_magenta}] + 
        extract_hourly_time.count.times.collect{|x| [extract_hourly_time[x], wmo_trad[x], extract_temp_2m[x], extract_humidity_2m[x], extract_wind_80m[x], wd_dir[x], precipitation_proba[x], snow[x]]})
    end

  end
}
f.wait_until_closed
