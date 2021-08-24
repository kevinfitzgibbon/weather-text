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
    @forecast_start_time = params.fetch("query_forecast_start_time")
    @forecast_end_time = params.fetch("query_forecast_end_time")

    # Put into DateTime with Zone
    @forecast_start = ActiveSupport::TimeZone[@current_user.time_zone].parse(@forecast_start_time)
    @forecast_end = ActiveSupport::TimeZone[@current_user.time_zone].parse(@forecast_end_time)

    # Move start and end back to nearest hour
    @forecast_start = @forecast_start - @forecast_start.sec - 60 * @forecast_start.min
    @forecast_end = @forecast_end - @forecast_end.sec - 60 * @forecast_end.min

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

    # Create the message to send if rain is in the forecast
    if @rain
      @message_to_send = "Rain is in the forecast, with up to a " + (@max_pop*100).round(2).to_i.to_s + "% chance by " + @datetime_of_max_pop.in_time_zone(@current_user.time_zone).strftime("%-l%P %Z ")   
      if @datetime_of_max_pop.in_time_zone(@current_user.time_zone).to_date == Date.current 
        @message_to_send = @message_to_send + "today."
      elsif @datetime_of_max_pop.in_time_zone(@current_user.time_zone).to_date == Date.current + 1.day
        @message_to_send = @message_to_send + "tomorrow."
      else
        @message_to_send = @message_to_send + @datetime_of_max_pop.in_time_zone(@current_user.time_zone).strftime("%A").to_s + "."
      end
    

      # Then send the message
      # Retrieve your credentials from secure storage
      twilio_sid = ENV.fetch("TWILIO_ACCOUNT_SID")
      twilio_token = ENV.fetch("TWILIO_AUTH_TOKEN")
      twilio_sending_number = ENV.fetch("TWILIO_SENDING_PHONE_NUMBER")

      # Create an instance of the Twilio Client and authenticate with your API key
      twilio_client = Twilio::REST::Client.new(twilio_sid, twilio_token)

      # Craft your SMS as a Hash with three keys
      sms_parameters = {
        :from => twilio_sending_number,
        :to => @current_user.phone_number, # Put your own phone number here if you want to see it in action
        :body => @message_to_send
      }

      # Send your SMS!
      twilio_client.api.account.messages.create(sms_parameters)
    end

    render({:template => "home_templates/test2.html.erb"})
  end

  def text
    # Retrieve your credentials from secure storage
    twilio_sid = ENV.fetch("TWILIO_ACCOUNT_SID")
    twilio_token = ENV.fetch("TWILIO_AUTH_TOKEN")
    twilio_sending_number = ENV.fetch("TWILIO_SENDING_PHONE_NUMBER")

    # Create an instance of the Twilio Client and authenticate with your API key
    twilio_client = Twilio::REST::Client.new(twilio_sid, twilio_token)

    # Craft your SMS as a Hash with three keys
    sms_parameters = {
      :from => twilio_sending_number,
      :to => @current_user.phone_number, # Put your own phone number here if you want to see it in action
      :body => "It's going to rain today — take an umbrella!"
    }

    # Send your SMS!
    twilio_client.api.account.messages.create(sms_parameters)

    render({:template => "home_templates/test.html.erb"})
  end

end