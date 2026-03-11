class CommentsController < ApplicationController
  def create
    profile = find_or_create_profile!

    @comment = commentable.comments.new(
      content: params[:comment][:content],
      profile: profile
    )

    if @comment.save
      redirect_to redirect_path(anchor: "comments")
    else
      redirect_to redirect_path(anchor: "comments"), alert: "Komentar ne sme biti prazen."
    end
  end

  private

  def commentable
    if params[:wish_id]
      Wish.find(params[:wish_id])
    elsif params[:article_id]
      Article.find_by!(slug: params[:article_id])
    end
  end

  def redirect_path(anchor:)
    if params[:wish_id]
      wish_path(params[:wish_id], anchor: anchor)
    else
      article_path(params[:article_id], anchor: anchor)
    end
  end
end
