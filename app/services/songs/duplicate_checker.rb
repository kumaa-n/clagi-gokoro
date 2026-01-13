module Songs
  class DuplicateChecker
    attr_reader :duplicate_song, :filter_url

    def initialize(title:, composer: nil, arranger: nil)
      @title = title
      @composer = composer
      @arranger = arranger
      @duplicate_song = nil
      @filter_url = nil
    end

    def call
      @duplicate_song = Song.find_duplicate_by_input(
        title: @title,
        composer: @composer,
        arranger: @arranger
      )

      if @duplicate_song
        @filter_url = build_filter_url
      end

      self
    end

    def duplicate?
      @duplicate_song.present?
    end

    def to_json_response
      if duplicate?
        {
          duplicate: true,
          url: @filter_url
        }
      else
        { duplicate: false }
      end
    end

    private

    def build_filter_url
      filter_params = { title: @title }
      filter_params[:composer] = @composer if @composer.present?
      filter_params[:arranger] = @arranger if @arranger.present?
      Rails.application.routes.url_helpers.songs_path(filter_params)
    end
  end
end
