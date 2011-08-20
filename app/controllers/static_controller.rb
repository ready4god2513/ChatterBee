Jegit.controllers :static do
  
  get :privacy do
    erb "static/privacy".to_sym
  end
  
  get :room, :with => :id do
    load_room(params[:id])
    @messages = @room.history(@pubnub)
    erb "static/room".to_sym
  end
  
end