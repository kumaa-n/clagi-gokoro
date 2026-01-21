class Review < ApplicationRecord
  include UuidPrimaryKey

  belongs_to :user
  belongs_to :song, primary_key: :uuid, foreign_key: :song_uuid
  has_many :review_favorites, primary_key: :uuid, foreign_key: :review_uuid, dependent: :destroy

  # バリデーションとビューで使用する文字数制限
  SUMMARY_MAX_LENGTH = 500

  RATING_ATTRIBUTES = %i[
    tempo_rating
    fingering_technique_rating
    plucking_technique_rating
    expression_rating
    memorization_rating
  ].freeze

  validates *RATING_ATTRIBUTES, inclusion: { in: 1..5 }
  validates :song_uuid, uniqueness: { scope: :user_id }
  validates :summary, content_length: { maximum: SUMMARY_MAX_LENGTH }, allow_blank: true
  validate :validate_tags

  before_save :calc_overall_rating

  # 指定したユーザーがお気に入りに追加したレビューを取得
  scope :favorited_by, ->(user) {
    joins(:review_favorites)
      .where(review_favorites: { user_id: user.id })
      .order("review_favorites.created_at DESC")
  }

  # いずれかのタグを含むレビューを取得
  scope :with_any_tags, ->(tags) {
    where("tags && ARRAY[?]::text[]", Array(tags))
  }

  # すべてのタグを含むレビューを取得
  scope :with_all_tags, ->(tags) {
    where("tags @> ARRAY[?]::text[]", Array(tags))
  }

  # ユーザーがレビューをお気に入りに追加しているかどうかを確認
  def favorited_by?(user)
    return false unless user

    # N+1問題を避けるため、既にロード済みの場合はメモリ内で検索
    if review_favorites.loaded?
      review_favorites.any? { |fav| fav.user_id == user.id }
    else
      review_favorites.exists?(user_id: user.id)
    end
  end

  private

  def validate_tags
    if tags.size > ReviewTags::MAX_TAGS_PER_REVIEW
      errors.add(:tags, "は#{ReviewTags::MAX_TAGS_PER_REVIEW}個まで選択できます")
    end

    invalid = tags - ReviewTags::AVAILABLE_TAGS
    if invalid.any?
      errors.add(:tags, "に不正な値が含まれています: #{invalid.join(', ')}")
    end
  end

  def calc_overall_rating
    # 全ての評価が存在する場合のみ計算
    return unless RATING_ATTRIBUTES.all? { |attr| self[attr].present? }

    ratings = RATING_ATTRIBUTES.map { |attr| self[attr] }
    self.overall_rating = (ratings.sum.to_d / ratings.size).round(2)
  end
end
