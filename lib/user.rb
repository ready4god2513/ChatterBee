require "sinatra/redis"

class User
  
  include MongoMapper::Document
  
  key :name, String
  key :location, String
  key :other, Array
  timestamps!
  
end