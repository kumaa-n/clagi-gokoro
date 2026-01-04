require "rails_helper"

RSpec.describe "ニックネーム変更", type: :system do
  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "1234567890",
      info: {
        name: "Google User"
      }
    )
  end

  let(:too_short_message) { I18n.t("errors.messages.too_short", count: User::NAME_MIN_LENGTH) }
  let(:too_long_message) { I18n.t("errors.messages.too_long", count: User::NAME_MAX_LENGTH) }
  let(:taken_message) { I18n.t("errors.messages.taken") }
  let(:updated_message) { I18n.t("defaults.flash_message.updated", resource: I18n.t("activerecord.attributes.user.name")) }
  let(:forbidden_message) { I18n.t("defaults.flash_message.forbidden") }

  describe "初回登録直後のアクセス" do
    before do
      OmniAuth.config.mock_auth[:google_oauth2] = auth_hash
      visit new_user_session_path
      click_button "Googleでログイン"
    end

    context "有効な情報を入力した場合" do
      it "ニックネームを変更できる" do
        expect(page).to have_current_path(edit_nickname_change_path)
        expect(page).to have_content("ニックネーム変更")

        user = User.last
        expect(page).to have_field("user_name", with: user.name)

        fill_in "user_name", with: "新しいニックネーム"
        click_button "変更する"

        expect(page).to have_current_path(root_path)
        expect(page).to have_content(updated_message)

        user.reload
        expect(user.name).to eq("新しいニックネーム")
      end
    end

    context "ニックネームが短すぎる場合" do
      it "エラーメッセージが表示される" do
        user = User.last
        original_name = user.name

        fill_in "user_name", with: "a"
        click_button "変更する"

        expect(page).to have_current_path(edit_nickname_change_path)
        expect(page).to have_content(too_short_message)
        expect(page).to have_field("user_name", with: "a")

        user.reload
        expect(user.name).to eq(original_name)
      end
    end

    context "ニックネームが長すぎる場合" do
      it "エラーメッセージが表示される" do
        user = User.last
        original_name = user.name
        too_long_name = "a" * (User::NAME_MAX_LENGTH + 1)

        fill_in "user_name", with: too_long_name
        click_button "変更する"

        expect(page).to have_current_path(edit_nickname_change_path)
        expect(page).to have_content(too_long_message)
        expect(page).to have_field("user_name", with: too_long_name)

        user.reload
        expect(user.name).to eq(original_name)
      end
    end

    context "ニックネームが既に使用されている場合" do
      let!(:existing_user) { create(:user, name: "existing_user") }

      it "エラーメッセージが表示される" do
        user = User.last
        original_name = user.name

        fill_in "user_name", with: "existing_user"
        click_button "変更する"

        expect(page).to have_current_path(edit_nickname_change_path)
        expect(page).to have_content(taken_message)

        user.reload
        expect(user.name).to eq(original_name)
      end
    end

    context "キャンセルボタンをクリックした場合" do
      it "トップページに戻る" do
        click_link "キャンセル"

        expect(page).to have_current_path(root_path)
      end
    end

    context "更新後に再アクセスした場合" do
      it "ニックネーム変更ページにアクセスできない" do
        fill_in "user_name", with: "新しいニックネーム"
        click_button "変更する"

        expect(page).to have_current_path(root_path)

        visit edit_nickname_change_path
        expect(page).to have_current_path(profile_path)
        expect(page).to have_content(forbidden_message)
      end
    end
  end

  describe "セッションがない場合" do
    let!(:user) { create(:user, provider: "google_oauth2", provider_uid: "1234567890") }

    before do
      sign_in user
    end

    it "ニックネーム変更ページにアクセスできない" do
      visit edit_nickname_change_path

      expect(page).to have_current_path(profile_path)
      expect(page).to have_content(forbidden_message)
    end
  end
end
