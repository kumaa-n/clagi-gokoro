class CreateSongs < ActiveRecord::Migration[7.2]
  def change
    create_table :songs do |t|
      t.string :title, null: false
      t.string :composer
      t.string :arranger

      t.timestamps
    end

    add_index :songs, :title
    add_index :songs, :composer
  end
end
