require 'rails_helper'

RSpec.describe "プロフィール", type: :system do
  let!(:user) { create(:user, self_introduction: "よろしくお願いします") }
  let(:error_message) { I18n.t("errors.messages.not_saved") }
  let(:blank_message) { I18n.t("errors.messages.blank") }
  let(:too_short_message) { I18n.t("errors.messages.too_short", count: User::NAME_MIN_LENGTH) }
  let(:too_long_message) { I18n.t("errors.messages.too_long", count: User::NAME_MAX_LENGTH) }
  let(:taken_message) { I18n.t("errors.messages.taken") }
  let(:self_introduction_too_long_message) do
    "#{User.human_attribute_name(:self_introduction)}#{I18n.t("errors.messages.too_long", count: User::SELF_INTRODUCTION_MAX_LENGTH)}"
  end

  # プロフィール更新失敗の共通期待値
  def expect_update_failure(specific_error: nil)
    expect(page).to have_content(error_message)
    expect(page).to have_content(specific_error) if specific_error
  end

  describe "マイページ表示" do
    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        visit profile_path

        expect(page).to have_current_path(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before do
        sign_in user
      end

      it "マイページが表示される" do
        visit profile_path

        expect(page).to have_content("プロフィール")
        expect(page).to have_content(user.name)
        expect(page).to have_content(user.self_introduction)
        expect(page).to have_content("プロフィール編集")
        expect(page).to have_content("投稿したレビュー")
        expect(page).to have_content("自己紹介")
      end

      context "自己紹介が未設定の場合" do
        let!(:user) { create(:user, self_introduction: nil) }

        it "自己紹介未設定のメッセージが表示される" do
          visit profile_path

          expect(page).to have_content("自己紹介を追加して、あなたの音楽の好みを共有しましょう")
        end
      end

      context "レビューがない場合" do
        it "レビューがないメッセージが表示される" do
          visit profile_path

          expect(page).to have_content("まだレビューがありません")
          expect(page).to have_content("お気に入りの音楽をレビューして、あなたの感想を共有しましょう")
        end
      end
    end
  end

  describe "プロフィール編集" do
    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        visit edit_profile_path

        expect(page).to have_current_path(new_user_session_path)
      end
    end

    context "ログインしている場合" do
      before do
        sign_in user
      end

      it "キャンセルボタンをクリックするとマイページに戻る" do
        visit edit_profile_path

        click_link "キャンセル"

        expect(page).to have_current_path(profile_path)
      end
    end

    context "有効な情報を入力した場合" do
      before do
        sign_in user
      end

      it "プロフィールが更新される" do
        visit edit_profile_path

        expect(page).to have_content("プロフィール編集")

        new_name = "updated_#{user.id}"
        fill_in "user_name", with: new_name
        fill_in "user_self_introduction", with: "新しい自己紹介文です"

        click_button "更新する"

        expect(page).to have_current_path(profile_path)
        expect(page).to have_content("プロフィールを更新しました")
        expect(page).to have_content(new_name)
        expect(page).to have_content("新しい自己紹介文です")
      end
    end

    context "ニックネームが空の場合" do
      before do
        sign_in user
      end

      it "エラーメッセージが表示される" do
        visit edit_profile_path

        fill_in "user_name", with: ""

        click_button "更新する"

        expect_update_failure(specific_error: too_short_message)
      end
    end

    context "ニックネームが短すぎる場合" do
      before do
        sign_in user
      end

      it "エラーメッセージが表示される" do
        visit edit_profile_path

        fill_in "user_name", with: "a"

        click_button "更新する"

        expect_update_failure(specific_error: too_short_message)
      end
    end

    context "自己紹介が500文字を超える場合" do
      before do
        sign_in user
      end

      it "エラーメッセージが表示される" do
        visit edit_profile_path

        fill_in "user_self_introduction", with: "a" * 501

        click_button "更新する"

        expect_update_failure(specific_error: self_introduction_too_long_message)
      end
    end

    context "ニックネームが既に使用されている場合" do
      let!(:other_user) { create(:user, name: "既存ユーザー") }

      before do
        sign_in user
      end

      it "エラーメッセージが表示される" do
        visit edit_profile_path

        fill_in "user_name", with: "既存ユーザー"

        click_button "更新する"

        expect_update_failure(specific_error: taken_message)
      end
    end

    context "ニックネームが15文字を超える場合" do
      before do
        sign_in user
      end

      it "エラーメッセージが表示される" do
        visit edit_profile_path

        fill_in "user_name", with: "a" * 16

        click_button "更新する"

        expect_update_failure(specific_error: too_long_message)
      end
    end
  end

  describe "お気に入りタブ" do
    before do
      sign_in user
    end

    context "お気に入りがある場合" do
      let!(:other_user) { create(:user) }
      let!(:song) { create(:song) }
      let!(:my_review) { create(:review, user: user, song: song) }
      let!(:other_review) { create(:review, user: other_user, song: song) }
      let!(:favorite) { create(:review_favorite, user: user, review: other_review) }

      it "お気に入りタブをクリックするとお気に入りしたレビューが表示される" do
        visit profile_path

        click_button "お気に入り"

        expect(page).to have_content(other_user.name)
      end

      it "投稿したレビュータブには自分のレビューのみ表示される" do
        visit profile_path

        expect(page).to have_content("投稿したレビュー")
        expect(page).to have_content(user.name)
      end
    end

    context "お気に入りがない場合" do
      it "お気に入りがないメッセージが表示される" do
        visit profile_path

        click_button "お気に入り"

        expect(page).to have_content("まだお気に入りがありません")
        expect(page).to have_content("気になるレビューを見つけたら、お気に入りに追加してみましょう")
      end
    end
  end

  describe "文字数カウンター" do
    before do
      sign_in user
    end

    it "ニックネームの文字数がリアルタイムで表示される", js: true do
      visit edit_profile_path

      fill_in "user_name", with: "test"

      expect(page).to have_content("4 / 15文字")
    end

    it "自己紹介の文字数がリアルタイムで表示される（改行除外）", js: true do
      visit edit_profile_path

      fill_in "user_self_introduction", with: "test\n\ntest"

      # 改行を除外して8文字
      expect(page).to have_content("8 / 500文字")
    end
  end

  describe "レビュー件数表示" do
    before do
      sign_in user
    end

    context "複数のレビューがある場合" do
      let!(:song1) { create(:song) }
      let!(:song2) { create(:song) }
      let!(:review1) { create(:review, user: user, song: song1) }
      let!(:review2) { create(:review, user: user, song: song2) }

      it "正しいレビュー件数が表示される" do
        visit profile_path

        within "button[data-tab-target='tab']", text: "投稿したレビュー" do
          expect(page).to have_content("2")
        end
      end
    end

    context "レビューが1件の場合" do
      let!(:song) { create(:song) }
      let!(:review) { create(:review, user: user, song: song) }

      it "1件のレビューと表示される" do
        visit profile_path

        within "button[data-tab-target='tab']", text: "投稿したレビュー" do
          expect(page).to have_content("1")
        end
      end
    end
  end

  describe "プロフィール編集のフィールド初期値" do
    before do
      sign_in user
    end

    it "編集フォームに現在の値が入力されている" do
      visit edit_profile_path

      expect(page).to have_field("user_name", with: user.name)
      expect(page).to have_field("user_self_introduction", with: user.self_introduction)
    end
  end

  describe "プロフィール更新後の入力値保持" do
    before do
      sign_in user
    end

    it "バリデーションエラー時に入力値が保持される" do
      visit edit_profile_path

      fill_in "user_name", with: "a"
      fill_in "user_self_introduction", with: "新しい自己紹介"

      click_button "更新する"

      expect(page).to have_field("user_name", with: "a")
      expect(page).to have_field("user_self_introduction", with: "新しい自己紹介")
    end
  end

  describe "自己紹介の空白文字のみ" do
    before do
      sign_in user
    end

    it "空白文字のみの自己紹介は保存できる" do
      visit edit_profile_path

      new_name = "blank_#{user.id}"
      fill_in "user_name", with: new_name
      fill_in "user_self_introduction", with: "   "

      click_button "更新する"

      expect(page).to have_current_path(profile_path)
      expect(page).to have_content(new_name)
      # 空白文字のみの自己紹介は未設定と同じ扱いになる
      expect(page).to have_content("自己紹介を追加して、あなたの音楽の好みを共有しましょう")
    end
  end

  describe "ニックネームの境界値テスト" do
    before do
      sign_in user
    end

    it "2文字のニックネームは保存できる" do
      visit edit_profile_path

      fill_in "user_name", with: "ab"

      click_button "更新する"

      expect(page).to have_current_path(profile_path)
      expect(page).to have_content("プロフィールを更新しました")
      expect(page).to have_content("ab")
    end

    it "15文字のニックネームは保存できる" do
      visit edit_profile_path

      fill_in "user_name", with: "a" * 15

      click_button "更新する"

      expect(page).to have_current_path(profile_path)
      expect(page).to have_content("プロフィールを更新しました")
    end
  end

  describe "自己紹介の境界値テスト" do
    before do
      sign_in user
    end

    it "500文字の自己紹介は保存できる" do
      visit edit_profile_path

      fill_in "user_self_introduction", with: "a" * 500

      click_button "更新する"

      expect(page).to have_current_path(profile_path)
      expect(page).to have_content("プロフィールを更新しました")
    end
  end

  describe "タブバッジのカウント表示" do
    before do
      sign_in user
    end

    context "レビューとお気に入りが両方ある場合" do
      let!(:other_user) { create(:user) }
      let!(:song) { create(:song) }
      let!(:my_review) { create(:review, user: user, song: song) }
      let!(:other_review) { create(:review, user: other_user, song: song) }
      let!(:favorite) { create(:review_favorite, user: user, review: other_review) }

      it "各タブに正しい件数が表示される" do
        visit profile_path

        # 投稿したレビュータブに1件
        within "button[data-tab-target='tab']:first-of-type" do
          expect(page).to have_content("1")
        end

        # お気に入りタブに1件
        within "button[data-tab-target='tab']:last-of-type" do
          expect(page).to have_content("1")
        end
      end
    end
  end

  describe "タブの初期状態" do
    before do
      sign_in user
    end

    it "投稿したレビュータブが最初に表示されている" do
      visit profile_path

      expect(page).to have_content("まだレビューがありません")
      expect(page).to have_content("お気に入りの音楽をレビューして、あなたの感想を共有しましょう")
    end
  end
end
