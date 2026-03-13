class AddStatusToExploreQueries < ActiveRecord::Migration[8.0]
  def change
    add_column :explore_queries, :status, :string, default: "pending", null: false
  end
end
