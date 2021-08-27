class UserAuthenticationController < ApplicationController
  # Uncomment this if you want to force users to sign in before any other actions
  skip_before_action(:force_user_sign_in, { :only => [:sign_up_form, :create, :sign_in_form, :create_cookie] })

  def sign_in_form
    render({ :template => "user_authentication/sign_in.html.erb" })
  end

  def create_cookie
    user = User.where({ :email => params.fetch("query_email") }).first
    
    the_supplied_password = params.fetch("query_password")
    
    if user != nil
      are_they_legit = user.authenticate(the_supplied_password)
    
      if are_they_legit == false
        redirect_to("/user_sign_in", { :alert => "Incorrect password." })
      else
        session[:user_id] = user.id
      
        redirect_to("/", { :notice => "Signed in successfully." })
      end
    else
      redirect_to("/user_sign_in", { :alert => "No user with that email address." })
    end
  end

  def destroy_cookies
    reset_session

    redirect_to("/", { :notice => "Signed out successfully." })
  end

  def sign_up_form
    render({ :template => "user_authentication/sign_up.html.erb" })
  end

  def create

    # Check Phone Number Validity
    phone_number = params.fetch("query_phone_number")
    if Phonelib.valid?(phone_number)
      phone_number = Phonelib.parse(phone_number).full_e164

      @user = User.new
      @user.email = params.fetch("query_email")
      @user.password = params.fetch("query_password")
      @user.password_confirmation = params.fetch("query_password_confirmation")
      @user.phone_number = phone_number
      @user.phone_confirmed = false
      @user.mail_confirmed = false
      @user.time_zone = params.fetch("query_time_zone").fetch("time_zone")

      save_status = @user.save

      if save_status == true
        session[:user_id] = @user.id
    
        redirect_to("/", { :notice => "User account created successfully."})
      else
        redirect_to("/user_sign_up", { :alert => "User account failed to create successfully."})
      end
    else
      redirect_to("/user_sign_up", { :alert => "Please enter a valid phone number."})
    end
  end

  def edit_profile_form
    render({ :template => "user_authentication/edit_profile.html.erb" })
  end

  def update

    # Check Phone Number Validity
    phone_number = params.fetch("query_phone_number")
    if Phonelib.valid?(phone_number)
      phone_number = Phonelib.parse(phone_number).full_e164

      @user = @current_user
      @user.email = params.fetch("query_email")
      @user.password = params.fetch("query_password")
      @user.password_confirmation = params.fetch("query_password_confirmation")
      @user.phone_number = phone_number
      @user.time_zone = params.fetch("query_time_zone").fetch("time_zone")

      if @user.valid?
        @user.save
  
        redirect_to("/edit_user_profile", { :notice => "User account updated successfully."})
      else
        render({ :template => "user_authentication/edit_profile_with_errors.html.erb" })
      end  
    else
      redirect_to("/edit_user_profile", { :alert => "Please enter a valid phone number."})
    end
  end

  def destroy
    # First, delete all the user's alerts
    Alert.where({ :user_id => @current_user.id }).each do |alert|
      alert.destroy
    end

    @current_user.destroy
    reset_session
    
    redirect_to("/", { :notice => "User account deleted" })
  end
 
end
