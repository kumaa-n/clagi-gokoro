class AddUuidToSongs < ActiveRecord::Migration[7.2]
  def change
    add_column :songs, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_index :songs, :uuid, unique: true

    # 既存データのuuidカラムにデータを追加
    Song.reset_column_information # モデルの操作を行うのでキャッシュを削除
    Song.find_each { |song| song.update_column(:uuid, SecureRandom.uuid) }
  end
end
