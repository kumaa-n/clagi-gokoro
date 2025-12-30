# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: %i[create]

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # 新規作成時に確認メールを送らず即時確認済みにする
  def build_resource(hash = {})
    super
    resource.skip_confirmation!
  end
end
