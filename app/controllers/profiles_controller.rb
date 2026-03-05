class ProfilesController < ApplicationController
  def show
    @profile = Profile.find_by!(token: params[:token])
    session[:profile_token] = @profile.token

    @wishes = @profile.wishes.order(created_at: :desc)

    all_matches = Match.joins(:wish).where(wishes: { profile_id: @profile.id })
    @party_scores = Party.joins(:matches)
      .merge(all_matches)
      .group("parties.id", "parties.name")
      .average(:score)
      .map { |(id, name), avg| { id: id, name: name, avg_score: avg.round(1) } }
      .sort_by { |p| -p[:avg_score] }
  end
end
