class WishExplorer
  MAX_WISHES = 30

  def initialize(question)
    @question = question
  end

  def call
    embedding = generate_embedding
    return { wishes: [], answer: "Napaka pri generiranju embeddinga." } unless embedding

    wishes = find_relevant_wishes(embedding)
    return { wishes: [], answer: "Nisem našel relevantnih želja za to vprašanje." } if wishes.empty?

    answer = generate_answer(wishes)
    { wishes: wishes, answer: answer }
  end

  private

  def generate_embedding
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    response = client.embeddings(parameters: { model: "text-embedding-3-small", input: @question })
    response.dig("data", 0, "embedding")
  rescue => e
    Rails.logger.error "WishExplorer embedding error: #{e.message}"
    nil
  end

  def find_relevant_wishes(embedding)
    Wish.visible
      .nearest_neighbors(:embedding, embedding, distance: "cosine")
      .limit(MAX_WISHES)
      .select { |w| w.neighbor_distance <= 0.6 }
  end

  def generate_answer(wishes)
    wishes_text = wishes.map.with_index do |w, i|
      "#{i + 1}. \"#{w.content}\" (podobnost: #{((1 - w.neighbor_distance) * 100).round}%)"
    end.join("\n")

    response = anthropic_client.messages.create(
      model: "claude-sonnet-4-20250514",
      max_tokens: 2000,
      messages: [
        {
          role: "user",
          content: <<~PROMPT
            Uporabnik sprašuje: "#{@question}"

            Spodaj so želje državljanov, ki so relevantne za to vprašanje (zbrane na platformi ZrcaloLjudi):

            #{wishes_text}

            Na podlagi teh želja napiši kratek povzetek (3-5 odstavkov) v slovenščini:
            - Kaj si ljudje mislijo o tej temi?
            - Kakšne konkretne spremembe si želijo?
            - Ali obstajajo različna mnenja ali so si ljudje enotni?

            Piši v HTML formatu (uporabi <p> in <strong>). Bodi objektiven in povzemaj samo to, kar so ljudje dejansko zapisali.
          PROMPT
        }
      ]
    )

    response.content.first.text
  rescue => e
    Rails.logger.error "WishExplorer AI error: #{e.message}"
    "Napaka pri generiranju povzetka."
  end

  def anthropic_client
    @anthropic_client ||= Anthropic::Client.new
  end
end
