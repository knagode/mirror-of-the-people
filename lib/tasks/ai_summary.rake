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
    sections = summarizer.send(:generate_summary, wishes)

    summary = AiSummary.create!(
      content: sections["summary"],
      recommendations: sections["recommendations"],
      party_matches: sections["party_matches"],
      wishes_count: wishes.count
    )
    Wish.where(ai_summary_id: nil).update_all(ai_summary_id: summary.id)

    puts "Created AI summary ##{summary.id} from #{summary.wishes_count} wishes"
  end

  desc "Re-match all wishes against current parties (batches of 10)"
  task rematch: :environment do
    wishes = Wish.order(created_at: :desc)
    parties = Party.all
    abort "No wishes found" if wishes.empty?
    abort "No parties found" if parties.empty?

    puts "Re-matching #{wishes.count} wishes against #{parties.count} parties in batches of 5..."
    puts "Deleting old matches..."
    Match.delete_all

    client = Anthropic::Client.new
    total_matched = 0

    party_descriptions = parties.map do |party|
      "STRANKA: #{party.name}\nID: #{party.id}\nPROGRAM:\n#{party.program}"
    end.join("\n---\n\n")

    wishes.in_batches(of: 5) do |batch|
      wishes_data = batch.map { |w| { id: w.id, content: w.content } }
      puts "\nProcessing batch of #{wishes_data.size} wishes..."

      begin
        response = client.messages.create(
          model: "claude-sonnet-4-20250514",
          max_tokens: 16000,
          messages: [
            {
              role: "user",
              content: <<~PROMPT
                Si politicni svetovalec v Sloveniji. Spodaj so zelje uporabnikov in programi politicnih strank.

                STRANKE:
                #{party_descriptions}

                ZELJE:
                #{wishes_data.to_json}

                Za VSAKO zeljo doloci ujemanje z VSAKO stranko (score 0-100).

                Odgovori IZKLJUCNO v JSON formatu (brez markdown, brez ```):
                [
                  {
                    "wish_id": ID,
                    "matches": [
                      {"party_id": PARTY_ID, "score": SCORE, "explanation": "Kratka obrazlozitev."}
                    ]
                  }
                ]

                Bodi iskren in objektiven. Score naj bo 0-100. Obrazlozitev naj bo KRATKA (1 stavek).
              PROMPT
            }
          ]
        )

        results = JSON.parse(response.content.first.text)
      rescue JSON::ParserError => e
        puts "  WARN: JSON parse error, skipping batch: #{e.message}"
        next
      rescue => e
        puts "  WARN: API error, skipping batch: #{e.message}"
        next
      end

      results.each do |result|
        wish = Wish.find_by(id: result["wish_id"])
        next unless wish

        result["matches"]&.each do |m|
          party = parties.find { |p| p.id == m["party_id"] }
          next unless party
          Match.create!(wish: wish, party: party, score: m["score"], explanation: m["explanation"])
        end

        puts "  ##{wish.id}: #{result['matches']&.size || 0} matchev"
        total_matched += 1
      end
    end

    puts "\nRe-matched #{total_matched}/#{wishes.count} wishes against #{parties.count} parties"
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
