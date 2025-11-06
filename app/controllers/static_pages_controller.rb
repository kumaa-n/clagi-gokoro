class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!

  def top
    @most_reviewed_songs = Song.most_reviewed(4)
    @recent_songs = Song.recent_with_stats(4)
  end
end
