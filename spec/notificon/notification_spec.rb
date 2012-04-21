require 'spec_helper'

describe Notification do
  describe "#_id=" do
    before(:each) do
      @notification = Notification.new
      @id = random_string
    end
    
    subject { @notification._id = @id }
    
    it "sets the id property" do
      subject
      @notification.id.should eq(@id)
    end
  end
  
  describe "#read?" do
    before(:each) do
      @notification = Notification.new
    end
    
    subject { @notification.read? }
    
    context "when read_at is nil" do
      it "should be false" do
        subject.should be_false
      end
    end
    
    context "when read_at has a value" do
      before(:each) do
        @notification.read_at = random_time
      end
      it "should be true" do
        subject.should be_true
      end
    end
  end
end
