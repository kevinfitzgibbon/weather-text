class AddTimeZoneToAlerts < ActiveRecord::Migration[6.0]
  def change
    add_column :alerts, :time_zone, :string
  end
end
