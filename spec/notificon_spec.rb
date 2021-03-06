require 'spec_helper'

describe Notificon do
  before(:each) do
    @notification = Notification.new(:id => @id = random_object_id, :username => @username = random_string)
    Notification.stub(:new) { @notification }

    @unread_count = random_integer
    @notification_store = mock(NotificationStore, :add => @id, :unread_count_for_user => @unread_count, :mark_as_read => @notification)
    Notificon.stub(:notification_store) { @notification_store }
    @user_state_store = mock(UserStateStore, :set_notifications => true)
    Notificon.stub(:user_state_store) { @user_state_store }
  end
  describe ".add_notification" do
    before(:each) do
      @item_url = random_string
      @item_text = random_string
      @actor = random_string
      @action = random_string.to_sym
      @occured_at = random_time
    end

    subject { Notificon.add_notification(@username, @item_url, @item_text, @actor, @action, @occured_at) }

    it "creates a notification" do
      Notification.should_receive(:new).with(:username => @username, :item_url => @item_url,
        :item_text => @item_text, :actor => @actor, :action => @action, :occured_at => @occured_at, :item_id => nil)
      subject
    end
    it "adds it to the notification store" do
      @notification_store.should_receive(:add).with(@notification)
      subject
    end
    it "updates the unread count for the user" do
      @user_state_store.should_receive(:set_notifications).with(@username, @unread_count)
      subject
    end
    it "returns the id of the items" do
      subject.should eq(@id)
    end
    context "when item id passed" do
      before(:each) do
        @item_id = random_string
      end

      subject { Notificon.add_notification(@username, @item_url, @item_text, @actor, @action, @occured_at, @item_id) }

      it "should create the notification with the item_id" do
        Notification.should_receive(:new).with(:username => @username, :item_url => @item_url,
          :item_text => @item_text, :actor => @actor, :action => @action, :occured_at => @occured_at, :item_id => @item_id)
        subject
      end
    end
  end

  describe "#mark_notification_read" do
    before(:each) do
      @read_at = random_time
    end

    subject { Notificon.mark_notification_read(@id, @read_at) }

    it "marks the notification as read" do
      @notification_store.should_receive(:mark_as_read).with(@id, @read_at)
      subject
    end
    it "updates the unread count for the user" do
      @user_state_store.should_receive(:set_notifications).with(@username, @unread_count)
      subject
    end
  end

  describe "#update_user_unread_counts" do

    subject { Notificon.update_user_unread_counts(@username) }

    it "gets the unread count for the user" do
      @notification_store.should_receive(:unread_count_for_user).with(@username)
      subject
    end
    it "sets the value on user state store" do
      @user_state_store.should_receive(:set_notifications).with(@username, @unread_count)
      subject
    end
  end

  describe "#mark_all_read_for_item" do
    before(:each) do
      @username = random_string
      @item_id = random_string
      @read_at = random_time
      @notification_store.stub(:mark_all_read_for_item)
    end

    subject { Notificon.mark_all_read_for_item(@username, @item_id, @read_at) }

    it "marks all notifications for item id" do
      @notification_store.should_receive(:mark_all_read_for_item).with(@username, @item_id, @read_at)
      subject
    end
    it "updates the unread count for the user" do
      @user_state_store.should_receive(:set_notifications).with(@username, @unread_count)
      subject
    end
  end

  describe ".clear_notifications" do
    before(:each) do
      @username = random_string
      @notification_store.stub(:mark_all_read_for_user)
      @user_state_store.stub(:clear_notifications)
    end

    subject { Notificon.clear_notifications(@username) }

    it "marks all notifications for user as read" do
      @notification_store.should_receive(:mark_all_read_for_user).with(@username, an_instance_of(Time))
      subject
    end
    it "updates the unread count for the user" do
      @user_state_store.should_receive(:clear_notifications).with(@username)
      subject
    end
  end
  
  describe ".get_notification" do
    before(:each) do
      @notification_store.stub(:get) { @notification }
    end
    
    subject { Notificon.get_notification(@notification.id) }
    
    it "should get the notification from the store" do
      @notification_store.should_receive(:get).with(@notification.id)
      subject
    end
    it "should return the notification" do
      subject.should eq(@notification)
    end
  end
end
