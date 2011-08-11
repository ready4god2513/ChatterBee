require "bundler/setup"
require "sinatra/base"
require ::File.expand_path("lib/room")


class ChatterBee < Sinatra::Base
  
  configure do
    enable :static
    set :scss, :style => :compact
  end
  
  require "sass"
  require "erb"
  require "coffee-script"
  
  before do
    @room = Room.new
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
  
  get "/style.css" do
    scss :style
  end
  
  get "/application.js" do
    coffee :application
  end
  
end