class AddCoverImageToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :cover_image, :string
  end
end
