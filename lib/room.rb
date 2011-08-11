require "sinatra/redis"

class Room
  
  ROOM_NAME = "open_rooms"
  
  
  def initialize
    @redis = Redis.new("redis://redistogo:60817b9a83a996948cfb124fd58c0f10@angler.redistogo.com:9457/")
  end
  
  
  def join
    if @redis.llen(ROOM_NAME) > 0
      @redis.lpop ROOM_NAME
    else
      new_room
    end
  end
  
  
  def leave!(room)
    @redis.rrem ROOM_NAME, 0, room
  end
  
  
  def new_room
    room = rand(36**8).to_s(36)
    @redis.rpush ROOM_NAME, room
    room
  end
  
  
end