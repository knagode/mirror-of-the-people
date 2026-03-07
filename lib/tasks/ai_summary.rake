namespace :ai do
  desc "Generate AI summary of unprocessed wishes (runs if 50+ unprocessed)"
  task summarize: :environment do
    summary = AiSummarizer.new.call
    if summary
      puts "Created AI summary ##{summary.id} from #{summary.wishes_count} wishes"
    else
      puts "Not enough unprocessed wishes (need #{AiSummarizer::MIN_WISHES}+)"
    end
  end

  desc "Force generate AI summary from all wishes (ignores minimum threshold)"
  task force_summarize: :environment do
    wishes = Wish.all
    abort "No wishes found" if wishes.count == 0

    summarizer = AiSummarizer.new
    wishes_json = summarizer.send(:wishes_with_upvotes, wishes)
    content = summarizer.send(:generate_summary, wishes)

    summary = AiSummary.create!(content: content, wishes_count: wishes.count)
    Wish.where(ai_summary_id: nil).update_all(ai_summary_id: summary.id)

    puts "Created AI summary ##{summary.id} from #{summary.wishes_count} wishes"
  end
end
