class AddSongUuidToReviews < ActiveRecord::Migration[7.2]
  # マイグレーション内でモデルを定義
  def up
    add_column :reviews, :song_uuid, :uuid
    add_index :reviews, :song_uuid

    # 既存データの移行
    Review.reset_column_information

    # 直接SQLを使用する方法
    execute <<-SQL
      UPDATE reviews
      SET song_uuid = songs.uuid
      FROM songs
      WHERE reviews.song_id = songs.id
    SQL

    change_column_null :reviews, :song_uuid, false
  end

  def down
    remove_column :reviews, :song_uuid
  end
end
