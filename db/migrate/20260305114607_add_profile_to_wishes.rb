class AddProfileToWishes < ActiveRecord::Migration[8.0]
  def change
    add_reference :wishes, :profile, null: true, foreign_key: true
  end
end
