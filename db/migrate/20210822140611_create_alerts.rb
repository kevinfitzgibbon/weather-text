class CreateAlerts < ActiveRecord::Migration[6.0]
  def change
    create_table :alerts do |t|
      t.integer :user_id
      t.string :address
      t.float :latitude
      t.float :longitude
      t.boolean :Sunday
      t.boolean :Monday
      t.boolean :Tuesday
      t.boolean :Wednesday
      t.boolean :Thursday
      t.boolean :Friday
      t.boolean :Saturday
      t.time :alert_send_time
      t.boolean :alert_sent
      t.time :forecast_start_time
      t.time :forecast_end_time

      t.timestamps
    end
  end
end
