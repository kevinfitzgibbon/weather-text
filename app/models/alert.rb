# == Schema Information
#
# Table name: alerts
#
#  id                  :integer          not null, primary key
#  Friday              :boolean
#  Monday              :boolean
#  Saturday            :boolean
#  Sunday              :boolean
#  Thursday            :boolean
#  Tuesday             :boolean
#  Wednesday           :boolean
#  address             :string
#  alert_send_time     :datetime
#  alert_sent          :boolean
#  forecast_end_time   :datetime
#  forecast_start_time :datetime
#  latitude            :float
#  longitude           :float
#  time_zone           :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :integer
#
class Alert < ApplicationRecord
  belongs_to(:user)


  def current_hourly_forecast
    # Looks up the hourly weather for a location and returns all results
    url = "https://api.openweathermap.org/data/2.5/onecall?lat=" + self.latitude.to_s + "&lon=" + self.longitude.to_s + "&exclude=current,minutely,daily&units=imperial&appid=" + ENV.fetch("OPEN_WEATHER_KEY")
    raw_data = open(url).read
    parsed_data = JSON.parse(raw_data)
    hourly_array = parsed_data.fetch("hourly")
    return hourly_array
  end

  def filtered_hourly_forecast
    # Looks up the hourly weather for a location and returns all results between the forecast start and end time
    url = "https://api.openweathermap.org/data/2.5/onecall?lat=" + self.latitude.to_s + "&lon=" + self.longitude.to_s + "&exclude=current,minutely,daily&units=imperial&appid=" + ENV.fetch("OPEN_WEATHER_KEY")
    raw_data = open(url).read
    parsed_data = JSON.parse(raw_data)
    hourly_array = parsed_data.fetch("hourly")

    # Determine start time of forecast
    forecast_start = self.forecast_start_time

    # Move start back to nearest hour
    forecast_start = forecast_start - forecast_start.sec - 60 * forecast_start.min

    # Determine end time of forecast
    forecast_end = self.forecast_end_time

    # Move end back to nearest hour
    forecast_end = forecast_end - forecast_end.sec - 60 * forecast_end.min

    results_array=[]
    hourly_array.each do |hourly_forecast|
      forecast_hour = DateTime.strptime(hourly_forecast.fetch("dt").to_s,'%s')
      if forecast_hour >= forecast_start && forecast_hour <= forecast_end
        results_array.push(hourly_forecast)
      end
    end
  return Forecast.new(results_array)
  end

  def update_to_next_alert_time
    require('time')

    # Parsing into Time with Zone so that daylight savings won't affect the time
    send_date = ActiveSupport::TimeZone[self.user.time_zone].parse(self.alert_send_time.to_s)

    # if the send date has passed, set it to today at the same time
    if send_date - DateTime.current < 0
      send_date = DateTime.current.in_time_zone(self.user.time_zone).midnight + (send_date - send_date.midnight).seconds
      # if it's today and already passed, move it to tomorrow
      if send_date - DateTime.current < 0
        send_date = send_date + 1.day
      end
    end
    send_date_weekday = send_date.strftime('%A')

    # Check if that date is in the schedule
    found_the_next_send_date = false
    while found_the_next_send_date == false
      if (send_date_weekday == "Sunday" && self.Sunday == true) || (send_date_weekday == "Monday" && self.Monday == true) || (send_date_weekday == "Tuesday" && self.Tuesday == true) || (send_date_weekday == "Wednesday" && self.Wednesday == true) || (send_date_weekday == "Thursday" && self.Thursday == true) || (send_date_weekday == "Friday" && self.Friday == true) || (send_date_weekday == "Saturday" && self.Saturday == true)
        found_the_next_send_date = true
      else
        send_date = send_date + 1.day
        send_date_weekday = send_date.strftime('%A')
      end
    end

    # The forecast start time will be the next time match after or equal to the send time
    # Parsing into Time with Zone so that daylight savings won't affect the time
    forecast_start_date = ActiveSupport::TimeZone[self.user.time_zone].parse(self.forecast_start_time.to_s)

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
    forecast_end_date = ActiveSupport::TimeZone[self.user.time_zone].parse(self.forecast_end_time.to_s)

    # if the forecast end is over a day past the start date, back it up
    while forecast_end_date - forecast_start_date >= 60*60*24
      forecast_end_date = forecast_end_date - 1.day
    end

    # if the forecast end is before the start date, move it forward
    while forecast_end_date - forecast_start_date < 0 # Equal to 0 is ok
      forecast_end_date = forecast_end_date + 1.day
    end
    
    self.alert_send_time = send_date
    self.forecast_start_time = forecast_start_date
    self.forecast_end_time = forecast_end_date
    self.alert_sent = false
  end

  def no_days_selected?
    if self.Sunday == false && self.Monday == false && self.Tuesday == false && self.Wednesday == false && self.Thursday == false && self.Friday == false && self.Saturday == false
      return true
    else
      return false
    end
  end
end
