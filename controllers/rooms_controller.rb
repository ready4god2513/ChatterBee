class Jegit
  
  get "/" do
    redirect to("/auth/") unless current_user?
    
    @room = Room.first_open_room || Room.create(:name => Room.generate_name, :open => true)
    redirect to("/room/#{@room.name}")
  end
  
  get "/room/:name" do |name|
    load_room(name)
    @room.join(current_user)
    erb "rooms/show".to_sym
  end
  
  get "/room/print/:name" do |name|
    load_room(name)
    @messages = @room.history(@pubnub)
    
    attachment "jegit-archive-#{name}.html"
    erb "rooms/print".to_sym, :layout => false
  end
  
  get "/room/leave/:name" do |name|
    load_room(name)
    
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
  
  def load_room(name)
    @room = Room.find_by_name(name)
    redirect to("/") if @room.nil?
  end
  
end