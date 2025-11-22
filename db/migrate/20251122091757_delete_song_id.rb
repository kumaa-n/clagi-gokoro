class DeleteSongId < ActiveRecord::Migration[7.2]
  def change
    remove_column :reviews, :song_id, :bigint
    remove_column :songs, :id, :bigint
  end
end
