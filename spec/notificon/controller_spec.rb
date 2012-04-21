require 'spec_helper'

class DummyController
  include Notificon::Controller
  
  def params
    @_params ||= {}
  end
  
end

describe Controller do
  describe "notificon_tracker" do
    before(:each) do
      @controller = DummyController.new
      @time = random_time
      @controller.stub(:current_time) { @time }
    end
    
    subject { @controller.notificon_tracker }
    
    context "when id param passed" do
      before(:each) do
        @id = random_string
        @controller.params[Notificon.notification_id_param] = @id
      end
      
      it "marks the notification as read" do
        Notificon.should_receive(:mark_notification_read).with(@id, @time)
        subject
      end
    end
    
    context "when id param not passed" do
      it "does not attempt to mark notification" do
        Notificon.should_not_receive(:mark_notification_read)
        subject
      end
    end
  end
end
