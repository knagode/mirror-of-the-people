class CreateParties < ActiveRecord::Migration[8.0]
  def change
    create_table :parties do |t|
      t.string :name
      t.text :description
      t.text :program
      t.string :logo_url

      t.timestamps
    end
  end
end
