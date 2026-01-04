class Users::NicknameChangesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_user_eligibility
  before_action :set_user

  def edit; end

  def update
    if @user.update(nickname_params)
      session.delete(:allow_nickname_change)
      redirect_to root_path, notice: t("defaults.flash_message.updated", resource: t("activerecord.attributes.user.name"))
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def check_user_eligibility
    # 初回登録時のセッションがない場合はアクセス不可
    unless session[:allow_nickname_change]
      redirect_to profile_path, alert: t("defaults.flash_message.forbidden")
    end
  end

  def set_user
    @user = current_user
  end

  def nickname_params
    params.require(:user).permit(:name)
  end
end
