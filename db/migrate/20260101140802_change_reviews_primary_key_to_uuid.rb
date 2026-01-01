class ChangeReviewsPrimaryKeyToUuid < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :review_favorites, :reviews

    # プライマリキーをuuidに変更
    execute "ALTER TABLE reviews DROP CONSTRAINT reviews_pkey;"
    execute "ALTER TABLE reviews ADD PRIMARY KEY (uuid);"

    # 外部キー制約を再設定
    add_foreign_key :review_favorites, :reviews, column: :review_uuid, primary_key: :uuid
  end
end
