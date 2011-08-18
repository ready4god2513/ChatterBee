class Jegit
  
  get "/auth/?" do
    redirect to("/") if current_user
    erb :auth
  end
  
  get "/auth/facebook/callback" do
    @user = User.create(
      :name => request.env["omniauth.auth"]["user_info"]["nickname"], 
      :location => nil, 
      :token => request.env["omniauth.auth"]["credentials"]["token"],
      :gender => nil
    )

    session[:user_id] = @user.id
    redirect to("https://apps.facebook.com/jegit-chat/")
  end
  
  get "/signout" do
    redirect to("/auth/") unless current_user
    
    current_user.destroy # We don"t need them in the database any longer
    session.delete(:user)
    redirect to("/auth")
  end
  
  post "/auth/sign-in" do
    @user = User.create(
      :name => params[:nickname], 
      :location => params[:location],
      :gender => params[:gender]
    )
    
    session[:user_id] = @user.id
    redirect to("/")
  end
  
  post "/convert-location" do
    addresses = Geocoder.search("40.586539,-122.391675")
    location = "#{addresses.first.city}, #{addresses.first.state}, #{addresses.first.country}"
    current_user.update_location(location) if current_user
    
    location
  end
  
end