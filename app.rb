require "bundler/setup"
require "sinatra/base"
require "pubnub"
require "mongo_mapper"
require "sass"
require "erb"
require "geocoder"

MongoMapper.connection = Mongo::Connection.new("localhost", 27017, :pool_size => 5, :timeout => 5)
MongoMapper.database = "jegit"

require ::File.expand_path("lib/room")
require ::File.expand_path("lib/user")


class ChatterBee < Sinatra::Base
  
  configure do
    enable :static
    enable :sessions
    set :scss, :style => :compact
    set :session_secret, "chatterbee-is-great"
  end
  
  use Rack::Session::Cookie
  
  
  before do
    @pubkey = "pub-32d1b09f-63b7-4015-8e59-bd603a2ec66e"
    @subkey = "sub-7e2e745c-c38c-11e0-a0a5-53ec83638759"
    @secretkey = "sec-a58d32c9-868c-4ab6-b70e-6555bee4758e"
    
    @pubnub = Pubnub.new(@pubkey, @subkey, @secretkey, false)
    @user = User.find(session[:id]) || nil
    
    redirect to("/auth") if auth_needed?
  end
    
  
  get "/" do
    @room = Room.where(:open => true).first(:order => :created_at.desc) || Room.create(:name => Room.generate_name, :open => true)
    @room.join(@user)
    
    redirect to("/room/#{@room.name}")
  end
  
  get "/room/:name" do |name|
    @room = Room.find_by_name(name)
    publish_room_count
    
    erb :index
  end
  
  get "/print/:name" do |name|
    @room = Room.find_by_name(name)
    @messages = @room.history(@pubnub)
    
    attachment "jegit-archive-#{name}.html"
    erb :print, :layout => false
  end
  
  get "/leave/:id" do |id|
    @room = Room.find(id)
    @room.leave(@user)
    publish_room_count
  end
  
  post "/facebook-chat/?" do
    erb :facebook, :layout => false
  end
  
  get "/style.css" do
    scss :style
  end
  
  get "/auth/?" do
    redirect to("/") if signed_in?
    erb :auth
  end
  
  post "/auth/sign-in" do
    @user = User.create(
      :name => params[:nickname], 
      :location => params[:location],
      :gender => params[:gender]
    )
    
    login!
  end
  
  get "/signout" do
    @user.destroy # We don"t need them in the database any longer
    publish_chatter_count
    
    session.delete(:user)
    redirect to("/auth")
  end
  
  get "/privacy" do
    erb :privacy
  end
  
  post "/convert-location" do
    addresses = Geocoder.search("40.586539,-122.391675")
    location = "#{addresses.first.city}, #{addresses.first.state}, #{addresses.first.country}"
    @user.update_location(location) if signed_in?
    
    location
  end
  
  
  def auth_needed?
    !signed_in? && !(request.path_info =~ /auth|privacy|convert-location|facebook-chat|\./)
  end
  
  def signed_in?
    !@user.nil?
  end
  
  def login!
    session[:id] = @user.id
    publish_chatter_count
    
    redirect to("/")
  end
  
  def publish_chatter_count
    @pubnub.publish({
      "channel" => "chatters-count",
      "message" => User.count
    })
  end
  
  def publish_room_count
    @pubnub.publish({
      "channel" => "room-count",
      "message" => Room.count
    })
  end
  
end