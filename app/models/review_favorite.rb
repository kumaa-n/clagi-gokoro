class ReviewFavorite < ApplicationRecord
  belongs_to :user
  belongs_to :review, primary_key: :uuid, foreign_key: :review_uuid

  validates :user_id, uniqueness: { scope: :review_uuid }
end
