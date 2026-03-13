class WishEmbedder
  MODEL = "text-embedding-3-small"
  BATCH_SIZE = 100

  def initialize
    @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end

  # Embed a single wish
  def embed(wish)
    response = @client.embeddings(parameters: { model: MODEL, input: wish.content })
    embedding = response.dig("data", 0, "embedding")
    wish.update!(embedding: embedding) if embedding
  end

  # Embed all wishes without embeddings
  def embed_all
    wishes = Wish.where(embedding: nil)
    total = wishes.count
    puts "Embedding #{total} wishes..."

    wishes.find_in_batches(batch_size: BATCH_SIZE).with_index do |batch, batch_index|
      texts = batch.map(&:content)
      response = @client.embeddings(parameters: { model: MODEL, input: texts })
      embeddings = response.dig("data")

      embeddings.each do |item|
        wish = batch[item["index"]]
        wish.update!(embedding: item["embedding"])
      end

      done = [(batch_index + 1) * BATCH_SIZE, total].min
      puts "  #{done}/#{total} done"
    end

    puts "Done."
  end
end
