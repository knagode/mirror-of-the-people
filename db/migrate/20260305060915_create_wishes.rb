class CreateWishes < ActiveRecord::Migration[8.0]
  def change
    create_table :wishes do |t|
      t.text :content
      t.string :session_id

      t.timestamps
    end
  end
end
