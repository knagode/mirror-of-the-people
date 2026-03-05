class ProfilesController < ApplicationController
  def show
    @profile = Profile.find_by!(token: params[:token])
    save_profile_token(@profile.token)

    @wishes = @profile.wishes.includes(:comments, :votes).order(created_at: :desc)

    all_matches = Match.joins(:wish).where(wishes: { profile_id: @profile.id })
    @party_scores = Party.joins(:matches)
      .merge(all_matches)
      .group("parties.id", "parties.name")
      .average(:score)
      .map { |(id, name), avg| { id: id, name: name, avg_score: avg.round(1) } }
      .sort_by { |p| -p[:avg_score] }
  end

  def forget
    session.delete(:profile_token)
    cookies.delete(:profile_token)
    @current_profile = nil
    redirect_to root_path
  end
end
