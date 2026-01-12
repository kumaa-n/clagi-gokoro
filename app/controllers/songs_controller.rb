class SongsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]

  def index
    search = SongSearchQuery.new(params).call
    @songs = Kaminari.paginate_array(search.songs).page(params[:page])
    @selected_tags = search.selected_tags

    # 楽曲投稿直後のレビュー促進モーダル用
    if (uuid = flash[:review_prompt_song_id]).present?
      @prompt_song = Song.find_by(uuid: uuid)
      flash.delete(:review_prompt_song_id)
    end
  end

  def autocomplete
    results = Song.autocomplete_by_field(params[:field], params[:query])
    render json: results
  end

  def check_duplicate
    duplicate = Song.find_duplicate_by_input(
      title: params[:title],
      composer: params[:composer],
      arranger: params[:arranger]
    )

    if duplicate
      render json: {
        duplicate: true,
        url: build_filter_url(params[:title], params[:composer], params[:arranger])
      }
    else
      render json: { duplicate: false }
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

  def build_filter_url(title, composer, arranger)
    filter_params = { title: title }
    filter_params[:composer] = composer if composer.present?
    filter_params[:arranger] = arranger if arranger.present?
    songs_path(filter_params)
  end
end
