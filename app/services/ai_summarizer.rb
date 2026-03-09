class AiSummarizer
  MIN_WISHES = Rails.env.development? ? 2 : 50

  def call
    unprocessed_wishes = Wish.visible.where(ai_summary_id: nil)
    return if unprocessed_wishes.count < MIN_WISHES

    wishes = Wish.visible
    sections = generate_summary(wishes)
    summary = AiSummary.create!(
      content: sections["summary"],
      recommendations: sections["recommendations"],
      party_matches: sections["party_matches"],
      wishes_count: wishes.count
    )

    unprocessed_wishes.update_all(ai_summary_id: summary.id)
    summary
  end

  def prompt
    wishes = Wish.visible
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

    JSON.parse(response.content.first.text)
  end

  def parties_text
    Party.all.map { |p| "#{p.name}:\n#{p.program}" }.join("\n---\n")
  end

  def build_prompt(wishes_json, count)
    <<~PROMPT
      Si analitični novinar v Sloveniji. Spodaj je #{count} želj v JSON formatu, ki so jih ljudje zapisali na platformi ZrcaloLjudi, kjer povedo, kaj si želijo od države. Polje "upvotes" pove, koliko ljudi se strinja z željo.

      #{wishes_json.to_json}

      Tu so programi političnih strank v Sloveniji:

      #{parties_text}

      Naredi povzetek v slovenščini. Povzetek naj vsebuje:
      1. Glavne teme in trende - kaj si ljudje najbolj želijo
      2. Pogosto omenjene teme
      3. Morebitne zanimive ali presenetljive želje

      Upoštevaj število upvotes - želje z več glasovi so bolj relevantne.
      Ignoriraj neresne, žaljive želje ali očitne šale (npr. provokativne želje, ki jih je verjetno napisala ena oseba). Osredotoči se na legitimne želje državljanov.

      Ignoriraj želje, ki:
        - vsebujejo vulgarno ali seksualno vsebino
        - so zapisane kot šala, meme ali provokacija
        - imajo zelo kratko vsebino (1–5 besede) in poleg tega potencialno provokativno. Če je želja kratka in provokativna, naj bo dobro utemeljena, preden jo vključiš v analizo
        - niso povezane z javnimi politikami ali delovanjem države
        - so očitno absurdne ali provokativne

      Analizo naredi samo na preostalih legitimnih željah državljanov.

      Odgovori IZKLJUČNO v JSON formatu (brez markdown, brez ```):
      {
        "summary": "HTML povzetek želja",
        "recommendations": "HTML 10 priporočil",
        "party_matches": "HTML ujemanje strank"
      }

      Za "summary" (med 100 in 300 besed):
      Kaj si ljudje želijo, glavne teme, trendi, zanimive želje. Uporabi <p> in <strong>.

      Za "recommendations":
      10 konkretnih ukrepov, ki bi jih država lahko izvedla. Ukrepi naj bodo realistični in izvedljivi. Vsak ukrep naj ima kratek naslov v <strong> in eno poved obrazložitve. Uporabi <ol> in <li>.

      Za "party_matches":
      Oceni, katere stranke se najbolj ujemajo s predlaganimi ukrepi. Razvrsti od najbolj do najmanj ujemajoče. Za vsako stranko na kratko pojasni zakaj. Uporabi <ol> in <li> z imenom stranke v <strong>.

      Piši v lepem, berljivem formatu kot članek za širšo publiko. Uporabi samo <p>, <strong>, <ol>, <li> značke.
    PROMPT
  end

  def client
    @client ||= Anthropic::Client.new
  end
end
