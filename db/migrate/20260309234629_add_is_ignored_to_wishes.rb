class AddIsIgnoredToWishes < ActiveRecord::Migration[8.0]
  def change
    add_column :wishes, :is_ignored, :boolean, default: false, null: false
  end
end
