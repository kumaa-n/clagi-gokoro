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

  validates *RATING_ATTRIBUTES, inclusion: { in: 1..5, message: "は1から5の間で評価してください" }
  validates :song_id, uniqueness: { scope: :user_id, message: "に対してレビュー済みです。" }

  before_save :calc_overall_rating

  private

  def calc_overall_rating
    # 全ての評価が存在する場合のみ計算
    return unless RATING_ATTRIBUTES.all? { |attr| self[attr].present? }

    ratings = RATING_ATTRIBUTES.map { |attr| self[attr] }
    self.overall_rating = (ratings.sum.to_f / ratings.size).round
  end
end
