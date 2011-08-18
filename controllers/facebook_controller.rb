class Jegit
  
  post "/facebook-chat/?" do
    if signed_in?
      redirect to("/")
    else
      erb :facebook_auth
    end
  end
  
end