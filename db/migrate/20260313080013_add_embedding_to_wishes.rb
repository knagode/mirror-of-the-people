class AddEmbeddingToWishes < ActiveRecord::Migration[8.0]
  def change
    enable_extension "vector"
    add_column :wishes, :embedding, :vector, limit: 1536
  end
end
