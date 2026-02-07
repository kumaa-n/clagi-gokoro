module Songs
  class SearchQuery
    attr_reader :selected_tags, :songs

    def initialize(params)
      @params = params
      @selected_tags = []
      @songs = nil
    end

    def call
      @songs = search_songs
      @songs = filter_by_tags(@songs)
      @songs = apply_associations_and_order(@songs)
      @songs = filter_by_difficulty_range(@songs)
      @songs = filter_by_top_tags(@songs)
      self
    end

    private

    def search_songs
      if @params[:title].present? || @params[:composer].present? || @params[:arranger].present?
        # 曲一覧からの検索
        Song.search_by_fields(
          title: @params[:title],
          composer: @params[:composer],
          arranger: @params[:arranger]
        )
      else
        # トップページからの検索
        Song.search_by_keywords(@params[:query])
      end
    end

    # 選択されたタグを持つレビューがある曲を取得
    def filter_by_tags(songs)
      tags_param = @params[:tag].presence || @params[:tags].presence
      @selected_tags = parse_tags_param(tags_param)

      return songs if @selected_tags.empty?

      song_uuids_with_tags = Review.with_any_tags(@selected_tags).distinct.pluck(:song_uuid)
      songs.where(uuid: song_uuids_with_tags)
    end

    # レビュー情報を含めて新しい順にソート
    def apply_associations_and_order(songs)
      songs.with_review_stats.includes(:reviews).order(created_at: :desc)
    end

    # 平均総合難易度で範囲フィルタリング
    def filter_by_difficulty_range(songs)
      min_val = @params[:min_difficulty].presence&.to_f
      max_val = @params[:max_difficulty].presence&.to_f

      return songs if min_val.nil? && max_val.nil?

      # 未指定の場合は制限なしとして扱うため無限大で補完
      min_val ||= -Float::INFINITY
      max_val ||=  Float::INFINITY

      songs.select do |song|
        avg_rating = song.average_overall_rating.to_f
        avg_rating.positive? && avg_rating.between?(min_val, max_val)
      end
    end

    # 選択されたタグがトップタグに含まれている曲を抽出
    def filter_by_top_tags(songs)
      return songs if @selected_tags.empty?

      songs.select do |song|
        @selected_tags.all? { |tag| song.top_tags.include?(tag) }
      end
    end

    # タグパラメータを配列形式に正規化
    # - JSON文字列: '["tag1", "tag2"]' → 検索フォームから送信
    # - 単一文字列: "tag1" → 曲カードのタグクリック時
    def parse_tags_param(tags_param)
      return [] if tags_param.blank?

      # JSON配列文字列の可能性がある場合のみパースを試みる
      if tags_param.start_with?("[") && tags_param.end_with?("]")
        JSON.parse(tags_param)
      else
        [tags_param]
      end
    rescue JSON::ParserError
      [tags_param]
    end
  end
end
