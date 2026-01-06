class UsersController < ApplicationController
  # 他ユーザーのプロフィール閲覧用コントローラー
  def show
    @user = User.find_by!(name: params[:name])
    @reviews = @user.reviews.includes(:song).order(created_at: :desc)
  end
end
