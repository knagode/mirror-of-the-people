class AddUserToProfiles < ActiveRecord::Migration[8.0]
  def change
    add_reference :profiles, :user, null: true, foreign_key: true, index: { unique: true }
  end
end
