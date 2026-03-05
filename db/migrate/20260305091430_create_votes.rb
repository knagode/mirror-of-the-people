class CreateVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :votes do |t|
      t.references :wish, null: false, foreign_key: true
      t.string :session_id
      t.integer :value

      t.timestamps
    end
  end
end
