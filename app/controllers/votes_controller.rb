class VotesController < ApplicationController
  def create
    @wish = Wish.find(params[:wish_id])
    sid = session.id.to_s
    vote = @wish.votes.find_by(session_id: sid)

    if vote
      if vote.value == params[:value].to_i
        vote.destroy
      else
        vote.update(value: params[:value].to_i)
      end
    else
      @wish.votes.create(session_id: sid, value: params[:value].to_i)
    end

    render partial: "wishes/vote_buttons", locals: { wish: @wish, current_session_id: sid }
  end
end
