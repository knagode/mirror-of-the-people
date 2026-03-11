class ArticlesController < ApplicationController
  def index
    @articles = Article.published
  end

  def show
    @article = Article.find_by!(slug: params[:id])
    @segments = @article.segments
    @scores = @article.segment_scores
    @my_reactions = if current_profile
      @article.article_reactions.where(profile: current_profile).index_by(&:segment_index).transform_values(&:value)
    else
      {}
    end
  end
end
