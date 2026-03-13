class ExploreController < ApplicationController
  def show
    @recent_queries = ExploreQuery.order(created_at: :desc).limit(20)
  end

  def query
    @explore_query = ExploreQuery.find(params[:id])
  end

  def search
    @question = params[:question]&.strip
    if @question.blank?
      redirect_to explore_path, alert: "Vnesite vprašanje."
      return
    end

    result = WishExplorer.new(@question).call
    @wishes = result[:wishes]
    @answer = result[:answer]

    ExploreQuery.create(
      question: @question,
      wishes_count: @wishes.size,
      answer: @answer
    )

    render :show
  end
end
