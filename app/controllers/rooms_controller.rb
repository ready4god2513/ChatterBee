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
    
    @pubnub.publish({
      "channel" => @room.to_param,
      "message" => {
        "message" => "has left the chat.",
        "status" => "left",
        "user" => current_user.name,
        "uuid" => 10
      }
    })
    
    @room.leave(current_user)
    redirect to("/")
  end
  
end