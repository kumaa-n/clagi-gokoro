class SongsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]

  def index
    search = Songs::SearchQuery.new(search_params).call
    @songs = Kaminari.paginate_array(search.songs).page(params[:page])
    @selected_tags = search.selected_tags

    # 楽曲投稿直後のレビュー促進モーダル用
    if (uuid = flash[:review_prompt_song_id]).present?
      @prompt_song = Song.find_by(uuid: uuid)
      flash.delete(:review_prompt_song_id)
    end
  end

  def autocomplete
    results = Song.autocomplete_by_field(field: params[:field], query: params[:query])
    render json: results
  end

  def check_duplicate
    checker = Songs::DuplicateChecker.new(
      title: params[:title],
      composer: params[:composer],
      arranger: params[:arranger]
    ).call

    render json: checker.to_json_response
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

  def search_params
    params.permit(:query, :title, :composer, :arranger, :tag, :tags, :min_difficulty, :max_difficulty)
  end

  def song_params
    params.require(:song).permit(:title, :composer, :arranger)
  end
end
