class WishesController < ApplicationController
  def index
  end

  def create
    @wish = Wish.new(
      content: params[:content],
      session_id: session.id.to_s
    )

    if @wish.save
      redirect_to wish_path(@wish)
    else
      render :index, status: :unprocessable_entity
    end
  end

  def show
    @wish = Wish.find(params[:id])
    @matches = @wish.matches.includes(:party).order(score: :desc)
  end

  def mine
    @wishes = Wish.where(session_id: session.id.to_s).order(created_at: :desc)

    all_matches = Match.joins(:wish).where(wishes: { session_id: session.id.to_s })
    @party_scores = Party.joins(:matches)
      .merge(all_matches)
      .group("parties.id", "parties.name")
      .average(:score)
      .map { |(id, name), avg| { id: id, name: name, avg_score: avg.round(1) } }
      .sort_by { |p| -p[:avg_score] }
  end

  def matches
    @wish = Wish.find(params[:id])
    @matches = @wish.matches.includes(:party).order(score: :desc)

    if @matches.empty?
      PartyMatcher.new(@wish).call
      @matches = @wish.matches.reload.includes(:party).order(score: :desc)
    end

    render partial: "matches", locals: { matches: @matches, wish: @wish }
  end
end
