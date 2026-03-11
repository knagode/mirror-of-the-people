class ArticleReactionsController < ApplicationController
  def create
    @article = Article.find_by!(slug: params[:article_id])
    profile = find_or_create_profile!
    segment_index = params[:segment_index].to_i
    value = params[:value].to_i

    reaction = @article.article_reactions.find_by(profile: profile, segment_index: segment_index)

    if reaction
      if reaction.value == value
        reaction.destroy
      else
        reaction.update(value: value)
      end
    else
      @article.article_reactions.create(profile: profile, segment_index: segment_index, value: value)
    end

    scores = @article.segment_scores
    my_reactions = @article.article_reactions.where(profile: profile).index_by(&:segment_index)

    render json: {
      scores: scores,
      my_reactions: my_reactions.transform_values(&:value)
    }
  end
end
