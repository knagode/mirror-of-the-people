class AddAiSummaryToWishes < ActiveRecord::Migration[8.0]
  def change
    add_reference :wishes, :ai_summary, null: true, foreign_key: true
  end
end
