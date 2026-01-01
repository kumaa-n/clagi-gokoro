class ReviewFavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review

  def create
    current_user.review_favorites.find_or_create_by(review: @review)
  end

  def destroy
    current_user.review_favorites.find_by(review: @review)&.destroy
  end

  private

  def set_review
    @review = Review.find_by_short_uuid(params[:review_id])
  end
end
