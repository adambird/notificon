require 'spec_helper'

describe NotificationStore do
  before(:each) do
    @store = NotificationStore.new
    @store.drop_collection
  end
  describe "#add" do
    before(:each) do
      @username = random_string
      @item_text = random_string
      @text = random_string
      @actor = random_string
      @action = random_string
      @occured_at = random_time
      @item_id = random_string
      @notification = Notification.new(:username => @username, :item_url => @item_url, 
        :item_text => @item_text, :actor => @actor, :action => @action, :occured_at => @occured_at, :item_id => @item_id)
    end
    
    subject { @store.add(@notification) }
    
    it "creates a record with username set" do
      @store.get(subject).username.should eq(@username)
    end
    it "creates a record with actor set" do
      @store.get(subject).actor.should eq(@actor)
    end
    it "creates a record with action set" do
      @store.get(subject).action.should eq(@action)
    end
    it "creates a record with occured_at set" do
      @store.get(subject).occured_at.to_i.should eq(@occured_at.to_i)
    end
    it "creates a record with item_url set" do
      @store.get(subject).item_url.should eq(@item_url)
    end
    it "creates a record with item_text set" do
      @store.get(subject).item_text.should eq(@item_text)
    end
    it "creates a record with item_id set" do
      @store.get(subject).item_id.should eq(@item_id)
    end
  end
  
  describe "#get_for_user" do
    before(:each) do
      @username = random_string
      
      @store.add(Notification.new(:username => @username, :item_url => random_string, :item_text => random_string, :actor => random_string, :occured_at => random_time))
      @store.add(Notification.new(:username => random_string, :item_url => random_string, :item_text => random_string, :actor => random_string, :occured_at => random_time))
      @store.add(Notification.new(:username => @username, :item_url => random_string, :item_text => random_string, :actor => random_string, :occured_at => random_time))
    end
    
    subject { @store.get_for_user(@username, 100) }
    
    it "returns 2 records" do
      subject.count.should eq(2)
    end
  end
  
  describe "#unread_count_for_user" do
    before(:each) do
      @username = random_string
      
      @store.add(Notification.new(:username => @username, :item_url => random_string, :item_text => random_string, :actor => random_string, :occured_at => random_time))
      id = @store.add(Notification.new(:username => @username, :item_url => random_string, :item_text => random_string, :actor => random_string, :occured_at => random_time))
      @store.add(Notification.new(:username => random_string, :item_url => random_string, :item_text => random_string, :actor => random_string, :occured_at => random_time))
      @store.add(Notification.new(:username => @username, :item_url => random_string, :item_text => random_string, :actor => random_string, :occured_at => random_time))
      @store.mark_as_read(id, random_time)
    end
    
    subject { @store.unread_count_for_user(@username) }
    
    it "returns 2" do
      subject.should eq(2)
    end
  end
  
  describe "#mark_as_read" do
    before(:each) do
      @id = @store.add(Notification.new(:username => @username, :item_url => random_string, :item_text => random_string, :actor => random_string, :occured_at => random_time))
      @store.add(Notification.new(:username => @username, :item_url => random_string, :item_text => random_string, :actor => random_string, :occured_at => random_time))
      @read_at = random_time
    end

    subject { @store.mark_as_read(@id, @read_at) }
    
    it "marks the record as read_at" do
      subject
      @store.get(@id).read_at.to_i.should eq(@read_at.utc.to_i)
    end
    it "returns the Notification" do
      subject.id.should eq(@id)
    end
  end
  
  describe "#mark_all_read_for_user" do
    before(:each) do
      @first_id = @store.add(Notification.new(:username => @username, :item_url => random_string, :item_text => random_string, :actor => random_string, :occured_at => random_time))
      @first_read_at = random_time
      @store.mark_as_read(@first_id, @first_read_at)
      
      @second_id = @store.add(Notification.new(:username => @username, :item_url => random_string, :item_text => random_string, :actor => random_string, :occured_at => random_time))
      
      @third_id = @store.add(Notification.new(:username => random_string, :item_url => random_string, :item_text => random_string, :actor => random_string, :occured_at => random_time))

      @fourth_id = @store.add(Notification.new(:username => @username, :item_url => random_string, :item_text => random_string, :actor => random_string, :occured_at => random_time))

      @read_at = random_time
    end
    
    subject { @store.mark_all_read_for_user(@username, @read_at) }
    
    it "leaves the first record as already read" do
      subject
      @store.get(@first_id).read_at.to_i.should eq(@first_read_at.to_i)
    end
    it "updates the second record as not read" do
      subject
      @store.get(@second_id).read_at.to_i.should eq(@read_at.to_i)
    end
    it "leaves the third record as not for the user" do
      subject
      @store.get(@third_id).read_at.should be_nil
    end
    it "updates the fourth record as not read" do
      subject
      @store.get(@fourth_id).read_at.to_i.should eq(@read_at.to_i)
    end
  end
  
  describe "#mark_all_read_for_item" do
    before(:each) do
      @item_id = random_string
      @first_id = @store.add(Notification.new(:username => @username, :item_url => random_string, 
        :item_text => random_string, :actor => random_string, :occured_at => random_time, :item_id => @item_id))
      @first_read_at = random_time
      @store.mark_as_read(@first_id, @first_read_at)
      
      @second_id = @store.add(Notification.new(:username => @username, :item_url => random_string, 
        :item_text => random_string, :actor => random_string, :occured_at => random_time, :item_id => @item_id))
      
      @third_id = @store.add(Notification.new(:username => random_string, :item_url => random_string, 
        :item_text => random_string, :actor => random_string, :occured_at => random_time, :item_id => @item_id))

      @fourth_id = @store.add(Notification.new(:username => @username, :item_url => random_string, 
        :item_text => random_string, :actor => random_string, :occured_at => random_time, :item_id => random_string))

      @read_at = random_time
    end
    
    subject { @store.mark_all_read_for_item(@username, @item_id, @read_at) }
    
    it "leaves the first record as already read" do
      subject
      @store.get(@first_id).read_at.to_i.should eq(@first_read_at.to_i)
    end
    it "updates the second record as not read" do
      subject
      @store.get(@second_id).read_at.to_i.should eq(@read_at.to_i)
    end
    it "leaves the third record as not for the user" do
      subject
      @store.get(@third_id).read_at.should be_nil
    end
    it "leaves the fourth record as not for the item" do
      subject
      @store.get(@fourth_id).read_at.should be_nil
    end
  end
end
