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
#  alert_send_time     :time
#  alert_sent          :boolean
#  forecast_end_time   :time
#  forecast_start_time :time
#  latitude            :float
#  longitude           :float
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :integer
#
class Alert < ApplicationRecord
  
end
