Jegit.controllers :room do
  
  before do
    redirect to(url(:auth, :index)) unless current_user?
    load_pubnub
  end
  
  
  get :index, :map => "/" do
    @room = Room.first_open_room || Room.generate
    redirect to(url(:room, :show, :id => @room.to_param))
  end
  
  
  get :show, :with => :id do
    load_room(params[:id])
    @room.join(current_user)
    erb "rooms/show".to_sym
  end
  
  
  get :leave, :with => :id do
    load_room(params[:id])
    @room.leave(current_user)
    redirect to("/")
  end
  
end