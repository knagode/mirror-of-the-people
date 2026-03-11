class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |user|
      if user.persisted? && cookies[:profile_token]
        sign_in(user)
        session[:pending_profile_token] = cookies[:profile_token]
        return redirect_to link_wishes_path, status: :see_other
      end
    end
  end
end
