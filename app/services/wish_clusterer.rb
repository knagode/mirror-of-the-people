class WishClusterer
  def initialize(k: nil)
    @k = k
  end

  def call
    wishes = Wish.visible.with_embedding.to_a
    return if wishes.size < 5

    k = @k || auto_k(wishes.size)
    data = wishes.map { |w| w.embedding.to_a }

    clusters = KMeansClusterer.run(k, data, runs: 10)

    WishCluster.transaction do
      Wish.where.not(wish_cluster_id: nil).update_all(wish_cluster_id: nil)
      WishCluster.delete_all

      clusters.each_with_index do |cluster, i|
        next if cluster.points.empty?

        cluster_wishes = cluster.points.map { |p| wishes[p.id] }
        name = generate_name(cluster_wishes)
        summary = generate_summary(cluster_wishes, name)

        wish_cluster = WishCluster.create!(
          name: name,
          summary: summary,
          wishes_count: cluster_wishes.size
        )

        Wish.where(id: cluster_wishes.map(&:id)).update_all(wish_cluster_id: wish_cluster.id)
      end
    end

    WishCluster.order(wishes_count: :desc)
  end

  private

  def auto_k(_n)
    12
  end

  def generate_name(wishes)
    sample = wishes.first(10).map(&:content).join("\n- ")

    response = client.messages.create(
      model: "claude-sonnet-4-20250514",
      max_tokens: 50,
      messages: [
        {
          role: "user",
          content: "Spodaj so želje državljanov iz ene skupine. Predlagaj kratko ime teme (2-4 besede) v slovenščini. Odgovori SAMO z imenom, brez ničesar drugega.\n\n- #{sample}"
        }
      ]
    )

    response.content.first.text.strip.delete('"')
  end

  def generate_summary(wishes, name)
    wishes_text = wishes.map(&:content).join("\n- ")

    response = client.messages.create(
      model: "claude-sonnet-4-20250514",
      max_tokens: 500,
      messages: [
        {
          role: "user",
          content: <<~PROMPT
            Tema: "#{name}"

            Spodaj so želje državljanov, ki spadajo v to tematsko skupino:

            - #{wishes_text}

            Napiši kratek povzetek (2-3 stavke) v slovenščini, kaj si ljudje v tej skupini želijo. Bodi konkreten. Odgovori samo s povzetkom, brez naslova.
          PROMPT
        }
      ]
    )

    response.content.first.text.strip
  end

  def client
    @client ||= Anthropic::Client.new
  end
end
