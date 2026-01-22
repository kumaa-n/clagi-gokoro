require "rails_helper"

RSpec.describe "AccountDeletion", type: :system do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "アカウント削除機能" do
    it "プロフィール編集ページにアカウント削除セクションが表示されること" do
      visit edit_profile_path

      expect(page).to have_content("アカウント削除")
      expect(page).to have_button("アカウント削除")
    end

    it "削除ボタンをクリックすると確認モーダルが表示されること", :js do
      visit edit_profile_path

      click_button "アカウント削除"

      expect(page).to have_content("アカウント削除の確認")
      expect(page).to have_content("本当にアカウントを削除しますか？")
      expect(page).to have_content("あなたが投稿したすべてのレビュー")
    end

    it "モーダルでキャンセルをクリックするとアカウントは削除されないこと", :js do
      visit edit_profile_path

      expect do
        click_button "アカウント削除"
        click_button "キャンセル"
      end.not_to change(User, :count)
    end

    it "アカウントを削除するとユーザーが削除され、ログアウト状態でトップページにリダイレクトされること", :js do
      visit edit_profile_path

      click_button "アカウント削除"

      # モーダルが表示されるのを待つ
      expect(page).to have_content("アカウント削除の確認")

      click_button "削除する"

      # リダイレクト完了を待つ（ページ遷移を先に待つ）
      expect(page).to have_current_path(root_path, wait: 10)
      expect(page).to have_content("アカウントを削除しました")
      expect(page).to have_link("ログイン") # ログアウト状態を確認

      # データベースの変更を確認
      expect(User.count).to eq(0)
    end

    context "レビューを投稿しているユーザー", :js do
      let!(:song) { create(:song) }
      let!(:review) { create(:review, user: user, song: song) }

      it "アカウント削除時にレビューも削除されること" do
        visit edit_profile_path

        click_button "アカウント削除"

        # モーダルが表示されるのを待つ
        expect(page).to have_content("アカウント削除の確認")

        click_button "削除する"

        # リダイレクト完了を待つ（ページ遷移を先に待つ）
        expect(page).to have_current_path(root_path, wait: 10)
        expect(page).to have_content("アカウントを削除しました")

        # データベースの変更を確認
        expect(Review.count).to eq(0)
        expect(Review.find_by(uuid: review.uuid)).to be_nil
      end
    end

    context "お気に入りを登録しているユーザー", :js do
      let!(:other_user) { create(:user) }
      let!(:song) { create(:song) }
      let!(:review) { create(:review, user: other_user, song: song) }
      let!(:review_favorite) { create(:review_favorite, user: user, review: review) }

      it "アカウント削除時にお気に入り情報も削除されること" do
        visit edit_profile_path

        click_button "アカウント削除"

        # モーダルが表示されるのを待つ
        expect(page).to have_content("アカウント削除の確認")

        click_button "削除する"

        # リダイレクト完了を待つ（ページ遷移を先に待つ）
        expect(page).to have_current_path(root_path, wait: 10)
        expect(page).to have_content("アカウントを削除しました")

        # データベースの変更を確認
        expect(ReviewFavorite.count).to eq(0)
        expect(ReviewFavorite.find_by(id: review_favorite.id)).to be_nil
      end
    end

    context "認証とセキュリティ" do
      it "ログインしていない場合、プロフィール編集ページにアクセスできないこと" do
        sign_out user
        visit edit_profile_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end
end
