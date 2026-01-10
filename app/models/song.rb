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
  validate :check_duplicate_song

  before_validation :set_normalized_fields

  # キーワード検索スコープ（複数フィールド対応、正規化カラムを使用）
  scope :search_by_keywords, ->(query) {
    keywords = query.to_s.strip.split(/[[:space:]]+/)
    return all if keywords.empty?

    # Arelテーブルを使って柔軟に検索条件を組み立てる
    table = Song.arel_table

    # キーワードごとにOR条件を作り、
    # reduceによってAND条件として積み重ねていく
    keywords.reduce(all) do |relation, keyword|
      normalized_keyword = normalize_for_duplicate_check(keyword)
      sanitized = "%#{sanitize_sql_like(normalized_keyword)}%"
      condition = table[:normalized_title].matches(sanitized)
                  .or(table[:normalized_composer].matches(sanitized))
                  .or(table[:normalized_arranger].matches(sanitized))

      relation.where(condition)
    end
  }

  # フィールド別検索スコープ（正規化カラムを使用）
  scope :search_by_fields, ->(title: nil, composer: nil, arranger: nil) {
    relation = all
    table = Song.arel_table

    { title: title, composer: composer, arranger: arranger }.each do |field, value|
      next if value.blank?

      normalized = normalize_for_duplicate_check(value)
      sanitized = "%#{sanitize_sql_like(normalized)}%"
      relation = relation.where(table[:"normalized_#{field}"].matches(sanitized))
    end

    relation
  }

  # オートコンプリート用スコープ（正規化カラムで検索し、元の値を返す）
  scope :autocomplete_by_field, ->(field, query) {
    return none if query.blank?
    return none unless %w[title composer arranger].include?(field)

    table = arel_table
    normalized_query = normalize_for_duplicate_check(query)
    sanitized_query = "%#{sanitize_sql_like(normalized_query)}%"
    normalized_field = "normalized_#{field}"

    where(table[normalized_field].matches(sanitized_query))
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

  # 重複チェック用の正規化メソッド
  def self.normalize_for_duplicate_check(value)
    return "" if value.blank?

    value.to_s.unicode_normalize(:nfkc).gsub(/[[:space:]]/, "").downcase
  end

  # ユーザー入力に基づいて重複曲を検索
  def self.find_duplicate_by_input(title:, composer: nil, arranger: nil, exclude_uuid: nil)
    return nil if title.blank?

    find_duplicate(
      title: title,
      composer: composer,
      arranger: arranger,
      exclude_uuid: exclude_uuid,
      skip_blank_fields: true
    )
  end

  # 重複曲を検索する共通メソッド（正規化カラムを使用）
  def self.find_duplicate(title:, composer:, arranger:, exclude_uuid: nil, skip_blank_fields: false)
    normalized_title = normalize_for_duplicate_check(title)
    normalized_composer = normalize_for_duplicate_check(composer)
    normalized_arranger = normalize_for_duplicate_check(arranger)

    return nil if normalized_title.blank?

    relation = exclude_uuid ? where.not(uuid: exclude_uuid) : all

    relation.find do |song|
      # 曲名は必須でチェック
      next false unless song.normalized_title == normalized_title

      # 作曲者のチェック
      if skip_blank_fields && normalized_composer.blank?
        # 空欄の場合は条件をスキップ
      elsif song.normalized_composer != normalized_composer
        next false
      end

      # 編曲者のチェック
      if skip_blank_fields && normalized_arranger.blank?
        # 空欄の場合は条件をスキップ
      elsif song.normalized_arranger != normalized_arranger
        next false
      end

      true
    end
  end

  private

  def set_normalized_fields
    self.normalized_title = self.class.normalize_for_duplicate_check(title)
    self.normalized_composer = self.class.normalize_for_duplicate_check(composer)
    self.normalized_arranger = self.class.normalize_for_duplicate_check(arranger)
  end

  def check_duplicate_song
    return if title.blank?

    duplicate = self.class.find_duplicate(
      title: title,
      composer: composer,
      arranger: arranger,
      exclude_uuid: uuid,
      skip_blank_fields: false
    )

    errors.add(:base, :duplicate_song) if duplicate
  end
end
