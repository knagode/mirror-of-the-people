class CreateExploreQueries < ActiveRecord::Migration[8.0]
  def change
    create_table :explore_queries do |t|
      t.text :question
      t.integer :wishes_count
      t.text :answer

      t.timestamps
    end
  end
end
