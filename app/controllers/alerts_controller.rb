class AlertsController < ApplicationController
  def index
    matching_alerts = Alert.all

    @list_of_alerts = matching_alerts.order({ :created_at => :desc })

    render({ :template => "alerts/index.html.erb" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_alerts = Alert.where({ :id => the_id })

    @the_alert = matching_alerts.at(0)

    render({ :template => "alerts/show.html.erb" })
  end

  def create
    # First, get latitude and longitude from address using Google Maps API
    address = params.fetch("query_address")
    url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + address + "&key=" + ENV.fetch("GOOGLE_MAPS_KEY")
    raw_data = open(url).read
    parsed_data = JSON.parse(raw_data)
    results_array = parsed_data.fetch("results")
    first_result = results_array.at(0)
    geometry_hash = first_result.fetch("geometry")
    location_hash = geometry_hash.fetch("location")
    latitude = location_hash.fetch("lat")
    longitude = location_hash.fetch("lng")


    # Create the new alert
    the_alert = Alert.new
    the_alert.user_id = @current_user.id
    the_alert.address = params.fetch("query_address")
    the_alert.latitude = latitude
    the_alert.longitude = longitude
    the_alert.Sunday = params.fetch("query_Sunday", false)
    the_alert.Monday = params.fetch("query_Monday", false)
    the_alert.Tuesday = params.fetch("query_Tuesday", false)
    the_alert.Wednesday = params.fetch("query_Wednesday", false)
    the_alert.Thursday = params.fetch("query_Thursday", false)
    the_alert.Friday = params.fetch("query_Friday", false)
    the_alert.Saturday = params.fetch("query_Saturday", false)
    the_alert.alert_sent = false

    # Calculations to determine the next time to send an alert
    # Test for finding the next send data and forceast start and end
    require('time')
    send_date = params.fetch("query_alert_send_time")
    forecast_start_date = params.fetch("query_forecast_start_time")
    forecast_end_date = params.fetch("query_forecast_end_time")
    sunday = params.fetch("query_Sunday", false) == "1"
    monday = params.fetch("query_Monday", false) == "1"
    tuesday = params.fetch("query_Tuesday", false) == "1"
    wednesday = params.fetch("query_Wednesday", false) == "1"
    thursday = params.fetch("query_Thursday", false) == "1"
    friday = params.fetch("query_Friday", false) == "1"
    saturday = params.fetch("query_Saturday", false) == "1"

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
    
    the_alert.alert_send_time = send_date
    the_alert.forecast_start_time = forecast_start_date
    the_alert.forecast_end_time = forecast_end_date

    if the_alert.valid?
      the_alert.save
      redirect_to("/alerts", { :notice => "Alert created successfully." })
    else
      redirect_to("/alerts", { :notice => "Alert failed to create successfully." })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_alert = Alert.where({ :id => the_id }).at(0)

    # First, get latitude and longitude from address using Google Maps API
    address = params.fetch("query_address")
    url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + address + "&key=" + ENV.fetch("GOOGLE_MAPS_KEY")
    raw_data = open(url).read
    parsed_data = JSON.parse(raw_data)
    results_array = parsed_data.fetch("results")
    first_result = results_array.at(0)
    geometry_hash = first_result.fetch("geometry")
    location_hash = geometry_hash.fetch("location")
    latitude = location_hash.fetch("lat")
    longitude = location_hash.fetch("lng")


    # Create the new alert
    the_alert.user_id = @current_user.id
    the_alert.address = params.fetch("query_address")
    the_alert.latitude = latitude
    the_alert.longitude = longitude
    the_alert.Sunday = params.fetch("query_Sunday", false)
    the_alert.Monday = params.fetch("query_Monday", false)
    the_alert.Tuesday = params.fetch("query_Tuesday", false)
    the_alert.Wednesday = params.fetch("query_Wednesday", false)
    the_alert.Thursday = params.fetch("query_Thursday", false)
    the_alert.Friday = params.fetch("query_Friday", false)
    the_alert.Saturday = params.fetch("query_Saturday", false)
    the_alert.alert_sent = false

    # Calculations to determine the next time to send an alert
    # Test for finding the next send data and forceast start and end
    require('time')
    send_date = params.fetch("query_alert_send_time")
    forecast_start_date = params.fetch("query_forecast_start_time")
    forecast_end_date = params.fetch("query_forecast_end_time")
    sunday = params.fetch("query_Sunday", false) == "1"
    monday = params.fetch("query_Monday", false) == "1"
    tuesday = params.fetch("query_Tuesday", false) == "1"
    wednesday = params.fetch("query_Wednesday", false) == "1"
    thursday = params.fetch("query_Thursday", false) == "1"
    friday = params.fetch("query_Friday", false) == "1"
    saturday = params.fetch("query_Saturday", false) == "1"

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
    
    the_alert.alert_send_time = send_date
    the_alert.forecast_start_time = forecast_start_date
    the_alert.forecast_end_time = forecast_end_date

    if the_alert.valid?
      the_alert.save
      redirect_to("/alerts/#{the_alert.id}", { :notice => "Alert updated successfully."} )
    else
      redirect_to("/alerts/#{the_alert.id}", { :alert => "Alert failed to update successfully." })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_alert = Alert.where({ :id => the_id }).at(0)

    the_alert.destroy

    redirect_to("/alerts", { :notice => "Alert deleted successfully."} )
  end
end