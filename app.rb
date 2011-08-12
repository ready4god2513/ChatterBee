require "bundler/setup"
require "sinatra/base"
require "forgery"
require "omniauth"

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
  end
  
  require "sass"
  require "erb"
  
  before do
    @room = Room.new
    @user = session[:user] || "user-#{Forgery(:name).company_name}"
  end
    
  
  get "/" do
    @connection = @room.join
    erb :index
  end
  
  get "/room/:id" do |id|
    @connection = id
    erb :index
  end
  
  get "/leave/:id" do |id|
    @room.leave!(id)
  end
  
  get "/auth/facebook/callback" do
    user = request.env["omniauth.auth"]
    raise user.inspect
  end
  
  get "/privacy" do
    erb :privacy
  end
  
end