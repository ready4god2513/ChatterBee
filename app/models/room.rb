require "forgery"

class Room
  
  include MongoMapper::Document
  
  key :name, String, :required => true
  key :open, Boolean
  key :user_ids, Array
  
  many :users, :in => :user_ids
  timestamps!
  
  Room.ensure_index(:name)
  Room.ensure_index(:open)
  
  
  def self.generate_name
    "#{Forgery(:name).company_name}-#{Random.new.rand(1..999999)}"
  end
  
  def self.generate
    Room.create(:name => self.generate_name, :open => true)
  end
  
  def self.first_open_room
    Room.where(:open => true).first(:order => :created_at.desc)
  end
  
  def join(user)
    self.users << user unless self.users.include?(user.to_param)
    self.open = open?
    self.save!
  end
  
  def leave(user)
    self.users.delete_all
    self.open = false
    self.save
  end
  
  def open?
    self.users.count < 2
  end
  
  def history(pubnub)
    pubnub.history({
        "channel" => self.to_param,
        "limit"   => 50000
    })
  end
  
end