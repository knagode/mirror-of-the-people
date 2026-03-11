class Users::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(resource)
    if resource.profile
      save_profile_token(resource.profile.token)
    elsif current_profile
      current_profile.update!(user: resource)
    else
      Profile.create!(user: resource).tap { |p| save_profile_token(p.token) }
    end
    root_path
  end

  def after_sign_out_path_for(_resource)
    session.delete(:profile_token)
    cookies.delete(:profile_token)
    @current_profile = nil
    root_path
  end
end
