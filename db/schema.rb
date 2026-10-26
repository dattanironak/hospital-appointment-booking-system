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

ActiveRecord::Schema[8.1].define(version: 2026_10_25_062343) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.bigint "doctor_id", null: false
    t.string "patient_name", null: false
    t.string "patient_phone", null: false
    t.date "appointment_date", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.index ["confirmation_token"], name: "index_appointments_on_confirmation_token", unique: true
    t.index ["doctor_id", "appointment_date", "start_time"], name: "idx_on_doctor_id_appointment_date_start_time_c9dd72390f"
    t.index ["doctor_id"], name: "index_appointments_on_doctor_id"
  end

  create_table "availability_rules", force: :cascade do |t|
    t.bigint "doctor_id", null: false
    t.integer "weekday", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.integer "slot_duration_minutes", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id", "weekday"], name: "index_availability_rules_on_doctor_id_and_weekday"
    t.index ["doctor_id"], name: "index_availability_rules_on_doctor_id"
  end

  create_table "blocked_slots", force: :cascade do |t|
    t.bigint "doctor_id", null: false
    t.date "date", null: false
    t.time "start_time"
    t.time "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doctor_id", "date"], name: "index_blocked_slots_on_doctor_id_and_date"
    t.index ["doctor_id"], name: "index_blocked_slots_on_doctor_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.string "name", null: false
    t.string "specialty"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "appointments", "users", column: "doctor_id"
  add_foreign_key "availability_rules", "users", column: "doctor_id"
  add_foreign_key "blocked_slots", "users", column: "doctor_id"
end
