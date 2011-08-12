require "bundler/setup"
require "sinatra/base"
require "forgery"
require "omniauth"
require 'openssl'
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
  end
  
  require "sass"
  require "erb"
  
  before do
    @room = Room.new
    @user = session[:user]
    
    save_path! && redirect to("/auth") unless auth_needed?
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
  
  get "/leave/:id" do |id|
    @room.leave!(id)
  end
  
  get "/style.css" do
    scss :style
  end
  
  get "/auth/facebook/callback" do
    user = request.env["omniauth.auth"]
    session[:user] = user["user_info"]["nickname"]
    session[:pic] = user["user_info"]["image"]
    
    redirect to(session[:redirect_after])
  end
  
  get "/privacy" do
    erb :privacy
  end
  
  
  def auth_needed?
    @user || request.path_info =~ /auth|\./
  end
  
  def save_path!
    session[:redirect_after] = request.path_info
  end
  
end