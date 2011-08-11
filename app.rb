require "bundler/setup"
require "sinatra/base"
require "sinatra/redis"


class ChatterBee < Sinatra::Base
  
  configure do
    enable :static
    set :scss, :style => :compact
  end
  
  require "sass"
  require "erb"
  require "coffee-script"
  
  before do
    @redis = Redis.new
  end
    
  
  get "/" do
    @connection = Random.new.rand(0...999)
    @redis.rpush "open_chat", @connection
    
    @openings = @redis.llen "open_chat"
    erb :index
  end
  
  get "/leave/:id" do |id|
    @redis.lrem "open_chat", id
  end
  
  get "/style.css" do
    scss :style
  end
  
  get "/application.js" do
    coffee :application
  end
  
end