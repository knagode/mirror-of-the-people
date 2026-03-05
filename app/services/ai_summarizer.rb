class AiSummarizer
  MIN_WISHES = Rails.env.development? ? 2 : 50

  def call
    wishes = Wish.where(ai_summary_id: nil)
    return if wishes.count < MIN_WISHES

    summary = AiSummary.create!(
      content: generate_summary(wishes),
      wishes_count: wishes.count
    )

    wishes.update_all(ai_summary_id: summary.id)
    summary
  end

  private

  def generate_summary(wishes)
    wishes_text = wishes.pluck(:content).map.with_index(1) do |content, i|
      "#{i}. #{content}"
    end.join("\n")

    response = client.messages.create(
      model: "claude-sonnet-4-20250514",
      max_tokens: 4000,
      messages: [
        {
          role: "user",
          content: build_prompt(wishes_text, wishes.count)
        }
      ]
    )

    response.content.first.text
  end

  def build_prompt(wishes_text, count)
    <<~PROMPT
      Si analitični novinar v Sloveniji. Spodaj je #{count} želj, ki so jih ljudje zapisali na platformi ZrcaloLjudi, kjer povedo, kaj si želijo od države.

      #{wishes_text}

      Naredi povzetek v slovenščini. Povzetek naj vsebuje:
      1. Glavne teme in trende - kaj si ljudje najbolj želijo
      2. Pogosto omenjene teme
      3. Morebitne zanimive ali presenetljive želje

      Piši v lepem, berljivem formatu. Izloči žaljive želje ali šale. Uporabi kratke odstavke. Ne uporabljaj markdowna ali posebnih znakov. Piši kot članek za širšo publiko. Med 100 in 300 besed.
    PROMPT
  end

  def client
    @client ||= Anthropic::Client.new
  end
end
