require 'rails_helper'

RSpec.describe "ユーザー登録", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "新規ユーザー登録" do
    let(:registration_title) { I18n.t("devise.registrations.new.sign_up") }
    let(:success_message) { I18n.t("devise.registrations.signed_up") }
    let(:error_message) { I18n.t("errors.messages.not_saved") }

    # ユーザー登録成功の共通期待値
    def expect_registration_success
      expect(page).to have_current_path(root_path)
      expect(page).to have_content(success_message)
    end

    # ユーザー登録失敗の共通期待値
    def expect_registration_failure
      expect(page).to have_content(registration_title)
      expect(page).to have_content(error_message)
    end

    context "有効な情報を入力した場合" do
      it "ユーザー登録が成功する" do
        visit new_user_registration_path

        expect(page).to have_content(registration_title)

        fill_in "user_name", with: "testuser"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button registration_title
        }.to change(User, :count).by(1)

        expect_registration_success
      end
    end

    context "ニックネームが空の場合" do
      it "ユーザー登録が失敗する" do
        visit new_user_registration_path

        fill_in "user_name", with: ""
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure
        expect(page).to have_content("ニックネームは2文字以上で入力してください")
      end
    end

    context "ニックネームが短すぎる場合（1文字）" do
      it "ユーザー登録が失敗する" do
        visit new_user_registration_path

        fill_in "user_name", with: "a"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure
        expect(page).to have_content("ニックネームは2文字以上で入力してください")
      end
    end

    context "ニックネームが有効な場合（2文字）" do
      it "ユーザー登録が成功する" do
        visit new_user_registration_path

        expect(page).to have_content(registration_title)

        fill_in "user_name", with: "a" * 2
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button registration_title
        }.to change(User, :count).by(1)

        expect_registration_success
      end
    end

    context "ニックネームが有効な場合（15文字）" do
      it "ユーザー登録が成功する" do
        visit new_user_registration_path

        expect(page).to have_content(registration_title)

        fill_in "user_name", with: "a" * 15
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button registration_title
        }.to change(User, :count).by(1)

        expect_registration_success
      end
    end

    context "ニックネームが長すぎる場合（16文字）" do
      it "ユーザー登録が失敗する" do
        visit new_user_registration_path

        fill_in "user_name", with: "a" * 16
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure
        expect(page).to have_content("ニックネームは15文字以内で入力してください")
      end
    end

    context "パスワードが空の場合" do
      it "ユーザー登録が失敗する" do
        visit new_user_registration_path

        fill_in "user_name", with: "testuser"
        fill_in "user_password", with: ""
        fill_in "user_password_confirmation", with: ""

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure
        expect(page).to have_content("パスワードを入力してください")
      end
    end

    context "パスワードが短すぎる場合（5文字）" do
      it "ユーザー登録が失敗する" do
        visit new_user_registration_path

        fill_in "user_name", with: "testuser"
        fill_in "user_password", with: "pass1"
        fill_in "user_password_confirmation", with: "pass1"

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure
        expect(page).to have_content("パスワードは6文字以上で入力してください")
      end
    end

    context "パスワードが有効な場合（6文字）" do
      it "ユーザー登録が成功する" do
        visit new_user_registration_path

        fill_in "user_name", with: "testuser"
        fill_in "user_password", with: "pass12"
        fill_in "user_password_confirmation", with: "pass12"

        expect {
          click_button registration_title
        }.to change(User, :count).by(1)

        expect_registration_success
      end
    end

    context "パスワードとパスワード確認が一致しない場合" do
      it "ユーザー登録が失敗する" do
        visit new_user_registration_path

        fill_in "user_name", with: "testuser"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "different_password"

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure
        expect(page).to have_content("パスワード（確認用）とパスワードの入力が一致しません")
      end
    end

    context "既に登録されているニックネームの場合" do
      it "ユーザー登録が失敗する" do
        create(:user, name: "existingname")

        visit new_user_registration_path

        fill_in "user_name", with: "existingname"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure
        expect(page).to have_content("ニックネームはすでに存在します")
      end
    end
  end
end
