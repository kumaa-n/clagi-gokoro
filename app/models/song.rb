class Song < ApplicationRecord
  has_many :reviews, primary_key: :uuid, foreign_key: :song_uuid, dependent: :destroy

  validates :title, presence: true, length: { maximum: 100 }
  validates :composer, length: { maximum: 50 }, allow_blank: true
  validates :arranger, length: { maximum: 50 }, allow_blank: true

  scope :with_review_stats, -> {
    left_joins(:reviews)
      .select("songs.*, COUNT(reviews.id) AS reviews_count, AVG(reviews.overall_rating) AS average_overall_rating")
      .group(:uuid)
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

  # uuidの短縮
  def short_uuid
    # base64で短縮
    # - を削除したあと16進数に変換、パディングの=を削除
    Base64.urlsafe_encode64([uuid.delete("-")].pack("H*")).tr("=", "")
  end

  # 短縮uuidから検索
  def self.find_by_short_uuid(short_uuid)
    # base64でデコード
    # uuidは「8-4-4-4-12」の形式（例：550e8400-e29b-41d4-a716-446655440000）
    # なので16進数から変換して-を挿入
    decode_uuid = Base64.urlsafe_decode64(short_uuid).unpack1("H*").insert(8, "-").insert(13, "-").insert(18, "-").insert(23, "-")
    find_by(uuid: decode_uuid)
  end

  # URLに短縮uuidを使用
  def to_param
    short_uuid
  end
end
