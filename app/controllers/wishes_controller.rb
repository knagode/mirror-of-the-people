class WishesController < ApplicationController
  def index
    @newest = Wish.includes(:comments, :votes).order(created_at: :desc).limit(20)

    @most_upvoted = Wish.left_joins(:votes)
      .preload(:comments, :votes)
      .group(:id)
      .having("COALESCE(SUM(votes.value), 0) > 0")
      .order(Arel.sql("COALESCE(SUM(votes.value), 0) DESC"))
      .limit(20)

    @recently_upvoted = Wish.where(
      id: Vote.where("votes.created_at > ?", 7.days.ago)
              .where(value: 1)
              .select(:wish_id)
    ).left_joins(:votes)
      .preload(:comments, :votes)
      .group(:id)
      .order(Arel.sql("COALESCE(SUM(votes.value), 0) DESC"))
      .limit(20)

    @recently_commented = Wish.joins(:comments)
      .preload(:comments, :votes)
      .group(:id)
      .order(Arel.sql("MAX(comments.created_at) DESC"))
      .limit(5)
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
