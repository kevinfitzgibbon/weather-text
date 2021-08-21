Rails.application.routes.draw do

  get("/", { :controller => "home", :action => "homepage" })

end
