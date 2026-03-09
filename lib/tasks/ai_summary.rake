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

  desc "Generate tags for all wishes (re-tags everything in batches of 50)"
  task tag_wishes: :environment do
    wishes = Wish.order(created_at: :desc)
    abort "No wishes found" if wishes.empty?

    puts "Tagging #{wishes.count} wishes in batches of 50..."

    client = Anthropic::Client.new
    available_tags = ActsAsTaggableOn::Tag.pluck(:name)
    total_tagged = 0

    wishes.in_batches(of: 50) do |batch|
      wishes_data = batch.map { |w| { id: w.id, content: w.content } }
      puts "\nProcessing batch of #{wishes_data.size} wishes..."

      response = client.messages.create(
        model: "claude-sonnet-4-20250514",
        max_tokens: 4000,
        messages: [
          {
            role: "user",
            content: <<~PROMPT
              Za vsako željo: #{TagPrompt.text}

              Želje:
              #{wishes_data.to_json}

              Odgovori IZKLJUČNO v JSON formatu (brez markdown, brez ```):
              [{"id": ID, "tags": ["tag1", "tag2"]}]

              Če se nobena oznaka ne ujema, vrni prazen array.
            PROMPT
          }
        ]
      )

      results = JSON.parse(response.content.first.text)
      results.each do |result|
        wish = Wish.find_by(id: result["id"])
        next unless wish
        valid_tags = result["tags"].select { |t| available_tags.include?(t) }
        wish.tag_list = valid_tags
        wish.save!
        total_tagged += 1 if valid_tags.any?
        puts "  ##{wish.id}: #{valid_tags.any? ? valid_tags.join(', ') : '(brez tagov)'}"
      end
    end

    puts "\nTagged #{total_tagged}/#{wishes.count} wishes"
  end
end
