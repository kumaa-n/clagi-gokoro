class SongDecorator < Draper::Decorator
  delegate_all

  def reviews_count
    (object.has_attribute?(:reviews_count) ? object[:reviews_count] : object.reviews.size).to_i
  end

  def average_overall_rating
    val = object.has_attribute?(:average_overall_rating) ? object[:average_overall_rating] : object.reviews.average(:overall_rating)
    val&.to_f
  end

  def rounded_average
    average_overall_rating&.round
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
