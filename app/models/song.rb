class Song < ApplicationRecord
  include UuidPrimaryKey

  has_many :reviews, primary_key: :uuid, foreign_key: :song_uuid, dependent: :destroy

  # バリデーションとビューで使用する文字数制限
  TITLE_MAX_LENGTH = 100
  COMPOSER_MAX_LENGTH = 50
  ARRANGER_MAX_LENGTH = 50

  validates :title, presence: true, length: { maximum: TITLE_MAX_LENGTH }
  validates :composer, length: { maximum: COMPOSER_MAX_LENGTH }, allow_blank: true
  validates :arranger, length: { maximum: ARRANGER_MAX_LENGTH }, allow_blank: true

  # キーワード検索スコープ（複数フィールド対応）
  scope :search_by_keywords, ->(query) {
    keywords = query.to_s.strip.split(/[[:space:]]+/)
    return all if keywords.empty?

    # Arelテーブルを使って柔軟に検索条件を組み立てる
    table = Song.arel_table

    # キーワードごとにOR条件を作り、
    # reduceによってAND条件として積み重ねていく
    keywords.reduce(all) do |relation, keyword|
      sanitized = "%#{sanitize_sql_like(keyword)}%"
      condition = table[:title].matches(sanitized)
                  .or(table[:composer].matches(sanitized))
                  .or(table[:arranger].matches(sanitized))

      relation.where(condition)
    end
  }

  # フィールド別検索スコープ
  scope :search_by_fields, ->(title: nil, composer: nil, arranger: nil) {
    relation = all
    table = Song.arel_table

    if title.present?
      sanitized = "%#{sanitize_sql_like(title)}%"
      relation = relation.where(table[:title].matches(sanitized))
    end

    if composer.present?
      sanitized = "%#{sanitize_sql_like(composer)}%"
      relation = relation.where(table[:composer].matches(sanitized))
    end

    if arranger.present?
      sanitized = "%#{sanitize_sql_like(arranger)}%"
      relation = relation.where(table[:arranger].matches(sanitized))
    end

    relation
  }

  # オートコンプリート用スコープ
  scope :autocomplete_by_field, ->(field, query) {
    return none if query.blank?
    return none unless %w[title composer arranger].include?(field)

    table = arel_table
    sanitized_query = "%#{sanitize_sql_like(query)}%"

    where(table[field].matches(sanitized_query))
      .where.not(field => [nil, ""])
      .distinct
      .limit(10)
      .pluck(field)
  }

  # レビュー数と平均評価を含むスコープ
  scope :with_review_stats, -> {
    left_joins(:reviews)
      .select("songs.*, COUNT(reviews.uuid) AS reviews_count, AVG(reviews.overall_rating) AS average_overall_rating")
      .group(:uuid)
  }

  # レビュー数が多い順のスコープ
  scope :most_reviewed, ->(limit_count) {
    with_review_stats
      .having("COUNT(reviews.uuid) > 0")
      .order("COUNT(reviews.uuid) DESC, songs.created_at DESC")
      .limit(limit_count)
  }

  # 最近追加された順のスコープ
  scope :recent_with_stats, ->(limit_count) {
    with_review_stats
      .order(created_at: :desc)
      .limit(limit_count)
  }
end
