require "sinatra/base"


class ChatterBox < Sinatra::Base
  
  require "sass"
  require "erb"
  
  get "/" do
    erb :index
  end
  
  get "/leave/?" do
    "Now leaving the chat"
  end
  
  get "/stylesheet.css" do
    scss :stylesheet
  end
  
end