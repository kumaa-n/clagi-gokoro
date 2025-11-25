require 'rails_helper'

RSpec.describe "曲投稿", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:user) { create(:user) }
  let(:title_label) { Song.human_attribute_name(:title) }

  describe "新規作成" do
    context "ログインしている場合" do
      before do
        sign_in user
        visit new_song_path
      end

      def fill_song_form(title: "テスト曲")
        fill_in "song_title", with: title
        fill_in "song_composer", with: "作曲者"
        fill_in "song_arranger", with: "編曲者"
        find('input[type="checkbox"][required]').check
      end

      it "有効な情報を入力すると曲が登録でき、レビュー促進モーダルが表示される" do
        fill_song_form
        created_song = nil
        expect {
          click_button "曲追加"
          created_song = Song.last
        }.to change(Song, :count).by(1)

        expect(page).to have_current_path(songs_path)
        expect(page).to have_content("テスト曲")
        expect(page).to have_selector("dialog#review_prompt_modal", visible: :all)
        within("#review_prompt_modal") do
          expect(page).to have_content("レビューを投稿しますか？")
          expect(page).to have_link("レビューを投稿する", href: new_song_review_path(created_song))
          expect(page).to have_button("あとで")
        end
      end

      it "モーダルで「あとで」を押すと閉じる" do
        fill_song_form
        expect {
          click_button "曲追加"
        }.to change(Song, :count).by(1)

        within("#review_prompt_modal") do
          click_button "あとで"
        end

        expect(page).to have_current_path(songs_path)
        expect(page).to have_no_selector("dialog#review_prompt_modal[open]", visible: :all)
      end

      it "モーダルで「レビューを投稿する」を押すとレビュー投稿ページへ遷移する" do
        fill_song_form
        created_song = nil
        expect {
          click_button "曲追加"
          created_song = Song.last
        }.to change(Song, :count).by(1)

        within("#review_prompt_modal") do
          click_link "レビューを投稿する"
        end

        expect(page).to have_current_path(new_song_review_path(created_song))
      end

      it "タイトルが空だと曲が登録できない" do
        fill_in "song_title", with: ""
        find('input[type="checkbox"][required]').check

        expect {
          click_button "曲追加"
        }.not_to change(Song, :count)

        expect(page).to have_content(I18n.t("errors.messages.not_saved"))
        expect(page).to have_content("#{title_label}を入力してください")
      end

      it "タイトルが長すぎると曲が登録できない" do
        fill_in "song_title", with: "a" * 101
        find('input[type="checkbox"][required]').check

        expect {
          click_button "曲追加"
        }.not_to change(Song, :count)

        expect(page).to have_content("#{title_label}は100文字以内で入力してください")
      end

      it "作曲者が長すぎると曲が登録できない" do
        fill_in "song_title", with: "テスト曲"
        fill_in "song_composer", with: "a" * 51
        find('input[type="checkbox"][required]').check

        expect {
          click_button "曲追加"
        }.not_to change(Song, :count)

        expect(page).to have_content("作曲者は50文字以内で入力してください")
      end

      it "編曲者が長すぎると曲が登録できない" do
        fill_in "song_title", with: "テスト曲"
        fill_in "song_arranger", with: "a" * 51
        find('input[type="checkbox"][required]').check

        expect {
          click_button "曲追加"
        }.not_to change(Song, :count)

        expect(page).to have_content("編曲者は50文字以内で入力してください")
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        visit new_song_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "一覧" do
    it "曲がない場合にメッセージが表示される" do
      visit songs_path

      expect(page).to have_content("まだ曲が登録されていません")
      expect(page).to have_link("ログイン / 新規登録", href: new_user_session_path)
    end

    it "曲がある場合にカードが表示される" do
      Song.create!(title: "曲A", composer: "作曲者A", arranger: "編曲者A")
      Song.create!(title: "曲B", composer: "作曲者B", arranger: "編曲者B")

      visit songs_path

      expect(page).to have_content("曲A")
      expect(page).to have_content("曲B")
      expect(page).to have_link("レビューを見る", href: song_reviews_path(Song.find_by(title: "曲A")))
    end
  end
end
