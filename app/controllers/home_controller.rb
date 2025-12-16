class HomeController < ApplicationController
  def index
    @most_reviewed_songs = Song.most_reviewed(4)
    @recent_songs = Song.recent_with_stats(4)
  end
end
