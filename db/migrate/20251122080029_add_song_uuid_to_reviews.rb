class AddSongUuidToReviews < ActiveRecord::Migration[7.2]
  def change
    add_column :reviews, :song_uuid, :uuid
    add_index :reviews, :song_uuid

    # 既存データの移行
    Review.reset_column_information
    Review.find_each do |review|
      review.update_column(:song_uuid, Song.find(review.song_id).uuid)
    end

    # null制約を追加
    change_column_null :reviews, :song_uuid, false
  end
end
