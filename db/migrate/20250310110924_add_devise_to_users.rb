class AddDeviseToUsers < ActiveRecord::Migration[7.2]
  def change
    change_table :users do |t|
      ## Devise fields
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
    end

    add_index :users, :reset_password_token, unique: true
  end
end
