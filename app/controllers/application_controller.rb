class ApplicationController < ActionController::Base
  before_action(:load_current_user)
  before_action(:set_user_time_zone) # sets the time zone for the logged in user

  # Uncomment this if you want to force users to sign in before any other actions
  # before_action(:force_user_sign_in)
  
  def load_current_user
    the_id = session[:user_id]
    @current_user = User.where({ :id => the_id }).first
  end
  
  def force_user_sign_in
    if @current_user == nil
      redirect_to("/user_sign_in", { :notice => "You have to sign in first." })
    end
  end

  # sets the time zone for the logged in user
  def set_user_time_zone
    if @current_user != nil
      Time.zone = @current_user.time_zone
    end
  end

end
