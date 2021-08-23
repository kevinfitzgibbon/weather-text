class TestController < ApplicationController

  def test

    # Test for finding the next send data and forceast start and end
    require('time')
    send_date = "2021-08-22 21:00:00 -0400"
    forecast_start_date = "2021-08-22 12:12:00 -0400"
    forecast_end_date = "2021-08-22 00:00:00 -0400"
    sunday = false
    monday = false
    tuesday = false
    wednesday = false
    thursday = false
    friday = false
    saturday = true

    # Parsing into Time with Zone so that daylight savings won't affect the time
    send_date = ActiveSupport::TimeZone[@current_user.time_zone].parse(send_date)

    # if the send date has passed, set it to today at the same time
    if send_date - DateTime.current < 0
      send_date = DateTime.current.midnight + (send_date - send_date.midnight).seconds
      # if it's today and already passed, move it to tomorrow
      if send_date - DateTime.current < 0
        send_date = send_date + 1.day
      end
    end
    send_date_weekday = send_date.strftime('%A')


    # Check if that date is in the schedule
    found_the_next_send_date = false
    while found_the_next_send_date == false
      if (send_date_weekday == "Sunday" && sunday == true) || (send_date_weekday == "Monday" && monday == true) || (send_date_weekday == "Tuesday" && tuesday == true) || (send_date_weekday == "Wednesday" && wednesday == true) || (send_date_weekday == "Thursday" && thursday == true) || (send_date_weekday == "Friday" && friday == true) || (send_date_weekday == "Saturday" && saturday == true)
        found_the_next_send_date = true
      else
        send_date = send_date + 1.day
        send_date_weekday = send_date.strftime('%A')
      end
    end

    # The forecast start time will be the next time match after or equal to the send time
    # Parsing into Time with Zone so that daylight savings won't affect the time
    forecast_start_date = ActiveSupport::TimeZone[@current_user.time_zone].parse(forecast_start_date)

    # if the forecast start is over a day past the send date, back it up
    while forecast_start_date - send_date >= 60*60*24
      forecast_start_date = forecast_start_date - 1.day
    end

    # if the forecast start is before the send date, move it forward
    while forecast_start_date - send_date < 0 # Equal to 0 is ok
      forecast_start_date = forecast_start_date + 1.day
    end

    # The forecast end time will be the next time match after or equal to the start time
    # Parsing into Time with Zone so that daylight savings won't affect the time
    forecast_end_date = ActiveSupport::TimeZone[@current_user.time_zone].parse(forecast_end_date)

    # if the forecast end is over a day past the start date, back it up
    while forecast_end_date - forecast_start_date >= 60*60*24
      forecast_end_date = forecast_end_date - 1.day
    end

    # if the forecast end is before the start date, move it forward
    while forecast_end_date - forecast_start_date < 0 # Equal to 0 is ok
      forecast_end_date = forecast_end_date + 1.day
    end

    @result = send_date

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

    # Check to see if rain is in the forecast and record the highest PoP if it is 
    @rain = false
    @max_pop = 0
    @hourly_array.each do |hourly_forecast|
      if hourly_forecast.fetch("weather").first.fetch("main") == "Rain"
        @rain = true
        if hourly_forecast.fetch("pop") > @max_pop
          @max_pop = hourly_forecast.fetch("pop")
          @datetime_of_max_pop = 
          DateTime.strptime(hourly_forecast.fetch("dt").to_s,'%s')
        end
      end
    end

    render({:template => "home_templates/test2.html.erb"})
  end

end
