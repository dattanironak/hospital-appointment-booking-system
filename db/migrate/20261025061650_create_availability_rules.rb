class CreateAvailabilityRules < ActiveRecord::Migration[8.1]
  def change
    create_table :availability_rules do |t|
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.integer :weekday, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :slot_duration_minutes, null: false

      t.timestamps
    end

    add_index :availability_rules, [ :doctor_id, :weekday ]
  end
end
