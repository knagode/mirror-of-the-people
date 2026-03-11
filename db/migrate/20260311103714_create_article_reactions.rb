class CreateArticleReactions < ActiveRecord::Migration[8.0]
  def change
    create_table :article_reactions do |t|
      t.references :article, null: false, foreign_key: true
      t.integer :segment_index
      t.references :profile, null: false, foreign_key: true
      t.integer :value

      t.timestamps
    end
    add_index :article_reactions, [:article_id, :segment_index, :profile_id], unique: true, name: "idx_article_reactions_unique"
  end
end
