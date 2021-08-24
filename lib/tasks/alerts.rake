task({ :send_alerts => :environment }) do
  Alert.where("alert_send_time < ? AND alert_sent == ?", Time.current, false).each do |alert|
    # These alerts have not been sent, but need to be

    # Get weather from coordinates and forecast times
    filtered_forecast = alert.filtered_hourly_forecast 
    
    # Check for rain
    if filtered_forecast.rain?
      # Send the message!
    end

    # Create and send the message if it needs one using phone number
    # p alert.user.phone_number

    # # Mark the alert as sent
    # p alert.alert_sent

    # # Calculate when the new alert time, forecast times
    # p alert.alert_send_time
    # p alert.Sunday
    # p alert.Monday
    # p alert.Tuesday
    # p alert.Wednesday
    # p alert.Thursday
    # p alert.Friday
    # # p alert.Saturday
    # p alert.forecast_start_time
    # p alert.forecast_end_time

    # # Mark the alert as not sent again
    # p alert.alert_sent
  end
end