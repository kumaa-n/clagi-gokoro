require 'rails_helper'

RSpec.describe "レビュー投稿/編集/削除", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:user) { create(:user) }
  let(:song) { Song.create!(title: "テスト曲", composer: "作曲者", arranger: "編曲者") }

  def choose_all_ratings(value: 3)
    choose "review_tempo_rating_#{value}"
    choose "review_fingering_technique_rating_#{value}"
    choose "review_plucking_technique_rating_#{value}"
    choose "review_expression_rating_#{value}"
    choose "review_memorization_rating_#{value}"
  end

  def choose_ratings_except(skip_field, value: 3)
    fields = {
      tempo_rating: "review_tempo_rating_#{value}",
      fingering_technique_rating: "review_fingering_technique_rating_#{value}",
      plucking_technique_rating: "review_plucking_technique_rating_#{value}",
      expression_rating: "review_expression_rating_#{value}",
      memorization_rating: "review_memorization_rating_#{value}"
    }

    fields.each do |field, radio_id|
      next if field == skip_field

      choose radio_id
    end
  end

  describe "投稿" do
    it "全項目を入力して投稿できる" do
      sign_in user
      visit new_song_review_path(song)

      choose_all_ratings(value: 4)
      fill_in "review_summary", with: "テストレビュー"

      expect {
        click_button "投稿する"
      }.to change(Review, :count).by(1)

      created = Review.last
      expect(page).to have_current_path(review_path(created))
      expect(page).to have_content("テストレビュー")
      expect(page).to have_content(user.name)
    end

    it "必須の評価を選択しないと投稿できない" do
      sign_in user
      visit new_song_review_path(song)

      fill_in "review_summary", with: "評価なし"

      expect {
        click_button "投稿する"
      }.not_to change(Review, :count)

      expect(page).to have_content(I18n.t("errors.messages.not_saved"))
      expect(page).to have_content("テンポは1から5の間で評価してください")
    end

    context "必須の評価を個別に未選択の場合" do
      before do
        sign_in user
        visit new_song_review_path(song)
        fill_in "review_summary", with: "個別未選択テスト"
      end

      it "テンポが未選択だとエラーになる" do
        choose_ratings_except(:tempo_rating)
        click_button "投稿する"

        expect(page).to have_content("テンポは1から5の間で評価してください")
      end

      it "運指技巧が未選択だとエラーになる" do
        choose_ratings_except(:fingering_technique_rating)
        click_button "投稿する"

        expect(page).to have_content("運指技巧は1から5の間で評価してください")
      end

      it "弾弦技巧が未選択だとエラーになる" do
        choose_ratings_except(:plucking_technique_rating)
        click_button "投稿する"

        expect(page).to have_content("弾弦技巧は1から5の間で評価してください")
      end

      it "表現力が未選択だとエラーになる" do
        choose_ratings_except(:expression_rating)
        click_button "投稿する"

        expect(page).to have_content("表現力は1から5の間で評価してください")
      end

      it "暗譜・構成が未選択だとエラーになる" do
        choose_ratings_except(:memorization_rating)
        click_button "投稿する"

        expect(page).to have_content("暗譜・構成は1から5の間で評価してください")
      end
    end
  end

  describe "ユニーク制約" do
    it "同じユーザーが同じ曲に2件目を投稿しようとすると失敗する" do
      sign_in user
      Review.create!(
        user: user,
        song: song,
        tempo_rating: 3,
        fingering_technique_rating: 3,
        plucking_technique_rating: 3,
        expression_rating: 3,
        memorization_rating: 3,
        summary: "既存レビュー"
      )

      visit new_song_review_path(song)
      choose_all_ratings(value: 4)
      fill_in "review_summary", with: "2件目レビュー"

      expect {
        click_button "投稿する"
      }.not_to change(Review, :count)

      expect(page).to have_content("曲に対してレビュー済みです。")
    end
  end

  describe "編集" do
    let!(:review) do
      Review.create!(
        user: user,
        song: song,
        tempo_rating: 3,
        fingering_technique_rating: 3,
        plucking_technique_rating: 3,
        expression_rating: 3,
        memorization_rating: 3,
        summary: "初回レビュー"
      )
    end

    it "内容を更新できる" do
      sign_in user
      visit edit_review_path(review)

      choose_all_ratings(value: 5)
      fill_in "review_summary", with: "更新後レビュー"
      click_button "更新する"

      expect(page).to have_current_path(review_path(review))
      expect(page).to have_content("更新後レビュー")
      expect(page).to have_selector("canvas[data-tempo='5'][data-fingering='5'][data-plucking='5'][data-expression='5'][data-memorization='5']")
    end
  end

  describe "削除" do
    let!(:review) do
      Review.create!(
        user: user,
        song: song,
        tempo_rating: 4,
        fingering_technique_rating: 4,
        plucking_technique_rating: 4,
        expression_rating: 4,
        memorization_rating: 4,
        summary: "削除対象レビュー"
      )
    end

    it "確認モーダルの削除ボタンで削除できる" do
      sign_in user
      visit review_path(review)

      expect {
        # rack_testではモーダルの開閉は無視されるため、直接「削除する」ボタンを押下
        click_button "削除する"
      }.to change(Review, :count).by(-1)

      expect(page).to have_current_path(song_reviews_path(song))
      expect(page).to have_content(I18n.t("defaults.flash_message.destroyed", resource: Review.model_name.human))
    end
  end

  describe "アクセス制御" do
    let!(:review) do
      Review.create!(
        user: user,
        song: song,
        tempo_rating: 4,
        fingering_technique_rating: 4,
        plucking_technique_rating: 4,
        expression_rating: 4,
        memorization_rating: 4,
        summary: "権限テストレビュー"
      )
    end

    context "未ログインの場合" do
      it "新規作成ページはログイン画面へリダイレクトされる" do
        visit new_song_review_path(song)
        expect(page).to have_current_path(new_user_session_path)
      end

      it "編集ページはログイン画面へリダイレクトされる" do
        visit edit_review_path(review)
        expect(page).to have_current_path(new_user_session_path)
      end

      it "詳細ページで編集/削除ボタンが表示されない" do
        visit review_path(review)
        expect(page).to have_no_link("編集")
        expect(page).to have_no_button("削除する")
      end
    end

    context "他ユーザーの場合" do
      let(:other_user) { create(:user) }

      it "編集ページへのアクセスは拒否され一覧へ戻される" do
        sign_in other_user
        visit edit_review_path(review)

        expect(page).to have_current_path(song_reviews_path(song))
        expect(page).to have_content(I18n.t("defaults.flash_message.forbidden"))
      end

      it "削除リクエストも拒否され一覧へ戻される" do
        sign_in other_user
        page.driver.submit :delete, review_path(review), {}

        expect(page).to have_current_path(song_reviews_path(song))
        expect(page).to have_content(I18n.t("defaults.flash_message.forbidden"))
        expect(Review.exists?(review.id)).to be true
      end

      it "詳細ページに編集/削除ボタンが表示されない" do
        sign_in other_user
        visit review_path(review)

        expect(page).to have_no_link("編集")
        expect(page).to have_no_button("削除する")
      end
    end
  end

  describe "一覧表示" do
    it "レビューがない場合はメッセージを表示する" do
      visit song_reviews_path(song)

      expect(page).to have_content("まだレビューが投稿されていません")
      expect(page).to have_link("ログイン / 新規登録", href: new_user_session_path)
    end

    it "自分のレビューがある場合は編集ボタンが表示され、投稿ボタンは出ない" do
      review = Review.create!(
        user: user,
        song: song,
        tempo_rating: 3,
        fingering_technique_rating: 3,
        plucking_technique_rating: 3,
        expression_rating: 3,
        memorization_rating: 3,
        summary: "自分のレビュー"
      )

      sign_in user
      visit song_reviews_path(song)

      expect(page).to have_link("自分のレビューを見る", href: review_path(review))
      expect(page).to have_no_link("レビューを投稿")
    end

    it "自分のレビューがない場合は投稿ボタンが表示され、編集ボタンは出ない" do
      other_user = create(:user)
      Review.create!(
        user: other_user,
        song: song,
        tempo_rating: 4,
        fingering_technique_rating: 4,
        plucking_technique_rating: 4,
        expression_rating: 4,
        memorization_rating: 4,
        summary: "他人のレビュー"
      )

      sign_in user
      visit song_reviews_path(song)

      expect(page).to have_link("レビューを投稿", href: new_song_review_path(song))
      expect(page).to have_no_link("レビューを編集")
    end
  end
end
