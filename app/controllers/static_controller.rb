Jegit.controllers :static do
  
  get :privacy do
    erb "static/privacy".to_sym
  end
  
  get :room, :with => :id do
    load_room(params[:id])
    load_pubnub
    @messages = @room.history(@pubnub)
    erb "static/room".to_sym
  end
  
  get :print, :with => :id do
    load_room(params[:id])
    load_pubnub
    @messages = @room.history(@pubnub)
    
    attachment "jegit-archive-#{params[:id]}.html"
    erb "static/room".to_sym, :layout => false
  end
  
end