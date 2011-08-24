require File.dirname(__FILE__) + "/spec_helper"

describe "App" do
  
  before(:each) do
    Room.delete_all
    User.delete_all
    
    @room = Factory(:room)
    @user = @room.users.first
    @user2 = Factory(:user, :name => "Melissa Hansen")
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
    
    it "should be open without any users" do
      @room.users.delete_all
      @room.open?.should == true
    end
  
    it "should be closed with more than 1 user" do
      @room.users.count.should == 1
      @room.join(@user2)
      @room.users.count.should == 2
      @room.open?.should == false
    end
    
    it "should kick everyone out once someone leaves" do
      @user3 = Factory(:user, :name => "Chris Gratigny")
      @room.users.count.should == 1
      @room.join(@user2)
      @room.users.count.should == 2
      @room.open?.should == false
      @room.join(@user3)
      @room.users.count.should == 3
      @room.leave(@user2)
      @room.users.count.should == 0
      @room.open.should == false
    end
    
  end
  
  
  describe "Api" do
    
  end
  
  
  
  
end