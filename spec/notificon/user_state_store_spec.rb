require 'spec_helper'

describe UserStateStore do
  before(:each) do
    @store = UserStateStore.new
    @store.drop_collection
    @username = random_string
    @store.set_notifications(@username, 2)
  end

  describe "#clear_notifications" do

    subject { @store.clear_notifications(@username) }

    it "should set the notifications to zero" do
      subject
      @store.get(@username).notifications.should eq(0)
    end
  end

  describe "#set_notifications" do
    before(:each) do
      @count = random_integer
    end

    subject { @store.set_notifications(@username, @count) }

    it "should set the notifications count" do
      subject
      @store.get(@username).notifications.should eq(@count)
    end
    it "should clear the cache" do
      @store.should_receive(:cache_delete).with("user_state_#{@username}")
      subject
    end
  end
end
