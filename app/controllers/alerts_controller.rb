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


    require 'time'

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
    the_alert.alert_send_time = params.fetch("query_alert_send_time")
    the_alert.alert_sent = params.fetch("query_alert_sent", false)
    the_alert.forecast_start_time = params.fetch("query_forecast_start_time")
    the_alert.forecast_end_time = params.fetch("query_forecast_end_time")

    #- Time.now.in_time_zone(@current_user.time_zone).utc_offset
    #ActiveSupport::TimeZone.new('America/New_York').local_to_utc(t)
    #Time.zone_offset(@current_user.time_zone)

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

    the_alert.user_id = params.fetch("query_user_id")
    the_alert.address = params.fetch("query_address")
    the_alert.latitude = params.fetch("query_latitude")
    the_alert.longitude = params.fetch("query_longitude")
    the_alert.Sunday = params.fetch("query_Sunday", false)
    the_alert.Monday = params.fetch("query_Monday", false)
    the_alert.Tuesday = params.fetch("query_Tuesday", false)
    the_alert.Wednesday = params.fetch("query_Wednesday", false)
    the_alert.Thursday = params.fetch("query_Thursday", false)
    the_alert.Friday = params.fetch("query_Friday", false)
    the_alert.Saturday = params.fetch("query_Saturday", false)
    the_alert.alert_send_time = params.fetch("query_alert_send_time")
    the_alert.alert_sent = params.fetch("query_alert_sent", false)
    the_alert.forecast_start_time = params.fetch("query_forecast_start_time")
    the_alert.forecast_end_time = params.fetch("query_forecast_end_time")

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
