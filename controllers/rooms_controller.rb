class Jegit
  
  
  before do
    redirect to("/auth/") unless current_user
    
    @pubkey = "pub-32d1b09f-63b7-4015-8e59-bd603a2ec66e"
    @subkey = "sub-7e2e745c-c38c-11e0-a0a5-53ec83638759"
    @secretkey = "sec-a58d32c9-868c-4ab6-b70e-6555bee4758e"
    
    @pubnub = Pubnub.new(@pubkey, @subkey, @secretkey, false)
  end
  
  
  get "/" do
    @room = Room.where(:open => true).first(:order => :created_at.desc) || Room.create(:name => Room.generate_name, :open => true)
    @room.join(@user)
    
    redirect to("/room/#{@room.name}")
  end
  
  get "/room/:name" do |name|
    @room = Room.find_by_name(name)
    redirect to("/") if @room.nil?
    
    publish_room_count
    erb :index
  end
  
  get "/room/print/:name" do |name|
    @room = Room.find_by_name(name)
    redirect to("/") if @room.nil?
    
    @messages = @room.history(@pubnub)
    
    attachment "jegit-archive-#{name}.html"
    erb :print, :layout => false
  end
  
  get "/room/leave/:id" do |id|
    @room = Room.find(id)
    redirect to("/") if @room.nil?
    
    @pubnub.publish({
      "channel" => @room.name,
      "message" => {
        "message" => "has left the chat.",
        "status" => "left",
        "user" => @user.name,
        "uuid" => 10
      }
    })
    
    @room.leave(@user)
    publish_room_count
    
    redirect to("/")
  end
  
  
  def publish_room_count
    @pubnub.publish({
      "channel" => "room-count",
      "message" => Room.count
    })
  end
  
end