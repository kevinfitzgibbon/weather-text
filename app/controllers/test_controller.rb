class TestController < ApplicationController

  def test
    render({:template => "home_templates/test.html.erb"})
  end

  def address_to_coordinates

    # Convert Address to Coordinates
    @address = params.fetch("query_address")
    url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + @address + "&key=" + ENV.fetch("GOOGLE_MAPS_KEY")
    raw_data = open(url).read
    parsed_data = JSON.parse(raw_data)
    results_array = parsed_data.fetch("results")
    first_result = results_array.at(0)
    geometry_hash = first_result.fetch("geometry")
    location_hash = geometry_hash.fetch("location")
    @latitude = location_hash.fetch("lat").to_s
    @longitude = location_hash.fetch("lng").to_s

    # Convert Coordinates to Weather
    url = "https://api.openweathermap.org/data/2.5/onecall?lat=" + @latitude + "&lon=" + @longitude + "&exclude=current,minutely,daily&units=imperial&appid=" + ENV.fetch("OPEN_WEATHER_KEY")
    raw_data = open(url).read
    parsed_data = JSON.parse(raw_data)
    @timezone = parsed_data.fetch("timezone")
    @timezone_offset = parsed_data.fetch("timezone_offset")
    @hourly_array = parsed_data.fetch("hourly")
    @first_result = @hourly_array.at(0)
    @first_dt = @first_result.fetch("dt").to_s
    require 'date'
    @first_dt = DateTime.strptime(@first_dt,'%s')
    @first_dt = @first_dt.strftime("%b %-d, %Y %-l%P") 

    render({:template => "home_templates/test2.html.erb"})
  end

end
