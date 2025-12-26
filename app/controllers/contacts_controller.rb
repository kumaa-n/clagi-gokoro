class ContactsController < ApplicationController
  GOOGLE_FORM_URL = "https://docs.google.com/forms/u/0/d/e/1FAIpQLScS9e24rAMmied6lSfZBVX2xpJPAzOpPJZrAy3-J9LSt9RLvg/formResponse".freeze
  FORM_ENTRIES = {
    name: "entry.243206244",
    email: "entry.1438955731",
    content: "entry.1389802120"
  }.freeze

  def create
    uri = URI.parse(GOOGLE_FORM_URL)

    # Googleフォームの各エントリーIDに合わせてフォーム値をセット
    form_data = {
      FORM_ENTRIES[:name] => params[:name],
      FORM_ENTRIES[:email] => params[:email],
      FORM_ENTRIES[:content] => params[:content]
    }

    Net::HTTP.post_form(uri, form_data)

    flash[:notice] = "お問い合わせいただきありがとうございます。"
    redirect_to root_path
  rescue StandardError => e
    Rails.logger.error("Contact form error: #{e.class} - #{e.message}")
    flash[:alert] = "送信に失敗しました。時間をおいて再度お試しください。"
    redirect_to contact_path
  end
end
