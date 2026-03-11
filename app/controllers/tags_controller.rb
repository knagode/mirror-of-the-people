class TagsController < ApplicationController
  def show
    @tag = ActsAsTaggableOn::Tag.find_by!(name: params[:tag])
    @wishes = Wish.visible.tagged_with(@tag.name)
      .includes(:comments, :votes)
      .order(created_at: :desc)
    @related_articles = Article.published.tagged_with(@tag.name)
  end
end
