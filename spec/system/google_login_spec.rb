require "rails_helper"

RSpec.describe "Googleログイン", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "1234567890",
      info: {
        name: "Google User"
      }
    )
  end

  let(:success_message) { I18n.t("devise.omniauth_callbacks.success", kind: "Google") }
  let(:success_first_time) { I18n.t("devise.omniauth_callbacks.success_first_time", kind: "Google") }
  let(:failure_message) { I18n.t("devise.omniauth_callbacks.failure", kind: "Google") }

  context "初回ログイン時" do
    it "Googleアカウントでユーザーを作成してニックネーム変更ページにリダイレクトされる" do
      OmniAuth.config.mock_auth[:google_oauth2] = auth_hash

      visit new_user_session_path

      expect {
        click_button "Googleでログイン"
      }.to change(User, :count).by(1)

      expect(page).to have_current_path(edit_nickname_change_path)
      expect(page).to have_content(success_first_time)

      created_user = User.find_by(provider: "google_oauth2", provider_uid: auth_hash.uid)
      expect(created_user).to be_present
    end
  end

  context "既存ユーザーがいる場合" do
    let!(:existing_user) do
      create(
        :user,
        name: "Existing User",
        provider: "google_oauth2",
        provider_uid: auth_hash.uid
      )
    end

    it "既存ユーザーでログインし、ユーザー数は増えない" do
      OmniAuth.config.mock_auth[:google_oauth2] = auth_hash

      visit new_user_session_path

      expect {
        click_button "Googleでログイン"
      }.not_to change(User, :count)

      expect(page).to have_current_path(root_path)
      expect(page).to have_content(success_message)
      expect(page).to have_content(existing_user.name)
    end
  end

  context "認証に失敗した場合" do
    it "ユーザーは作成されずトップページに戻る" do
      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

      visit new_user_session_path

      expect {
        click_button "Googleでログイン"
      }.not_to change(User, :count)

      expect(page).to have_current_path(root_path)
      expect(page).not_to have_content(success_message)
    end
  end

  context "ユーザーの保存に失敗した場合" do
    it "ユーザーは作成されず新規登録ページにリダイレクトされる" do
      OmniAuth.config.mock_auth[:google_oauth2] = auth_hash
      allow(User).to receive(:from_omniauth).and_return([User.new, true])

      visit new_user_session_path

      expect {
        click_button "Googleでログイン"
      }.not_to change(User, :count)

      expect(page).to have_current_path(new_user_registration_path)
      expect(page).to have_content(failure_message)
    end
  end
end
