class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    link_profile_to_user(resource)
    root_path
  end

  private

  def link_profile_to_user(user)
    profile = current_profile || Profile.create!
    profile.update!(user: user)
    save_profile_token(profile.token)
  end
end
