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


    # Determine start time of forecast
    @forecast_start = params.fetch("query_forecast_start_time")
    @forecast_end = params.fetch("query_forecast_end_time")

    # Put into DateTime with Zone
    @forecast_start = ActiveSupport::TimeZone[@current_user.time_zone].parse(@forecast_start)
    @forecast_end = ActiveSupport::TimeZone[@current_user.time_zone].parse(@forecast_end)

    # Move start and end back to nearest hour
    @forecast_start = @forecast_start - @forecast_start.sec - 60 * @forecast_start.min
    @forecast_end = @forecast_end - @forecast_end.sec - 60 * @forecast_end.min

    # Move start and end back to nearest hour
    @forecast_start = @forecast_start - @forecast_start.sec - 60 * @forecast_start.min
    @forecast_end = @forecast_end - @forecast_end.sec - 60 * @forecast_end.min

    # Round start time up and end time down to nearest hour


    # Check to see if rain is in the forecast and record the highest PoP if it is 
    @rain = false
    @max_pop = 0
    @results_array = Array.new
    @hourly_array.each do |hourly_forecast|
      forecast_hour = DateTime.strptime(hourly_forecast.fetch("dt").to_s,'%s')
      if forecast_hour >= @forecast_start && forecast_hour <= @forecast_end
        @results_array.push(hourly_forecast)
        if hourly_forecast.fetch("weather").first.fetch("main") == "Rain"
          @rain = true
          if hourly_forecast.fetch("pop") > @max_pop
            @max_pop = hourly_forecast.fetch("pop")
            @datetime_of_max_pop = DateTime.strptime(hourly_forecast.fetch("dt").to_s,'%s')
          end
        end
      end
    end

    render({:template => "home_templates/test2.html.erb"})
  end

  def text
    # Download the twilio-ruby library from twilio.com/docs/libraries/ruby
    require 'twilio-ruby'

    # To set up environmental variables, see http://twil.io/secure
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = 'ca40cb8e7f25fda5b5204feb0837fec1'
    client = Twilio::REST::Client.new(account_sid, auth_token)

    from = '+16672131068' # Your Twilio number
    to = '+3143223136' # Your mobile phone number

    client.messages.create(
    from: from,
    to: to,
    body: "Hey friend!"
    )
  end

end