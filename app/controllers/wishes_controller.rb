class WishesController < ApplicationController
  def index
    @newest = Wish.visible.includes(:comments, :votes).order(created_at: :desc).limit(20)

    @most_upvoted = Wish.visible.left_joins(:votes)
      .preload(:comments, :votes)
      .group(:id)
      .having("COALESCE(SUM(votes.value), 0) > 0")
      .order(Arel.sql("COALESCE(SUM(votes.value), 0) DESC"))
      .limit(20)

    @recently_upvoted = Wish.visible.where(
      id: Vote.where("votes.created_at > ?", 7.days.ago)
              .where(value: 1)
              .select(:wish_id)
    ).left_joins(:votes)
      .preload(:comments, :votes)
      .group(:id)
      .order(Arel.sql("COALESCE(SUM(votes.value), 0) DESC"))
      .limit(20)

    @recently_commented = Wish.visible.joins(:comments)
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
    @related_articles = if @wish.tag_list.any?
      Article.published.tagged_with(@wish.tag_list, any: true)
    else
      Article.none
    end
    @similar_wishes = @wish.similar_wishes(limit: 5)
  end

  def destroy
    @wish = Wish.find(params[:id])

    if user_signed_in? && current_profile && @wish.profile_id == current_profile.id
      @wish.destroy
      redirect_to profile_path(current_profile.token), notice: "Želja je bila izbrisana."
    else
      redirect_to wish_path(@wish), alert: "Nimate dovoljenja za brisanje."
    end
  end

  def disown
    @wish = Wish.find(params[:id])

    if user_signed_in? && current_profile && @wish.profile_id == current_profile.id
      @wish.update!(profile: nil)
      redirect_to profile_path(current_profile.token), notice: "Povezava med željo in tvojim profilom je bila odstranjena."
    else
      redirect_to wish_path(@wish), alert: "Nimate dovoljenja za to dejanje."
    end
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
