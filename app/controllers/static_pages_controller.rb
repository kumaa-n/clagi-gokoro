class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!

  def top
    @most_reviewed_songs = Song
      .left_outer_joins(:reviews)
      .select("songs.*, COUNT(reviews.id) AS reviews_count, AVG(reviews.overall_rating) AS average_overall_rating")
      .group(:id)
      .having("COUNT(reviews.id) > 0")
      .order(Arel.sql("COUNT(reviews.id) DESC, songs.created_at DESC"))
      .limit(4)

    @recent_songs = Song
      .left_outer_joins(:reviews)
      .select("songs.*, COUNT(reviews.id) AS reviews_count, AVG(reviews.overall_rating) AS average_overall_rating")
      .group(:id)
      .order(Arel.sql("songs.created_at DESC"))
      .limit(4)
  end
end
