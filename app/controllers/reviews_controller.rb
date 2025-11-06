class ReviewsController < ApplicationController
  before_action :set_song
  before_action :set_review, only: %i[show edit update destroy]
  before_action :authorize_review, only: %i[edit update destroy]
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @reviews = @song.reviews.includes(:user).order(created_at: :desc)
    @user_review = current_user&.reviews&.find_by(song: @song)
  end

  def show
    @review_comments = @review.review_comments.includes(:user).order(created_at: :desc)
    @review_comment = @review.review_comments.build
  end

  def new
    @review = @song.reviews.build
  end

  def create
    @review = @song.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to song_review_path(@song, @review), notice: "レビューが投稿されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @review.update(review_params)
      redirect_to song_review_path(@song, @review), notice: "レビューが更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy!
    redirect_to song_reviews_path(@song), notice: "レビューが削除されました。"
  end

  private

  def set_song
    @song = Song.find(params[:song_id])
  end

  def set_review
    @review = @song.reviews.find(params[:id])
  end

  def authorize_review
    unless @review.user == current_user
      redirect_to song_reviews_path(@song), alert: "他のユーザーのレビューは編集できません。"
    end
  end

  def review_params
    params.require(:review).permit(:tempo_rating, :fingering_technique_rating, :plucking_technique_rating, :expression_rating, :memorization_rating, :summary)
  end
end
