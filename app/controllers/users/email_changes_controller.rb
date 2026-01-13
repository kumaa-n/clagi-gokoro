class Users::EmailChangesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_user_eligibility
  before_action :set_user

  def edit; end

  def update
    if invalid_email_change?
      render :edit, status: :unprocessable_entity
      return
    end

    # Deviseの:confirmable機能により、updateすると確認処理が行われる
    if @user.update(email_params)
      redirect_to profile_path, notice: t("devise.registrations.update_needs_confirmation")
    else
      @user.reload
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # メールアドレス変更可能なユーザーか
  def check_user_eligibility
    if current_user.oauth_user?
      redirect_to profile_path, alert: t("defaults.flash_message.forbidden")
    end
  end

  def set_user
    @user = current_user
  end

  def email_params
    params.require(:user).permit(:email)
  end

  # メールアドレス変更画面固有のバリデーション
  def invalid_email_change?
    validate_email_presence || validate_email_uniqueness
  end

  def validate_email_presence
    return false if email_params[:email].present?

    @user.errors.add(:email, "を入力してください")
    true
  end

  def validate_email_uniqueness
    return false unless email_params[:email] == @user.email

    @user.errors.add(:email, "は現在のメールアドレスと同じです")
    true
  end
end
