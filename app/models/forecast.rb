class Forecast
  attr_accessor :forecast
  attr_accessor :rain_max_pop
  attr_accessor :rain_max_pop_datetime

  def initialize(forecast_array)
    @forecast = forecast_array
  end

  def rain?
    # Will return true if rain is in the forecast

    rain = false
    self.forecast.each do |hourly_forecast|
      if hourly_forecast.fetch("weather").first.fetch("main") == "Rain"
        rain = true
        if hourly_forecast.fetch("pop") > self.rain_max_pop
          self.rain_max_pop = hourly_forecast.fetch("pop")
          self.rain_max_pop_datetime = DateTime.strptime(hourly_forecast.fetch("dt").to_s,'%s')
        end
      end
    end
    return rain
  end
  
end