class TagsController < ApplicationController
  def show
    @tag = ActsAsTaggableOn::Tag.find_by!(name: params[:tag])
    @wishes = Wish.visible.tagged_with(@tag.name)
      .includes(:comments, :votes)
      .order(created_at: :desc)
  end
end
