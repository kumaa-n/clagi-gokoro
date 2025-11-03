class ReviewsController < ApplicationController
  before_action :set_song

  def new
    @review = @song.reviews.build
  end

  def create
    @review = @song.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to song_reviews_path(@song), notice: "レビューが投稿されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_song
    @song = Song.find(params[:song_id])
  end

  def review_params
    params.require(:review).permit(:tempo_rating, :fingering_technique_rating, :plucking_technique_rating, :expression_rating, :memorization_rating, :summary)
  end
end
