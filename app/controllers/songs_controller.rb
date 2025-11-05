class SongsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @songs = Song
      .left_joins(:reviews)
      .select("songs.*, COUNT(reviews.id) AS reviews_count, AVG(reviews.overall_rating) AS average_overall_rating")
      .group(:id)
      .order(created_at: :desc)
    @prompt_song = Song.find_by(id: params[:review_prompt_song_id]) if params[:review_prompt_song_id].present?
  end

  def new
    @song = Song.new
  end

  def create
    @song = Song.new(song_params)
    if @song.save
      redirect_to songs_path(review_prompt_song_id: @song.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def song_params
    params.require(:song).permit(:title, :composer, :arranger)
  end
end
