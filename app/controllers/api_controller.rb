Jegit.controllers "/api/rooms" do
  
  before do
    authenticate_api!
  end
  
  get :index do
    @room = Room.first_open_room || Room.generate
    @room.join(current_user)
    
    content_type :json
    @room.to_json(:include => :users)
  end


  get :leave, :with => :id do
    load_room(params[:id])

    @pubnub.publish({
      "channel" => @room.to_param,
      "message" => {
        "message" => "has left the chat.",
        "status" => "left",
        "user" => current_user.name,
        "uuid" => 10
      }
    })

    @room.leave(current_user)
  end
  
end

Jegit.controllers :api do
  
  post :auth do
    content_type :json
    
    if @user = User.find_or_create_by_name(params[:username])
      @user.to_json(:only => [:name, :id])
    else
      @user.errors.to_json
    end
  end
  
  
end


class Jegit
  
  def authenticate_api!
    @user = User.find(params[:token]) unless params[:token].nil?
    halt 401, {'Content-Type' => 'text/plain'}, '{:error => "Please login"}' unless current_user?
  end
  
end