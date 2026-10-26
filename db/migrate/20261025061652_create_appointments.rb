class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.string :patient_name, null: false
      t.string :patient_phone, null: false
      t.date :appointment_date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :appointments, [ :doctor_id, :appointment_date, :start_time ]
  end
end
