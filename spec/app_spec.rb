require File.dirname(__FILE__) + "/spec_helper"

describe "App" do
  
  before(:each) do
    Room.delete_all
    User.delete_all
    
    @room = Factory(:room)
    @user = @room.users.first
  end
  
  
  describe "User" do
    
    it "should be valid" do
      @user.should be_valid
    end

    it "should not be valid without a name" do
      @user.name = nil
      @user.should_not be_valid
    end
    
  end
  
  
  describe "Room" do
    
    it "should be valid" do
      @room.should be_valid
    end

    it "should not be valid without a name" do
      @room.name = nil
      @room.should_not be_valid
    end
    
  end
  
  
  describe "Api" do
    
  end
  
  
  
  
end