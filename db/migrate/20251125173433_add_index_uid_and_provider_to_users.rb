class AddIndexUidAndProviderToUsers < ActiveRecord::Migration[7.2]
  def change
    add_index :users, [:provider, :provider_uid], unique: true
  end
end
