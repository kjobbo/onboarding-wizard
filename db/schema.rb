# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_27_000007) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.datetime "completed_at"
    t.string "country"
    t.datetime "created_at", null: false
    t.bigint "onboarding_id", null: false
    t.string "postcode"
    t.datetime "updated_at", null: false
    t.index ["onboarding_id"], name: "index_addresses_on_onboarding_id", unique: true
  end

  create_table "onboardings", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "current_step", default: "personal_details", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_onboardings_on_token", unique: true
  end

  create_table "personal_details", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.bigint "onboarding_id", null: false
    t.datetime "updated_at", null: false
    t.index ["onboarding_id"], name: "index_personal_details_on_onboarding_id", unique: true
  end

  create_table "preferences", force: :cascade do |t|
    t.string "billing_period"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.boolean "newsletter_opt_in", default: false, null: false
    t.bigint "onboarding_id", null: false
    t.string "plan"
    t.datetime "updated_at", null: false
    t.index ["onboarding_id"], name: "index_preferences_on_onboarding_id", unique: true
  end

  add_foreign_key "addresses", "onboardings"
  add_foreign_key "personal_details", "onboardings"
  add_foreign_key "preferences", "onboardings"
end
