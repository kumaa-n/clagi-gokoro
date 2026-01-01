class UpdateReviewFavoritesUniqueIndexToUseUuid < ActiveRecord::Migration[7.2]
  def change
    remove_index :review_favorites, name: "index_review_favorites_on_review_id"

    add_index :review_favorites, [:user_id, :review_uuid], unique: true, name: "index_review_favorites_on_user_id_and_review_uuid"
  end
end
