class Review < ApplicationRecord
  belongs_to :user
  belongs_to :song, primary_key: :uuid, foreign_key: :song_uuid
  has_many :review_favorites, dependent: :destroy

  RATING_ATTRIBUTES = %i[
    tempo_rating
    fingering_technique_rating
    plucking_technique_rating
    expression_rating
    memorization_rating
  ].freeze

  validates *RATING_ATTRIBUTES, inclusion: { in: 1..5, message: "は1から5の間で評価してください" }
  validates :song_uuid, uniqueness: { scope: :user_id, message: "に対してレビュー済みです。" }

  before_save :calc_overall_rating

  # ユーザーがレビューをお気に入りに追加しているかどうかを確認
  def favorited_by?(user)
    return false unless user

    if review_favorites.loaded?
      review_favorites.any? { |fav| fav.user_id == user.id }
    else
      review_favorites.exists?(user_id: user.id)
    end
  end

  private

  def calc_overall_rating
    # 全ての評価が存在する場合のみ計算
    return unless RATING_ATTRIBUTES.all? { |attr| self[attr].present? }

    ratings = RATING_ATTRIBUTES.map { |attr| self[attr] }
    self.overall_rating = (ratings.sum.to_f / ratings.size).round
  end
end
