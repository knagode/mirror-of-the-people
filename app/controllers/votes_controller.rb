class VotesController < ApplicationController
  def create
    @wish = Wish.find(params[:wish_id])
    profile = find_or_create_profile!

    vote = @wish.votes.find_by(profile: profile)

    if vote
      if vote.value == params[:value].to_i
        vote.destroy
      else
        vote.update(value: params[:value].to_i)
      end
    else
      @wish.votes.create(profile: profile, value: params[:value].to_i)
    end

    render partial: "wishes/vote_buttons", locals: { wish: @wish }
  end
end
