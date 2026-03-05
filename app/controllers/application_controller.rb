class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

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
