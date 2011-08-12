require "bundler/setup"
require "sinatra/base"
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
  
  post "/auth" do
    session[:user] = params[:username] unless params[:username].nil?
    redirect to("/") unless request.xhr?
  end
  
  get "/style.css" do
    scss :style
  end
  
end