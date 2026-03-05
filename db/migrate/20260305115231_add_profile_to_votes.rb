class AddProfileToVotes < ActiveRecord::Migration[8.0]
  def change
    add_reference :votes, :profile, null: true, foreign_key: true
  end
end
