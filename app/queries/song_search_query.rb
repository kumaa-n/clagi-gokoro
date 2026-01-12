class SongSearchQuery
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
    @songs = filter_by_top_tags(@songs)
    self
  end

  private

  def search_songs
    if @params[:title].present? || @params[:composer].present? || @params[:arranger].present?
      Song.search_by_fields(
        title: @params[:title],
        composer: @params[:composer],
        arranger: @params[:arranger]
      )
    else
      Song.search_by_keywords(@params[:query])
    end
  end

  def filter_by_tags(songs)
    tags_param = @params[:tag].presence || @params[:tags].presence
    @selected_tags = parse_tags_param(tags_param)

    return songs if @selected_tags.empty?

    candidate_song_uuids = Review.with_any_tags(@selected_tags).distinct.pluck(:song_uuid)
    songs.where(uuid: candidate_song_uuids)
  end

  def apply_associations_and_order(songs)
    songs.with_review_stats.includes(:reviews).order(created_at: :desc)
  end

  def filter_by_top_tags(songs)
    return songs if @selected_tags.empty?

    songs.select do |song|
      top_tags = song.top_tags(3)
      @selected_tags.all? { |tag| top_tags.include?(tag) }
    end
  end

  def parse_tags_param(tags_param)
    return [] if tags_param.blank?

    if tags_param.is_a?(String) && tags_param.start_with?("[")
      JSON.parse(tags_param) rescue [tags_param]
    elsif tags_param.is_a?(Array)
      tags_param
    else
      [tags_param]
    end
  end
end
