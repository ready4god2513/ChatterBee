Jegit.controllers :facebook do
  
  
  before do
    redirect to("/") if current_user?
  end
  
  post :chat do
    erb :facebook_auth
  end
  
end