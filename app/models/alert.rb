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
end
