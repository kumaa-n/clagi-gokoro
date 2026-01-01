class AddReviewUuidToReviewFavorites < ActiveRecord::Migration[7.2]
  def up
    add_column :review_favorites, :review_uuid, :uuid
    add_index :review_favorites, :review_uuid

    # 既存データの移行
    ReviewFavorite.reset_column_information
    execute <<-SQL
      UPDATE review_favorites
      SET review_uuid = reviews.uuid
      FROM reviews
      WHERE review_favorites.review_id = reviews.id
    SQL

    change_column_null :review_favorites, :review_uuid, false
  end

  def down
    remove_column :review_favorites, :review_uuid
  end
end
