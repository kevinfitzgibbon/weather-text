
class AlertsController < ApplicationController
  def index
    matching_alerts = Alert.where({ :user_id => @current_user.id })

    @list_of_alerts = matching_alerts.order({ :created_at => :desc })

    render({ :template => "alerts/index.html.erb" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_alerts = Alert.where({ :id => the_id })

    @the_alert = matching_alerts.at(0)

    if @the_alert.user.id == @current_user.id
      render({ :template => "alerts/show.html.erb" })
    else
      redirect_to("/alerts", { :alert => "You cannot view another user's alerts."} )
    end
  end

  def create

    # Address class calculates longitutde and latitude
    address = Address.new(params.fetch("query_address"))

    # Create the new alert
    the_alert = Alert.new
    the_alert.user_id = @current_user.id
    the_alert.address = address.address
    the_alert.latitude = address.latitude
    the_alert.longitude = address.longitude
    the_alert.Sunday = params.fetch("query_Sunday", false)
    the_alert.Monday = params.fetch("query_Monday", false)
    the_alert.Tuesday = params.fetch("query_Tuesday", false)
    the_alert.Wednesday = params.fetch("query_Wednesday", false)
    the_alert.Thursday = params.fetch("query_Thursday", false)
    the_alert.Friday = params.fetch("query_Friday", false)
    the_alert.Saturday = params.fetch("query_Saturday", false)
    the_alert.alert_sent = false

    if the_alert.no_days_selected?
      redirect_to("/alerts", { :alert => "At least one day must be selected." })
    else

      the_alert.alert_send_time = params.fetch("query_alert_send_time")
      the_alert.forecast_start_time = params.fetch("query_forecast_start_time")
      the_alert.forecast_end_time = params.fetch("query_forecast_end_time")

      the_alert.update_to_next_alert_time # updates the alert send time and forecast times to their next message times

      if the_alert.valid?
        the_alert.save
        redirect_to("/alerts", { :notice => "Alert created successfully." })
      else
        redirect_to("/alerts", { :notice => "Alert failed to create successfully." })
      end
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_alert = Alert.where({ :id => the_id }).at(0)

    # Address class calculates longitutde and latitude
    address = Address.new(params.fetch("query_address"))

    # Update the alert
    the_alert.user_id = @current_user.id
    the_alert.address = address.address
    the_alert.latitude = address.latitude
    the_alert.longitude = address.longitude
    the_alert.Sunday = params.fetch("query_Sunday", false)
    the_alert.Monday = params.fetch("query_Monday", false)
    the_alert.Tuesday = params.fetch("query_Tuesday", false)
    the_alert.Wednesday = params.fetch("query_Wednesday", false)
    the_alert.Thursday = params.fetch("query_Thursday", false)
    the_alert.Friday = params.fetch("query_Friday", false)
    the_alert.Saturday = params.fetch("query_Saturday", false)
    the_alert.alert_sent = false

    # Make sure at least one date was selected
    if the_alert.no_days_selected?
      redirect_to("/alerts/#{the_alert.id}", { :alert => "At least one day must be selected." })
    else

      the_alert.alert_send_time = params.fetch("query_alert_send_time")
      the_alert.forecast_start_time = params.fetch("query_forecast_start_time")
      the_alert.forecast_end_time = params.fetch("query_forecast_end_time")

      the_alert.update_to_next_alert_time # updates the alert send time and forecast times to their next message times

      if the_alert.valid?
        the_alert.save
        redirect_to("/alerts/#{the_alert.id}", { :notice => "Alert updated successfully."} )
      else
        redirect_to("/alerts/#{the_alert.id}", { :alert => "Alert failed to update successfully." })
      end
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_alert = Alert.where({ :id => the_id }).at(0)
    if the_alert.user.id == @current_user.id
      the_alert.destroy
      redirect_to("/alerts", { :notice => "Alert deleted successfully."} )
    else
      redirect_to("/alerts", { :alert => "You cannot delete another user's alerts."} )
    end
  end
end