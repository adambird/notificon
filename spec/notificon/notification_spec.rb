require 'spec_helper'
require 'addressable/uri'

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
  
  describe "#url" do
    before(:each) do
      @id = random_string
    end
    
    subject { Notification.new(:id => @id, :item_url => @item_url).url }
    
    context "url with query string param" do    
      before(:each) do
        @param = random_string
        @value = random_string
        @item_url = "http://#{random_string}.com?#{@param}=#{@value}"
      end
      it "should return url with notification param appended" do
        # having to parse result to cope with order of query string params
        uri = Addressable::URI.parse(subject)
        uri.query_values.should eq({ @param => @value, Notificon.notification_id_param => @id })
      end
    end
    
    context "url without query string param" do    
      before(:each) do
        @item_url = "http://#{random_string}.co.uk"
      end
      it "should return url with notification param appended" do
        subject.should eq("#{@item_url}?#{Notificon.notification_id_param}=#{@id}")
      end
    end
    
    context "path with anchor" do
      before(:each) do
        @item_url = "/clubs/4f8ea8bb3d99cf0001000008/posts/4f995996cc1db30001000001#4f9fa6f673a9650001000009"
      end
      it "should return url" do
        subject.should eq("/clubs/4f8ea8bb3d99cf0001000008/posts/4f995996cc1db30001000001#4f9fa6f673a9650001000009?#{Notificon.notification_id_param}=#{@id}")
      end 
    end
  end
end
