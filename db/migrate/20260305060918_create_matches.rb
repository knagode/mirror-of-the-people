class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.references :wish, null: false, foreign_key: true
      t.references :party, null: false, foreign_key: true
      t.float :score
      t.text :explanation

      t.timestamps
    end
  end
end
