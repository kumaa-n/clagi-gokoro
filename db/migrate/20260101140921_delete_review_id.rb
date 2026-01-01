class DeleteReviewId < ActiveRecord::Migration[7.2]
  def change
    remove_column :review_favorites, :review_id, :bigint
    remove_column :reviews, :id, :bigint
  end
end
