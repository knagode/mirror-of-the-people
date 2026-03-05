class StatsController < ApplicationController
  def index
    @total_wishes = Wish.count
    @parties = Party.all.map do |party|
      avg_score = party.matches.average(:score)&.round(1) || 0
      match_count = party.matches.count
      {
        party: party,
        avg_score: avg_score,
        match_count: match_count
      }
    end.sort_by { |p| -p[:avg_score] }

    @recent_wishes = Wish.order(created_at: :desc).limit(20)
  end
end
