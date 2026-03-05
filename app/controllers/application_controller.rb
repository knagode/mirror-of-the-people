class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :enforce_canonical_domain
  before_action :restore_profile_from_params

  private

  CANONICAL_HOST = "www.zrcaloljudi.com"

  def enforce_canonical_domain
    return unless Rails.env.production?
    return if request.host == CANONICAL_HOST
    return if request.path == "/up"

    url = "https://#{CANONICAL_HOST}#{request.fullpath}"
    if current_profile
      separator = request.fullpath.include?("?") ? "&" : "?"
      url += "#{separator}pt=#{current_profile.token}"
    end
    redirect_to url, status: :moved_permanently, allow_other_host: true
  end

  def restore_profile_from_params
    return if session[:profile_token].present?
    return unless params[:pt].present?

    profile = Profile.find_by(token: params[:pt])
    session[:profile_token] = profile.token if profile
  end

  def current_profile
    @current_profile ||= if session[:profile_token]
      Profile.find_by(token: session[:profile_token])
    end
  end
  helper_method :current_profile

  def find_or_create_profile!
    return current_profile if current_profile

    profile = Profile.create!
    session[:profile_token] = profile.token
    @current_profile = profile
  end
end
