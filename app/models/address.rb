class Address

  attr_accessor :address
  attr_accessor :latitude
  attr_accessor :longitude

  def initialize(address)
    @address = address

    url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + self.address + "&key=" + ENV.fetch("GOOGLE_MAPS_KEY")
    raw_data = open(url).read
    parsed_data = JSON.parse(raw_data)
    results_array = parsed_data.fetch("results")
    first_result = results_array.at(0)
    geometry_hash = first_result.fetch("geometry")
    location_hash = geometry_hash.fetch("location")
    @latitude = location_hash.fetch("lat")
    @longitude = location_hash.fetch("lng")
  end

end