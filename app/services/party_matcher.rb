class PartyMatcher
  def initialize(wish)
    @wish = wish
  end

  def call
    parties = Party.all
    return [] if parties.empty?

    response = client.messages.create(
      model: "claude-sonnet-4-20250514",
      max_tokens: 2000,
      messages: [
        {
          role: "user",
          content: build_prompt(parties)
        }
      ]
    )

    parse_response(response, parties)

    generate_embedding if @wish.embedding.nil?
  end

  private

  def client
    @client ||= Anthropic::Client.new
  end

  def build_prompt(parties)
    party_descriptions = parties.map do |party|
      "STRANKA: #{party.name}\nID: #{party.id}\nOPIS: #{party.description}\nPROGRAM:\n#{party.program}\n"
    end.join("\n---\n\n")

    <<~PROMPT
      Si politicni svetovalec v Sloveniji. Uporabnik je zapisal svojo zeljo oz. pricakovanje od drzave:

      "#{@wish.content}"

      Tu so programi politicnih strank:

      #{party_descriptions}

      Analiziraj zeljo uporabnika in jo primerjaj s programi vseh strank. Za VSAKO stranko doloci ujemanje od 0 do 100.

      Odgovori IZKLJUCNO v JSON formatu (brez markdown, brez ```):
      {
        "tags": ["tema1", "tema2", "tema3"],
        "matches": [
          {"party_id": ID, "score": SCORE, "explanation": "Kratka obrazlozitev v slovenscini zakaj se stranka ujema ali ne ujema z zeljo."}
        ]
      }

      Za "tags": #{TagPrompt.text}

      Razvrsti matches od najvisje do najnizje ocene. Bodi iskren in objektiven.
    PROMPT
  end

  def generate_embedding
    WishEmbedder.new.embed(@wish)
  rescue => e
    Rails.logger.warn "Failed to generate embedding for wish ##{@wish.id}: #{e.message}"
  end

  def parse_response(response, parties)
    text = response.content.first.text
    data = JSON.parse(text)

    if data["tags"].present?
      @wish.tag_list = data["tags"]
      @wish.save!
    end

    data["matches"].map do |result|
      party = parties.find { |p| p.id == result["party_id"] }
      next unless party

      @wish.matches.find_or_create_by(party: party) do |match|
        match.score = result["score"]
        match.explanation = result["explanation"]
      end
    end.compact
  end
end
