class StatsController < ApplicationController
  def index
    @total_wishes = Wish.count

    # Weighted average: wishes with more upvotes count more
    # Weight = max(1, sum of votes) - downvoted wishes still count as 1
    @parties = Party.all.map do |party|
      weighted = party.matches
        .joins(:wish)
        .joins("LEFT JOIN votes ON votes.wish_id = wishes.id")
        .group("matches.id", "matches.score")
        .select("matches.score, GREATEST(1, COALESCE(SUM(votes.value), 0)) AS weight")

      total_weight = 0.0
      total_score = 0.0
      weighted.each do |m|
        w = [1, m.weight.to_i].max
        total_weight += w
        total_score += m.score * w
      end

      avg_score = total_weight > 0 ? (total_score / total_weight).round(1) : 0
      {
        party: party,
        avg_score: avg_score,
        match_count: party.matches.count
      }
    end.sort_by { |p| -p[:avg_score] }

    @recent_wishes = Wish.left_joins(:votes)
      .group(:id)
      .order(Arel.sql("COALESCE(SUM(votes.value), 0) DESC, wishes.created_at DESC"))
      .limit(20)
  end
end
