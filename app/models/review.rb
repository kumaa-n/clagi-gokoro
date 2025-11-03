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

  validates :user_id, uniqueness: { scope: :song_id, message: "この曲に既にレビューを投稿しています" }
end
