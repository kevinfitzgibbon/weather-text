class ChangeAlertTimesToDateTimes < ActiveRecord::Migration[6.0]
  def change
    remove_column :alerts, :alert_send_time
    remove_column :alerts, :forecast_start_time 
    remove_column :alerts, :forecast_end_time 
    add_column :alerts, :alert_send_time, :datetime
    add_column :alerts, :forecast_start_time , :datetime
    add_column :alerts, :forecast_end_time , :datetime
  end
end
