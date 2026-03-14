class CreateWishClusters < ActiveRecord::Migration[8.0]
  def change
    create_table :wish_clusters do |t|
      t.string :name
      t.text :summary
      t.integer :wishes_count

      t.timestamps
    end
  end
end
