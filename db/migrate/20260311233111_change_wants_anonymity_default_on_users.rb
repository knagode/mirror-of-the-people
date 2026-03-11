class ChangeWantsAnonymityDefaultOnUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_default :users, :wants_anonymity, from: false, to: nil
    change_column_null :users, :wants_anonymity, true
  end
end
