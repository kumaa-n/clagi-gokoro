class ChangeSongsPrimaryKeyToUuid < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :reviews, :songs

    # プライマリキーをuuidに変更
    execute "ALTER TABLE songs DROP CONSTRAINT songs_pkey;"
    execute "ALTER TABLE songs ADD PRIMARY KEY (uuid);"

    # 外部キー制約を再設定
    add_foreign_key :reviews, :songs, column: :song_uuid, primary_key: :uuid
  end
end
