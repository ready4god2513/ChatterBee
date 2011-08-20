require "bundler/setup"
require "sinatra/base"


# It's good form to make your Sinatra applications be a subclass of
#Sinatra::Base. This way, we're not polluting the global namespace with our
#methods and routes and such.
class Jegit < Sinatra::Base; end;

# Need to require the config so it can set up the connection to mongo
require_relative "config/config"

# Include all models and controllers
Dir.glob("app/controllers/*.rb").each { |r| require_relative r }
Dir.glob("app/models/*.rb").each { |r| require_relative r }


class Jegit < Sinatra::Base
  
  not_found do
    erb "static/404".to_sym
  end
  
  error do
    @error = env["sinatra.error"]
    erb "static/error".to_sym
  end
  
  get :stylesheets, :map => "/stylesheets/:name.css" do
    content_type "text/css", :charset => "utf-8"
    scss "stylesheets/#{params[:name]}".to_sym
  end
  
  def load_pubnub
    @pubkey = "pub-32d1b09f-63b7-4015-8e59-bd603a2ec66e"
    @subkey = "sub-7e2e745c-c38c-11e0-a0a5-53ec83638759"
    @secretkey = "sec-a58d32c9-868c-4ab6-b70e-6555bee4758e"
    
    @pubnub = Pubnub.new(@pubkey, @subkey, @secretkey, false)
  end
  
  def current_user
    @user ||= User.find(session[:user_id])
  end

  def current_user?
    !current_user.nil?
  end
  
  
end