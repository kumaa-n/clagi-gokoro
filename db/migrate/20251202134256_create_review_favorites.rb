class CreateReviewFavorites < ActiveRecord::Migration[7.2]
  def change
    create_table :review_favorites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :review, null: false, foreign_key: true

      t.timestamps
    end

    add_index :review_favorites, [:user_id, :review_id], unique: true
  end
end
