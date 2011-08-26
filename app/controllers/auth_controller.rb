Jegit.controllers :auth do
  
  get :index do
    erb "auth/index".to_sym
  end
  
  get :facebook, :map => "/auth/facebook/callback" do
    auth = request.env["omniauth.auth"]
    @user = User.find_by_name(auth["user_info"]["nickname"]) || User.create_with_omniauth(auth)

    session[:user_id] = current_user.id
    redirect to("https://apps.facebook.com/jegit-chat/")
  end
  
  get :signout do
    session.delete(:user_id)
    redirect to(url(:auth, :index))
  end
  
  post :sign_in do
    @user = User.find_or_create_by_name(params[:nickname])
    session[:user_id] = current_user.id
    redirect to("/")
  end
  
end