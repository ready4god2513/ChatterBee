require "bundler/setup"
require "sinatra/base"


class ChatterBee < Sinatra::Base
  
  configure do
    enable :static
    set :scss, :style => :compact
  end
  
  require "sass"
  require "erb"
  require "coffee-script"
    
  
  get "/" do
    erb :index
  end
  
  get "/leave/?" do
    "Now leaving the chat"
  end
  
  get "/style.css" do
    scss :style
  end
  
  get "/application.js" do
    coffee :application
  end
  
end