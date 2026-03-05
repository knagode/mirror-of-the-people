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
  end

  private

  def client
    @client ||= Anthropic::Client.new
  end

  def build_prompt(parties)
    party_descriptions = parties.map do |party|
      "STRANKA: #{party.name}\nID: #{party.id}\nPROGRAM:\n#{party.program}\n"
    end.join("\n---\n\n")

    <<~PROMPT
      Si politicni svetovalec v Sloveniji. Uporabnik je zapisal svojo zeljo oz. pricakovanje od drzave:

      "#{@wish.content}"

      Tu so programi politicnih strank:

      #{party_descriptions}

      Analiziraj zeljo uporabnika in jo primerjaj s programi vseh strank. Za VSAKO stranko doloci ujemanje od 0 do 100.

      Odgovori IZKLJUCNO v JSON formatu (brez markdown, brez ```):
      [
        {"party_id": ID, "score": SCORE, "explanation": "Kratka obrazlozitev v slovenscini zakaj se stranka ujema ali ne ujema z zeljo."}
      ]

      Razvrsti od najvisje do najnizje ocene. Bodi iskren in objektiven.
    PROMPT
  end

  def parse_response(response, parties)
    text = response.content.first.text
    results = JSON.parse(text)

    results.map do |result|
      party = parties.find { |p| p.id == result["party_id"] }
      next unless party

      @wish.matches.find_or_create_by(party: party) do |match|
        match.score = result["score"]
        match.explanation = result["explanation"]
      end
    end.compact
  end
end
