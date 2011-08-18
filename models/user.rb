class User
  
  include MongoMapper::Document
  
  key :name, String
  key :location, String
  key :gender, String
  key :token, String
  timestamps!
  
  
  def approximate_location
    self.location || "undisclosed"
  end
  
  def update_location(loc)
    self.location = loc
    self.save
  end
  
end