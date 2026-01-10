class AddNormalizedFieldsToSongs < ActiveRecord::Migration[7.2]
  def change
    add_column :songs, :normalized_title, :string
    add_column :songs, :normalized_composer, :string
    add_column :songs, :normalized_arranger, :string

    # 検索パフォーマンス向上のためインデックスを追加
    add_index :songs, :normalized_title
    add_index :songs, :normalized_composer
    add_index :songs, :normalized_arranger

    # 既存データの正規化カラムを更新
    reversible do |dir|
      dir.up do
        # カラム追加後にモデルのカラム情報キャッシュをリセット
        Song.reset_column_information

        Song.find_each do |song|
          song.update_columns(
            normalized_title: Song.normalize_for_duplicate_check(song.title),
            normalized_composer: Song.normalize_for_duplicate_check(song.composer),
            normalized_arranger: Song.normalize_for_duplicate_check(song.arranger)
          )
        end
      end
    end
  end
end
