class Review < ApplicationRecord
  belongs_to :user
  belongs_to :song

  RATING_ATTRIBUTES = %i[
    tempo_rating
    fingering_technique_rating
    plucking_technique_rating
    expression_rating
    memorization_rating
  ].freeze

  validates *RATING_ATTRIBUTES, presence: true
  validates *RATING_ATTRIBUTES, inclusion: { in: 1..5 }, allow_blank: true

  validates :song_id, uniqueness: { scope: :user_id, message: "に対してレビュー済みです。" }

  before_save :calc_overall_rating

  private

  def calc_overall_rating
    ratings = RATING_ATTRIBUTES.map { |attr| self[attr] || 0 }
    self.overall_rating = (ratings.sum.to_f / ratings.size).round
  end
end
