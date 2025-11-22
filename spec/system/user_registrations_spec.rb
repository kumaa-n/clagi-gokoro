require 'rails_helper'

RSpec.describe "ユーザー登録", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "新規ユーザー登録" do
    context "有効な情報を入力した場合" do
      it "ユーザー登録が成功する" do
        visit new_user_registration_path

        expect(page).to have_content("アカウント登録")

        fill_in "user_name", with: "testuser"
        fill_in "user_email", with: "test@example.com"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button "アカウント登録"
        }.to change(User, :count).by(1)

        expect(page).to have_current_path(root_path)
      end
    end

    context "名前が空の場合" do
      it "ユーザー登録が失敗する" do
        visit new_user_registration_path

        fill_in "user_name", with: ""
        fill_in "user_email", with: "test@example.com"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button "アカウント登録"
        }.not_to change(User, :count)

        expect(page).to have_content("入力内容に不備があります")
      end
    end

    context "名前が短すぎる場合（1文字）" do
      it "ユーザー登録が失敗する" do
        visit new_user_registration_path

        fill_in "user_name", with: "a"
        fill_in "user_email", with: "test@example.com"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button "アカウント登録"
        }.not_to change(User, :count)

        expect(page).to have_content("入力内容に不備があります")
      end
    end

    context "名前が長すぎる場合（16文字）" do
      it "ユーザー登録が失敗する" do
        visit new_user_registration_path

        fill_in "user_name", with: "a" * 16
        fill_in "user_email", with: "test@example.com"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button "アカウント登録"
        }.not_to change(User, :count)

        expect(page).to have_content("入力内容に不備があります")
      end
    end

    context "メールアドレスが空の場合" do
      it "ユーザー登録が失敗する" do
        visit new_user_registration_path

        fill_in "user_name", with: "testuser"
        fill_in "user_email", with: ""
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button "アカウント登録"
        }.not_to change(User, :count)

        expect(page).to have_content("入力内容に不備があります")
      end
    end

    context "メールアドレスが無効な形式の場合" do
      it "ユーザー登録が失敗する" do
        visit new_user_registration_path

        fill_in "user_name", with: "testuser"
        fill_in "user_email", with: "invalid_email"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button "アカウント登録"
        }.not_to change(User, :count)

        expect(page).to have_content("入力内容に不備があります")
      end
    end

    context "パスワードが短すぎる場合（5文字）" do
      it "ユーザー登録が失敗する" do
        visit new_user_registration_path

        fill_in "user_name", with: "testuser"
        fill_in "user_email", with: "test@example.com"
        fill_in "user_password", with: "pass1"
        fill_in "user_password_confirmation", with: "pass1"

        expect {
          click_button "アカウント登録"
        }.not_to change(User, :count)

        expect(page).to have_content("入力内容に不備があります")
      end
    end

    context "パスワードとパスワード確認が一致しない場合" do
      it "ユーザー登録が失敗する" do
        visit new_user_registration_path

        fill_in "user_name", with: "testuser"
        fill_in "user_email", with: "test@example.com"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "different_password"

        expect {
          click_button "アカウント登録"
        }.not_to change(User, :count)

        expect(page).to have_content("入力内容に不備があります")
      end
    end

    context "既に登録されているメールアドレスの場合" do
      it "ユーザー登録が失敗する" do
        create(:user, email: "existing@example.com")

        visit new_user_registration_path

        fill_in "user_name", with: "newuser"
        fill_in "user_email", with: "existing@example.com"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button "アカウント登録"
        }.not_to change(User, :count)

        expect(page).to have_content("入力内容に不備があります")
      end
    end

    context "既に登録されている名前の場合" do
      it "ユーザー登録が失敗する" do
        create(:user, name: "existingname")

        visit new_user_registration_path

        fill_in "user_name", with: "existingname"
        fill_in "user_email", with: "new@example.com"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button "アカウント登録"
        }.not_to change(User, :count)

        expect(page).to have_content("入力内容に不備があります")
      end
    end
  end
end
