class AiSummaryJob < ApplicationJob
  queue_as :default

  def perform
    AiSummarizer.new.call
  end
end
