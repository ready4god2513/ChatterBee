require File.dirname(__FILE__) + "/spec_helper"

describe "App" do
  
  before(:each) do
    Room.delete_all
    User.delete_all
    
    @room = Factory(:room)
    @user = @room.users.first
  end
  
  it "should be a valid user" do
    @user.should be_valid
  end
  
end