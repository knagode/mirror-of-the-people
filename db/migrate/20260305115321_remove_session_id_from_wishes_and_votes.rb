class RemoveSessionIdFromWishesAndVotes < ActiveRecord::Migration[8.0]
  def change
    remove_column :wishes, :session_id, :string
    remove_column :votes, :session_id, :string
  end
end
