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
    @latitude = location_hash.fetch("lat")
    @longitude = location_hash.fetch("lng")

    # Convert Coordinates to Weather
    url = "https://api.openweathermap.org/data/2.5/onecall?lat=39.2699&lon=-76.6073&exclude=current,minutely,daily&units=imperial&appid="

    render({:template => "home_templates/test2.html.erb"})
  end

end
