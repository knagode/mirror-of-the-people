class AddClusterIdToWishes < ActiveRecord::Migration[8.0]
  def change
    add_reference :wishes, :wish_cluster, null: true, foreign_key: true
  end
end
