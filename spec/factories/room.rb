Factory.define :room do |r|
  
  r.name {"My Random Room - #{Random.new.rand}"}
  r.open true
  r.after_create { |room| room.users << Factory(:user)}
  
end