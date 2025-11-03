class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :song, null: false, foreign_key: true
      t.integer :tempo_rating, null: false
      t.integer :fingering_technique_rating, null: false
      t.integer :plucking_technique_rating, null: false
      t.integer :expression_rating, null: false
      t.integer :memorization_rating, null: false
      t.integer :overall_rating, null: false
      t.text :summary

      t.timestamps
    end
  end
end
