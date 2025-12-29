class Users::PasswordsController < Devise::PasswordsController
  # ログイン中のユーザーもパスワードリセットを許可
  skip_before_action :require_no_authentication, only: %i[new create], if: :user_signed_in?
  before_action :check_user_eligibility, only: %i[new create], if: :user_signed_in?

  def new
    self.resource = resource_class.new

    if user_signed_in?
      # ログイン中: マイページからのパスワードリセット
      render :new_authenticated
    else
      # 未ログイン: パスワードを忘れた場合
      render :new_guest
    end
  end

  def create
    if user_signed_in?
      # ログイン中: 自分のメールアドレスにリセットメール送信
      current_user.send_reset_password_instructions
      redirect_to profile_path, notice: t("devise.passwords.send_instructions")
    else
      # 未ログイン: Deviseのデフォルト処理を使用
      super
    end
  end

  def update
    super do |resource|
      # パスワード更新成功時に明示的にログイン
      if resource.errors.empty?
        sign_in(resource, bypass: true)
      end
    end
  end

  protected

  # パスワードリセット後のリダイレクト先（ログイン状態を維持）
  def after_resetting_password_path_for(resource)
    profile_path
  end

  private

  # パスワードリセット可能なユーザーかチェック（ログイン中のみ）
  def check_user_eligibility
    # SNS認証ユーザーはアクセス不可
    if current_user.oauth_user?
      redirect_to profile_path, alert: t("defaults.flash_message.forbidden")
      return
    end

    # メールアドレス未登録の場合はメール登録画面へ
    unless current_user.email_registered?
      redirect_to edit_email_change_path, alert: t("users.passwords.email_registration_required")
    end
  end
end
