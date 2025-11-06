class Song < ApplicationRecord
  has_many :reviews, dependent: :destroy

  validates :title, presence: true, length: { maximum: 100 }
  validates :composer, length: { maximum: 50 }, allow_blank: true
  validates :arranger, length: { maximum: 50 }, allow_blank: true

  scope :with_review_stats, -> {
    left_joins(:reviews)
      .select("songs.*, COUNT(reviews.id) AS reviews_count, AVG(reviews.overall_rating) AS average_overall_rating")
      .group(:id)
  }

  scope :most_reviewed, ->(limit_count) {
    with_review_stats
      .having("COUNT(reviews.id) > 0")
      .order("COUNT(reviews.id) DESC, songs.created_at DESC")
      .limit(limit_count)
  }

  scope :recent_with_stats, ->(limit_count) {
    with_review_stats
      .order(created_at: :desc)
      .limit(limit_count)
  }
end
