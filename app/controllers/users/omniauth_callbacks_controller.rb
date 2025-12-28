class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    callback_for(:google)
  end

  def failure
    redirect_to root_path
  end

  private

  def callback_for(provider)
    provider_name = provider.to_s.capitalize
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
    else
      session["devise.#{provider}_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: t("devise.omniauth_callbacks.failure", kind: provider_name)
    end
  end
end
