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

ActiveRecord::Schema.define(version: 2020_08_18_162618) do

  create_table "activities", force: :cascade do |t|
    t.integer "trip_id"
    t.string "activity_api_id"
  end

  create_table "attractions", force: :cascade do |t|
    t.string "attraction_api_id"
    t.integer "trip_id"
  end

  create_table "authentications", force: :cascade do |t|
    t.integer "user_id"
    t.string "username"
    t.string "password"
  end

  create_table "cities", force: :cascade do |t|
    t.integer "country_id"
    t.string "name"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
  end

  create_table "itineraries", force: :cascade do |t|
    t.integer "trip_id"
    t.integer "country_id"
    t.date "itinerary_start"
    t.date "itinerary_end"
  end

  create_table "trips", force: :cascade do |t|
    t.integer "user_id"
    t.date "departure"
    t.date "return"
    t.boolean "completed?", default: false
  end

  create_table "users", force: :cascade do |t|
    t.string "f_name"
    t.string "l_name"
    t.string "address"
    t.string "email"
  end

end
