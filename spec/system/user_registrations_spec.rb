require "rails_helper"

RSpec.describe "ユーザー登録", type: :system do
  let(:registration_title) { I18n.t("devise.registrations.new.sign_up") }
  let(:success_message) { I18n.t("devise.registrations.signed_up") }
  let(:error_message) { I18n.t("errors.messages.not_saved") }
  let(:blank_message) { I18n.t("errors.messages.blank") }
  let(:too_short_name_message) { I18n.t("errors.messages.too_short", count: User::NAME_MIN_LENGTH) }
  let(:too_long_name_message) { I18n.t("errors.messages.too_long", count: User::NAME_MAX_LENGTH) }
  let(:too_short_password_message) { I18n.t("errors.messages.too_short", count: User::PASSWORD_MIN_LENGTH) }
  let(:taken_message) { I18n.t("errors.messages.taken") }
  let(:confirmation_message) { I18n.t("errors.messages.confirmation", attribute: User.human_attribute_name(:password)) }

  # ユーザー登録失敗の共通期待値
  def expect_registration_failure(specific_error: nil)
    expect(page).to have_content(error_message)
    expect(page).to have_content(specific_error) if specific_error
  end

  describe "新規ユーザー登録ページ" do
    it "登録フォームが表示される" do
      visit new_user_registration_path

      expect(page).to have_content(registration_title)
      expect(page).to have_field("user_name")
      expect(page).to have_field("user_password")
      expect(page).to have_field("user_password_confirmation")
      expect(page).to have_button(registration_title)
    end
  end

  describe "新規ユーザー登録" do
    context "有効な情報を入力した場合" do
      it "ユーザー登録が成功する" do
        visit new_user_registration_path

        fill_in "user_name", with: "testuser"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        click_button registration_title

        expect(page).to have_current_path(root_path)
        expect(page).to have_content(success_message)
        expect(User.find_by(name: "testuser")).to be_present
      end
    end

    context "ニックネームが空の場合" do
      it "エラーメッセージが表示される" do
        visit new_user_registration_path

        fill_in "user_name", with: ""
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure(specific_error: too_short_name_message)
      end
    end

    context "ニックネームが短すぎる場合（1文字）" do
      it "エラーメッセージが表示される" do
        visit new_user_registration_path

        fill_in "user_name", with: "a"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure(specific_error: too_short_name_message)
      end
    end

    context "ニックネームが長すぎる場合（16文字）" do
      it "エラーメッセージが表示される" do
        visit new_user_registration_path

        fill_in "user_name", with: "a" * 16
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure(specific_error: too_long_name_message)
      end
    end

    context "既に登録されているニックネームの場合" do
      let!(:existing_user) { create(:user, name: "existingname") }

      it "エラーメッセージが表示される" do
        visit new_user_registration_path

        fill_in "user_name", with: "existingname"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure(specific_error: taken_message)
      end
    end

    context "パスワードが空の場合" do
      it "エラーメッセージが表示される" do
        visit new_user_registration_path

        fill_in "user_name", with: "testuser"
        fill_in "user_password", with: ""
        fill_in "user_password_confirmation", with: ""

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure(specific_error: blank_message)
      end
    end

    context "パスワードが短すぎる場合（5文字）" do
      it "エラーメッセージが表示される" do
        visit new_user_registration_path

        fill_in "user_name", with: "testuser"
        fill_in "user_password", with: "pass1"
        fill_in "user_password_confirmation", with: "pass1"

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure(specific_error: too_short_password_message)
      end
    end

    context "パスワードとパスワード確認が一致しない場合" do
      it "エラーメッセージが表示される" do
        visit new_user_registration_path

        fill_in "user_name", with: "testuser"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "different_password"

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure(specific_error: confirmation_message)
      end
    end
  end

  describe "ニックネームの境界値テスト" do
    context "2文字のニックネーム（最小有効値）" do
      it "登録が成功する" do
        visit new_user_registration_path

        fill_in "user_name", with: "ab"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        click_button registration_title

        expect(page).to have_current_path(root_path)
        expect(page).to have_content(success_message)
        expect(User.find_by(name: "ab")).to be_present
      end
    end

    context "15文字のニックネーム（最大有効値）" do
      it "登録が成功する" do
        visit new_user_registration_path

        fifteen_chars = "u#{SecureRandom.hex(7)}"
        fill_in "user_name", with: fifteen_chars
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        click_button registration_title

        expect(page).to have_current_path(root_path)
        expect(page).to have_content(success_message)
        expect(User.find_by(name: fifteen_chars)).to be_present
      end
    end
  end

  describe "パスワードの境界値テスト" do
    context "6文字のパスワード（最小有効値）" do
      it "登録が成功する" do
        visit new_user_registration_path

        fill_in "user_name", with: "passtest"
        fill_in "user_password", with: "pass12"
        fill_in "user_password_confirmation", with: "pass12"

        click_button registration_title

        expect(page).to have_current_path(root_path)
        expect(page).to have_content(success_message)
        expect(User.find_by(name: "passtest")).to be_present
      end
    end
  end

  describe "特殊文字を含むニックネーム" do
    context "日本語のニックネーム" do
      it "登録が成功する" do
        visit new_user_registration_path

        fill_in "user_name", with: "テストユーザー"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        click_button registration_title

        expect(page).to have_current_path(root_path)
        expect(page).to have_content(success_message)
        expect(User.find_by(name: "テストユーザー")).to be_present
      end
    end

    context "英数字と記号の混在" do
      it "登録が成功する" do
        visit new_user_registration_path

        fill_in "user_name", with: "user_123"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        click_button registration_title

        expect(page).to have_current_path(root_path)
        expect(page).to have_content(success_message)
        expect(User.find_by(name: "user_123")).to be_present
      end
    end

    context "ひらがなとカタカナの混在" do
      it "登録が成功する" do
        visit new_user_registration_path

        fill_in "user_name", with: "あいうカタカナ"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        click_button registration_title

        expect(page).to have_current_path(root_path)
        expect(page).to have_content(success_message)
        expect(User.find_by(name: "あいうカタカナ")).to be_present
      end
    end
  end

  describe "セキュリティテスト" do
    context "HTMLタグを含むニックネーム" do
      it "タグがエスケープされて登録される" do
        visit new_user_registration_path

        malicious_name = "<b>test</b>"
        fill_in "user_name", with: malicious_name
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        click_button registration_title

        expect(page).to have_current_path(root_path)
        # スクリプトが実行されないことを確認
        expect(page).not_to have_selector("b", text: "test", visible: :all)
        expect(User.find_by(name: malicious_name)).to be_present
      end
    end

    context "SQLインジェクション風の入力" do
      it "無害化されて登録される" do
        visit new_user_registration_path

        sql_injection = "';DROP users"
        fill_in "user_name", with: sql_injection
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        click_button registration_title

        expect(page).to have_current_path(root_path)
        # テーブルが削除されていないことを確認
        expect(User.count).to be > 0
        expect(User.find_by(name: sql_injection)).to be_present
      end
    end
  end

  describe "エッジケース" do
    context "ニックネームの前後に空白がある場合" do
      it "空白も含めて登録される" do
        visit new_user_registration_path

        name_with_spaces = "  spacetest  "
        fill_in "user_name", with: name_with_spaces
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"

        click_button registration_title

        expect(page).to have_current_path(root_path)
        # 空白がそのまま保存されるか、trim されるかを確認
        user = User.last
        expect([name_with_spaces, name_with_spaces.strip]).to include(user.name)
      end
    end

    context "パスワードに空白文字が含まれる場合" do
      it "空白も含めて登録される" do
        visit new_user_registration_path

        fill_in "user_name", with: "spacepass"
        fill_in "user_password", with: "pass word 123"
        fill_in "user_password_confirmation", with: "pass word 123"

        click_button registration_title

        expect(page).to have_current_path(root_path)
        expect(User.find_by(name: "spacepass")).to be_present
      end
    end

    context "パスワード確認のみ空欄の場合" do
      it "エラーメッセージが表示される" do
        visit new_user_registration_path

        fill_in "user_name", with: "testuser"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: ""

        expect {
          click_button registration_title
        }.not_to change(User, :count)

        expect_registration_failure(specific_error: confirmation_message)
      end
    end
  end

  describe "バリデーションエラー時の入力値保持" do
    it "エラー時に入力値が保持される" do
      visit new_user_registration_path

      fill_in "user_name", with: "a"
      fill_in "user_password", with: "password123"
      fill_in "user_password_confirmation", with: "password123"

      click_button registration_title

      expect(page).to have_field("user_name", with: "a")
      # パスワードフィールドは保持されない（セキュリティのため）
      expect(page).to have_field("user_password", with: "")
      expect(page).to have_field("user_password_confirmation", with: "")
    end
  end

  describe "文字数カウンター" do
    describe "ニックネーム" do
      it "初期状態で0文字と表示される", js: true do
        visit new_user_registration_path

        expect(page).to have_content("0 / 15文字")
      end

      it "1文字入力時に赤色で表示される", js: true do
        visit new_user_registration_path

        fill_in "user_name", with: "a"

        expect(page).to have_content("1 / 15文字")
        expect(page).to have_css("[data-char-counter-target='counter'].text-error", text: "1")
      end

      it "2文字入力時に通常色で表示される", js: true do
        visit new_user_registration_path

        fill_in "user_name", with: "ab"

        expect(page).to have_content("2 / 15文字")
        expect(page).not_to have_css("[data-char-counter-target='counter'].text-error", text: "2")
      end

      it "4文字入力時に文字数がリアルタイムで表示される", js: true do
        visit new_user_registration_path

        fill_in "user_name", with: "test"

        expect(page).to have_content("4 / 15文字")
      end

      it "15文字入力時に通常色で表示される", js: true do
        visit new_user_registration_path

        fill_in "user_name", with: "a" * 15

        expect(page).to have_content("15 / 15文字")
        expect(page).not_to have_css("[data-char-counter-target='counter'].text-error", text: "15")
      end

      it "16文字入力時に赤色で警告が表示される", js: true do
        visit new_user_registration_path

        fill_in "user_name", with: "a" * 16

        expect(page).to have_content("16 / 15文字")
        expect(page).to have_css("[data-char-counter-target='counter'].text-error", text: "16")
      end

      it "日本語入力時に正しくカウントされる", js: true do
        visit new_user_registration_path

        fill_in "user_name", with: "テスト"

        expect(page).to have_content("3 / 15文字")
      end
    end

    describe "パスワード" do
      it "初期状態で0文字と表示される", js: true do
        visit new_user_registration_path

        expect(page).to have_content("0文字（6文字以上）")
      end

      it "5文字入力時に赤色で表示される", js: true do
        visit new_user_registration_path

        fill_in "user_password", with: "pass1"

        expect(page).to have_content("5文字（6文字以上）")
        expect(page).to have_css("[data-char-counter-target='counter'].text-error", text: "5")
      end

      it "6文字入力時に通常色で表示される", js: true do
        visit new_user_registration_path

        fill_in "user_password", with: "pass12"

        expect(page).to have_content("6文字（6文字以上）")
        expect(page).not_to have_css("[data-char-counter-target='counter'].text-error", text: "6")
      end
    end

    describe "パスワード確認" do
      it "初期状態で0文字と表示される", js: true do
        visit new_user_registration_path

        expect(page).to have_content("0文字（6文字以上）")
      end

      it "5文字入力時に赤色で表示される", js: true do
        visit new_user_registration_path

        fill_in "user_password_confirmation", with: "pass1"

        expect(page).to have_content("5文字（6文字以上）")
        expect(page).to have_css("[data-char-counter-target='counter'].text-error", text: "5")
      end

      it "6文字入力時に通常色で表示される", js: true do
        visit new_user_registration_path

        fill_in "user_password_confirmation", with: "pass12"

        expect(page).to have_content("6文字（6文字以上）")
        expect(page).not_to have_css("[data-char-counter-target='counter'].text-error", text: "6")
      end
    end
  end

  describe "複数の入力エラーがある場合" do
    it "すべてのエラーメッセージが表示される" do
      create(:user, name: "existing")

      visit new_user_registration_path

      fill_in "user_name", with: "existing"
      fill_in "user_password", with: "short"
      fill_in "user_password_confirmation", with: "different"

      click_button registration_title

      expect(page).to have_content(error_message)
      expect(page).to have_content(taken_message)
      expect(page).to have_content(too_short_password_message)
      expect(page).to have_content(confirmation_message)
    end
  end

  describe "ログインページへのリンク" do
    it "ログインページへのリンクが表示されている" do
      visit new_user_registration_path

      expect(page).to have_link(I18n.t("devise.shared.links.sign_in"), href: new_user_session_path)
    end
  end
end
