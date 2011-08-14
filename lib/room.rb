require "sinatra/redis"

class Room
  
  ROOM_NAME = "open_rooms"
  
  
  def initialize(pubkey, subkey, secretkey)
    @redis = Redis.new
    @pubnub = Pubnub.new(pubkey, subkey, secretkey, false)
  end
  
  
  # Needs to return the name of the new room
  def join
    increment_chatters
    
    if @redis.llen(ROOM_NAME) > 0
      @redis.lpop ROOM_NAME
    else
      new_room
    end
  end
  
  
  def leave!(room)
    @redis.rrem ROOM_NAME, 0, room
    decrement_chatters
  end
  
  
  def new_room
    room = generate_room_name
    @redis.rpush ROOM_NAME, room
    room
  end
  
  def generate_room_name
    "#{Forgery(:name).company_name}-#{Random.new.rand(1..999999)}"
  end
  
  
  def history(channel)
    @pubnub.history({
        "channel" => id,
        "limit"   => 50000
    })
  end
  
  def chatters_count
    @redis.get("chatters-count").to_i
  end
  
  
  private
  
    def increment_chatters
      @redis.set("chatters-count", chatters_count + 1)
      publish_chatters_count
    end
    
    
    def decrement_chatters
      @redis.set("chatters-count", chatters_count - 1)
      publish_chatters_count
    end
    
    
    def publish_chatters_count
      @pubnub.publish({
        "channel" => "chatters-count",
        "message" => chatters_count
      })
    end
  
  
end