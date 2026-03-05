class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :wish, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
