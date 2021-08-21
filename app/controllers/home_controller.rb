class HomeController < ApplicationController

  def homepage
    render({:template => "home_templates/homepage.html.erb"})
  end

end
