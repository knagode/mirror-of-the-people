class PartyMatcherJob < ApplicationJob
  queue_as :default

  def perform(wish_id)
    wish = Wish.find(wish_id)
    PartyMatcher.new(wish).call
  rescue => e
    Rails.logger.error "PartyMatcherJob failed for wish ##{wish_id}: #{e.message}"
  end
end
