class CommentsController < ApplicationController
  def create
    @wish = Wish.find(params[:wish_id])
    profile = find_or_create_profile!

    @comment = @wish.comments.new(
      content: params[:comment][:content],
      profile: profile
    )

    if @comment.save
      redirect_to wish_path(@wish, anchor: "comments")
    else
      redirect_to wish_path(@wish, anchor: "comments"), alert: "Komentar ne sme biti prazen."
    end
  end
end
