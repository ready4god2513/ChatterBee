require "forgery"

class Room
  
  include MongoMapper::Document
  
  key :name, String
  key :open, Boolean
  key :user_ids, Array
  
  many :users, :in => :user_ids
  timestamps!
  
  Room.ensure_index(:name)
  Room.ensure_index(:open)
  
  
  def self.generate_name
    "#{Forgery(:name).company_name}-#{Random.new.rand(1..999999)}"
  end
  
  def self.first_open_room
    Room.where(:open => true).first(:order => :created_at.desc)
  end
  
  def join(user)
    self.users << user
    self.open = open?
    self.save!
  end
  
  def leave(user)
    self.users.delete(user)
    if self.users.count < 2 # Get rid of the room if it is now empty
      self.open = false
      self.save
    end
  end
  
  def open?
    self.users.count < 2
  end
  
  def history(pubnub)
    pubnub.history({
        "channel" => self.name,
        "limit"   => 50000
    })
  end
  
end