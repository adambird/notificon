require 'spec_helper'

describe UserStateStore do
  before(:each) do
    @store = UserStateStore.new
    @store.drop_collection
    @username = random_string
    @store.increment_notifications(@username)
    @store.increment_notifications(@username)
  end
  describe "#increment_notifications" do
    
    subject { @store.increment_notifications(@username) }
    
    it "should increment the notifications by one" do
      subject
      @store.get(@username).notifications.should eq(3)
    end
  end
  describe "#increment_notifications" do
    
    subject { @store.decrement_notifications(@username) }
    
    it "should decrement the notifications by one" do
      subject
      @store.get(@username).notifications.should eq(1)
    end
  end
  
  describe "#clear_notifications" do
    
    subject { @store.clear_notifications(@username) }
    
    it "should set the notifications to zero" do
      subject
      @store.get(@username).notifications.should eq(0)
    end
  end
end
