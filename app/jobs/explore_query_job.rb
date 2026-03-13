class ExploreQueryJob < ApplicationJob
  queue_as :default

  def perform(explore_query_id)
    query = ExploreQuery.find(explore_query_id)
    result = WishExplorer.new(query.question).call

    query.update!(
      answer: result[:answer],
      wishes_count: result[:wishes].size,
      status: "completed"
    )
  rescue => e
    query&.update!(status: "failed", answer: "Napaka: #{e.message}")
    Rails.logger.error "ExploreQueryJob failed: #{e.message}"
  end
end
