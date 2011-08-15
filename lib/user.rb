class User
  
  include MongoMapper::Document
  
  key :name, String
  key :location, String
  key :other, Hash
  timestamps!
  
  
  def approximate_location
    self.location || other["location"]
  end
  
  def update_location(loc)
    self.location = loc
    self.save
  end
  
end