module WishesHelper
  def score_class(score)
    if score >= 70
      "score-high"
    elsif score >= 40
      "score-medium"
    else
      "score-low"
    end
  end
end
