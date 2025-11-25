require 'rails_helper'

RSpec.describe "ユーザーログイン", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "ログイン" do
    let!(:user) { create(:user) }
    let(:sign_in_title) { I18n.t("devise.sessions.new.sign_in") }
    let(:success_message) { I18n.t("devise.sessions.signed_in") }
    let(:invalid_message) do
      I18n.t("devise.failure.invalid", authentication_keys: User.human_attribute_name(:name))
    end

    # ログイン成功の共通期待値
    def expect_login_success
      expect(page).to have_current_path(root_path)
      expect(page).to have_content(success_message)
    end

    # ログイン失敗の共通期待値
    def expect_login_failure
      expect(page).to have_content(sign_in_title)
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content(invalid_message)
    end

    context "有効な情報を入力した場合" do
      it "ログインが成功する" do
        visit new_user_session_path

        expect(page).to have_content(sign_in_title)

        fill_in "user_name", with: user.name
        fill_in "user_password", with: user.password

        click_button sign_in_title

        expect_login_success
      end
    end

    context "ニックネームが空の場合" do
      it "ログインが失敗する" do
        visit new_user_session_path

        fill_in "user_name", with: ""
        fill_in "user_password", with: user.password

        click_button sign_in_title

        expect_login_failure
      end
    end

    context "パスワードが空の場合" do
      it "ログインが失敗する" do
        visit new_user_session_path

        fill_in "user_name", with: user.name
        fill_in "user_password", with: ""

        click_button sign_in_title

        expect_login_failure
      end
    end

    context "パスワードが間違っている場合" do
      it "ログインが失敗する" do
        visit new_user_session_path

        fill_in "user_name", with: user.name
        fill_in "user_password", with: "wrongpassword"

        click_button sign_in_title

        expect_login_failure
      end
    end
  end
end
