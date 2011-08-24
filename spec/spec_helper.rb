# Load the Sinatra app
require File.dirname(__FILE__) + "/../app"

require "factory_girl"
Dir[File.dirname(__FILE__)+"/factories/*.rb"].each {|file| require file }

require "rspec"
require "rack/test"

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end