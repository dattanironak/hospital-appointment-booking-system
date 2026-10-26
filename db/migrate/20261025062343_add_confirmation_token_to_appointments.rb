class AddConfirmationTokenToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :confirmation_token, :string
    add_index :appointments, :confirmation_token, unique: true
  end
end
