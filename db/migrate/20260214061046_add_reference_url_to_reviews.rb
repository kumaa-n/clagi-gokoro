class AddReferenceUrlToReviews < ActiveRecord::Migration[7.2]
  def change
    add_column :reviews, :reference_url, :text
  end
end
