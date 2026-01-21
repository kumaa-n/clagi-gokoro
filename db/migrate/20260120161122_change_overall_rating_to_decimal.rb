class ChangeOverallRatingToDecimal < ActiveRecord::Migration[7.2]
  def up
    change_column :reviews, :overall_rating, :decimal, null: false

    # 既存の全レビューのoverall_ratingを更新
    Review.find_each do |review|
      rating_attributes = %i[
        tempo_rating
        fingering_technique_rating
        plucking_technique_rating
        expression_rating
        memorization_rating
      ]

      next unless rating_attributes.all? { |attr| review[attr].present? }

      ratings = rating_attributes.map { |attr| review[attr] }
      new_overall_rating = (ratings.sum.to_d / ratings.size).round(2)

      review.update_column(:overall_rating, new_overall_rating)
    end
  end

  def down
    change_column :reviews, :overall_rating, :integer, null: false
  end
end
