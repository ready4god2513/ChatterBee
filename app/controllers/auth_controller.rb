Jegit.controllers :auth do
  
  get :index do
    erb "auth/index".to_sym
  end
  
  get :facebook, :map => "/facebook/callback" do
    auth = request.env["omniauth.auth"]
    @user = User.find_by_name(auth["user_info"]["nickname"]) || User.create_with_omniauth(auth)

    session[:user_id] = @user.id
    redirect to("https://apps.facebook.com/jegit-chat/")
  end
  
  get :signout do
    session.delete(:user_id)
    redirect to(url(:auth, :index))
  end
  
  post :sign_in do
    @user = User.create(
      :name => params[:nickname], 
      :location => params[:location],
      :gender => params[:gender]
    )
    
    session[:user_id] = @user.id
    redirect to("/")
  end
  
  post :location do
    addresses = Geocoder.search("40.586539,-122.391675")
    location = "#{addresses.first.city}, #{addresses.first.state}, #{addresses.first.country}"
    current_user.update_location(location) if current_user
    
    location
  end
  
end