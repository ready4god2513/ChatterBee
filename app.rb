require "bundler/setup"
require "sinatra/base"
require "oauth2"
require "json"

require ::File.expand_path("lib/room")


class ChatterBee < Sinatra::Base
  
  configure do
    enable :static
    enable :sessions
    set :scss, :style => :compact
    set :session_secret, "chatterbee-is-great"
  end
  
  
  
  require "sass"
  require "erb"
  
  before do
    @room = Room.new
    @user = session[:user] || "user-#{rand(36**8).to_s(36)}"
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
  
  get "/privacy" do
    erb :privacy
  end  
  
  get "/auth/facebook" do
    redirect client.web_server.authorize_url(
      :redirect_uri => redirect_uri,
      :scope => "email,offline_access"
    )
  end


  get "/auth/facebook/callback" do
    access_token = client.web_server.access_token(params[:code], :redirect_uri => redirect_uri)
    user = JSON.parse(access_token.get("/me"))
    
    raise user.inspect
    @user = session[:user] = user
  end
  
  
  get "/style.css" do
    scss :style
  end
  
  
  # BEGIN METHODS
  def client
    OAuth2::Client.new("261061570588802", "b8393cb5960916a7df9ff5954b236739", :site => "https://graph.facebook.com")    
  end
  
  def redirect_uri
    uri = URI.parse(request.url)
    uri.path = "/auth/facebook/callback"
    uri.query = nil
    uri.to_s
  end
  
end