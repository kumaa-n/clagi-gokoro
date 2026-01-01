class AddUuidToReviews < ActiveRecord::Migration[7.2]
  def change
    add_column :reviews, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_index :reviews, :uuid, unique: true

    # 既存データのuuidカラムにデータを追加
    Review.reset_column_information # モデルの操作を行うのでキャッシュを削除
    Review.find_each { |review| review.update_column(:uuid, SecureRandom.uuid) }
  end
end
