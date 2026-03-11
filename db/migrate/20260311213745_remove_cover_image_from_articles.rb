class RemoveCoverImageFromArticles < ActiveRecord::Migration[8.0]
  def change
    remove_column :articles, :cover_image, :string
  end
end
