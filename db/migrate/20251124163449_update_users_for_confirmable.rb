class UpdateUsersForConfirmable < ActiveRecord::Migration[7.2]
  def change
    change_column_default :users, :email, from: "", to: nil
    change_column_null :users, :email, true

    change_table :users, bulk: true do |t|
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email
    end

    remove_index :users, :email
    add_index :users, :email, unique: true, where: "email IS NOT NULL AND email <> ''"
    add_index :users, :confirmation_token, unique: true
  end
end
