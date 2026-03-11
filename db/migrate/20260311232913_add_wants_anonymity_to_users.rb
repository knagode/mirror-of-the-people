class AddWantsAnonymityToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :wants_anonymity, :boolean, default: false, null: false
  end
end
