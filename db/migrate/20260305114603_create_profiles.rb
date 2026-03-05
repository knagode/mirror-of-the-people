class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.string :token

      t.timestamps
    end
    add_index :profiles, :token, unique: true
  end
end
