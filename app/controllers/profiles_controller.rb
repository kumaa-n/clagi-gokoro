class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
    @reviews = @user.reviews.includes(:song).order(created_at: :desc)
    @favorited_reviews = Review.favorited_by(@user).includes(:song, :user)
  end

  def edit; end

  def update
    if @user.update(profile_params)
      redirect_to profile_path, notice: t("defaults.flash_message.updated", resource: t("defaults.profile"))
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(:name, :self_introduction)
  end
end
