class AddSectionsToAiSummaries < ActiveRecord::Migration[8.0]
  def change
    add_column :ai_summaries, :recommendations, :text
    add_column :ai_summaries, :party_matches, :text
  end
end
