require "bundler/setup"
require "sinatra/base"
require "pubnub"
require "mongo_mapper"
require "sass"
require "erb"
require "geocoder"
require "omniauth"
require "openssl"
require "openid/store/filesystem"
require "rack/flash"
require "rack/timeout"

# We moved lots of helpers into a separate file. These are all things that are
# useful throughout the rest of the application.
require_relative "helpers"

# It's good form to make your Sinatra applications be a subclass of
#Sinatra::Base. This way, we're not polluting the global namespace with our
#methods and routes and such.
class Jegit < Sinatra::Base; end;

# Need to require the config so it can set up the connection to mongo
require_relative "config/config"

# Include all models and controllers
Dir.glob("controllers/*.rb").each { |r| require_relative r }
Dir.glob("models/*.rb").each { |r| require_relative r }


class Jegit < Sinatra::Base
  
  before do
    redirect to("/auth/") if auth_needed?
    
    @pubkey = "pub-32d1b09f-63b7-4015-8e59-bd603a2ec66e"
    @subkey = "sub-7e2e745c-c38c-11e0-a0a5-53ec83638759"
    @secretkey = "sec-a58d32c9-868c-4ab6-b70e-6555bee4758e"
    
    @pubnub = Pubnub.new(@pubkey, @subkey, @secretkey, false)
  end
  
  not_found do
    erb "static/404".to_sym
  end
  
  # error do
  #   erb "static/error".to_sym
  # end
  
  
  def auth_needed?
    return false if current_user?
    request.path_info =~ /room/
  end
  
  def current_user
    User.find(session[:user_id])
  end
  
  def current_user?
    !current_user.nil?
  end
  
end