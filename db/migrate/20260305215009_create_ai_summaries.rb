class CreateAiSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_summaries do |t|
      t.text :content
      t.integer :wishes_count

      t.timestamps
    end
  end
end
