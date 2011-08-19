class Jegit
  
  post "/facebook-chat/?" do
    if current_user?
      redirect to("/")
    else
      erb :facebook_auth
    end
  end
  
end