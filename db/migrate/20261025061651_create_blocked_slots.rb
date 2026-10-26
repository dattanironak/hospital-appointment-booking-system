class CreateBlockedSlots < ActiveRecord::Migration[8.1]
  def change
    create_table :blocked_slots do |t|
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.date :date, null: false
      t.time :start_time
      t.time :end_time

      t.timestamps
    end

    add_index :blocked_slots, [ :doctor_id, :date ]
  end
end
