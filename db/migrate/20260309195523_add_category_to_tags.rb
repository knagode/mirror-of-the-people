class AddCategoryToTags < ActiveRecord::Migration[8.0]
  def change
    add_column :tags, :category, :string
  end
end
