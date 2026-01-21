class SongDecorator < Draper::Decorator
  delegate_all

  def reviews_count
    # 集約済みの属性があればそれを使用し、なければ動的に計算（N+1回避のため）
    (object.has_attribute?(:reviews_count) ? object[:reviews_count] : object.reviews.size).to_i
  end

  def average_overall_rating
    # 集約済みの属性があればそれを使用し、なければ動的に計算（N+1回避のため）
    # AVG関数はレビューが0件の場合nilを返す
    object.has_attribute?(:average_overall_rating) ? object[:average_overall_rating] : object.reviews.average(:overall_rating)
  end

  def has_average?
    reviews_count.positive? && average_overall_rating.present?
  end

  def composer_or_dash
    object.composer.presence || "ー"
  end

  def arranger_or_dash
    object.arranger.presence || "ー"
  end
end
