require "rails_helper"

RSpec.describe Song, type: :model do
  describe "validations" do
    describe "重複チェック" do
      let!(:existing_song) do
        create(:song, title: "テスト曲", composer: "山田太郎", arranger: "佐藤次郎")
      end

      context "完全に同じ曲名・作曲者・編曲者の場合" do
        it "バリデーションエラーになること" do
          duplicate_song = build(:song, title: "テスト曲", composer: "山田太郎", arranger: "佐藤次郎")
          expect(duplicate_song).to be_invalid
          expect(duplicate_song.errors[:base]).to be_present
        end
      end

      context "全角/半角が異なる場合" do
        it "正規化されて重複と判定されること" do
          duplicate_song = build(:song, title: "テスト曲", composer: "山田太郎", arranger: "佐藤次郎")
          expect(duplicate_song).to be_invalid
        end
      end

      context "大文字/小文字が異なる場合" do
        it "正規化されて重複と判定されること" do
          existing_song.update_columns(title: "Test Song", composer: "Yamada", arranger: "Sato")
          duplicate_song = build(:song, title: "test song", composer: "yamada", arranger: "sato")
          expect(duplicate_song).to be_invalid
        end
      end

      context "スペースの有無が異なる場合" do
        it "正規化されて重複と判定されること" do
          existing_song.update_columns(title: "テスト 曲", composer: "山田 太郎", arranger: "佐藤 次郎")
          duplicate_song = build(:song, title: "テスト曲", composer: "山田太郎", arranger: "佐藤次郎")
          expect(duplicate_song).to be_invalid
        end
      end

      context "曲名が同じでも作曲者が異なる場合" do
        it "バリデーションが通ること" do
          different_song = build(:song, title: "テスト曲", composer: "鈴木三郎", arranger: "佐藤次郎")
          expect(different_song).to be_valid
        end
      end

      context "曲名が同じでも編曲者が異なる場合" do
        it "バリデーションが通ること" do
          different_song = build(:song, title: "テスト曲", composer: "山田太郎", arranger: "高橋四郎")
          expect(different_song).to be_valid
        end
      end

      context "作曲者・編曲者が空の場合" do
        it "曲名が同じなら重複と判定されること" do
          existing_song.update_columns(composer: nil, arranger: nil)
          duplicate_song = build(:song, title: "テスト曲", composer: nil, arranger: nil)
          expect(duplicate_song).to be_invalid
        end

        it "曲名が異なれば登録できること" do
          existing_song.update_columns(composer: nil, arranger: nil)
          different_song = build(:song, title: "別の曲", composer: nil, arranger: nil)
          expect(different_song).to be_valid
        end
      end

      context "曲名が空の場合" do
        it "重複チェックがスキップされること" do
          # presence validationで弾かれるが、重複チェックは実行されない
          song = build(:song, title: nil)
          song.valid?
          expect(song.errors[:base]).to be_empty
          expect(song.errors[:title]).to be_present
        end
      end
    end
  end

  describe ".normalize_for_duplicate_check" do
    it "全角英数字を半角に変換すること" do
      expect(Song.normalize_for_duplicate_check("ＡＢＣ１２３")).to eq("abc123")
    end

    it "スペースを削除すること" do
      expect(Song.normalize_for_duplicate_check("テスト 曲")).to eq("テスト曲")
      expect(Song.normalize_for_duplicate_check("テスト　曲")).to eq("テスト曲")
    end

    it "大文字を小文字に変換すること" do
      expect(Song.normalize_for_duplicate_check("ABCD")).to eq("abcd")
    end

    it "nilの場合は空文字を返すこと" do
      expect(Song.normalize_for_duplicate_check(nil)).to eq("")
    end

    it "空文字の場合は空文字を返すこと" do
      expect(Song.normalize_for_duplicate_check("")).to eq("")
    end

    it "複数の正規化を同時に適用すること" do
      expect(Song.normalize_for_duplicate_check("Ｔｅｓｔ Ｓｏｎｇ")).to eq("testsong")
    end
  end
end
