task({ :send_alerts => :environment }) do
  Alert.where("alert_send_time < Time.current, false).each do |alert|
    # These alerts have not been sent, but need to be

    # Get weather from coordinates and forecast times
    filtered_forecast = alert.filtered_hourly_forecast 
    
    # Check for rain
    if filtered_forecast.rain?

      # Create the message text
      message = Message.new(alert, filtered_forecast)

      # Send the message to the user
      message.send_text
    end

    # Mark the message as complete
    alert.alert_sent = true

    # Update to the next send and forecast times
    alert.update_to_next_alert_time # alert_sent is changed to false here

    if alert.valid?
      alert.save
    end
  end
end