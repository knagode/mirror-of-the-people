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
end
