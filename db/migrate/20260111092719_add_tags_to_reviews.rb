class AddTagsToReviews < ActiveRecord::Migration[7.2]
  def change
    add_column :reviews, :tags, :text, array: true, default: []
  end
end
