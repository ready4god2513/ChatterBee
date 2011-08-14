require "bundler/setup"
require "sinatra/base"
require "forgery"
require "omniauth"
require "openssl"
require "openid/store/filesystem"
require "pubnub"

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

require ::File.expand_path("lib/room")


class ChatterBee < Sinatra::Base
  
  configure do
    enable :static
    enable :sessions
    set :scss, :style => :compact
    set :session_secret, "chatterbee-is-great"
  end
  
  use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider :facebook, "261061570588802", "b8393cb5960916a7df9ff5954b236739"
    provider :twitter, "2I4tbMUdkYlscDnhLQhbqw", "Nw7oaPzt6HfgSS42K57BwdjwAfzLbmxnp2LOyxohws"
  end
  
  require "sass"
  require "erb"
  
  before do
    
    @pubkey = "pub-32d1b09f-63b7-4015-8e59-bd603a2ec66e"
    @subkey = "sub-7e2e745c-c38c-11e0-a0a5-53ec83638759"
    @secretkey = "sec-a58d32c9-868c-4ab6-b70e-6555bee4758e"
    
    @room = Room.new(@pubkey, @subkey, @secretkey)
    @user = session[:user]
    
    save_path! unless auth_needed?
    redirect to("/auth") unless auth_needed?
  end
    
  
  get "/" do
    @connection = @room.join
    erb :index
  end
  
  get "/auth/?" do
    redirect to("/") if @user
    erb :auth
  end
  
  get "/room/:id" do |id|
    @connection = id
    erb :index
  end
  
  get "/print/:id" do |id|
    @messages = @room.history(id)
    
    attachment "jegit-archive-#{id}.html"
    erb :manuscript, :layout => false
  end
  
  get "/leave/:id" do |id|
    @room.leave!(id)
  end
  
  get "/style.css" do
    scss :style
  end
  
  get "/auth/:name/callback" do
    user = request.env["omniauth.auth"]
    session[:user] = user["user_info"]["nickname"]
    redirect to(session[:redirect_after])
  end
  
  post "/auth/custom" do
    session[:user] = params[:nickname]
    redirect to(session[:redirect_after])
  end
  
  get "/signout" do
    session.delete(:user)
    redirect to("/auth")
  end
  
  get "/privacy" do
    erb :privacy
  end
  
  
  def auth_needed?
    @user || request.path_info =~ /auth|privacy|\./
  end
  
  def save_path!
    session[:redirect_after] = request.path_info
  end
  
end