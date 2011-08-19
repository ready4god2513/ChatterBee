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
require "padrino"
require_relative "../app/lib/sass_init"

class Jegit
  
  configure do
    enable :static
    enable :sessions
    set :session_secret, "8y38H@(@DKW9eur93j!ieJHDJHDhe8#^@(!)})"
    set :views, File.expand_path("app/views")
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
  
  
  register SassInitializer
  register Padrino::Helpers
  register Padrino::Routing
  
  
  MOBILE_USER_AGENTS =  'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                            'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                            'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                            'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                            'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
                            'mobile'
  
  
  helpers do
    [:development, :production, :test].each do |environment|
      define_method "#{environment.to_s}?" do
        return settings.environment == environment
      end
      
      define_method "is_mobile_device?" do
        return request.user_agent =~ /MOBILE_USER_AGENTS/
      end
      
    end
  end
  
end