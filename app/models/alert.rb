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
end
