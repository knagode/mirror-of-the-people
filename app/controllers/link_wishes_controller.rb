class LinkWishesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_pending_profile

  def show
    redirect_to root_path unless @pending_profile
  end

  def accept
    current_user.update!(wants_anonymity: false)
    if @pending_profile
      @pending_profile.update!(user: current_user)
      save_profile_token(@pending_profile.token)
    else
      Profile.create!(user: current_user).tap { |p| save_profile_token(p.token) }
    end
    session.delete(:pending_profile_token)
    redirect_to root_path, notice: "Želje so povezane z vašim računom."
  end

  def decline
    current_user.update!(wants_anonymity: true)
    session.delete(:pending_profile_token)
    redirect_to root_path, notice: "Hvala za vašo odločitev. Želje niso povezane z vašim email-om v naši bazi, lahko pa zaradi seje, ki je shranjena v vašemu brskalniku še vedno dostopate do relevantnih podatkov."
  end

  private

  def find_pending_profile
    @pending_profile = Profile.find_by(token: session[:pending_profile_token]) if session[:pending_profile_token]
  end
end
