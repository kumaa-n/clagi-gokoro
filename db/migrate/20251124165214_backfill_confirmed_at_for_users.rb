class BackfillConfirmedAtForUsers < ActiveRecord::Migration[7.2]
  class User < ApplicationRecord
    self.table_name = "users"
  end

  def up
    User.reset_column_information
    now = Time.current

    User.where(confirmed_at: nil).find_each do |user|
      user.update_columns(
        confirmed_at: now,
        confirmation_sent_at: user.confirmation_sent_at || now
      )
    end
  end
end
