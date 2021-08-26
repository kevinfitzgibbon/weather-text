class HomeController < ApplicationController

  skip_before_action(:force_user_sign_in, { :only => [:homepage] })
  def homepage
    render({:template => "home_templates/homepage.html.erb"})
  end

end
