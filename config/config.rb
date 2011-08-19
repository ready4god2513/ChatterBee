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
require "padrino-helpers"
require "padrino-core/application/routing"

class Jegit
  
  configure do
    enable :static
    enable :sessions
    set :scss, :style => :compact
    set :session_secret, "8y38H@(@DKW9eur93j!ieJHDJHDhe8#^@(!)})"
  end
    
  use OmniAuth::Builder do
    provider :facebook, "261061570588802", "b8393cb5960916a7df9ff5954b236739"
    provider :twitter, "2I4tbMUdkYlscDnhLQhbqw", "Nw7oaPzt6HfgSS42K57BwdjwAfzLbmxnp2LOyxohws"
  end
  
  use Rack::Session::Cookie
  use Rack::Timeout
  Rack::Timeout.timeout = 10
  use Rack::Flash
  
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

  MongoMapper.connection = Mongo::Connection.new("localhost", 27017, :pool_size => 5, :timeout => 5)
  MongoMapper.database = "jegit"
  
  register Padrino::Helpers
  register Padrino::Routing
  
  
  helpers do
    [:development, :production, :test].each do |environment|
      define_method "#{environment.to_s}?" do
        return settings.environment == environment
      end
    end
  end
  
end