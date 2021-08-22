# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_08_22_194612) do

  create_table "alerts", force: :cascade do |t|
    t.integer "user_id"
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.boolean "Sunday"
    t.boolean "Monday"
    t.boolean "Tuesday"
    t.boolean "Wednesday"
    t.boolean "Thursday"
    t.boolean "Friday"
    t.boolean "Saturday"
    t.time "alert_send_time"
    t.boolean "alert_sent"
    t.time "forecast_start_time"
    t.time "forecast_end_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "phone_number"
    t.boolean "phone_confirmed"
    t.boolean "mail_confirmed"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "time_zone"
  end

end
