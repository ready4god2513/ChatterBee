class User
  
  include MongoMapper::Document
  
  key :name, String, :unique => true, :required => true
  key :location, String
  key :token, String
  timestamps!
  
  before_save :cleanup_name
  
  
  def self.create_with_omniauth(auth)
    User.create(
      :name => auth["user_info"]["nickname"], 
      :location => nil, 
      :token => auth["credentials"]["token"]
    )
  end
  
  
  def approximate_location
    self.location || "undisclosed"
  end
  
  def update_location(loc)
    self.location = loc
    self.save
  end
  
  
  def cleanup_name
    self.name = name.gsub(/[^0-9a-z]/i, '')
  end
  
end