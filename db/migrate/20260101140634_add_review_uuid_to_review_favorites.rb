class AddReviewUuidToReviewFavorites < ActiveRecord::Migration[7.2]
  def up
    add_column :review_favorites, :review_uuid, :uuid
    add_index :review_favorites, :review_uuid

    # 既存データの移行
    ReviewFavorite.reset_column_information
    ReviewFavorite.find_each do |review_favorite|
      review = Review.find_by(id: review_favorite.review_id)
      review_favorite.update_column(:review_uuid, review.uuid) if review
    end

    change_column_null :review_favorites, :review_uuid, false
  end

  def down
    remove_column :review_favorites, :review_uuid
  end
end
