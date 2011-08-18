class Jegit
  
  get "/auth/?" do
    redirect to("/") if signed_in?
    erb :auth
  end
  
  get "/auth/facebook/callback" do
    @user = User.create(
      :name => request.env["omniauth.auth"]["user_info"]["nickname"], 
      :location => nil, 
      :token => request.env["omniauth.auth"]["credentials"]["token"],
      :gender => nil
    )

    login!
    redirect to("https://apps.facebook.com/jegit-chat/")
  end
  
  post "/auth/sign-in" do
    @user = User.create(
      :name => params[:nickname], 
      :location => params[:location],
      :gender => params[:gender]
    )
    
    login!
    redirect to("/")
  end
  
  get "/signout" do
    @user.destroy # We don"t need them in the database any longer
    session.delete(:user)
    redirect to("/auth")
  end
  
  post "/convert-location" do
    addresses = Geocoder.search("40.586539,-122.391675")
    location = "#{addresses.first.city}, #{addresses.first.state}, #{addresses.first.country}"
    @user.update_location(location) if signed_in?
    
    location
  end
  
  
  def auth_needed?
    !signed_in? && !(request.path_info =~ /auth|privacy|convert-location|facebook-chat|\./)
  end
  
  def signed_in?
    !@user.nil?
  end
  
  def login!
    session[:id] = @user.id    
  end
  
end