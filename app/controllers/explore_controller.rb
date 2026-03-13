class ExploreController < ApplicationController
  def show
    @recent_queries = ExploreQuery.where(status: "completed").order(created_at: :desc).limit(20)
  end

  def query
    @explore_query = ExploreQuery.find(params[:id])
  end

  def search
    question = params[:question]&.strip
    if question.blank?
      redirect_to explore_path, alert: "Vnesite vprašanje."
      return
    end

    explore_query = ExploreQuery.create!(question: question, status: "pending")
    ExploreQueryJob.perform_later(explore_query.id)

    redirect_to explore_query_path(explore_query)
  end
end
