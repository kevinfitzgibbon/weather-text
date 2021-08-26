# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string
#  mail_confirmed  :boolean
#  password_digest :string
#  phone_confirmed :boolean
#  phone_number    :string
#  time_zone       :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
  validates :email, :uniqueness => { :case_sensitive => false }
  validates :email, :presence => true
  validates :phone_number, :presence => true
  has_secure_password
  has_many(:alerts)
end
