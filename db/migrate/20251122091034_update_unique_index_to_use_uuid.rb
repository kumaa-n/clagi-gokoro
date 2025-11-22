class UpdateUniqueIndexToUseUuid < ActiveRecord::Migration[7.2]
  def change
    remove_index :reviews, name: "index_reviews_on_song_id"

    add_index :reviews, [:user_id, :song_uuid], unique: true
  end
end
