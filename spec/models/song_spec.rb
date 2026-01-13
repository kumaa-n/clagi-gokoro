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
          existing_song.update!(title: "Test Song", composer: "Yamada", arranger: "Sato")
          duplicate_song = build(:song, title: "test song", composer: "yamada", arranger: "sato")
          expect(duplicate_song).to be_invalid
        end
      end

      context "スペースの有無が異なる場合" do
        it "正規化されて重複と判定されること" do
          existing_song.update!(title: "テスト 曲", composer: "山田 太郎", arranger: "佐藤 次郎")
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
          existing_song.update!(composer: nil, arranger: nil)
          duplicate_song = build(:song, title: "テスト曲", composer: nil, arranger: nil)
          expect(duplicate_song).to be_invalid
        end

        it "曲名が異なれば登録できること" do
          existing_song.update!(composer: nil, arranger: nil)
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

  describe "正規化カラムの自動設定" do
    it "保存時に正規化カラムが自動的に設定されること" do
      song = create(:song, title: "Love Me", composer: "John Smith", arranger: "Jane Doe")
      expect(song.normalized_title).to eq("loveme")
      expect(song.normalized_composer).to eq("johnsmith")
      expect(song.normalized_arranger).to eq("janedoe")
    end

    it "全角・スペース・大文字が正規化されること" do
      song = create(:song, title: "ＬＯＶＥ　ＭＥ", composer: "ＪＯＨＮ　ＳＭＩＴＨ", arranger: "ＪＡＮＥ　ＤＯＥ")
      expect(song.normalized_title).to eq("loveme")
      expect(song.normalized_composer).to eq("johnsmith")
      expect(song.normalized_arranger).to eq("janedoe")
    end

    it "空の値は空文字として正規化されること" do
      song = create(:song, title: "Test", composer: "", arranger: nil)
      expect(song.normalized_title).to eq("test")
      expect(song.normalized_composer).to eq("")
      expect(song.normalized_arranger).to eq("")
    end

    it "更新時に正規化カラムも更新されること" do
      song = create(:song, title: "Old Title", composer: "Old Composer", arranger: "Old Arranger")
      song.update!(title: "New Title", composer: "New Composer", arranger: "New Arranger")
      expect(song.normalized_title).to eq("newtitle")
      expect(song.normalized_composer).to eq("newcomposer")
      expect(song.normalized_arranger).to eq("newarranger")
    end
  end

  describe ".search_by_keywords" do
    let!(:song1) { create(:song, title: "Love me", composer: "John Smith", arranger: "Jane Doe") }
    let!(:song2) { create(:song, title: "Lovely Day", composer: "Mary Johnson", arranger: "Bob Williams") }
    let!(:song3) { create(:song, title: "Yesterday", composer: "Paul McCartney", arranger: "George Martin") }

    context "スペースなしのキーワードで検索" do
      it "スペースありの曲名が見つかること" do
        results = Song.search_by_keywords("Loveme")
        expect(results).to include(song1)
        expect(results).not_to include(song3)
      end
    end

    context "スペースありのキーワードで検索" do
      it "スペースなしの正規化で一致する曲が見つかること" do
        results = Song.search_by_keywords("Love me")
        expect(results).to include(song1)
      end
    end

    context "全角キーワードで検索" do
      it "半角の曲が見つかること" do
        results = Song.search_by_keywords("ＬＯＶＥ")
        expect(results).to include(song1, song2)
        expect(results).not_to include(song3)
      end
    end

    context "大文字キーワードで検索" do
      it "小文字の曲が見つかること" do
        results = Song.search_by_keywords("LOVE")
        expect(results).to include(song1, song2)
        expect(results).not_to include(song3)
      end
    end

    context "作曲者名で検索" do
      it "作曲者名でも検索できること" do
        results = Song.search_by_keywords("johnsmith")
        expect(results).to include(song1)
        expect(results).not_to include(song2, song3)
      end
    end

    context "複数キーワードで検索" do
      it "すべてのキーワードを含む曲が見つかること" do
        results = Song.search_by_keywords("me john")
        expect(results).to include(song1)
        expect(results).not_to include(song2, song3)
      end
    end

    context "空の検索クエリ" do
      it "全ての曲が返されること" do
        results = Song.search_by_keywords("")
        expect(results.count).to eq(3)
      end
    end

    context "nilを渡した場合" do
      it "エラーにならず全件が返されること" do
        expect { Song.search_by_keywords(nil) }.not_to raise_error
        results = Song.search_by_keywords(nil)
        expect(results.count).to eq(3)
      end
    end

    context "特殊文字を含むキーワード" do
      it "SQLのワイルドカード文字がエスケープされること" do
        create(:song, title: "100% Love", composer: "Test", arranger: "Test")
        results = Song.search_by_keywords("%")
        # %がリテラルとして扱われ、"100% Love"のみマッチ
        expect(results.count).to eq(1)
      end

      it "アンダースコアがエスケープされること" do
        create(:song, title: "Love_Song", composer: "Test", arranger: "Test")
        results = Song.search_by_keywords("_")
        # _がリテラルとして扱われる
        expect(results.count).to eq(1)
      end
    end
  end

  describe ".search_by_fields" do
    let!(:song1) { create(:song, title: "Love me", composer: "John Smith", arranger: "Jane Doe") }
    let!(:song2) { create(:song, title: "Lovely Day", composer: "Mary Johnson", arranger: "Bob Williams") }
    let!(:song3) { create(:song, title: "Yesterday", composer: "Paul McCartney", arranger: "George Martin") }

    context "タイトルで検索（スペースなし）" do
      it "スペースありの曲名が見つかること" do
        results = Song.search_by_fields(title: "Loveme")
        expect(results).to include(song1)
        expect(results).not_to include(song3)
      end
    end

    context "タイトルで検索（スペースあり）" do
      it "正規化されて検索されること" do
        results = Song.search_by_fields(title: "Love me")
        expect(results).to include(song1)
      end
    end

    context "タイトルで検索（全角）" do
      it "半角の曲が見つかること" do
        results = Song.search_by_fields(title: "ＬＯＶＥ")
        expect(results).to include(song1, song2)
        expect(results).not_to include(song3)
      end
    end

    context "作曲者で検索" do
      it "正規化されて検索されること" do
        results = Song.search_by_fields(composer: "johnsmith")
        expect(results).to include(song1)
        expect(results).not_to include(song2, song3)
      end
    end

    context "編曲者で検索" do
      it "正規化されて検索されること" do
        results = Song.search_by_fields(arranger: "janedoe")
        expect(results).to include(song1)
        expect(results).not_to include(song2, song3)
      end
    end

    context "複数フィールドで検索" do
      it "全ての条件に一致する曲が見つかること" do
        results = Song.search_by_fields(title: "Loveme", composer: "JohnSmith")
        expect(results).to include(song1)
        expect(results).not_to include(song2, song3)
      end
    end

    context "空の検索条件" do
      it "全ての曲が返されること" do
        results = Song.search_by_fields
        expect(results.count).to eq(3)
      end
    end

    context "全フィールドで検索" do
      it "全ての条件に一致する曲のみが見つかること" do
        results = Song.search_by_fields(title: "Loveme", composer: "JohnSmith", arranger: "JaneDoe")
        expect(results).to include(song1)
        expect(results).not_to include(song2, song3)
      end
    end

    context "条件に一致しない検索" do
      it "空の結果が返されること" do
        results = Song.search_by_fields(title: "NonExistent")
        expect(results).to be_empty
      end
    end
  end

  describe ".autocomplete_by_field" do
    let!(:song1) { create(:song, title: "Love me", composer: "John Smith", arranger: "Jane Doe") }
    let!(:song2) { create(:song, title: "Lovely Day", composer: "Mary Johnson", arranger: "Bob Williams") }
    let!(:song3) { create(:song, title: "Yesterday", composer: "Paul McCartney", arranger: "George Martin") }

    context "タイトルのオートコンプリート（スペースなし）" do
      it "スペースありの曲名が返されること" do
        results = Song.autocomplete_by_field(field: "title", query: "Loveme")
        expect(results).to include("Love me")
      end
    end

    context "タイトルのオートコンプリート（スペースあり）" do
      it "正規化されて検索されること" do
        results = Song.autocomplete_by_field(field: "title", query: "Love me")
        expect(results).to include("Love me")
      end
    end

    context "タイトルのオートコンプリート（全角）" do
      it "半角の曲名が返されること" do
        results = Song.autocomplete_by_field(field: "title", query: "ＬＯＶＥ")
        expect(results).to include("Love me", "Lovely Day")
        expect(results).not_to include("Yesterday")
      end
    end

    context "作曲者のオートコンプリート" do
      it "正規化されて検索され、元の値が返されること" do
        results = Song.autocomplete_by_field(field: "composer", query: "johnsmith")
        expect(results).to include("John Smith")
        expect(results).not_to include("Mary Johnson")
      end
    end

    context "編曲者のオートコンプリート" do
      it "正規化されて検索され、元の値が返されること" do
        results = Song.autocomplete_by_field(field: "arranger", query: "janedoe")
        expect(results).to include("Jane Doe")
        expect(results).not_to include("Bob Williams")
      end
    end

    context "空のクエリ" do
      it "空の配列が返されること" do
        results = Song.autocomplete_by_field(field: "title", query: "")
        expect(results).to be_empty
      end
    end

    context "不正なフィールド名" do
      it "空の配列が返されること" do
        results = Song.autocomplete_by_field(field: "invalid_field", query: "test")
        expect(results).to be_empty
      end
    end

    context "最大10件の制限" do
      it "最大10件しか返さないこと" do
        11.times do |i|
          create(:song, title: "Test Song #{i}", composer: "Composer #{i}", arranger: "Arranger #{i}")
        end
        results = Song.autocomplete_by_field(field: "title", query: "test")
        expect(results.size).to eq(10)
      end
    end
  end

  describe ".find_duplicate" do
    let!(:existing_song) { create(:song, title: "Love me", composer: "John Smith", arranger: "Jane Doe") }

    context "完全一致（スペースなし）" do
      it "重複が検出されること" do
        duplicate = Song.find_duplicate(title: "Loveme", composer: "JohnSmith", arranger: "JaneDoe")
        expect(duplicate).to eq(existing_song)
      end
    end

    context "完全一致（全角）" do
      it "重複が検出されること" do
        duplicate = Song.find_duplicate(title: "ＬＯＶＥ　ＭＥ", composer: "ＪＯＨＮ　ＳＭＩＴＨ", arranger: "ＪＡＮＥ　ＤＯＥ")
        expect(duplicate).to eq(existing_song)
      end
    end

    context "作曲者が異なる場合" do
      it "重複が検出されないこと" do
        duplicate = Song.find_duplicate(title: "Loveme", composer: "Different Person", arranger: "JaneDoe")
        expect(duplicate).to be_nil
      end
    end

    context "編曲者が異なる場合" do
      it "重複が検出されないこと" do
        duplicate = Song.find_duplicate(title: "Loveme", composer: "JohnSmith", arranger: "Different Person")
        expect(duplicate).to be_nil
      end
    end

    context "exclude_uuidが指定された場合" do
      it "指定したUUIDの曲を除外すること" do
        duplicate = Song.find_duplicate(
          title: "Loveme",
          composer: "JohnSmith",
          arranger: "JaneDoe",
          exclude_uuid: existing_song.uuid
        )
        expect(duplicate).to be_nil
      end
    end
  end

  describe ".find_duplicate_by_input" do
    let!(:existing_song) { create(:song, title: "Love me", composer: "John Smith", arranger: "Jane Doe") }

    context "タイトルのみで検索（skip_blank_fields: true）" do
      it "重複が検出されること" do
        duplicate = Song.find_duplicate_by_input(title: "Loveme")
        expect(duplicate).to eq(existing_song)
      end
    end

    context "タイトルと作曲者で検索" do
      it "重複が検出されること" do
        duplicate = Song.find_duplicate_by_input(title: "Loveme", composer: "JohnSmith")
        expect(duplicate).to eq(existing_song)
      end
    end

    context "タイトルと作曲者と編曲者で検索" do
      it "重複が検出されること" do
        duplicate = Song.find_duplicate_by_input(title: "Loveme", composer: "JohnSmith", arranger: "JaneDoe")
        expect(duplicate).to eq(existing_song)
      end
    end

    context "タイトルが空の場合" do
      it "nilが返されること" do
        duplicate = Song.find_duplicate_by_input(title: "")
        expect(duplicate).to be_nil
      end
    end

    context "作曲者が異なる曲が存在する場合" do
      let!(:another_song) { create(:song, title: "Love me", composer: "Different Person", arranger: "Someone Else") }

      it "タイトルのみで検索すると最初の曲が見つかること" do
        duplicate = Song.find_duplicate_by_input(title: "Loveme")
        expect(duplicate).to eq(existing_song)
      end

      it "作曲者を指定すると一致する曲のみが見つかること" do
        duplicate = Song.find_duplicate_by_input(title: "Loveme", composer: "DifferentPerson")
        expect(duplicate).to eq(another_song)
      end
    end
  end

  describe ".find_duplicate with skip_blank_fields: false" do
    let!(:existing_song) { create(:song, title: "Love me", composer: "John Smith", arranger: "Jane Doe") }
    let!(:song_without_arranger) { create(:song, title: "Another Song", composer: "Someone", arranger: "") }

    context "空欄を厳密に比較する場合" do
      it "編曲者が空の曲と空文字で検索すると見つかること" do
        duplicate = Song.find_duplicate(
          title: "AnotherSong",
          composer: "Someone",
          arranger: "",
          skip_blank_fields: false
        )
        expect(duplicate).to eq(song_without_arranger)
      end

      it "編曲者が異なると見つからないこと" do
        duplicate = Song.find_duplicate(
          title: "AnotherSong",
          composer: "Someone",
          arranger: "DifferentArranger",
          skip_blank_fields: false
        )
        expect(duplicate).to be_nil
      end
    end
  end
end
