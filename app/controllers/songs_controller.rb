class SongsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @songs = Song.order(created_at: :desc)
  end

  def new
    @song = Song.new
  end

  def create
    @song = Song.new(song_params)
    if @song.save
      redirect_to root_path, notice: "曲が投稿されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def song_params
    params.require(:song).permit(:title, :composer, :arranger)
  end
end
