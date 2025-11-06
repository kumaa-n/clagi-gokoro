class ReviewCommentsController < ApplicationController
  before_action :set_song
  before_action :set_review

  def create
    @review_comment = @review.review_comments.build(review_comment_params)
    @review_comment.user = current_user

    respond_to do |format|
      if @review_comment.save
        format.turbo_stream do
          @new_review_comment = @review.review_comments.build
        end
        format.html { redirect_to song_review_path(@song, @review) }
      else
        @review_comments = @review.review_comments.includes(:user).order(created_at: :desc)
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "review_comment_form",
            partial: "review_comments/form_frame",
            locals: { review_comment: @review_comment, song: @song, review: @review }
          ), status: :unprocessable_entity
        end
        format.html { render "reviews/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def set_song
    @song = Song.find(params[:song_id])
  end

  def set_review
    @review = @song.reviews.find(params[:review_id])
  end

  def review_comment_params
    params.require(:review_comment).permit(:content)
  end
end
