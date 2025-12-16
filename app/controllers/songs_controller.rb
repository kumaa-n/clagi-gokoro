class SongsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]

  def index
    @songs = Song.search_by_keywords(params[:query])
                 .with_review_stats
                 .order(created_at: :desc)
                 .page(params[:page])

    # 楽曲投稿直後のレビュー促進モーダル用
    if (uuid = flash[:review_prompt_song_id]).present?
      @prompt_song = Song.find_by(uuid: uuid)
      flash.delete(:review_prompt_song_id)
    end
  end

  def new
    @song = Song.new
  end

  def create
    @song = Song.new(song_params)

    if @song.save
      # モーダル表示用にflashに保存
      flash[:review_prompt_song_id] = @song.uuid
      redirect_to songs_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def song_params
    params.require(:song).permit(:title, :composer, :arranger)
  end
end
