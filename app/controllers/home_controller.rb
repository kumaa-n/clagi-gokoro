class HomeController < ApplicationController
  DISPLAY_SONG_COUNT = 4

  def index
    @most_reviewed_songs = Song.most_reviewed(limit: DISPLAY_SONG_COUNT)
    @recent_songs = Song.recent_with_stats(limit: DISPLAY_SONG_COUNT)
  end
end
