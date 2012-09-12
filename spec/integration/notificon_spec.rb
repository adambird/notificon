require 'spec_helper'

describe Notificon do
  describe "add and retrieve notificaton" do
    before(:each) do
      @username = random_string
      @item_url = random_string
      @item_text = random_string
      @actor = random_string
      @action = random_string.to_sym
      @occured_at = random_time
      
      @id = Notificon.add_notification(@username, @item_url, @item_text, @actor, @action, @occured_at)
    end

    subject { Notificon.get_notification(@id) }
    
    it "notification should have username" do
      subject.username.should eq(@username)
    end
  end

end
