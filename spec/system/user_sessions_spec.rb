require "rails_helper"

RSpec.describe "ユーザーログイン", type: :system do
  let!(:user) { create(:user, password: "password123", password_confirmation: "password123") }
  let(:sign_in_title) { I18n.t("devise.sessions.new.sign_in") }
  let(:success_message) { I18n.t("devise.sessions.signed_in") }
  let(:invalid_message) do
    I18n.t("devise.failure.invalid", authentication_keys: User.human_attribute_name(:name))
  end

  # 失敗時の共通処理
  def expect_login_failure
    expect(page).to have_content(sign_in_title)
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content(invalid_message)
  end

  describe "ログインページ" do
    it "ログインフォームが表示される" do
      visit new_user_session_path

      expect(page).to have_content(sign_in_title)
      expect(page).to have_field("user_name")
      expect(page).to have_field("user_password")
      expect(page).to have_field("user_remember_me")
      expect(page).to have_button(sign_in_title)
    end
  end

  describe "ログイン" do
    context "有効な情報を入力した場合" do
      it "ログインが成功する" do
        visit new_user_session_path

        fill_in "user_name", with: user.name
        fill_in "user_password", with: "password123"

        click_button sign_in_title

        expect(page).to have_current_path(root_path)
        expect(page).to have_content(success_message)
      end
    end

    context "ニックネームが空の場合" do
      it "ログインが失敗する" do
        visit new_user_session_path

        fill_in "user_name", with: ""
        fill_in "user_password", with: "password123"

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

    context "存在しないニックネームの場合" do
      it "ログインが失敗する" do
        visit new_user_session_path

        fill_in "user_name", with: "nonexistentuser"
        fill_in "user_password", with: "password123"

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

  describe "ログイン状態の保持" do
    it "「ログイン状態を保持する」にチェックを入れてログインできる" do
      visit new_user_session_path

      fill_in "user_name", with: user.name
      fill_in "user_password", with: "password123"
      check "user_remember_me"

      click_button sign_in_title

      expect(page).to have_current_path(root_path)
      expect(page).to have_content(success_message)
    end
  end

  describe "ログアウト" do
    it "ログアウトが成功する", js: true do
      sign_in user

      visit root_path

      find("summary", text: user.name).click
      within(".dropdown-content") do
        click_link "ログアウト"
      end

      expect(page).to have_current_path(root_path)
      expect(page).to have_content(I18n.t("devise.sessions.signed_out"))
    end
  end

  describe "新規登録ページへのリンク" do
    it "新規登録ページへのリンクが表示されている" do
      visit new_user_session_path

      expect(page).to have_link(I18n.t("devise.shared.links.sign_up"), href: new_user_registration_path)
    end
  end
end
