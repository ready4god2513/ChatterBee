Jegit.controllers :room do
  
  before do
    redirect to(url(:user, :auth)) unless current_user?
    load_pubnub
  end
  
  
  get :index, :map => "/" do
    @room = Room.first_open_room || Room.create(:name => Room.generate_name, :open => true)
    redirect to(url(:room, :show, :id => @room.id))
  end
  
  
  get :show, :with => :id do
    load_room(id)
    @room.join(current_user)
    erb "rooms/show".to_sym
  end
  
  
  get :print, :with => :id do
    load_room(id)
    @messages = @room.history(@pubnub)
    
    attachment "jegit-archive-#{name}.html"
    erb "rooms/print".to_sym, :layout => false
  end
  
  
  get :leave, :with => :id do
    load_room(id)
    
    @pubnub.publish({
      "channel" => @room.name,
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
  
  def load_room(id)
    @room = Room.find(id)
    redirect to("/") if @room.nil?
  end
  
end