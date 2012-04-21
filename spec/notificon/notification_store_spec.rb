require 'spec_helper'

describe NotificationStore do
  before(:each) do
    @store = NotificationStore.new
    @store.drop_collection
  end
  describe "#add" do
    before(:each) do
      @username = random_string
      @item_url = random_string
      @text = random_string
      @occured_at = random_time
      @notification = Notification.new(:username => @username, :item_url => @item_url, :text => @text, :occured_at => @occured_at)
    end
    
    subject { @store.add(@notification) }
    
    it "creates a record with username set" do
      @store.get(subject).username.should eq(@username)
    end
  end
  
  describe "#get_for_user" do
    before(:each) do
      @username = random_string
      
      @store.add(Notification.new(:username => @username, :item_url => random_string, :text => random_string, :occured_at => random_time))
      @store.add(Notification.new(:username => random_string, :item_url => random_string, :text => random_string, :occured_at => random_time))
      @store.add(Notification.new(:username => @username, :item_url => random_string, :text => random_string, :occured_at => random_time))
    end
    
    subject { @store.get_for_user(@username) }
    
    it "returns 2 records" do
      subject.count.should eq(2)
    end
  end
  
  describe "#mark_as_read" do
    before(:each) do
      @id = @store.add(Notification.new(:username => @username, :item_url => random_string, :text => random_string, :occured_at => random_time))
      @store.add(Notification.new(:username => @username, :item_url => random_string, :text => random_string, :occured_at => random_time))
      @read_at = random_time
    end

    subject { @store.mark_as_read(@id, @read_at) }
    
    it "marks the record as read_at" do
      subject
      @store.get(@id).read_at.to_i.should eq(@read_at.utc.to_i)
    end
  end
end
