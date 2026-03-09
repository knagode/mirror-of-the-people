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

  desc "Generate tags for untagged wishes (batch AI call)"
  task tag_wishes: :environment do
    untagged = Wish.left_joins(:taggings).where(taggings: { id: nil }).order(created_at: :desc).limit(50)
    abort "No untagged wishes found" if untagged.empty?

    puts "Tagging #{untagged.count} wishes..."

    wishes_data = untagged.map { |w| { id: w.id, content: w.content } }

    client = Anthropic::Client.new
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

    available_tags = ActsAsTaggableOn::Tag.pluck(:name)
    results = JSON.parse(response.content.first.text)
    tagged = 0
    results.each do |result|
      wish = Wish.find_by(id: result["id"])
      next unless wish
      valid_tags = result["tags"].select { |t| available_tags.include?(t) }
      next if valid_tags.empty?
      wish.tag_list = valid_tags
      wish.save!
      tagged += 1
      puts "  ##{wish.id}: #{valid_tags.join(', ')}"
    end

    puts "Tagged #{tagged} wishes"
  end
end
