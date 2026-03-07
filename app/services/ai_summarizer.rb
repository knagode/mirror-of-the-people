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

  def prompt
    wishes = Wish.all
    wishes_json = wishes_with_upvotes(wishes)
    build_prompt(wishes_json, wishes.count)
  end

  private

  def wishes_with_upvotes(wishes)
    wishes
      .left_joins(:votes)
      .group(:id)
      .select("wishes.id, wishes.content, COALESCE(SUM(votes.value), 0) AS upvotes")
      .map { |w| { content: w.content, upvotes: w.upvotes.to_i } }
  end

  def generate_summary(wishes)
    wishes_json = wishes_with_upvotes(wishes)

    response = client.messages.create(
      model: "claude-sonnet-4-20250514",
      max_tokens: 4000,
      messages: [
        {
          role: "user",
          content: build_prompt(wishes_json, wishes.count)
        }
      ]
    )

    response.content.first.text
  end

  def build_prompt(wishes_json, count)
    <<~PROMPT
      Si analitični novinar v Sloveniji. Spodaj je #{count} želj v JSON formatu, ki so jih ljudje zapisali na platformi ZrcaloLjudi, kjer povedo, kaj si želijo od države. Polje "upvotes" pove, koliko ljudi se strinja z željo.

      #{wishes_json.to_json}

      Naredi povzetek v slovenščini. Povzetek naj vsebuje:
      1. Glavne teme in trende - kaj si ljudje najbolj želijo
      2. Pogosto omenjene teme
      3. Morebitne zanimive ali presenetljive želje

      Upoštevaj število upvotes - želje z več glasovi so bolj relevantne.
      Ignoriraj neresne, žaljive želje ali očitne šale (npr. provokativne želje, ki jih je verjetno napisala ena oseba). Osredotoči se na legitimne želje državljanov.

      Piši v lepem, berljivem formatu. Uporabi kratke odstavke. Piši kot članek za širšo publiko. Med 100 in 300 besed.
      Vrni osnovni HTML (uporabi <p>, <strong>, <br> značke). Ne uporabljaj markdowna.
    PROMPT
  end

  def client
    @client ||= Anthropic::Client.new
  end
end
