class ReviewsController < ApplicationController
  before_action :set_song, only: %i[index new create]
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
      redirect_to review_path(@review), notice: t("defaults.flash_message.created", resource: Review.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @review.update(review_params)
      redirect_to review_path(@review), notice: t("defaults.flash_message.updated", resource: Review.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy!
    redirect_to song_reviews_path(@song), notice: t("defaults.flash_message.destroyed", resource: Review.model_name.human)
  end

  private

  def set_song
    @song = Song.find(params[:song_id])
  end

  def set_review
    @review = Review.find(params[:id])
    @song = @review.song
  end

  def authorize_review
    return if @review.user == current_user

    redirect_to song_reviews_path(@song), alert: t("defaults.flash_message.forbidden")
  end

  def review_params
    params.require(:review).permit(:tempo_rating, :fingering_technique_rating, :plucking_technique_rating, :expression_rating, :memorization_rating, :summary)
  end
end
