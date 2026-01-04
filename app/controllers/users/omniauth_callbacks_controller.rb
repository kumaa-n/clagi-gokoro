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
    @user, is_new_registration = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in @user, event: :authentication

      if is_new_registration
        session[:allow_nickname_change] = true
        flash[:notice] = t("devise.omniauth_callbacks.success_first_time", kind: provider_name)
        redirect_to edit_nickname_change_path
      else
        set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
        redirect_to root_path
      end
    else
      session["devise.#{provider}_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: t("devise.omniauth_callbacks.failure", kind: provider_name)
    end
  end
end
