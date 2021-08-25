class Message
  attr_accessor :alert
  attr_accessor :forecast
  attr_accessor :message

  def initialize(alert, forecast)
    @alert = alert
    @forecast = forecast

    require('time')

    if forecast.rain?
      self.message = "Rain is in the forecast for " + self.alert.address.downcase.titleize + ", with up to a " + (self.forecast.rain_max_pop*100).round(2).to_i.to_s + "% chance by " + self.forecast.rain_max_pop_datetime.in_time_zone(self.alert.user.time_zone).strftime("%-l%P %Z ")   
      if self.forecast.rain_max_pop_datetime.in_time_zone(self.alert.user.time_zone).to_date == DateTime.current.in_time_zone(self.alert.user.time_zone).to_date 
        self.message = self.message + "today."
      elsif self.forecast.rain_max_pop_datetime.in_time_zone(self.alert.user.time_zone).to_date == DateTime.current.in_time_zone(self.alert.user.time_zone).to_date + 1.day
        self.message = self.message + "tomorrow."
      else
        self.message = self.message + self.forecast.rain_max_pop_datetime.in_time_zone(self.alert.user.time_zone).strftime("%A").to_s + "."
      end
    end
  end

  def send_text
    # Retrieve your credentials from secure storage
    twilio_sid = ENV.fetch("TWILIO_ACCOUNT_SID")
    twilio_token = ENV.fetch("TWILIO_AUTH_TOKEN")
    twilio_sending_number = ENV.fetch("TWILIO_SENDING_PHONE_NUMBER")

    # Create an instance of the Twilio Client and authenticate with your API key
    twilio_client = Twilio::REST::Client.new(twilio_sid, twilio_token)

    # Craft your SMS as a Hash with three keys
    sms_parameters = {
      :from => twilio_sending_number,
      :to => self.alert.user.phone_number, # Put your own phone number here if you want to see it in action
      :body => self.message
    }

    # Send your SMS!
    twilio_client.api.account.messages.create(sms_parameters)
  end
  
end