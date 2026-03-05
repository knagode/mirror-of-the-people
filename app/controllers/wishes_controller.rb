class WishesController < ApplicationController
  def index
  end

  def create
    profile = find_or_create_profile!
    @wish = Wish.new(
      content: params[:content],
      profile: profile
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
